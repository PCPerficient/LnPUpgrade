using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "Common Settings")]
    public class CommonSettings : BaseSettingsGroup
    {
        [SettingsField(DisplayName = "Error Emails Send To", Description = "Error Emails Send To(comma seperated multiple emails)", IsGlobal = false)]
        public virtual string ErrorEmailsSendTo
        {
            get
            {
                return this.GetValue<string>("", nameof(ErrorEmailsSendTo));
            }
        }

        [SettingsField(DisplayName = "Exception Error Email Active", Description = "Notify the Leggett & Platt team of unexpected failure using email.", IsGlobal = false)]
        public virtual bool ExceptionErrorEmailActive
        {
            get
            {
                return this.GetValue<bool>(true, nameof(ExceptionErrorEmailActive));
            }
        }

        [SettingsField(DisplayName = "Disable Shipping Display", Description = "By enabling this customer not able to see any Shipping related Info.", IsGlobal = false)]
        public virtual bool DisableShippingDisplay
        {
            get
            {
                return this.GetValue<bool>(true, nameof(DisableShippingDisplay));
            }
        }

        [SettingsField(DisplayName = "Display Promotion Code Form in ReviewAndPay Page", Description = "By disabling this User will not able to see Promotion Code Form in ReviewAndPay Page", IsGlobal = false)]
        public virtual bool DisplayPromotionCodeFormReviewAndPayPage
        {
            get
            {
                return this.GetValue<bool>(false, nameof(DisplayPromotionCodeFormReviewAndPayPage));
            }
        }

        [SettingsField(DisplayName = "Enable Debug Mode",
           Description = "Display information with details to help troubleshoot and debug on the website and source code",
           IsGlobal = false)]

        public virtual bool DebugMode
        {
            get
            {
                return this.GetValue<bool>(false, nameof(DebugMode));
            }
        }
        [SettingsField(DisplayName = "Cross Site Scripting Validation Charecters", Description = "Validate the special charecters", IsGlobal = true)]
        public virtual string CrossSiteScriptingValidationCharecters
        {
            get
            {
                return this.GetValue<string>("/[<>“‘%;)(&+]/", nameof(CrossSiteScriptingValidationCharecters));
            }
        }
    }
}
