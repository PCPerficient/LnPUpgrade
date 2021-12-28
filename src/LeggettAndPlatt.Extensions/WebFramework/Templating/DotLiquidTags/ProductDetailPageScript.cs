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
    public class ProductDetailPageScript:Tag
    {
        protected string settingName;
        private string arg1 = string.Empty;
        public override void Initialize(string tagName, string markup, List<string> tokens)
        {
            markup = markup.Trim();
            this.settingName = LoadPDPScript();
            base.Initialize(tagName, markup, tokens);
        }

        private string LoadPDPScript()
        {

            var addThisScriptURL = SettingsGroupProvider.Current.Get<SirvImagesSetting>().SirvScriptUrl;
            return $"<script async = 'async' src = '{@addThisScriptURL}' type = 'text/javascript' ></script>";
          
        }

        public override void Render(Context context, TextWriter result)
        {
            result.Write(this.settingName);
        }
    }
}
