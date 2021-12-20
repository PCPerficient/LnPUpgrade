using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "AddThis Settings")]
    public class AddThisSetting : BaseSettingsGroup
    {
      
        [SettingsField(DisplayName = "AddThis script URL", Description = "URL for AddThis script to display icons and links to social media.", IsGlobal = false)]

        public virtual string AddThisScriptURL
        {
            get
            {
                return this.GetValue<string>("//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-5b96c31d61a82107", nameof(AddThisScriptURL));
            }
        }
       
    }
}
