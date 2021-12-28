using DotLiquid;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags
{
   public class HeaderScripts:Tag
    {

        protected string settingName;
        private string arg1 = string.Empty;
        public override void Initialize(string tagName, string markup, List<string> tokens)
        {
            markup = markup.Trim();
            this.settingName = LoadFontsInHeader();
            base.Initialize(tagName, markup, tokens);
        }

        private string LoadFontsInHeader()
        {
            return $"<link href='https://fonts.googleapis.com/css?family=Roboto:300,300i,400,500,700,700i' rel='stylesheet'>";
        }

        public override void Render(Context context, TextWriter result)
        {
            result.Write(this.settingName);
        }
    }
}
