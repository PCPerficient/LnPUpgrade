using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "Abandoned Cart Setting")]
    public class AbandonedCartSetting : BaseSettingsGroup
    {
        [SettingsField(DisplayName = "Abandoned Cart Interval Time In Second", Description = "Interval Time", IsGlobal = false)]

        public virtual string AbandonedCartIntervalTimeInSecond
        {
            get
            {
                return this.GetValue<string>("60", nameof(AbandonedCartIntervalTimeInSecond));
            }
        }
        [SettingsField(DisplayName = "Abandoned Cart Number Of Times Popup Prompt", Description = "Abandoned Cart No Of Times Popup Prompt", IsGlobal = false)]

        public virtual string AbandonedCartNoOfTimesPopupPrompt
        {
            get
            {
                return this.GetValue<string>("5", nameof(AbandonedCartNoOfTimesPopupPrompt));
            }
        }
        [SettingsField(DisplayName = "Abandoned Cart Popup Exclude Page URL", Description = "Abandoned Cart Popup Exclude Page URL", IsGlobal = false)]

        public virtual string AbandonedCartPopupPageURL
        {
            get
            {
                return this.GetValue<string>("", nameof(AbandonedCartPopupPageURL));
            }
        }
        [SettingsField(DisplayName = "Disabled Abandoned Cart Popup", Description = "Disabled Abandoned Cart Popup", IsGlobal = false)]

        public virtual bool DisabledAbandonedCartPopup
        {
            get
            {
                return this.GetValue<bool>(false, nameof(DisabledAbandonedCartPopup));
            }
        }
    }
}
