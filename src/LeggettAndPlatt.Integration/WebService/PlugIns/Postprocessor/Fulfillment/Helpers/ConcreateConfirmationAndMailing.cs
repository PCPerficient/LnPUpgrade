using Insite.Integration.WebService.Interfaces;
using LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Common;
using System;
using System.Data;
using System.Dynamic;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Helpers
{
    public class ConcreateConfirmationAndMailing : AbstractFullfillmentAndMailing
    {
        public ExpandoObject BuildExpandoObject(IJobLogger jobLogger, DataTable dtModel)
        {
            try
            {
                dynamic emailModel = base.BaseBuildObject(jobLogger, dtModel);

                emailModel.ShipToFirstName = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToFirstName");
                emailModel.ShipToLastName = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToLastName");
                emailModel.ShipToEmail = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToEmail");
                emailModel.ShipToCompany = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToCompany");
                emailModel.ShipToAddress1 = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToAddress1");
                emailModel.ShipToAddress2 = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToAddress2");
                emailModel.ShipToCity = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToCity");
                emailModel.ShipToState = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToState");
                emailModel.ShipToCountry = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToCountry");
                emailModel.ShipToPostalCode = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToPostalCode");
                emailModel.ShipToPhone = UtilHelper.GetColumnValue(dtModel.Rows[0], "ShipToPhone");

                emailModel.BillToFirstName = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToFirstName");
                emailModel.BillToLastName = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToLastName");
                emailModel.BillToCompany = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToCompany");
                emailModel.BillToEmail = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToEmail");
                emailModel.BillToAddress1 = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToAddress1");
                emailModel.BillToAddress2 = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToAddress2");
                emailModel.BillToCity = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToCity");
                emailModel.BillToState = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToState");
                emailModel.BillToCountry = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToCountry");
                emailModel.BillToPostalCode = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToPostalCode");
                emailModel.BillToPhone = UtilHelper.GetColumnValue(dtModel.Rows[0], "BillToPhone");

                return emailModel;
            }
            catch (Exception ex)
            {
                jobLogger.Error("Error in building email model for order confirmation");
                jobLogger.Error(ex.StackTrace.ToString());
                return new ExpandoObject();
            }
        }
    }
}
