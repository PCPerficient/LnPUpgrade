using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(Description = "", Label = "Google ReCaptcha Setting", PrimaryGroupName = "Custom Settings")]
    public class RecaptchaSetting : BaseSettingsGroup
    {
        [SettingsField(Description = "When set to YES, requires users who are not signed in to validate authenticity using reCaptcha on any pages that can generate emails.", DisplayName = "Enable ReCaptcha", IsGlobal = false)]
        public virtual bool EnableReCaptcha => this.GetValue<bool>(false, nameof(EnableReCaptcha));

        [SettingsField(Description = "", DisplayName = "ReCaptcha Site Key", IsEncrypted = true, IsGlobal = false)]
        [SettingsFieldDependency(typeof(RecaptchaSetting), "EnableReCaptcha", "true", true)]
        public virtual string ReCaptchaSiteKey => this.GetValue<string>(string.Empty, nameof(ReCaptchaSiteKey));

        [SettingsField(Description = "", DisplayName = "ReCaptcha Secret Key", IsEncrypted = true, IsGlobal = false)]
        [SettingsFieldDependency(typeof(RecaptchaSetting), "EnableReCaptcha", "true", true)]
        public virtual string ReCaptchaSecretKey => this.GetValue<string>(string.Empty, nameof(ReCaptchaSecretKey));
    }
}
