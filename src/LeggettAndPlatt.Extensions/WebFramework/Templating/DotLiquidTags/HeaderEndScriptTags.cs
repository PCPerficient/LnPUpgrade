using DotLiquid;
using Insite.Core.SystemSetting;
using LeggettAndPlatt.Extensions.CustomSettings;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags
{
  public  class HeaderEndScriptTags:Tag
    {
        protected string settingName;
        private string arg1 = string.Empty;
        public override void Initialize(string tagName, string markup, List<string> tokens)
        {
            markup = markup.Trim();
            this.settingName = LoadHeaderEndScript();
            base.Initialize(tagName, markup, tokens);
        }

        private string LoadHeaderEndScript()
        {
            	    
                var elavonSettings = SettingsGroupProvider.Current.Get<ElavonSettings>();
                var elavonTransactionUrl = (elavonSettings.ElavonTestMode) ? elavonSettings.ElavonDemoTransactionUrl : elavonSettings.ElavonProdTransactionUrl;
              var elavon3DS2JSUrl = (elavonSettings.ElavonTestMode) ? elavonSettings.ElavonDemo3DS2JSUrl : elavonSettings.ElavonProd3DS2JSUrl;
           
             return $"<script type = 'text/javascript' src = '{elavonTransactionUrl}' ></script><script type = 'text/javascript' src = '{elavon3DS2JSUrl}' ></script>";
        }

        public override void Render(Context context, TextWriter result)
        {
            result.Write(this.settingName);
        }
    }
}
