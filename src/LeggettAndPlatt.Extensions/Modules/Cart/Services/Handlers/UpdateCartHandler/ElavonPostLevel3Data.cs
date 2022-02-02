using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Common.Helpers;
using Insite.Common.Logging;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Providers;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Core.SystemSetting.Groups.OrderManagement;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using LeggettAndPlatt.Extensions.Common;
using LeggettAndPlatt.Extensions.Core.Providers;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Extensions;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler.Elavon;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler
{
    [DependencyName("ElavonPostLevel3Data")]
    public class ElavonPostLevel3Data : HandlerBase<UpdateCartParameter, UpdateCartResult>
    {
        private readonly ElavonSettings ElavonSettings;
        private readonly CustomPropertyHelper CustomPropertyHelper;
        private readonly ICustomerOrderUtilities customerOrderUtilities;
        private readonly IEmailService EmailService;
        protected readonly EmailHelper EmailHelper;
        private readonly OrderManagementGeneralSettings orderManagementGeneralSettings;

        public override int Order
        {
            get
            {
                return 2290;
            }
        }

        public ElavonPostLevel3Data(ICustomerOrderUtilities customerOrderUtilities, ElavonSettings elavonSettings, CustomPropertyHelper customPropertyHelper, IEmailService emailService, EmailHelper emailHelper, OrderManagementGeneralSettings orderManagementGeneralSettings)
        {
            this.customerOrderUtilities = customerOrderUtilities;
            this.ElavonSettings = elavonSettings;
            this.CustomPropertyHelper = customPropertyHelper;
            this.EmailService = emailService;
            this.EmailHelper = emailHelper;
            this.orderManagementGeneralSettings = orderManagementGeneralSettings;
        }

        public override UpdateCartResult Execute(IUnitOfWork unitOfWork, UpdateCartParameter parameter, UpdateCartResult result)
        {
            if(result.GetCartResult.Cart!= null && result.GetCartResult.Cart.OrderNumber.IsGuid())
            {
                SetCustomerOrderNumber(unitOfWork, result.GetCartResult.Cart);
            }
          
            if (!result.Properties.ContainsKey("ElavonRespMessage"))
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            try
            {
                if (result.Properties.ContainsKey("ElavonRespMessage") && !string.IsNullOrEmpty(result.Properties["ElavonRespMessage"]))
                {
                    CustomerOrder cart = result.GetCartResult.Cart;
                    string isTaxTBD = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameIsTaxTBD, cart);
                    if (string.IsNullOrEmpty(isTaxTBD) || isTaxTBD.Equals("false", StringComparison.InvariantCultureIgnoreCase))
                    {
                        string level3Response = PostElavonLevel3Data(result.Properties["ElavonRespMessage"], cart, unitOfWork);
                        bool isValidResponse = CheckElavonResponseIsValid(level3Response);
                        if (isValidResponse)
                        {
                            result.Properties.Remove("ElavonRespMessage");
                            result.Properties.Add("ElavonRespMessage", level3Response);
                            result.Properties.Add("ElavonResponseType", "AUTHONLY");
                        }
                        else
                        {
                            result.Properties.Add("ElavonResponseType", "GETTOKEN");
                            return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CreditCardFailed, CustomMessageProvider.Current.ElavonLevel3APiErrorMessage);
                        }
                    }
                    else
                    {
                        result.Properties.Add("ElavonResponseType", "GETTOKEN");
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);

                result.Properties.Add("ElavonResponseType", "GETTOKEN");
            }
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }

        private string PostElavonLevel3Data(string elavonRespMessage, CustomerOrder cart, IUnitOfWork unitOfWork)
        {
            string elavonXMLAPIUrl = ElavonSettings.ElavonTestMode ? ElavonSettings.ElavonXMLAPIDemoUrl : ElavonSettings.ElavonXMLAPIProductionUrl;

            string result = string.Empty;

            dynamic paymentJson = JsonConvert.DeserializeObject(elavonRespMessage);
            string sslToken = Convert.ToString(paymentJson["ssl_token"]);

            Txn txn = GetTxn(cart, sslToken, unitOfWork);

            WebClient client = new WebClient();

            ServicePointManager.ServerCertificateValidationCallback = delegate (object s, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) { return true; };
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

            string xml = ToXml(txn);
            client.QueryString.Add("xmldata", xml);

            var response_data = client.UploadValues(elavonXMLAPIUrl, "post", client.QueryString);

            result = UnicodeEncoding.UTF8.GetString(response_data);

            if (ElavonSettings.LogEvalonPaymentResponse)
            {
                LogHelper.For((object)this).Info((object)xml, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler.ElavonPostLevel3Data - Elavon XML API Request");

                LogHelper.For((object)this).Info((object)result, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler.ElavonPostLevel3Data - Elavon XML API Response");
            }

            return result;
        }

        

        private bool CheckElavonResponseIsValid(string elavonResponse)
        {
            bool result = false;
            Txn txn = Deserialize<Txn>(elavonResponse);
            if (txn != null && string.IsNullOrEmpty(txn.ErrorCode) && !string.IsNullOrEmpty(txn.Ssl_Result) && txn.Ssl_Result.Equals("0") && !string.IsNullOrWhiteSpace(txn.Ssl_Approval_Code))
            {
                result = true;
            }
            else
            {
                string xmlResponse = SerializeObject(elavonResponse);
                SendLevl3FailureMail(xmlResponse);
            }
            return result;
        }
        private Txn GetTxn(CustomerOrder cart, string sslToken, IUnitOfWork unitOfWork)
        {
            Txn txn = new Txn();
            txn.Ssl_merchant_ID = ElavonSettings.ElavonSSLMerchantId;
            txn.Ssl_user_id = ElavonSettings.ElavonSSLUserId;
            txn.Ssl_pin = ElavonSettings.ElavonSSLPinId;
            txn.Ssl_vendor_id = ElavonSettings.ElavonVendorId;
            txn.Ssl_vendor_app_name = ElavonSettings.ElavonSSLVendorAppName;
            txn.Ssl_vendor_app_version = ElavonSettings.ElavonSSLVendorAppVersion.ToString();
            txn.Ssl_transaction_type = "CCAUTHONLY";
            txn.Ssl_token = sslToken;
            txn.Ssl_amount = NumberHelper.RoundCurrency(this.customerOrderUtilities.GetOrderTotal(cart)).ToString();
            txn.Ssl_salestax = NumberHelper.RoundCurrency(this.customerOrderUtilities.GetTotalTax(cart)).ToString();
            txn.Ssl_customer_code = CustomStringHelperExtensions.Truncate(cart.CustomerNumber, 17);//cart.CustomerNumber.Truncate(17);
            txn.Ssl_discount_amount = NumberHelper.RoundCurrency(this.customerOrderUtilities.GetTotalDiscountAmount(cart)).ToString();
            txn.Ssl_duty_amount = "0.00";
            txn.Ssl_shipping_amount = NumberHelper.RoundCurrency(this.customerOrderUtilities.GetShippingAndHandling(cart)).ToString();
            txn.Ssl_level3_indicator = "Y";
            txn.Ssl_Freight_Tax_Amount = "0.00";
            txn.Ssl_Salestax_Indicator = "Y";            
            txn.Ssl_Invoice_Number = CustomStringHelperExtensions.Truncate(cart.OrderNumber,25);
            txn.Ssl_Ship_To_Zip = cart.ShipTo?.PostalCode;
            txn.Ssl_ship_to_country = cart.ShipTo?.Country?.IsoCode3;
            txn.Ssl_ship_from_postal_code = cart.ShipTo?.PostalCode;
            txn.Ssl_national_tax_indicator = GetNationalTaxIndicatorValue(cart);
            txn.Ssl_national_tax_amount = NumberHelper.RoundCurrency(this.customerOrderUtilities.GetTotalTax(cart)).ToString();
            txn.Ssl_order_date = cart.OrderDate.ToString("yyMMdd");
            txn.Ssl_other_tax = "0.00";
            txn.Ssl_summary_commodity_code = "";
            txn.Ssl_merchant_vat_number = "";
            txn.Ssl_customer_vat_number = "";
            txn.Ssl_vat_invoice_number = "";
            txn.Ssl_tracking_number = "";
            txn.Ssl_shipping_company = "";
            txn.Ssl_other_fees = "0.00";
            txn.LineItemProducts = new LineItemProducts() { Product = GetProductData(cart) };

            return txn;
        }
        private void SetCustomerOrderNumber(IUnitOfWork unitOfWork, CustomerOrder customerOrder)
        {
            if (!customerOrder.OrderNumber.IsGuid())
                return;
            ICustomerOrderRepository typedRepository = unitOfWork.GetTypedRepository<ICustomerOrderRepository>();
            customerOrder.OrderNumber = typedRepository.GetNextOrderNumber(this.orderManagementGeneralSettings.OrderNumberPrefix, this.orderManagementGeneralSettings.OrderNumberFormat);
        }

        private string GetNationalTaxIndicatorValue(CustomerOrder cart)
        {
            string nationalTaxIndicator = string.Empty;
            if (cart.CreditCardTransactions?.Count > 0)
            {
                if (cart.CreditCardTransactions.ToList().First().CardType == "VISA")
                {
                    if (cart.TaxCalculated)
                        nationalTaxIndicator= "1";
                    else
                        nationalTaxIndicator = "0";
                }
                else
                {
                    if (cart.TaxCalculated)
                        nationalTaxIndicator = "Y";
                    else
                        nationalTaxIndicator = "N";
                }
                
            }
            return nationalTaxIndicator;
        }

        private List<ElavonProduct> GetProductData(CustomerOrder cart)
        {
            List<ElavonProduct> products = new List<ElavonProduct>();
            if (cart.OrderLines != null && cart.OrderLines.Count > 0)
            {
                foreach (var orderLine in cart.OrderLines)
                {
                    string shortDescription = ReplaceSpecialCharacter(orderLine.Product.ShortDescription);

                    ElavonProduct elavonProduct = new ElavonProduct();
                    elavonProduct.Ssl_line_Item_commodity_code = CustomStringHelperExtensions.Truncate(orderLine.Product.ErpNumber, 12);
                    elavonProduct.Ssl_line_item_description = CustomStringHelperExtensions.Truncate(shortDescription, 25);
                    elavonProduct.Ssl_line_item_discount_amount = NumberHelper.RoundCurrency(orderLine.TotalNetPrice - orderLine.TotalRegularPrice).ToString();
                    string discountIndicator = "N";
                    if (orderLine.TotalNetPrice < orderLine.TotalRegularPrice)
                    {
                        discountIndicator = "Y";
                    }
                    elavonProduct.Ssl_line_Item_discount_indicator = discountIndicator;
                    elavonProduct.Ssl_line_Item_extended_total = NumberHelper.RoundCurrency(orderLine.TotalNetPrice).ToString();
                    elavonProduct.Ssl_line_Item_product_code = CustomStringHelperExtensions.Truncate(orderLine.Product.ErpNumber, 12);
                    elavonProduct.Ssl_line_Item_quantity = orderLine.QtyOrdered.ToString();
                    elavonProduct.Ssl_line_Item_unit_cost = NumberHelper.RoundCurrency(orderLine.UnitListPrice).ToString();
                    elavonProduct.Ssl_line_Item_unit_of_measure = CustomStringHelperExtensions.Truncate(orderLine.UnitOfMeasure, 2);
                    elavonProduct.Ssl_Line_Item_Total = NumberHelper.RoundCurrency(orderLine.TotalNetPrice).ToString();
                    //Elavon 3DS Integration
                    elavonProduct.Ssl_line_Item_tax_indicator =  orderLine.TaxAmount >0 ? "Y":"N";
                    //elavonProduct.Ssl_line_Item_tax_rate = "";
                    elavonProduct.Ssl_line_Item_tax_amount = Convert.ToString(orderLine.TaxAmount);
                    elavonProduct.Ssl_line_Item_tax_type = "";
                    elavonProduct.Ssl_line_Item_alternative_tax = "0.00";
                    products.Add(elavonProduct);
                }
            }
            return products;
        }

        private string ToXml<T>(T value)
        {
            //this avoids xml document declaration
            XmlWriterSettings settings = new XmlWriterSettings()
            {
                Indent = false,
                OmitXmlDeclaration = true
            };

            var stream = new MemoryStream();
            using (XmlWriter xw = XmlWriter.Create(stream, settings))
            {
                //this avoids xml namespace declaration
                XmlSerializerNamespaces ns = new XmlSerializerNamespaces(
                                   new[] { XmlQualifiedName.Empty });
                XmlSerializer x = new XmlSerializer(value.GetType(), "");
                x.Serialize(xw, value, ns);
            }


            return Encoding.UTF8.GetString(stream.ToArray());

        }


        public T Deserialize<T>(string xmlText)
        {
            if (String.IsNullOrWhiteSpace(xmlText)) return default(T);

            using (StringReader stringReader = new System.IO.StringReader(xmlText))
            {
                var serializer = new XmlSerializer(typeof(T));
                return (T)serializer.Deserialize(stringReader);
            }

        }

        private string SerializeObject(object value)
        {
            XmlSerializer xmlSerializer = new XmlSerializer(value.GetType());
            StringWriter stringWriter1 = new StringWriter();
            StringWriter stringWriter2 = stringWriter1;
            object o = value;
            xmlSerializer.Serialize((TextWriter)stringWriter2, o);
            return stringWriter1.ToString();
        }

        private string ReplaceSpecialCharacter(string productDescription)
        {
            if (!string.IsNullOrEmpty(productDescription))
            {
                string shortDescription = productDescription;
                string specialCharacter = ElavonSettings.SpecialCharacters;
                if (!string.IsNullOrEmpty(specialCharacter))
                {
                    string[] specialChars = specialCharacter.Split(',');

                    foreach (var specialChar in specialChars)
                    {
                        if (shortDescription.Contains(specialChar))
                        {
                            shortDescription = shortDescription.Replace(specialChar, "");
                        }
                    }

                }
                return shortDescription;
            }

            return productDescription;
        }

        private void SendLevl3FailureMail(string elavonResponse)
        {

            dynamic obj = new ExpandoObject();
            obj.ApiModle = "Elavon Level3 Failure Mail";
            obj.MailSubject = "Error while sending level3 data to Elavon";
            obj.JsonInput = "Website = " + SiteContext.Current.WebsiteDto.Name + ", Elavon Pin = " + SettingHelper.GetSSLPinForElavonErrorEmail();
            obj.JsonOutput = string.Empty;
            obj.AdditionalInfo = elavonResponse;

            this.EmailHelper.ErrorEmail(obj, this.EmailService);
        }

    }
}
