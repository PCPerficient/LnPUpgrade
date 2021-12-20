using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(Label = "PIM Settings", PrimaryGroupName = "Custom Settings")]
    public class PIMSettings : BaseSettingsGroup
    {
        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Comma separated PIM attribute names that are used to create Variant Trait", DisplayName = "Variant Attribute Name", IsGlobal = true)]
        public virtual string VariantAttributeName
        {
            get
            {
                return this.GetValue<string>("ItemSizeName,ItemColorName", nameof(VariantAttributeName));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "InSite Location where PIM images are available.", DisplayName = "Image Path Prefix", IsGlobal = true)]
        public virtual string ImagePathPrefix
        {
            get
            {
                return this.GetValue<string>("/UserFiles/Images/PIMImages/", nameof(ImagePathPrefix));
            }
        }
    }
}
