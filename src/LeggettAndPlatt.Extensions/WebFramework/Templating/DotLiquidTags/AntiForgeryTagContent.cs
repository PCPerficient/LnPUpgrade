using DotLiquid;
using Insite.Common.Dependencies;
using Insite.WebFramework.Content;
using Insite.WebFramework.Content.Interfaces;
using Insite.WebFramework.Mvc;
using Insite.WebFramework.Mvc.Extensions;
using System;
using System.Collections.Generic;
using System.IO;
//using System;
//using System.Collections.Generic;
//using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;

namespace LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags
{
    public class AntiForgeryTagContent : Tag
    {
        protected string settingName;
        private string arg1 = string.Empty;
        public override void Initialize(string tagName, string markup, List<string> tokens)
        {
            markup = markup.Trim();
            this.settingName = RequestVerificationToken();
            base.Initialize(tagName, markup, tokens);
        }

        public override void Render(Context context, TextWriter result)
        {
            result.Write(this.settingName);
        }

        public static string RequestVerificationToken()
        {
            return String.Format("antiforgerytokencontent={0}", GetTokenHeaderValue());
        }

        private static string GetTokenHeaderValue()
        {
            string cookieToken, formToken;
            System.Web.Helpers.AntiForgery.GetTokens(null, out cookieToken, out formToken);
            return cookieToken + ":" + formToken;
        }
    }
}
