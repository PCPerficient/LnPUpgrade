using Insite.Integration.WebService.Interfaces;
using System;
using System.Data;
using System.Dynamic;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Helpers
{
    public class ConcreateShipmentAndMailing :AbstractFullfillmentAndMailing
    {
        public ExpandoObject BuildExpandoObject(IJobLogger jobLogger, DataTable dtModel)
        {
            try
            {
                return base.BaseBuildObject(jobLogger, dtModel);
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
