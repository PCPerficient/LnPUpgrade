
using System;
using System.IO;
using System.Xml;
using System.Data;
using System.Linq;
using Insite.Integration.Enums;
using System.Xml.Serialization;
using System.Collections.Generic;
using Insite.WIS.Broker;
using Insite.Common.Helpers;
using Insite.WIS.Broker.Plugins;
using Insite.WIS.Broker.Interfaces;
using Insite.WIS.Broker.Plugins.Constants;
using Insite.WIS.Broker.WebIntegrationService;
using Newtonsoft.Json;
using LeggettAndPlatt.FTP;
using LeggettAndPlatt.IntegrationProcessor.Common;
using LeggettAndPlatt.IntegrationProcessor.Models;
using LeggettAndPlatt.FTP.RequestModel;
using Ionic.Zip;
using System.Text;
using System.Globalization;

namespace LeggettAndPlatt.IntegrationProcessor
{
    public class IntegrationProcessorOrderSubmit : IIntegrationProcessor
    {
        DataSet initialDataset = null;
        DataTable dataTableCustomer = null;
        DataTable dataTableCustomerOrder = null;
        DataTable dataTableOrderSettings = null;
        DataTable dataTableCustomerOrderProperty = null;
        DataTable dataTablePaymentMethod = null;
        DataTable dataTableShitpTo = null;
        DataTable dataTableCurrency = null;
        IntegrationJobLogger JobLogger;
        IntegrationJob IntegrationJob;
        string paymentStatus = null;
        string localDirectoryPath = null;
        string orderXmlFileName = null;
        string ftpUsername = null;
        string ftpPassword = null;
        string ftpHost = null;
        string ftpPort = null;
        string ftpUploadDirectoryLocation = null;
        string archiveRetentionDays = null;

        public DataSet Execute(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
            string path = AppDomain.CurrentDomain.BaseDirectory;
            this.JobLogger = new IntegrationJobLogger(siteConnection, integrationJob);
            this.IntegrationJob = integrationJob;
            this.JobLogger.Info("Order xml job start.");
            this.initialDataset = XmlDatasetManager.ConvertXmlToDataset(integrationJob.InitialData);

            if (this.initialDataset == null
                || !this.initialDataset.Tables.Contains(Data.CustomerOrderTable)
                || this.initialDataset.Tables[Data.CustomerOrderTable].Rows.Count == 0)
            {
                this.JobLogger.Fatal("The initial dataset is empty and OrderSubmit cannot proceed. Please verify that the GenericSubmit preprocessor is being used for this job.");
                throw new ArgumentException(Messages.InvalidInitialDataSetExceptionMessage);
            }
            this.InitDataTables();
            this.InitJobParameters(integrationJob);

            DataRow dataRowCustomerOrder = this.dataTableCustomerOrder.Rows[0];
            var orderNumber = this.GetsanitizedDataRowValue(dataRowCustomerOrder, Data.OrderNumberColumn);
            var orderXmlModel = GetOrder(dataRowCustomerOrder);
            bool isSaved = this.SaveOrderXML(orderXmlModel, orderNumber);
            DataSet resultDataSet = new DataSet();
            if (isSaved)
            {
                bool isUploaded = this.UploadOrderXml();
                if (isUploaded)
                {
                    DataSet result = this.CreateResult();
                    resultDataSet = result;
                    this.Archive(orderNumber);
                    this.DeleteOldFiles();
                }
            }
            this.JobLogger.Info("Order xml job end.");
            return resultDataSet;
        }

        private DataTable GetCustomerOrderTable()
        {
            return this.initialDataset.Tables[Data.CustomerOrderTable];
        }
        private DataTable GetCustomerOrderPropertyTable()
        {
            return this.initialDataset.Tables[Data.CustomerOrderPropertyTable];
        }
        private DataTable GetCustomerTable()
        {
            return this.initialDataset.Tables[Data.CustomerTable];
        }
        private DataTable GetShipToTable()
        {
            return this.initialDataset.Tables[Data.ShipToTable];
        }
        private DataTable GetShipToCountryTable()
        {
            return this.initialDataset.Tables[Data.ShipToCountryTable];
        }
        private DataTable GetCreditCardTransactionTable()
        {
            return this.initialDataset.Tables[Data.CreditCardTransactionTable];
        }
        private DataTable GetOrderSettingTable()
        {
            return this.initialDataset.Tables["OrderSetting"];
        }

        private DataTable GetCurrencyTable()
        {
            return this.initialDataset.Tables[Data.CurrencyTable];
        }
        private void InitDataTables()
        {
            this.dataTableCustomer = this.GetCustomerTable();
            this.dataTableCustomerOrder = this.GetCustomerOrderTable();
            this.dataTableOrderSettings = this.GetOrderSettingTable();
            this.dataTableCustomerOrderProperty = this.GetCustomerOrderPropertyTable();
            this.dataTablePaymentMethod = this.GetCreditCardTransactionTable();
            this.dataTableShitpTo = this.GetShipToTable();
            this.dataTableCurrency = this.GetCurrencyTable();
        }

        private void InitJobParameters(IntegrationJob integrationJob)
        {
            string portNumber = string.Empty;
            string address = string.Empty;

            IntegrationJobParameter[] integrationJobParameters = this.IntegrationJob.IntegrationJobParameters.Where(
                x => x.JobDefinitionParameter != null
                ).ToArray();

            JobDefinitionStep jobDefinitionStep = (from step in integrationJob.JobDefinition.JobDefinitionSteps
                                                   orderby step.Sequence ascending
                                                   select step).FirstOrDefault();

            if (jobDefinitionStep == null)
            {
                this.JobLogger.Info("JobDefinitionStep is not define");
                throw new ArgumentException("Step 1 is not define.");
            }


            if (jobDefinitionStep != null && jobDefinitionStep.IntegrationConnectionOverride != null)
            {
                IntegrationConnection connection = jobDefinitionStep.IntegrationConnectionOverride;

                if (string.IsNullOrEmpty(connection.LogOn))
                    throw new ArgumentException("User name for ftp connection is required.");
                if (string.IsNullOrEmpty(connection.Password))
                    throw new ArgumentException("Password for ftp connection is required.");
                if (string.IsNullOrEmpty(connection.Url))
                    throw new ArgumentException("Host name for ftp connection is required.");

                string[] addressPort = connection.Url.Split(':');

                for (int i = 0; i < addressPort.Length; i++)
                {
                    if (i == 0)
                        address = addressPort[0];
                    else if (i == 1)
                        portNumber = string.IsNullOrEmpty(addressPort[1]) ? "21" : addressPort[1];
                }

                this.ftpHost = address;
                this.ftpPort = portNumber;
                this.ftpUsername = connection.LogOn;
                this.ftpPassword = EncryptionHelper.DecryptAes(connection.Password);
                this.JobLogger.Info("Finished reading FTP connection credentials");
            }
            else
            {
                this.JobLogger.Info("Integration connection override for FTP credentials is not defined.");
                throw new ArgumentException("Integration connection override for FTP credentials is not defined.");
            }

            this.ftpUploadDirectoryLocation = this.GetParameterValue(
                (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
                "FTPUploadDirectoryLocation",
                "Unable to find job definition parameter 'FTPUploadDirectoryLocation'. This is an required parameter used to upload order xml on remote server.",
                IntegrationJobLogType.Fatal
                );

            this.localDirectoryPath = this.GetParameterValue(
                (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
                "OrderXmlLocalDirectoryPath",
                "Unable to find job definition parameter 'OrderXmlLocalDirectoryPath'. This is an required parameter used to save order xml on local server.",
                IntegrationJobLogType.Fatal
                );

            this.archiveRetentionDays = this.GetParameterValue(
                (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
                "ArchiveRetentionDays",
                "Unable to find job definition parameter 'ArchiveRetentionDays'. This is an required parameter used to delete xml files created before inserted days from local server.",
                IntegrationJobLogType.Fatal
                );
        }
        private DataSet CreateResult()
        {
            this.JobLogger.Info($"Create order submit response start.");
            DataSet resultDataSet = new DataSet();
            DataRow dataRowCustomerOrder = this.dataTableCustomerOrder.Rows[0];
            var orderId = this.GetsanitizedDataRowValue(dataRowCustomerOrder, "Id");
            var orderNumber = this.GetsanitizedDataRowValue(dataRowCustomerOrder, Data.OrderNumberColumn);
            var orderSubmitTable = resultDataSet.Tables.Add(Data.OrderSubmitTable);
            orderSubmitTable.Columns.Add("OrderNumber");
            orderSubmitTable.Columns.Add("Id");
            var orderNumberRow = orderSubmitTable.NewRow();
            orderNumberRow["OrderNumber"] = orderNumber;
            orderNumberRow["Id"] = orderId;
            orderSubmitTable.Rows.Add(orderNumberRow);
            this.JobLogger.Info($"Create order submit responce for #{orderNumber}. end.");
            return resultDataSet;
        }
        private Order GetOrder(DataRow dataRowCustomerOrder)
        {
            this.JobLogger.Info("Get order start.");
            DataRow dataRowOrderSetting = this.dataTableOrderSettings.Rows[0];

            var customerNumber = this.GetsanitizedDataRowValue(dataRowCustomerOrder, Data.CustomerNumberColumn);
            var orderNumber = this.GetsanitizedDataRowValue(dataRowCustomerOrder, Data.OrderNumberColumn);
            var formatedOrderDate = this.GetFormatedOrderDate(this.GetsanitizedDataRowValue(dataRowCustomerOrder, Data.OrderDateColumn));

            Order order = new Order();
            order.OtherCharges = this.GetsanitizedDataRowValue(dataRowOrderSetting, "OtherCharges");
            order.AllocationRuleID = this.GetsanitizedDataRowValue(dataRowOrderSetting, "AllocationRuleID");
            order.DepartmentCode = this.GetsanitizedDataRowValue(dataRowOrderSetting, "DepartmentCode");
            order.ValidateItem = this.GetsanitizedDataRowValue(dataRowOrderSetting, "ValidateItem");
            order.CustomerPhoneNo = this.GetShipToPhone();
            order.BypassPricing = this.GetsanitizedDataRowValue(dataRowOrderSetting, "ByPassPricing");
            order.AuthorizedClient = this.GetsanitizedDataRowValue(dataRowOrderSetting, "AuthorizedClient");
            order.CustomerEMailID = this.GetsanitizedDataRowValue(dataRowCustomerOrder, "BTEmail");
            order.DocumentType = this.GetsanitizedDataRowValue(dataRowOrderSetting, "DocumentType");
            order.EnterpriseCode = this.GetsanitizedDataRowValue(dataRowOrderSetting, "EnterpriseCode");
            order.CustomerContactID = customerNumber;
            order.BillToID = customerNumber;
            order.AllAddressesVerified = GetIsAllAddressesVerified();
            order.ShipToID = this.GetShipToID();
            order.EntryType = this.GetsanitizedDataRowValue(dataRowOrderSetting, "EntryType");
            order.OrderDate = formatedOrderDate;
            order.OrderNo = orderNumber;
            order.OrderType = this.GetsanitizedDataRowValue(dataRowOrderSetting, "LineType");
            order.PaymentRuleId = this.GetsanitizedDataRowValue(dataRowOrderSetting, "PaymentRuleId");
            order.Extn = new Extn { ExtnIsTaxed = this.GetVertexIsTaxTBD() };
            order.PriceInfo = new PriceInfo { Currency = this.GetCurrency() };
            order.PersonInfoBillTo = this.GetPersonInfoBillTo();
            order.PersonInfoShipTo = this.GetPersonInfoShipTo();
            order.CustomerFirstName = order.PersonInfoShipTo.FirstName;
            order.CustomerLastName = order.PersonInfoShipTo.LastName;
            order.CustomerZipCode = order.PersonInfoShipTo.ZipCode;
            order.PaymentMethods = new PaymentMethods { PaymentMethod = this.GetPaymentMethods() };
            if (!string.IsNullOrEmpty(this.paymentStatus) && this.paymentStatus.Equals("AUTHONLY"))
            {
                order.PaymentStatus = this.GetsanitizedDataRowValue(dataRowOrderSetting, "PaymentStatus");
            }
            order.OrderLines = new OrderLines { OrderLine = GetOrderLines() };
            this.JobLogger.Info("Get order end.");
            return order;

        }
        private string GetSubString(string stringContent, int allowLength)
        {
            if (stringContent.Length >= allowLength)
            {
                int stringLength = allowLength - 1;
                return stringContent.Substring(0, stringLength);
            }
            return stringContent;
        }

        private string GetVertexIsTaxTBD()
        {
            string isExtnIsTaxed = "false";
            DataRow[] isExtnIsTaxedRow = this.dataTableCustomerOrderProperty.Select($"Name='{OrderSettingConstant.isTaxTBD }'");
            if (isExtnIsTaxedRow.Length > 0)
            {
                isExtnIsTaxed = this.GetsanitizedDataRowValue(isExtnIsTaxedRow[0], "Value");
            }
            return (isExtnIsTaxed == "true") ? "N" : "Y";
        }


        private string GetIsAllAddressesVerified()
        {
            this.JobLogger.Info("Get is all addresses verified start.");
            string isAllAddressesVerified = "false";
            DataRow[] isAllAddressesVerifiedRow = this.dataTableCustomerOrderProperty.Select($"Name='{ OrderSettingConstant.isAddressVerified}'");

            if (isAllAddressesVerifiedRow.Length > 0)
            {
                isAllAddressesVerified = this.GetsanitizedDataRowValue(isAllAddressesVerifiedRow[0], "Value");
            }
            this.JobLogger.Info("Get is all addresses verified end.");
            return (isAllAddressesVerified == "true") ? "Y" : "N"; ;
        }


        private string GetShipToID()
        {
            this.JobLogger.Info("Get ship to id start.");
            DataRow dataRowShipto = this.dataTableShitpTo.Rows[0];
            this.JobLogger.Info("Get ship to id end.");
            return this.GetsanitizedDataRowValue(dataRowShipto, Data.CustomerSequenceColumn);
        }

        private string GetShipToPhone()
        {
            this.JobLogger.Info("Get ship to phone start.");
            DataRow dataRowShipto = this.dataTableShitpTo.Rows[0];
            this.JobLogger.Info("Get ship to phone end.");
            return this.GetsanitizedDataRowValue(dataRowShipto, Data.PhoneColumn);
        }

        private string GetCurrency()
        {
            this.JobLogger.Info("Get curreny start.");
            DataRow dataRowCurrency = this.dataTableCurrency.Rows[0];
            this.JobLogger.Info("Get curreny end.");
            return this.GetsanitizedDataRowValue(dataRowCurrency, "CurrencyCode");
        }


        private PersonInfoBillTo GetPersonInfoBillTo()
        {
            this.JobLogger.Info("Get person info bill to start.");
            DataRow dataRowCustomer = this.dataTableCustomer.Rows[0];
            DataRow btCountry = this.initialDataset.Tables[Data.BillToCountryTable].Rows[0];
            DataRow btState = this.initialDataset.Tables[Data.BillToStateTable].Rows[0];
            PersonInfoBillTo billtoInfo = new PersonInfoBillTo
            {
                AddressLine1 = this.GetsanitizedDataRowValue(dataRowCustomer, Data.Address1Column),
                AddressLine2 = this.GetsanitizedDataRowValue(dataRowCustomer, Data.Address2Column),
                City = this.GetsanitizedDataRowValue(dataRowCustomer, Data.CityColumn),
                Country = this.GetsanitizedDataRowValue(btCountry, "Abbreviation"),
                Company = this.GetsanitizedDataRowValue(dataRowCustomer, "CompanyName"),
                DayPhone = this.GetsanitizedDataRowValue(dataRowCustomer, Data.PhoneColumn),
                OtherPhone = this.GetsanitizedDataRowValue(dataRowCustomer, Data.PhoneColumn),
                EMailID = this.GetsanitizedDataRowValue(dataRowCustomer, Data.EmailColumn),
                FirstName = this.GetsanitizedDataRowValue(dataRowCustomer, Data.FirstNameColumn),
                LastName = this.GetsanitizedDataRowValue(dataRowCustomer, Data.LastNameColumn),
                State = this.GetsanitizedDataRowValue(btState, "Abbreviation"),
                ZipCode = this.GetsanitizedDataRowValue(dataRowCustomer, Data.PostalCodeColumn),
                PersonID = this.GetsanitizedDataRowValue(dataRowCustomer, Data.CustomerNumberColumn)
            };
            this.JobLogger.Info("Get person info bill to end.");
            return billtoInfo;
        }

        private PersonInfoShipTo GetPersonInfoShipTo()
        {
            this.JobLogger.Info("Get person info ship to start.");
            DataRow dataRowShipto = this.dataTableShitpTo.Rows[0];
            DataRow stCountry = this.initialDataset.Tables[Data.ShipToCountryTable].Rows[0];
            DataRow stState = this.initialDataset.Tables[Data.ShipToStateTable].Rows[0];
            PersonInfoShipTo InfoShipTo = new PersonInfoShipTo
            {
                AddressLine1 = this.GetsanitizedDataRowValue(dataRowShipto, Data.Address1Column),
                AddressLine2 = this.GetsanitizedDataRowValue(dataRowShipto, Data.Address2Column),
                City = this.GetsanitizedDataRowValue(dataRowShipto, Data.CityColumn),
                Country = this.GetsanitizedDataRowValue(stCountry, "Abbreviation"),
                Company = this.GetsanitizedDataRowValue(dataRowShipto, Data.CompanyNameColumn),
                DayPhone = this.GetsanitizedDataRowValue(dataRowShipto, Data.PhoneColumn),
                OtherPhone = this.GetsanitizedDataRowValue(dataRowShipto, Data.PhoneColumn),
                EMailID = this.GetsanitizedDataRowValue(dataRowShipto, Data.EmailColumn),
                FirstName = this.GetsanitizedDataRowValue(dataRowShipto, Data.FirstNameColumn),
                LastName = this.GetsanitizedDataRowValue(dataRowShipto, Data.LastNameColumn),
                State = this.GetsanitizedDataRowValue(stState, "Abbreviation"),
                ZipCode = this.GetsanitizedDataRowValue(dataRowShipto, Data.PostalCodeColumn),
                PersonID = GetShipToID()
            };
            this.JobLogger.Info("Get person info ship to end.");
            return InfoShipTo;
        }

        private List<PaymentMethod> GetPaymentMethods()
        {
            this.JobLogger.Info("Get payment methods start.");
            DataRow dataRowCustomer = this.dataTableCustomer.Rows[0];
            DataRow dataRowCustomerOrder = this.dataTableCustomerOrder.Rows[0];
            List<PaymentMethod> lstPaymentMethod = null;
            DataRow[] transactionRow = this.dataTablePaymentMethod.Select($"CustomerOrderid='{dataRowCustomerOrder["Id"].ToString()}'");
            if (transactionRow.Length > 0)
            {
                var ResponseString = transactionRow[0]["ResponseString"].ToString();
                if (ResponseString.Length > 0)
                {
                    lstPaymentMethod = new List<PaymentMethod>();
                    var paymentMethod = this.GetPaymentMethod(transactionRow);
                    lstPaymentMethod.Add(paymentMethod);
                }
            }
            this.JobLogger.Info("Get payment methods end.");
            return lstPaymentMethod;
        }

        private PaymentMethod GetPaymentMethod(DataRow[] transactionRow)
        {           
            this.JobLogger.Info("Get payment method method start.");
            var responseString = transactionRow[0]["ResponseString"].ToString();
            var responseType = transactionRow[0]["OrigId"].ToString();
            DataRow dataRowOrderSetting = this.dataTableOrderSettings.Rows[0];
            PaymentMethod paymentMethod = new PaymentMethod();
            dynamic paymentJson = ParseElavonResponse(responseString, responseType);

            string cardNumber = Convert.ToString(paymentJson["ssl_card_number"]);
            string cardNumberLast4 = cardNumber.Substring(cardNumber.Length - 4);

            string vertexFalg = this.GetVertexIsTaxTBD();
            if ((paymentJson["ssl_transaction_type"] != null) && Convert.ToString(paymentJson["ssl_transaction_type"]) == "AUTHONLY")
            {
                this.paymentStatus = this.GetsanitizedObjectValue(paymentJson, "ssl_transaction_type");
                paymentMethod.PaymentDetails = this.GetPaymentDetails(paymentJson);
            }
            paymentMethod.MaxChargeLimit = this.ConvertToDecimal(this.GetsanitizedObjectValue(paymentJson, "ssl_amount"));
            paymentMethod.CreditCardExpDate = this.GetsanitizedObjectValue(paymentJson, "ssl_exp_date");
            paymentMethod.CreditCardName = this.GetsanitizedDataRowValue(transactionRow[0], "Name");
            paymentMethod.CreditCardNo = this.GetsanitizedObjectValue(paymentJson, "ssl_token");
            paymentMethod.CreditCardType = this.GetsanitizedObjectValue(paymentJson, "ssl_card_short_description");
            paymentMethod.DisplayCreditCardNo = $"{cardNumberLast4}";
            paymentMethod.FirstName = this.GetsanitizedObjectValue(paymentJson, "ssl_first_name");
            paymentMethod.LastName = this.GetsanitizedObjectValue(paymentJson, "ssl_last_name");
            paymentMethod.PaymentReference1 = this.GetsanitizedDataRowValue(transactionRow[0], "OrderNumber");
            paymentMethod.PaymentType = this.GetsanitizedDataRowValue(dataRowOrderSetting, "PaymentType");
            paymentMethod.UnlimitedCharges = (vertexFalg == "Y") ? "Y" : "";
            paymentMethod.PersonInfoBillTo = this.GetPersonInfoBillTo();
            this.JobLogger.Info("Get payment method end.");
            return paymentMethod;
        }
        private PaymentDetails GetPaymentDetails(dynamic paymentJson)
        {
            this.JobLogger.Info("Get payment details start.");
            DataRow dataRowOrderSetting = this.dataTableOrderSettings.Rows[0];
            PaymentDetails paymentDetails = new PaymentDetails
            {
                AuthAmount = this.ConvertToDecimal(this.GetsanitizedObjectValue(paymentJson, "ssl_amount")),
                AuthCode = this.GetsanitizedObjectValue(paymentJson, "ssl_approval_code"),
                AuthorizationExpirationDate = this.GetFormatedAuthorizationExpirationDate(Convert.ToString(paymentJson["ssl_txn_time"])),
                AuthorizationID = this.GetsanitizedObjectValue(paymentJson, "ssl_txn_id"),
                ChargeType = this.GetsanitizedObjectValue(dataRowOrderSetting, "ChargeType"),
                ProcessedAmount = this.ConvertToDecimal(this.GetsanitizedObjectValue(paymentJson, "ssl_amount")),
                RequestAmount = this.ConvertToDecimal(this.GetsanitizedObjectValue(paymentJson, "ssl_amount")),
                RequestId = this.GetsanitizedObjectValue(paymentJson, "ssl_txn_id")
            };
            this.JobLogger.Info("Get payment details end.");
            return paymentDetails;
        }

        private dynamic ParseElavonResponse(string responseString, string responseType)
        {
            dynamic paymentJson = null;
            if (responseType.Equals("GETTOKEN", StringComparison.InvariantCultureIgnoreCase))
            {
                paymentJson = JsonConvert.DeserializeObject(responseString);
            }

            if (responseType.Equals("AUTHONLY", StringComparison.InvariantCultureIgnoreCase))
            {
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(responseString);
                var txnTag = doc.FirstChild.NextSibling;
                string json = JsonConvert.SerializeXmlNode(txnTag, Newtonsoft.Json.Formatting.None, true);

                paymentJson = JsonConvert.DeserializeObject(json);
            }

                return paymentJson;
        }
        private List<OrderLine> GetOrderLines()
        {
            this.JobLogger.Info("Get order lines start.");
            DataTable orderLinesTabel = this.initialDataset.Tables[Data.OrderLineTable];
            List<OrderLine> lstOrderLine = null;

            DataRow dataRowOrderSetting = this.dataTableOrderSettings.Rows[0];
            if (orderLinesTabel.Rows.Count > 0)
            {
                lstOrderLine = new List<OrderLine>();
                foreach (DataRow row in orderLinesTabel.Rows)
                {
                    DataTable product = this.initialDataset.Tables[Data.ProductTable];
                    DataRow[] producrow = product.Select($"Id='{row["ProductId"].ToString()}'");
                    string unitOfMeasure = (this.GetsanitizedDataRowValue(row, "UnitOfMeasure") != "") ? this.GetsanitizedDataRowValue(row, "UnitOfMeasure") : "    ";

                    var orderLine = new OrderLine()
                    {
                        CarrierServiceCode = this.GetsanitizedDataRowValue(dataRowOrderSetting, "CarrierServiceCode"),
                        DeliveryMethod = this.GetsanitizedDataRowValue(dataRowOrderSetting, "DeliveryMethod"),
                        ItemGroupCode = this.GetsanitizedDataRowValue(dataRowOrderSetting, "ItemGroupCode"),
                        LineType = this.GetsanitizedDataRowValue(dataRowOrderSetting, "LineType"),
                        OrderedQty = this.GetsanitizedDataRowValue(row, "QtyOrdered"),
                        PrimeLineNo = this.GetsanitizedDataRowValue(row, "Line"),

                        Item = new Item
                        {
                            ItemID = this.GetsanitizedDataRowValue(producrow[0], "ErpNumber"),
                            ProductClass = this.GetsanitizedDataRowValue(dataRowOrderSetting, "ProductClass"),
                            UnitCost = this.ConvertToDecimal(this.GetsanitizedDataRowValue(row, "UnitCost")),
                            UnitOfMeasure = unitOfMeasure
                        },
                        LinePriceInfo = new LinePriceInfo
                        {
                            IsPriceLocked = this.GetsanitizedDataRowValue(dataRowOrderSetting, "IsPriceLocked"),
                            ListPrice = this.ConvertToDecimal(this.GetsanitizedDataRowValue(row, "UnitListPrice")),
                            RetailPrice = this.ConvertToDecimal(this.GetsanitizedDataRowValue(row, "UnitListPrice")),
                            TaxableFlag = this.GetsanitizedDataRowValue(dataRowOrderSetting, "TaxableFlag"),
                            UnitPrice = this.ConvertToDecimal(this.GetsanitizedDataRowValue(row, "UnitNetPrice"))
                        },
                        LineTaxes = new LineTaxes
                        {
                            LineTax = GetLineTaxes(row)
                        }
                    };
                    lstOrderLine.Add(orderLine);
                }
            }
            this.JobLogger.Info("Get order lines end.");
            return lstOrderLine;
        }

        private List<LineTax> GetLineTaxes(DataRow row)
        {
            this.JobLogger.Info("Get line taxes start.");
            List<LineTax> lstTax = null;
            lstTax = new List<LineTax>();
            var lineTax = this.GetLineTax(row);
            lstTax.Add(lineTax);
            this.JobLogger.Info("Get line taxes end.");
            return lstTax;
        }
        private LineTax GetLineTax(DataRow row)
        {
            DataRow dataRowOrderSetting = this.dataTableOrderSettings.Rows[0];
            LineTax lineTax = new LineTax();
            lineTax.Tax = this.ConvertToDecimal(this.GetsanitizedObjectValue(row, "TaxAmount"));
            lineTax.ChargeCategory = this.GetsanitizedDataRowValue(dataRowOrderSetting, "ChargeCategory");
            lineTax.ChargeName = this.GetsanitizedDataRowValue(dataRowOrderSetting, "ChargeName");
            lineTax.TaxName = this.GetsanitizedDataRowValue(dataRowOrderSetting, "TaxName");
            lineTax.TaxPercentage = this.GetsanitizedObjectValue(row, "TaxCode2");
            return lineTax;
        }
        private string GetCardType(string responceType)
        {
            switch (responceType)
            {
                case "VISA":
                    return "VI";
                case "DISC":
                    return "DS";
                case "MC":
                    return "MC";
                case "AMEX":
                    return "AX";
                default:
                    return "VI";
            }

        }


        private bool SaveOrderXML(Order orderXmlModel, string orderNumber)
        {
            this.JobLogger.Info("Order xml save start.");
            bool result = false;

            if (this.IntegrationJob.IntegrationJobParameters == null)
            {
                this.JobLogger.Info(
                    "No job parameters defined. 'OrderXmlLocalDirectoryPath', 'FTPUsername', 'FTPHost','FTPPassword','FTPPort','FTPUploadDirectoryLocaltion','archiveRetentionDays' and  'SpecialCharectorsValue' are all required parameters",
                    true
                    );
            }
            else
            {
                this.CreatePathIfMissing(this.localDirectoryPath);
                XmlDocument xmlDoc = new XmlDocument();
                using (MemoryStream xmlStream = new MemoryStream())
                {
                    XmlSerializerNamespaces ns = new XmlSerializerNamespaces();
                    ns.Add("ns0", $"{OrderSettingConstant.orderXmlHeader}");
                    XmlSerializer xmlSerializer = new XmlSerializer(orderXmlModel.GetType());

                    xmlSerializer.Serialize(xmlStream, orderXmlModel, ns);
                    xmlStream.Position = 0;
                    xmlDoc.Load(xmlStream);
                    var xmlString = xmlDoc.InnerXml;
                    this.orderXmlFileName = $"Order_{ orderNumber}.xml";
                    var orderXmlFile = $"{this.localDirectoryPath}{this.orderXmlFileName}";
                    using (XmlTextWriter writer = new XmlTextWriter(orderXmlFile, Encoding.UTF8))
                    {
                        writer.Formatting = System.Xml.Formatting.Indented;
                        xmlDoc.Save(writer);
                    }
                }
                result = true;
            }

            this.JobLogger.Info("Order xml save end.");

            return result;
        }
        private bool UploadOrderXml()
        {
            this.JobLogger.Info("Order xml upload start.");
            bool result = false;

            if (this.IntegrationJob.IntegrationJobParameters == null)
            {
                this.JobLogger.Info(
                    "No job parameters defined. 'OrderXmlLocalDirectoryPath', 'FTPUsername', 'FTPHost','FTPPassword','FTPPort' and 'FTPUploadDirectoryLocaltion' are all required parameters",
                    true
                    );
            }
            else
            {
                int port = 0;
                int.TryParse(this.ftpPort, out port);
                FTPRequestModel ftpRequest = new FTPRequestModel
                {
                    FTPAddress = this.ftpHost,
                    FTPUsername = this.ftpUsername,
                    FTPPassword = this.ftpPassword,
                    FTPPort = port,
                    FTPRemoteFolderPath = this.ftpUploadDirectoryLocation,
                    LocalFolderPath = this.localDirectoryPath,
                };
                FtpManager ftpClient = new FtpManager(ftpRequest);
                ftpClient.Upload(this.orderXmlFileName);

                result = true;
            }
            this.JobLogger.Info("Order xml upload end.");
            return result;

        }
        private string GetParameterValue(
            IEnumerable<IntegrationJobParameter> integrationJobParameters,
            string parameterName, string notFoundMessage,
            IntegrationJobLogType logType = IntegrationJobLogType.Fatal
            )
        {
            this.JobLogger.Info("Get Parameter Value for " + parameterName + " Parameters count " + integrationJobParameters.Count());

            IntegrationJobParameter integrationJobParameter = integrationJobParameters.FirstOrDefault<IntegrationJobParameter>((Func<IntegrationJobParameter, bool>)(p => p.JobDefinitionParameter.Name.EqualsIgnoreCase(parameterName)));
            if (integrationJobParameter != null)
                return integrationJobParameter.Value;
            this.JobLogger.AddLogMessage(notFoundMessage, true, logType);
            return (string)null;
        }
        private void CreatePathIfMissing(string path)
        {
            try
            {
                if (!Directory.Exists(path))
                {
                    DirectoryInfo di = Directory.CreateDirectory(path);
                }
            }
            catch (IOException ioex)
            {
                Console.WriteLine(ioex.Message);
            }

        }

        private string GetsanitizedDataRowValue(DataRow row, string columnName)
        {
            return (row[columnName] != null) ? row[columnName].ToString() : "";
        }
        private string GetFormatedOrderDate(string originOrderDate)
        {
            if (originOrderDate.Length > 0)
            {
                DateTime _date;
                string formatedDate = "";
                _date = DateTime.Parse(originOrderDate);

                formatedDate = _date.ToString("yyyy-MM-ddTHH:mm:sszzz");
                return formatedDate;
            }
            return originOrderDate;
        }

        private string GetFormatedAuthorizationExpirationDate(string authorizationExpirationDate)
        {
            if (authorizationExpirationDate.Length > 0)
            {
                DateTime _date;
                string formatedDate = "";
                _date = DateTime.Parse(authorizationExpirationDate);
                _date = _date.AddDays(7);
                formatedDate = _date.ToString("yyyy-MM-ddTHH:mm:sszzz");

                return formatedDate;
            }
            return authorizationExpirationDate;
        }

        private string GetsanitizedObjectValue(dynamic row, string columnName)
        {
            return (row[columnName] != null) ? Convert.ToString(row[columnName]) : "";
        }

        private void Archive(string orderNumber)
        {
            this.JobLogger.Info("Order xml zip start.");
            using (ZipFile zipFile = new ZipFile())
            {
                string localDirectoryPath = Path.GetDirectoryName(this.localDirectoryPath).Replace(this.localDirectoryPath, string.Empty); ;
                var filesToArchives = Directory.GetFiles(localDirectoryPath, "*", SearchOption.AllDirectories)
                    .Where(f => Path.GetExtension(f).ToLowerInvariant() != ".zip").ToArray();
                foreach (var file in filesToArchives)
                {
                    zipFile.AddFile(file, Path.GetDirectoryName(file).Replace(localDirectoryPath, string.Empty));
                }

                if (zipFile.Count > 0)
                {
                    string fileName = Path.Combine(localDirectoryPath, string.Format("LNP_OrderXML_{0}.zip", orderNumber));
                    zipFile.Save(Path.ChangeExtension(fileName, ".zip"));

                    foreach (string file in filesToArchives)
                        if (!file.EndsWith(".zip"))
                            File.Delete(file);
                }
            }
            this.JobLogger.Info("Order xml zip end.");
        }

        private void DeleteOldFiles()
        {
            this.JobLogger.Info("Delete order xml files created before given days start.");
            string[] files = Directory.GetFiles(this.localDirectoryPath, "*.zip");
            int retentionDays = 0;
            int.TryParse(this.archiveRetentionDays, out retentionDays);
            foreach (string file in files)
            {
                FileInfo fi = new FileInfo(file);
                if (fi.CreationTime < DateTime.Now.AddDays(-retentionDays))
                    fi.Delete();
            }
            this.JobLogger.Info("Delete order xml files created before given days end.");
        }
        private string ConvertToNumber(string value)
        {
            if (value == string.Empty) return null;

            var dec = decimal.Parse(value,
                NumberStyles.AllowDecimalPoint |
                NumberStyles.Number |
                NumberStyles.AllowThousands);
            var qty = (int)Math.Round(dec);

            return Convert.ToString(qty);
        }

        private string ConvertToDecimal(string value)
        {
            string price = "0.00";
            if (value != string.Empty)
            {
                decimal priceValue = Decimal.Round(Convert.ToDecimal(value), 2, MidpointRounding.AwayFromZero);
                price = Convert.ToString(priceValue);
            }
            return price;
        }

    }
}
