using Insite.Common.Dependencies;
using Insite.Core.Interfaces.Data;
using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;
using System.Collections.Generic;
using Insite.Data.Entities;
using System.Linq;
namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "Employee Store Settings")]
    public class EmployeeSettings : BaseSettingsGroup
    {
       
        [SettingsField(ControlType = SystemSettingControlType.Dropdown, DisplayName = "Employee Website", Description = "Select website for Employee store.", IsGlobal = true)]
        [PossibleWebsiteValues]
        public virtual string EmployeeWebsiteName
        {
            get
            {
                return this.GetValue<string>(string.Empty, nameof(EmployeeWebsiteName));
            }
        }

        [SettingsField(DisplayName = "Contact Customer Service Url", Description = "Enter Url to direct user to contact customer service.", IsGlobal = true)]
        public virtual string ContactCustomerServiceUrl
        {
            get
            {
                return this.GetValue<string>("/ContactCustomerService", nameof(ContactCustomerServiceUrl));
            }
        }

        [SettingsField(DisplayName = "Reset Password Or Login Url", Description = "Enter Url to direct user to reset password.", IsGlobal = true)]
        public virtual string ResetPasswordOrLoginUrl
        {
            get
            {
                return this.GetValue<string>("/ResetPasswordOrLogin", nameof(ResetPasswordOrLoginUrl));
            }
        }

        [SettingsField(DisplayName = "Activation Email Sent Url", Description = "Enter Url to direct user to notifying activation email being sent.", IsGlobal = true)]
        public virtual string ActivationEmailSentUrl
        {
            get
            {
                return this.GetValue<string>("/ActivationEmailSent", nameof(ActivationEmailSentUrl));
            }
        }

       
    }

    public class PossibleWebsiteValues : Attribute, IPossibleValuesAttribute
    {
        public ICollection<SystemSettingPossibleValueDto> GetOptions()
        { 
            List<SystemSettingPossibleValueDto> list = DependencyLocator.Current.GetInstance<IUnitOfWorkFactory>().GetUnitOfWork().GetRepository<Website>().GetTable().Select(X => new SystemSettingPossibleValueDto() { Name = X.Name,Value = X.Id.ToString().ToLower()}).ToList();           
            return (ICollection<SystemSettingPossibleValueDto>)list;
        }
    }
}
