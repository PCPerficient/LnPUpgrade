using Insite.Common.Providers;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups.SystemSettings;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using Insite.Integration.WebService.Interfaces;
using LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.Linq;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Helpers
{
    public abstract class AbstractFullfillmentAndMailing
    {
        public virtual ExpandoObject BaseBuildObject(IJobLogger jobLogger, DataTable dtModel)
        {
            try
            {
                dynamic emailModel = new ExpandoObject();

                #region Order Information
                emailModel.EnterpriseCode = UtilHelper.GetColumnValue(dtModel.Rows[0], "EnterpriseCode");
                emailModel.MailSentDate = String.Format("{0:MM/dd/yyyy HH:mm:ss}", DateTimeProvider.Current.Now).Replace('-', '/');
                emailModel.FromEmail = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromEmail");
                emailModel.FromName = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromName");
                emailModel.FromAddress1 = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromAddress1");
                emailModel.FromAddress2 = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromAddress2");
                emailModel.FromCity = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromCity");
                emailModel.FromCountry = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromCountry");
                emailModel.FromToState = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromToState");
                emailModel.FromPostalCode = UtilHelper.GetColumnValue(dtModel.Rows[0], "FromPostalCode");

                emailModel.ToEmail = UtilHelper.GetColumnValue(dtModel.Rows[0], "ToEmail");
                emailModel.OrderDate = UtilHelper.GetColumnValue(dtModel.Rows[0], "OrderDate");
                emailModel.OrderNumber = UtilHelper.GetColumnValue(dtModel.Rows[0], "OrderNumber");
                emailModel.OrderStatus = UtilHelper.GetColumnValue(dtModel.Rows[0], "OrderStatus");

                emailModel.FullShippingChargeDisplay = UtilHelper.GetColumnValue(dtModel.Rows[0], "FullShippingChargeDisplay");
                emailModel.OrderGrandTotalDisplay = UtilHelper.GetColumnValue(dtModel.Rows[0], "OrderGrandTotalDisplay");
                emailModel.TotalTaxDisplay = UtilHelper.GetColumnValue(dtModel.Rows[0], "TotalTaxDisplay");
                emailModel.OrderLineSubTotal = UtilHelper.GetColumnValue(dtModel.Rows[0], "OrderLineSubTotal");
                #endregion

                #region OrderLines
                var orderLines = new List<ExpandoObject>();
                foreach (DataRow orderLine in dtModel.Rows)
                {
                    dynamic orderLineModel = new ExpandoObject();
                    orderLineModel.OrderLineNumber = UtilHelper.GetColumnValue(orderLine, "OrderLineNumber");
                    orderLineModel.OrderPlaced = UtilHelper.GetColumnValue(orderLine, "OrderPlaced");
                    orderLineModel.OrderStatus = UtilHelper.GetColumnValue(orderLine, "OrderStatus");
                    orderLineModel.TrackingNo = UtilHelper.GetColumnValue(orderLine, "TrackingNo");
                    orderLineModel.TrackingURL = UtilHelper.GetColumnValue(orderLine, "TrackingURL");
                    orderLineModel.QtyShipped = UtilHelper.GetColumnValue(orderLine, "QtyShipped");
                    orderLineModel.QtyChanged = UtilHelper.GetColumnValue(orderLine, "QtyChanged");
                    orderLineModel.QtyChanged = !string.IsNullOrEmpty(orderLineModel.QtyChanged) ? orderLineModel.QtyChanged.Replace("-", "") : string.Empty;
                    orderLineModel.OrderLineQtyOrdered = UtilHelper.GetColumnValue(orderLine, "OrderLineQtyOrdered");
                    orderLineModel.OrderLineDescription = UtilHelper.GetColumnValue(orderLine, "OrderLineDescription");
                    orderLineModel.OrderLineProduct = UtilHelper.GetColumnValue(orderLine, "OrderLineProduct");
                    orderLineModel.OrderLineUnitOfMeasure = UtilHelper.GetColumnValue(orderLine, "OrderLineUnitOfMeasure");
                    orderLineModel.OrderLineTax = UtilHelper.GetColumnValue(orderLine, "OrderLineTax");
                    orderLineModel.orderLineExtendedUnitNetPriceDisplay = UtilHelper.GetColumnValue(orderLine, "orderLineExtendedUnitNetPriceDisplay");
                    orderLineModel.OrderLineTotal = UtilHelper.GetColumnValue(orderLine, "OrderLineTotal");
                    orderLineModel.OrderLineUnitNetPriceDisplay = UtilHelper.GetColumnValue(orderLine, "OrderLineUnitNetPriceDisplay");
                    orderLines.Add(orderLineModel);
                }
                #endregion

                emailModel.OrderLines = orderLines;
                emailModel.OrderDate = !string.IsNullOrEmpty(emailModel.OrderDate) ? emailModel.OrderDate : orderLines.Any() ? emailModel.OrderLines[0].OrderPlaced : string.Empty;
                if (!string.IsNullOrEmpty(emailModel.OrderDate))
                    emailModel.OrderDate = String.Format("{0:MM/dd/yyyy}", Convert.ToDateTime(emailModel.OrderDate)).Replace('-', '/');
                return emailModel;
            }
            catch (Exception ex)
            {
                jobLogger.Error("Error in building Email Model.");
                jobLogger.Error(ex.StackTrace.ToString());
                return null;
            }
        }

        public virtual void SendMail(IJobLogger jobLogger, IEmailService emailService, IUnitOfWork unitOfWork, ExpandoObject expObj, string emailListName)
        {
            dynamic expandoObject = expObj;

            try
            {
                Website website = UtilHelper.GetWebsiteBasedOnEnterpriseCode(unitOfWork, expandoObject.EnterpriseCode);
                if (website == null) {
                    jobLogger.Warning(string.Format("Getting Null Website For {0} Enterprice Code.", expandoObject.EnterpriseCode));
                    return;
                }
              

                #region Content Base URL
                var httpsMode = SettingsGroupProvider.Current.Get<SecuritySettings>(new Guid?(website.Id)).HttpsMode;
                string secureMode = httpsMode.ToString().Equals(HttpsMode.Always.ToString()) ? "https" : "http";
                string baseUrl = website.DomainName.Split(',').FirstOrDefault();
                expandoObject.ContentBaseUrl = baseUrl.StartsWith("http") ? baseUrl : string.Format("{0}://{1}", secureMode, baseUrl);
                #endregion
                List<string> toList = UtilHelper.GetEmailToList(expandoObject.ToEmail);

                EmailList emailList = unitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName(emailListName, string.Empty, string.Empty);
                if (emailList == null)
                {              
                    return;
                }

                var subject = string.Format(emailList.Subject, expandoObject.OrderNumber);

                jobLogger.Info(string.Format("Sending email for Email List {0} of order number {1}", emailListName, expandoObject.OrderNumber));
                emailService.SendEmailList(emailList.Id, toList, expandoObject, subject, unitOfWork, website.Id);
            }
            catch (Exception ex)
            {
                jobLogger.Error(string.Format("Error in Sending email for Email List {0} of order number {1}", emailListName, expandoObject.OrderNumber));
                jobLogger.Error(ex.StackTrace.ToString());
            }
        }
    }
}
