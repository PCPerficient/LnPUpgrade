using IdentityServer3.AccessTokenValidation;
using IdentityServer3.Core.Configuration;
using IdentityServer3.Core.Logging;
using Insite.Common.Dependencies;
using Insite.Common.Providers;
using Insite.Core.BootStrapper;
using Insite.Core.Interfaces.BootStrapper;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Providers;
using Insite.Core.Security;
using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups.SystemSettings;
using Insite.Data.Entities;
using Insite.IdentityServer;
using Insite.IdentityServer.AspNetIdentity;
using Insite.IdentityServer.Options;
using Insite.IdentityServer.Startup;
using Insite.IdentityServer.SystemSettings;
using Insite.WebFramework.Mvc;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;
using Microsoft.Owin.Infrastructure;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.DataProtection;
using Microsoft.Owin.Security.Facebook;
using Microsoft.Owin.Security.Google;
using Microsoft.Owin.Security.OAuth;
using Microsoft.Owin.Security.OpenIdConnect;
using Microsoft.Owin.Security.WsFederation;
using Newtonsoft.Json.Linq;
using Owin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Net.Http;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Helpers;
using System.Web.Http;

namespace LeggettAndPlatt.Extensions.Modules.IdentityServer.Startup
{
    [BootStrapperOrder(25)]
    public class ConfigureIdentityServer : IStartupTask, IMultiInstanceDependency, IDependency, IExtension
    {
        public ConfigureIdentityServer(SecuritySettings securitySettings)
        {
            DbMigrations.Run("identity");
            LogProvider.SetCurrentLogProvider((ILogProvider)new NoopLogProvider());
            CookieAuthenticationOptions authenticationOptions = new CookieAuthenticationOptions();
            authenticationOptions.AuthenticationType = "ApplicationCookie";
            authenticationOptions.LoginPath = new PathString("/RedirectTo/SignInPage");
            authenticationOptions.ExpireTimeSpan = TimeSpan.FromMinutes((double)securitySettings.SiteTimeoutMinutes);
            authenticationOptions.Provider = (ICookieAuthenticationProvider)new CookieAuthenticationProvider()
            {
                OnValidateIdentity = SecurityStampValidator.OnValidateIdentity<IdentityUserManager, IdentityUser>(TimeSpan.FromMinutes((double)securitySettings.SiteTimeoutMinutes), (Func<IdentityUserManager, IdentityUser, Task<ClaimsIdentity>>)((manager, user) => manager.CreateIdentityAsync(user, "ApplicationCookie")))
            };
            authenticationOptions.CookieManager = (ICookieManager)new PreferAccessTokenCookieManager();
            SecurityOptions.CookieOptions = authenticationOptions;
            ConfigureIdentityServer.ConfigureIdentityServerOptions();
            AntiForgeryConfig.UniqueClaimTypeIdentifier = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name";
        }

        private static void ConfigureIdentityServerOptions()
        {
            string identityServerUrl = IdentityServerUrlProvider.GetIdentityServerUrl();
            SecurityOptions.IssuerUri = identityServerUrl.IsBlank() ? "http://www.dummy.com" : identityServerUrl;
            SecurityOptions.RequireSsl = AppSettingProvider.Current["IdentityServerRequireSsl"].EqualsIgnoreCase("true");
        }

        public void Run(IAppBuilder app, HttpConfiguration config)
        {
            app.CreatePerOwinContext<Insite.IdentityServer.AspNetIdentity.IdentityDbContext>(new Func<Insite.IdentityServer.AspNetIdentity.IdentityDbContext>(Insite.IdentityServer.AspNetIdentity.IdentityDbContext.Create));
            app.CreatePerOwinContext<IdentityUserManager>(new Func<IdentityFactoryOptions<IdentityUserManager>, IOwinContext, IdentityUserManager>(IdentityUserManager.Create));
            app.CreatePerOwinContext<IdentitySignInManager>(new Func<IdentityFactoryOptions<IdentitySignInManager>, IOwinContext, IdentitySignInManager>(IdentitySignInManager.Create));
            app.UseKentorOwinCookieSaver();
            IdentityServerBearerTokenAuthenticationOptions adminTokenOptions = new IdentityServerBearerTokenAuthenticationOptions()
            {
                Authority = SecurityOptions.IssuerUri,
                RequiredScopes = (IEnumerable<string>)new string[1]
              {
          "isc_admin_api"
              },
                NameClaimType = "preferred_username",
                RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role",
                TokenProvider = (IOAuthBearerAuthenticationProvider)new MixedOAuthBearerAuthenticationProvider(),
                IssuerName = SecurityOptions.IssuerUri,
                SigningCertificate = Certificate.Get(),
                ValidationMode = ValidationMode.Local
            };
            MapExtensions.Map(app, "/admin", (Action<IAppBuilder>)(admin =>
            {
                admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions);
                admin.MapSignalR();
            }));
            MapExtensions.Map(app, "/secureElmah", (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            MapExtensions.Map(app, "/userfiles/_system", (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            MapExtensions.Map(app, "/api/v1/admin", (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            MapExtensions.Map(app, "/contentadmin", (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            MapExtensions.Map(app, "/webpageconverter", (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            foreach (string micrositeName in (IEnumerable<string>)ConfigureIdentityServer.GetMicrositeNames())
                MapExtensions.Map(app, "/" + micrositeName + "/contentadmin", (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            foreach (string authenticationPath in SiteStartup.Instance.GetAdditionalAdminAuthenticationPaths())
                MapExtensions.Map(app, authenticationPath, (Action<IAppBuilder>)(admin => admin.UseIdentityServerBearerTokenAuthentication(adminTokenOptions)));
            app.UseIdentityServerBearerTokenAuthentication(new IdentityServerBearerTokenAuthenticationOptions()
            {
                Authority = SecurityOptions.IssuerUri,
                RequiredScopes = (IEnumerable<string>)new string[1]
              {
          "iscapi"
              },
                NameClaimType = "preferred_username",
                RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role",
                TokenProvider = (IOAuthBearerAuthenticationProvider)new MixedOAuthBearerAuthenticationProvider(),
                IssuerName = SecurityOptions.IssuerUri,
                SigningCertificate = Certificate.Get(),
                ValidationMode = ValidationMode.Local
            });
            app.UseCookieAuthentication(SecurityOptions.CookieOptions);
            app.UseExternalSignInCookie("ExternalCookie");
            MapExtensions.Map(app, "/identity", (Action<IAppBuilder>)(identityApp => identityApp.UseIdentityServer(new IdentityServerOptions()
            {
                SiteName = "Insite Commerce - Identity Server",
                CspOptions = new CspOptions() { Enabled = false },
                SigningCertificate = Certificate.Get(),
                Factory = CustomFactory.Configure(ConnectionStringProvider.Current.ConnectionStringName),
                AuthenticationOptions = new IdentityServer3.Core.Configuration.AuthenticationOptions()
                {
                    IdentityProviders = new Action<IAppBuilder, string>(ConfigureIdentityServer.ConfigureIdentityProviders)
                },
                IssuerUri = SecurityOptions.IssuerUri,
                RequireSsl = SecurityOptions.RequireSsl
            })));
            IdentityUserManager.DataProtectionProvider = app.GetDataProtectionProvider();
        }

        private static IList<string> GetMicrositeNames()
        {
            return (IList<string>)DependencyLocator.Current.GetInstance<IUnitOfWorkFactory>().GetUnitOfWork().GetRepository<Website>().GetTable().Select<Website, string>((Expression<Func<Website, string>>)(o => o.MicroSiteIdentifiers)).ToList<string>().SelectMany<string, string>((Func<string, IEnumerable<string>>)(o => (IEnumerable<string>)o.Split(',', ';'))).Select<string, string>((Func<string, string>)(o => o.Trim())).Where<string>((Func<string, bool>)(o => !o.IsBlank())).ToList<string>();
        }

        private static void ConfigureIdentityProviders(IAppBuilder app, string signInAsType)
        {
            ConfigureIdentityServer.ConfigureFacebookLogin(app, signInAsType);
            ConfigureIdentityServer.ConfigureGoogleLogin(app, signInAsType);
            ConfigureIdentityServer.ConfigureWindowsAuthentication(app, signInAsType);
            ConfigureIdentityServer.ConfigureOpenIdConnectAuthentication(app, signInAsType);
        }

        private static void ConfigureGoogleLogin(IAppBuilder app, string signInAsType)
        {
            GoogleSsoSettings googleSsoSettings = SettingsGroupProvider.Current.Get<GoogleSsoSettings>(new Guid?());
            if (!googleSsoSettings.Enabled)
                return;
            string clientId = googleSsoSettings.ClientId;
            string clientSecret = googleSsoSettings.ClientSecret;
            if (clientId.IsBlank() || clientSecret.IsBlank())
                return;
            IAppBuilder app1 = app;
            GoogleOAuth2AuthenticationOptions options = new GoogleOAuth2AuthenticationOptions();
            options.Caption = "Google";
            options.ClientId = clientId;
            options.ClientSecret = clientSecret;
            options.SignInAsAuthenticationType = signInAsType;
            options.AuthenticationType = "Google";
            app1.UseGoogleAuthentication(options);
        }

        private static void ConfigureFacebookLogin(IAppBuilder app, string signInAsType)
        {
            FacebookSsoSettings facebookSsoSettings = SettingsGroupProvider.Current.Get<FacebookSsoSettings>(new Guid?());
            if (!facebookSsoSettings.Enabled)
                return;
            string appId = facebookSsoSettings.AppId;
            string appSecret = facebookSsoSettings.AppSecret;
            if (appId.IsBlank() || appSecret.IsBlank())
                return;
            FacebookAuthenticationOptions authenticationOptions = new FacebookAuthenticationOptions();
            authenticationOptions.AppId = appId;
            authenticationOptions.AppSecret = appSecret;
            authenticationOptions.Caption = "Facebook";
            authenticationOptions.SignInAsAuthenticationType = signInAsType;
            authenticationOptions.AuthenticationType = "Facebook";
            authenticationOptions.Provider = (IFacebookAuthenticationProvider)new FacebookAuthenticationProvider()
            {
                //OnAuthenticated = (Func<FacebookAuthenticatedContext, Task>)(context =>
                //{
                //    foreach (KeyValuePair<string, JToken> keyValuePair in context.User)
                //    {
                //        string key = keyValuePair.Key;
                //        if (!(key == "first_name"))
                //        {
                //            if (key == "last_name")
                //                context.Identity.AddClaim(new Claim("family_name", keyValuePair.Value.ToString(), "XmlSchemaString", "Facebook"));
                //        }
                //        else
                //            context.Identity.AddClaim(new Claim("given_name", keyValuePair.Value.ToString(), "XmlSchemaString", "Facebook"));
                //    }
                //    int num = await Task.FromResult<bool>(false) ? 1 : 0;
                //})
            };
            authenticationOptions.BackchannelHttpHandler = (HttpMessageHandler)new ConfigureIdentityServer.FacebookBackChannelHandler();
            authenticationOptions.UserInformationEndpoint = "https://graph.facebook.com/v2.8/me?fields=id,name,email,first_name,last_name";
            FacebookAuthenticationOptions options = authenticationOptions;
            options.Scope.Add("email");
            options.Scope.Add("public_profile");
            app.UseFacebookAuthentication(options);
        }

        private static void ConfigureWindowsAuthentication(IAppBuilder app, string signInAsType)
        {
            WindowsSsoSettings windowsSsoSettings = SettingsGroupProvider.Current.Get<WindowsSsoSettings>(new Guid?());
            if (!windowsSsoSettings.Enabled || windowsSsoSettings.MetadataUrl.IsBlank())
                return;
            WsFederationAuthenticationOptions authenticationOptions = new WsFederationAuthenticationOptions();
            authenticationOptions.AuthenticationType = "Windows";
            authenticationOptions.Caption = "Windows";
            authenticationOptions.SignInAsAuthenticationType = signInAsType;
            authenticationOptions.MetadataAddress = windowsSsoSettings.MetadataUrl;
            authenticationOptions.Wtrealm = SecurityOptions.IssuerUri;
            WsFederationAuthenticationOptions wsFederationOptions = authenticationOptions;
            app.UseWsFederationAuthentication(wsFederationOptions);
        }

        private static void ConfigureOpenIdConnectAuthentication(IAppBuilder app, string signInAsType)
        {
            OpenIdConnectSsoSettings connectSsoSettings = SettingsGroupProvider.Current.Get<OpenIdConnectSsoSettings>(new Guid?());
            if (!connectSsoSettings.Enabled || connectSsoSettings.Authority.IsBlank())
                return;
            OpenIdConnectAuthenticationOptions authenticationOptions = new OpenIdConnectAuthenticationOptions();
            authenticationOptions.AuthenticationType = "OpenIdConnect";
            authenticationOptions.Caption = connectSsoSettings.Caption;
            authenticationOptions.SignInAsAuthenticationType = signInAsType;
            authenticationOptions.ClientId = connectSsoSettings.ClientId;
            authenticationOptions.ClientSecret = connectSsoSettings.ClientSecret;
            authenticationOptions.Authority = connectSsoSettings.Authority;
            authenticationOptions.Scope = "openid profile email";
            authenticationOptions.AuthenticationMode = AuthenticationMode.Passive;
            OpenIdConnectAuthenticationOptions openIdConnectOptions = authenticationOptions;
            app.UseOpenIdConnectAuthentication(openIdConnectOptions);
        }

        private class FacebookBackChannelHandler : HttpClientHandler
        {
            protected override async Task<HttpResponseMessage> SendAsync(
              HttpRequestMessage request,
              CancellationToken cancellationToken)
            {
                if (!request.RequestUri.AbsolutePath.Contains("/oauth"))
                    request.RequestUri = new Uri(request.RequestUri.AbsoluteUri.Replace("?access_token", "&access_token"));
                return await base.SendAsync(request, cancellationToken);
            }
        }
    }
}
