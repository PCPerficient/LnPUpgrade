using System;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;
using System.Web.Routing;

namespace LeggettAndPlatt.Extensions.Extensions
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true, Inherited = true)]
    public class ValidateAntiForgeryForContent : ActionFilterAttribute
    {

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var headers = filterContext.RequestContext.HttpContext.Request.Headers;

            string cookieToken = null;
            string formToken = null;

            if (headers.GetValues("RequestVerificationToken") != null)
            {

                var rvt = headers.GetValues("RequestVerificationToken");

                if (rvt != null)
                {
                    string[] tokens = rvt[0].Split(':');
                    if (tokens.Length == 2)
                    {
                        cookieToken = tokens[0].Trim();
                        formToken = tokens[1].Trim();
                    }
                }
                string newCookietoken, newformToken;
                AntiForgery.GetTokens(cookieToken, out newCookietoken, out newformToken);
                AntiForgery.Validate(newCookietoken ?? cookieToken, newformToken);
            }
            //else
            //{
            //    throw new System.Web.Mvc.HttpAntiForgeryException("Missing AntiForgeryToken.");
            //}

        }
    }
}
