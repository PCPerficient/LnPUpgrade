using System;
using System.Linq;
using System.Web.Helpers;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

namespace LeggettAndPlatt.Extensions.Extensions
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true, Inherited = true)]
    public class ValidateAntiForgeryAngular : ActionFilterAttribute, IActionFilter
    {
        public override void OnActionExecuting(HttpActionContext filterContext)
        {
            var headers = filterContext.Request.Headers;

            string cookieToken = null;
            string formToken = null;

            if (headers.Contains("RequestVerificationToken") && headers.GetValues("RequestVerificationToken") != null)
            {

                var rvt = headers.GetValues("RequestVerificationToken")?.FirstOrDefault();

                if (rvt != null)
                {
                    string[] tokens = rvt.Split(':');
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
            else
            {
                throw new System.Web.Mvc.HttpAntiForgeryException("Missing AntiForgeryToken.");
            }
        }
    }
}
