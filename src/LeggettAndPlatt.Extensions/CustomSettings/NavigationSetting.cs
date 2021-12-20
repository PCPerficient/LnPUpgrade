using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "Navigation Settings")]
    public class NavigationSetting : BaseSettingsGroup
    {
        [SettingsField(DisplayName = "Display Navigation Link", Description = "Navigation Links", IsGlobal = false)]

        public virtual bool DisplayNavigationLinks
        {
            get
            {
                return this.GetValue<bool>(true, nameof(DisplayNavigationLinks));
            }
        }

        [SettingsField(DisplayName = "Display Breadcrumbs Link in PDP", Description = "Breadcrumbs", IsGlobal = false)]

        public virtual bool DisplayBreadcrumbsInPDP
        {
            get
            {
                return this.GetValue<bool>(true, nameof(DisplayBreadcrumbsInPDP));
            }
        }
    }
}
