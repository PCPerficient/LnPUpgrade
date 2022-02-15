using Insite.Core.Interfaces.Data;
using Insite.Data.Entities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Linq.Expressions;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Common
{
    public class ConstantsUtil
    {
        public const char MailSeperator = ';';
        public const string WebsiteEnterpriseCodeMapping = "WebsiteEnterpriseCodeMapping";
        public const string OrderConfirmationTableName = "2OrderConfirmation";
        public const string ShipmentTableName = "3Shipment";
        public const string OrderCancellationTableName = "4OrderCancellation";
        public const string EmailListName = "EmailListName";
    }

    public class UtilHelper
    {
        public static object GetColumnValue(DataRow row, string column)
        {
            return row.Table.Columns.Contains(column) ? Convert.ToString(row[column]) : string.Empty;
        }

        public static List<string> GetEmailToList(dynamic toValue)
        {
            if (string.IsNullOrEmpty(toValue)) return new List<string>();

            List<string> toValues = new List<string>();
            char[] delimiters = new char[] { ConstantsUtil.MailSeperator };
            string[] parts = toValue.Split(delimiters,
                             StringSplitOptions.RemoveEmptyEntries);
            if (parts != null && parts.Length > 0)
                parts.ToList().ForEach(a => toValues.Add(a));

            return toValues;
        }

        public static string GetEmailListNameFromJobSteps(dynamic mailObject, IntegrationJob integrationJob, string jobStepName)
        {
            var enterpriseCode = mailObject.EnterpriseCode;
            if (string.IsNullOrEmpty(enterpriseCode)) return string.Empty;

            var jobStep = integrationJob.JobDefinition.JobDefinitionSteps.FirstOrDefault(a => a.Name.Equals(jobStepName, StringComparison.OrdinalIgnoreCase));
            if (jobStep == null) return string.Empty;

            var emailListParam = jobStep.JobDefinitionStepParameters.FirstOrDefault(a => a.Name.Equals(ConstantsUtil.EmailListName));
            if (emailListParam == null || string.IsNullOrEmpty(emailListParam.DefaultValue)) return string.Empty;

            return string.Format("{0}_{1}", enterpriseCode, emailListParam.DefaultValue);
        }

        public static Website GetWebsiteBasedOnEnterpriseCode(IUnitOfWork unitOfWork, string enterpriseCode)
        {
            try
            {
                IRepository<SystemSetting> systemSettingRepository = unitOfWork.GetRepository<SystemSetting>();
                SystemSetting systemSetting = systemSettingRepository.GetTable().FirstOrDefault((Expression<Func<SystemSetting, bool>>)(o => o.Value == enterpriseCode));
                if (systemSetting != null && systemSetting.Website != null)
                {
                    return systemSetting.Website;
                }
                //IRepository<SystemList> repository = unitOfWork.GetRepository<SystemList>();
                //var firstOrDefault = repository.GetTable().FirstOrDefault((Expression<Func<SystemList, bool>>)(o => o.Name == ConstantsUtil.WebsiteEnterpriseCodeMapping));
                //if (firstOrDefault != null)
                //{
                //    var singleOrDefault = firstOrDefault.Values.SingleOrDefault(v => v.Name == enterpriseCode);
                //    if (singleOrDefault != null)
                //    {
                //        var website = unitOfWork.GetRepository<Website>().GetTable().FirstOrDefault(a => a.Name.Equals(singleOrDefault.Description, StringComparison.OrdinalIgnoreCase));
                //        if (website != null && website != null)
                //            return website;
                //    }
                //}
                return null;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
    }

    public enum JobStepNames
    {
        OrderConfirmation,
        Shipment,
        OrderCancellation
    }
}
