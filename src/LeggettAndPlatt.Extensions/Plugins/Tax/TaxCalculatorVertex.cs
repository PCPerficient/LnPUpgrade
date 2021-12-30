using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Tax;
using System;
using System.Collections.Generic;
using System.Linq;
using Insite.Core.Interfaces.Data;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Data.Entities;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Vertex.Services.Interfaces;
using LeggettAndPlatt.Vertex.RequestModels;
using System.Linq.Expressions;
using LeggettAndPlatt.Vertex.ResponseModels;
using Insite.Common.Logging;
using Newtonsoft.Json;
using LeggettAndPlatt.Extensions.Common;
using System.Dynamic;
using Insite.Core.Interfaces.Plugins.Emails;

namespace LeggettAndPlatt.Extensions.Plugins.Tax
{
    [DependencyName("Vertex")]
    [Serializable]
    public class TaxCalculatorVertex : ITaxCalculator, IDependency, IExtension
    {
        protected readonly VertexSettings VertexSettings;
        protected readonly IVertexTaxRateService VertexTaxRateService;
        protected readonly IUnitOfWork UnitOfWork;
        protected readonly IOrderLineUtilities OrderLineUtilities;
        protected readonly EmailHelper EmailHelper;
        protected readonly CommonSettings CommonSettings;
        protected readonly IEmailService EmailService;
        protected readonly CustomPropertyHelper CustomPropertyHelper;
        public TaxCalculatorVertex(IUnitOfWorkFactory unitOfWorkFactory, IOrderLineUtilities orderLineUtilities, VertexSettings vertexSettings, IVertexTaxRateService vertexTaxRateService, EmailHelper emailHelper, CommonSettings commonSettings, IEmailService emailService, CustomPropertyHelper customPropertyHelper)
        {
            this.VertexSettings = vertexSettings;
            this.VertexTaxRateService = vertexTaxRateService;
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.OrderLineUtilities = orderLineUtilities;
            this.EmailHelper = emailHelper;
            this.CommonSettings = commonSettings;
            this.EmailService = emailService;
            this.CustomPropertyHelper = customPropertyHelper;
        }

        public void CalculateTax(OriginAddress originAddress, CustomerOrder customerOrder)
        {
            if (customerOrder.Website == null)
                return;

            Website website = customerOrder.Website;
            customerOrder.StateTax = Decimal.Zero;

            ReSetOrderLineTax(customerOrder);

            UpdateCustomerOrderPropertyIfExist(customerOrder, CustomPropertyConstants.customPropertyNameIsTaxTBD, "false");

            VertexTaxRateRequestModel vertexTaxRateRequestModel = new VertexTaxRateRequestModel();

            this.PopulateShipTo(vertexTaxRateRequestModel, customerOrder);
            this.PopulateSeller(vertexTaxRateRequestModel);
            this.PopulateOrderLines(vertexTaxRateRequestModel, website, customerOrder);

            try
            {
                VertexTaxRateResponseModel vertexTaxRateResponseModel = VertexTaxRateService.GetTaxRate(vertexTaxRateRequestModel);

                AddVertexLog(vertexTaxRateResponseModel);

                customerOrder.StateTax = vertexTaxRateResponseModel.TotalTax;
                SetOrderLineTaxFromVertaxResponse(vertexTaxRateResponseModel, customerOrder);
            }
            catch (Exception ex)
            {
                SetCustomerOrderProperty(customerOrder, CustomPropertyConstants.customPropertyNameIsTaxTBD, "true");
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                this.SendExceptionEmail("Vertex Tax Error: " + ex.ToString());
            }
        }

        public void PostTax(OriginAddress originAddress, CustomerOrder customerOrder)
        {
            string isTaxTBD = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameIsTaxTBD, customerOrder);
            if (!string.IsNullOrEmpty(isTaxTBD) && isTaxTBD.Equals("true", StringComparison.InvariantCultureIgnoreCase))
            {
                customerOrder.RecalculateTax = true;
            }
        }


        protected virtual void PopulateShipTo(VertexTaxRateRequestModel vertexTaxRateRequestModel, CustomerOrder customerOrder)
        {
            Country country = this.UnitOfWork.GetRepository<Country>().GetTable().FirstOrDefault<Country>((Expression<Func<Country, bool>>)(c => c.Name == customerOrder.STCountry));

            vertexTaxRateRequestModel.StreetAddress1 = customerOrder.STAddress1;
            vertexTaxRateRequestModel.StreetAddress2 = customerOrder.STAddress2;
            vertexTaxRateRequestModel.City = customerOrder.STCity;
            vertexTaxRateRequestModel.State = customerOrder.STState;
            vertexTaxRateRequestModel.Country = country?.IsoCode3;
            vertexTaxRateRequestModel.Zip = customerOrder.STPostalCode;
        }

        protected virtual void PopulateSeller(VertexTaxRateRequestModel vertexTaxRateRequestModel)
        {
            vertexTaxRateRequestModel.Company = VertexSettings.VertexCompany;
            vertexTaxRateRequestModel.LegalEntity = VertexSettings.LegalEntity;
            vertexTaxRateRequestModel.TaxAreaId = VertexSettings.TaxAreaId;
            vertexTaxRateRequestModel.Branch = VertexSettings.Branch;
            vertexTaxRateRequestModel.UserName = VertexSettings.VertexUserName;
            vertexTaxRateRequestModel.Password = VertexSettings.VertexPassword;
            vertexTaxRateRequestModel.EnableLog = VertexSettings.VertexEnableLog;
            vertexTaxRateRequestModel.VertexEndPoint = VertexSettings.VertexEndPoint;
        }

        protected virtual void PopulateOrderLines(VertexTaxRateRequestModel vertexTaxRateRequestModel, Website website, CustomerOrder customerOrder)
        {
            Predicate<OrderLine> isValidOrderLine = (Predicate<OrderLine>)(orderLine =>
            {
                if (!(orderLine.QtyOrdered > Decimal.Zero) || orderLine.IsPromotionItem || !this.OrderLineUtilities.GetIsActive(orderLine))
                    return false;
                if (!(customerOrder.Type == "Quote"))
                    return !orderLine.Product.IsQuoteRequired;
                return true;
            });

            foreach (OrderLine orderLine in (IEnumerable<OrderLine>)customerOrder.OrderLines)
            {
                if (isValidOrderLine(orderLine))
                {
                    LineItemRequestModel lineItemRequestModel = new LineItemRequestModel();
                    lineItemRequestModel.Sku = orderLine.Product.ErpNumber;
                    //lineItemRequestModel.UnitOfMeasure = orderLine.Product.UnitOfMeasure;
                    lineItemRequestModel.UnitPrice = orderLine.UnitNetPrice;
                    lineItemRequestModel.Qty = Convert.ToInt32(orderLine.QtyOrdered);
                    string productBranch = GetProductCustomProperty(CustomPropertyConstants.customPropertyNameVertaxBranch, orderLine.Product);
                    lineItemRequestModel.Branch = !string.IsNullOrEmpty(productBranch) ? productBranch : this.VertexSettings.Branch;
                    string productLegalEntity = GetProductCustomProperty(CustomPropertyConstants.customPropertyNameVertaxLegalEntity, orderLine.Product);
                    lineItemRequestModel.LegalEntity = !string.IsNullOrEmpty(productLegalEntity) ? productLegalEntity : this.VertexSettings.LegalEntity;
                    string productTaxAreaId = GetProductCustomProperty(CustomPropertyConstants.customPropertyNameVertaxTaxAreaId, orderLine.Product);
                    lineItemRequestModel.TaxAreaId = !string.IsNullOrEmpty(productTaxAreaId) ? productTaxAreaId : this.VertexSettings.TaxAreaId;
                    vertexTaxRateRequestModel.LineItems.Add(lineItemRequestModel);
                }
            }
        }

        private void AddVertexLog(VertexTaxRateResponseModel vertexTaxRateResponseModel)
        {
            if (VertexSettings.VertexEnableLog)
            {
                LogHelper.For((object)this).Info("Vertex Tax Request: " + vertexTaxRateResponseModel.RequestXml);

                LogHelper.For((object)this).Info("Vertex Tax Response: " + vertexTaxRateResponseModel.ResponseXml);
            }
        }

        private void SendExceptionEmail(string error)
        {
            if (this.CommonSettings.ExceptionErrorEmailActive)
            {
                string subject = "Vertex - Tax Calulation : Failed On " + DateTime.Now;
                dynamic obj = new ExpandoObject();
                obj.ApiModle = string.Empty;
                obj.MailSubject = subject;
                obj.JsonInput = string.Empty;
                obj.JsonOutput = string.Empty;
                obj.AdditionalInfo = error;

                this.EmailHelper.ErrorEmail(obj, this.EmailService);
            }
        }

        private string GetProductCustomProperty(string propertyName, Product product)
        {
            string customPropertyValue = string.Empty;
            CustomProperty customProperty = product.CustomProperties.FirstOrDefault(c => c.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null && !string.IsNullOrEmpty(customProperty.Value))
            {
                customPropertyValue = customProperty.Value;
            }
            return customPropertyValue;
        }

        private void SetOrderLineTaxFromVertaxResponse(VertexTaxRateResponseModel vertexTaxRateResponseModel, CustomerOrder customerOrder)
        {
            foreach (var item in vertexTaxRateResponseModel.LineItems)
            {
                var orderLine = customerOrder.OrderLines.FirstOrDefault(o => o.Product.ErpNumber.Equals(item.Sku, StringComparison.InvariantCultureIgnoreCase));
                if (orderLine != null)
                {
                    orderLine.TaxAmount = item.TotalTax;
                    decimal taxPercantageRound = 0;
                    if (item.TotalTax > 0)
                    {
                        decimal taxPercantage = (item.TotalTax / (orderLine.TotalNetPrice));
                        taxPercantageRound = Decimal.Round(Convert.ToDecimal(taxPercantage), 2, MidpointRounding.AwayFromZero);                       
                    }
                    orderLine.TaxCode2 = Convert.ToString(taxPercantageRound);
                }
            }
        }

        private void ReSetOrderLineTax(CustomerOrder customerOrder)
        {
            foreach (var orderLine in customerOrder.OrderLines)
            {
                orderLine.TaxAmount = 0;
                orderLine.TaxCode2 = "0";
            }
        }

        private void SetCustomerOrderProperty(CustomerOrder customerorder, string propertyName, string propertyValue)
        {
            CustomProperty customProperty = customerorder.CustomProperties.FirstOrDefault(o => o.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));

            if (customProperty != null)
            {
                customProperty.Value = propertyValue;
            }
            else
            {
                customerorder.SetProperty(propertyName, propertyValue);
            }

            this.UnitOfWork.Save();
        }

        private void UpdateCustomerOrderPropertyIfExist(CustomerOrder customerorder, string propertyName, string propertyValue)
        {
            CustomProperty customProperty = customerorder.CustomProperties.FirstOrDefault(o => o.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null && propertyValue.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                customProperty.Value = propertyValue;
                this.UnitOfWork.Save();
            }

        }

    }
}
