// --------------------------------------------------------------------------------------------------------------------
// <copyright file="Global.asax.cs" company="Insite Software">
//   Copyright © 2019. Insite Software. All rights reserved.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------
using Insite.WebFramework.Mvc;
using InsiteCommerce.Web.App_Start;
using System;
using System.Security.Claims;
using System.Web.Helpers;
using System.Web.Mvc;
namespace InsiteCommerce.Web
{
#pragma warning disable SA1649 // File name must match first type name
    public class MvcApplication : Insite.WebFramework.Mvc.MvcApplication
#pragma warning restore SA1649 // File name must match first type name
    {
        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {
            var identity = System.Web.HttpContext.Current.User?.Identity as System.Security.Claims.ClaimsIdentity ?? null;
            if (identity != null && identity.Name != null && (identity.Name == "Anonymous" || (!identity.HasClaim(x => x.Type == ClaimTypes.NameIdentifier && x.Value == identity.Name))))
            {
               
                AntiForgeryConfig.UniqueClaimTypeIdentifier = ClaimTypes.NameIdentifier;
            }
        }

        protected override void Application_Start()
        {
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);

            ViewEngines.Engines.Clear();
            ViewEngines.Engines.Add((IViewEngine)new CSharpRazorViewEngine());
            AntiForgeryConfig.SuppressIdentityHeuristicChecks = true;
        }
    }
}