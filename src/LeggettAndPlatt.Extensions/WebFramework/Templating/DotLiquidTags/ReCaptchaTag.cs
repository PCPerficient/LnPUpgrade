using System;
using System.Collections.Generic;
using DotLiquid;
using Insite.Common.Dependencies;
using Insite.Core.Context;
using Insite.Data.Entities.Dtos;
using System.IO;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using LeggettAndPlatt.Extensions.Plugins.ReCaptcha;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Core.Providers;

namespace LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags
{
    class ReCaptchaTag : Tag
  {
    private string location;
    private static readonly Regex LocationRegex = new Regex("^(['\"])([a-zA-Z]+)\\1$");

    public override void Initialize(string tagName, string markup, List<string> tokens)
    {
        markup = markup.Trim();
        if (!ReCaptchaTag.LocationRegex.IsMatch(markup))
            throw new ArgumentException("The markup for the reCaptcha tag was: " + markup + ". It is expected to be of the form (use single or double quotes) '[Location]'");
        this.location = ReCaptchaTag.LocationRegex.Match(markup).Groups[2].Value;
        base.Initialize(tagName, markup, tokens);
    }

    public override void Render(DotLiquid.Context context, TextWriter result)
    {
      
      
        IReCaptchaService instance = DependencyLocator.Current.GetInstance<IReCaptchaService>();
        if (instance.CheckVerified())
            return;
        TagBuilder tagBuilder1 = new TagBuilder("div")
        {
            Attributes = {
          {
            "id",
            "reCaptcha" + this.location
          },
          {
            "data-sitekey",
            DependencyLocator.Current.GetInstance<RecaptchaSetting>().ReCaptchaSiteKey
          },
          /*{
            "data-size",
            "invisible"
          },*/
                {
                    "class",
                    "g-recaptcha"
                }
        }
        };
        result.Write(tagBuilder1.ToString((TagRenderMode)0));
        TagBuilder tagBuilder2 = new TagBuilder("span")
        {
            Attributes = {
          {
            "id",
            "reCaptcha" + this.location + "Error"
          },
          {
            "class",
            "field-validation-error"
          },
          {
            "style",
            "display: none;"
          }
        },
            InnerHtml = CustomMessageProvider.Current.ReCaptcha_RequiredErrorMessage
        };
        result.Write(tagBuilder2.ToString((TagRenderMode)0));
        string scripttag = "<script src='https://www.google.com/recaptcha/api.js?render=explicit' async defer></script>";
        result.Write(scripttag);
        
        }
}
}
 