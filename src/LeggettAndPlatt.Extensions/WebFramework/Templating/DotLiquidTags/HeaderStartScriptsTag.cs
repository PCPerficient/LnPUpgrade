using DotLiquid;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags
{
   public class HeaderStartScriptsTag : Tag
    {
        protected string settingName;
        private string arg1 = string.Empty;
        public override void Initialize(string tagName, string markup, List<string> tokens)
        {
            markup = markup.Trim();
            this.settingName = LoadHeaderStartScript();
            base.Initialize(tagName, markup, tokens);
        }

        private string LoadHeaderStartScript()
        {
            return @"<script type='text/javascript' src='https://cdn.cookielaw.org/consent/6001660a-de58-461f-ab9b-b48b811ff217/OtAutoBlock.js'></script>
    <script src='https://cdn.cookielaw.org/consent/6001660a-de58-461f-ab9b-b48b811ff217/otSDKStub.js'  type='text/javascript' charset='UTF-8' data-domain-script='6001660a-de58-461f-ab9b-b48b811ff217'></script>
    <script type='text/javascript'>function OptanonWrapper() { }</script>";
        }

        public override void Render(Context context, TextWriter result)
        {
            result.Write(this.settingName);
        }
    }
}
