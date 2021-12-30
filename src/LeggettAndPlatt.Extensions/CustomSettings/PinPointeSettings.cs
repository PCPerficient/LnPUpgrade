using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "PinPointe Settings")]
    public class PinPointeSettings : BaseSettingsGroup
    {
        [SettingsField(DisplayName = "User Name", Description = "PinPointe User Name", IsGlobal = false)]    
        public virtual string UserName => this.GetValue("ryan.brashears@leggett.com", "UserName");

        [SettingsField(DisplayName = "User Token", Description = "PinPointe User Token", IsGlobal = false)]
        public virtual string UserToken => this.GetValue("1e16aecdcbca2aeefaac211c2e3a0df8f7d8517d", "UserToken");

        [SettingsField(DisplayName = "Mailing List", Description = "PinPointe Mailing List", IsGlobal = false)]
        public virtual string MailingList => this.GetValue("50", "MailingList");

        [SettingsField(DisplayName = "Tag", Description = "PinPointe Tag", IsGlobal = false)]
        public virtual string Tag => this.GetValue("60", "Tag");

        [SettingsField(DisplayName = "Post URL", Description = "PinPointe Post URL", IsGlobal = false)]
        public virtual string PostURL => this.GetValue("https://lpnews.leggett.com/xml.php", "PostURL");

        [SettingsField(DisplayName = "Enable Log", Description = "PinPointe Enable Log for debugging", IsGlobal = false)]
        public virtual bool EnableLog => this.GetValue(true, "EnableLog");

        [SettingsField(DisplayName = "Pinpoint Error Emails Active", Description = "Pinpoint Error Emails", IsGlobal = false)]
        public virtual bool PinpointErrorEmails
        {
            get
            {
                return this.GetValue<bool>(true, nameof(PinpointErrorEmails));
            }
        }
    }
}
