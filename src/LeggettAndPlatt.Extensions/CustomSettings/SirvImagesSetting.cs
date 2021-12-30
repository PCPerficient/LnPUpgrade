using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "Sirv 360 Images Setting")]
    public class SirvImagesSetting : BaseSettingsGroup
    {

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Sirv Script URL", DisplayName = "Sirv Script URL", IsGlobal = true)]
        public virtual string SirvScriptUrl
        {
            get
            {
                return this.GetValue<string>("https://scripts.sirv.com/sirv.js", nameof(SirvScriptUrl));
            }
        }

    }
}
