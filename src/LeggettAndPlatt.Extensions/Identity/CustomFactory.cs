using IdentityModel;
using IdentityServer3.Core.Configuration;
using IdentityServer3.Core.Models;
using IdentityServer3.Core.Services;
using IdentityServer3.Core.Services.Default;
using IdentityServer3.EntityFramework;
using IdentityServer3.EntityFramework.Entities;
using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups.SystemSettings;
using Insite.Data.Extensions;
using Insite.IdentityServer;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IdentityModel.Tokens;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Security.Claims;
using System.Security.Principal;

namespace LeggettAndPlatt.Extensions.Modules.IdentityServer
{
    public static class CustomFactory
    {
        public static readonly EntityFrameworkServiceOptions EntityFrameworkServiceOptions = new EntityFrameworkServiceOptions()
        {
            Schema = "identity"
        };

        /// <summary>The Configure method creates and configures the <see cref="T:IdentityServer3.Core.Configuration.IdentityServerServiceFactory" />.</summary>
        /// <param name="connectionString">The connection String for the .NET Identity databqase.</param>
        /// <returns>The <see cref="T:IdentityServer3.Core.Configuration.IdentityServerServiceFactory" />.</returns>
        public static IdentityServerServiceFactory Configure(
          string connectionString)
        {
            EntityFrameworkServiceOptions.ConnectionString = connectionString;
            new TokenCleanup(EntityFrameworkServiceOptions, 60).Start();
            ConfigureClients(Clients.Get());
            ConfigureScopes(Scopes.Get());
            IdentityServerServiceFactory factory = new IdentityServerServiceFactory();
            factory.RegisterConfigurationServices(EntityFrameworkServiceOptions);
            factory.RegisterOperationalServices(EntityFrameworkServiceOptions);
            factory.ViewService = new DefaultViewServiceRegistration<ViewService>();
            factory.ConfigureUserService(connectionString);
            factory.Register<ICorsPolicyService>(new Registration<ICorsPolicyService>((ICorsPolicyService)new DefaultCorsPolicyService()
            {
                AllowAll = true,
                AllowedOrigins = (ICollection<string>)((IEnumerable<string>)SettingsGroupProvider.Current.Get<SecuritySettings>(new Guid?()).CorsOrigin.Split(',')).ToList<string>()
            }, (string)null));
            return factory;
        }

        public static string GetAdminJsonWebToken(IPrincipal principal, string issuerUri)
        {
            return Factory.GetJsonWebToken(principal, issuerUri, "isc_admin", "isc_admin_api");
        }

        /// <summary>Creates and returns a valid JWT for the supplied <see cref="T:System.Security.Principal.IPrincipal" />.</summary>
        /// <param name="principal">The principal.</param>
        /// <param name="issuerUri">The issuer uri.</param>
        /// <param name="clientId">The client id.</param>
        /// <param name="scope">The scope.</param>
        /// <returns>The <see cref="T:System.String" />.</returns>
        public static string GetJsonWebToken(
          IPrincipal principal,
          string issuerUri,
          string clientId = "isc",
          string scope = "iscapi")
        {
            if (principal == null)
                throw new ArgumentNullException(nameof(principal));
            if (principal.Identity == null)
                throw new ArgumentNullException("Identity");
            if (issuerUri == null)
                throw new ArgumentNullException(nameof(issuerUri));
            ClaimsIdentity claimsIdentity = new ClaimsIdentity(principal.Identity);
            if (!claimsIdentity.Claims.Any<Claim>((Func<Claim, bool>)(c => c.Type.Equals("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"))))
                throw new ArgumentNullException("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier Claim");
            List<Claim> claimList = new List<Claim>()
      {
        new Claim("client_id", clientId),
        new Claim(nameof (scope), scope),
        new Claim("sub", claimsIdentity.Claims.First<Claim>((Func<Claim, bool>) (c => c.Type.Equals("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"))).Value),
        new Claim("amr", "password"),
        new Claim("auth_time", ((IEnumerable<string>) (string.Empty + (object) (DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc)).TotalSeconds).Split('.')).First<string>()),
        new Claim("idp", "idsrv"),
        new Claim("preferred_username", principal.Identity.Name)
      };
            ClaimsPrincipal claimsPrincipal = principal as ClaimsPrincipal;
            if (claimsPrincipal != null)
                claimList.AddRange(claimsPrincipal.Claims.Where<Claim>((Func<Claim, bool>)(c => c.Type.Equals(claimsIdentity.RoleClaimType))).Select<Claim, Claim>((Func<Claim, Claim>)(roleClaim => new Claim("role", roleClaim.Value))));
            X509SigningCredentials signingCredentials = new X509SigningCredentials(Certificate.Get());
            JwtSecurityToken jwtSecurityToken = new JwtSecurityToken(issuerUri, string.Format("{0}resources", (object)(issuerUri + "/")), (IEnumerable<Claim>)claimList, new DateTime?(DateTime.UtcNow), new DateTime?(DateTime.UtcNow.AddSeconds(3600.0)), (SigningCredentials)signingCredentials);
            jwtSecurityToken.Header.Add("kid", (object)Base64UrlEncoder.Encode(signingCredentials.Certificate.GetCertHash()));
            return new JwtSecurityTokenHandler().WriteToken((SecurityToken)jwtSecurityToken);
        }

        /// <summary>Creates and returns a valid JWT for the supplied <see cref="T:System.Security.Principal.IPrincipal" />.</summary>
        /// <param name="principal">The principal.</param>
        /// <param name="issuerUri">The issuer uri.</param>
        /// <returns>The web token or a blank string if unauthenticated or there is an error.</returns>
        /// <remarks>This method will never throw</remarks>
        public static string GetJsonWebTokenSafe(IPrincipal principal, string issuerUri)
        {
            try
            {
                return Factory.GetJsonWebToken(principal, issuerUri, "isc", "iscapi");
            }
            catch
            {
                return string.Empty;
            }
        }

        /// <summary>If no <see cref="T:IdentityServer3.Core.Models.Client" />s exist in the database, this method populates the database with the supplied list of <see cref="T:IdentityServer3.Core.Models.Client" />s.</summary>
        private static void ConfigureClients(IEnumerable<IdentityServer3.Core.Models.Client> clients)
        {
            clients = (IEnumerable<IdentityServer3.Core.Models.Client>)clients.ToArray<IdentityServer3.Core.Models.Client>();
            using (ClientConfigurationDbContext configurationDbContext = new ClientConfigurationDbContext(EntityFrameworkServiceOptions.ConnectionString, EntityFrameworkServiceOptions.Schema))
            {
                ParameterExpression parameterExpression;
                // ISSUE: method reference
                //List<string> existingClients = configurationDbContext.Clients.Select<IdentityServer3.EntityFramework.Entities.Client, string>(Expression.Lambda<Func<IdentityServer3.EntityFramework.Entities.Client, string>>((Expression)Expression.Call(x.ClientId, (MethodInfo)MethodBase.GetMethodFromHandle(__methodref(string.ToLower)), Array.Empty<Expression>()), parameterExpression)).ToList<string>();
                List<string> existingClients = configurationDbContext.Clients.Select(x => x.ClientId.ToLower()).ToList();
                DbSet<IdentityServer3.EntityFramework.Entities.Client> clients1 = configurationDbContext.Clients;
                Expression<Func<IdentityServer3.EntityFramework.Entities.Client, ICollection<ClientScope>>> expand = (Expression<Func<IdentityServer3.EntityFramework.Entities.Client, ICollection<ClientScope>>>)(m => m.AllowedScopes);
                foreach (IdentityServer3.EntityFramework.Entities.Client client1 in (IEnumerable<IdentityServer3.EntityFramework.Entities.Client>)clients1.Expand<IdentityServer3.EntityFramework.Entities.Client, ICollection<ClientScope>>(expand))
                {
                    IdentityServer3.EntityFramework.Entities.Client client = client1;
                    IdentityServer3.Core.Models.Client client2 = clients.FirstOrDefault<IdentityServer3.Core.Models.Client>((Func<IdentityServer3.Core.Models.Client, bool>)(m => string.Equals(m.ClientId, client.ClientId, StringComparison.CurrentCultureIgnoreCase)));
                    if (client2 != null)
                    {
                        IEnumerable<string> existingScopes = client.AllowedScopes.Select<ClientScope, string>((Func<ClientScope, string>)(m => m.Scope));
                        foreach (string str in client2.AllowedScopes.Where<string>((Func<string, bool>)(m => !existingScopes.Contains<string>(m))))
                            client.AllowedScopes.Add(new ClientScope()
                            {
                                Scope = str
                            });
                    }
                }
                foreach (IdentityServer3.EntityFramework.Entities.Client entity in clients.Where<IdentityServer3.Core.Models.Client>((Func<IdentityServer3.Core.Models.Client, bool>)(o => !existingClients.Contains(o.ClientId.ToLower()))).Select<IdentityServer3.Core.Models.Client, IdentityServer3.EntityFramework.Entities.Client>((Func<IdentityServer3.Core.Models.Client, IdentityServer3.EntityFramework.Entities.Client>)(c => CustomFactory.ToClientEntity(c))))
                    configurationDbContext.Clients.Add(entity);
                configurationDbContext.SaveChanges();
            }
        }

        /// <summary>If no <see cref="T:IdentityServer3.Core.Models.Scope" />s exist in the database, this method populates the database with the supplied list of <see cref="T:IdentityServer3.Core.Models.Scope" />s.</summary>
        /// <param name="scopes">The scopes.</param>
        private static void ConfigureScopes(IEnumerable<IdentityServer3.Core.Models.Scope> scopes)
        {
            using (ScopeConfigurationDbContext configurationDbContext = new ScopeConfigurationDbContext(EntityFrameworkServiceOptions.ConnectionString, EntityFrameworkServiceOptions.Schema))
            {
                IQueryable<string> existingScopes = configurationDbContext.Scopes.Select(m => m.Name);
                foreach (IdentityServer3.EntityFramework.Entities.Scope entity in scopes.Where((Func<IdentityServer3.Core.Models.Scope, bool>)(m => !existingScopes.Contains<string>(m.Name))).Select(s => ToScopeEntity(s)))
                    configurationDbContext.Scopes.Add(entity);
                configurationDbContext.SaveChanges();
            }
        }

        private static IdentityServer3.EntityFramework.Entities.Client ToClientEntity(
          IdentityServer3.Core.Models.Client client)
        {
            return new IdentityServer3.EntityFramework.Entities.Client()
            {
                AbsoluteRefreshTokenLifetime = client.AbsoluteRefreshTokenLifetime,
                AccessTokenLifetime = client.AccessTokenLifetime,
                AccessTokenType = client.AccessTokenType,
                AllowAccessToAllGrantTypes = client.AllowAccessToAllCustomGrantTypes,
                AllowAccessToAllScopes = client.AllowAccessToAllScopes,
                AllowClientCredentialsOnly = client.AllowClientCredentialsOnly,
                AllowedCorsOrigins = (ICollection<ClientCorsOrigin>)client.AllowedCorsOrigins.Select<string, ClientCorsOrigin>((Func<string, ClientCorsOrigin>)(o => new ClientCorsOrigin()
                {
                    Origin = o
                })).ToList<ClientCorsOrigin>(),
                AllowedCustomGrantTypes = (ICollection<ClientCustomGrantType>)client.AllowedCustomGrantTypes.Select<string, ClientCustomGrantType>((Func<string, ClientCustomGrantType>)(o => new ClientCustomGrantType()
                {
                    GrantType = o
                })).ToList<ClientCustomGrantType>(),
                AllowedScopes = (ICollection<ClientScope>)client.AllowedScopes.Select<string, ClientScope>((Func<string, ClientScope>)(o => new ClientScope()
                {
                    Scope = o
                })).ToList<ClientScope>(),
                AllowRememberConsent = client.AllowRememberConsent,
                AlwaysSendClientClaims = client.AlwaysSendClientClaims,
                AuthorizationCodeLifetime = client.AuthorizationCodeLifetime,
                Claims = (ICollection<ClientClaim>)client.Claims.Select<Claim, ClientClaim>((Func<Claim, ClientClaim>)(o => new ClientClaim()
                {
                    Type = o.Type,
                    Value = o.Value
                })).ToList<ClientClaim>(),
                ClientId = client.ClientId,
                ClientName = client.ClientName,
                ClientSecrets = (ICollection<ClientSecret>)client.ClientSecrets.Select<Secret, ClientSecret>((Func<Secret, ClientSecret>)(o => new ClientSecret()
                {
                    Description = o.Description,
                    Expiration = o.Expiration,
                    Type = o.Type,
                    Value = o.Value
                })).ToList<ClientSecret>(),
                ClientUri = client.ClientUri,
                Enabled = client.Enabled,
                EnableLocalLogin = client.EnableLocalLogin,
                Flow = client.Flow,
                IdentityProviderRestrictions = (ICollection<ClientIdPRestriction>)client.IdentityProviderRestrictions.Select<string, ClientIdPRestriction>((Func<string, ClientIdPRestriction>)(x => new ClientIdPRestriction()
                {
                    Provider = x
                })).ToList<ClientIdPRestriction>(),
                IdentityTokenLifetime = client.IdentityTokenLifetime,
                IncludeJwtId = client.IncludeJwtId,
                LogoUri = client.LogoUri,
                PostLogoutRedirectUris = (ICollection<ClientPostLogoutRedirectUri>)client.PostLogoutRedirectUris.Select<string, ClientPostLogoutRedirectUri>((Func<string, ClientPostLogoutRedirectUri>)(x => new ClientPostLogoutRedirectUri()
                {
                    Uri = x
                })).ToList<ClientPostLogoutRedirectUri>(),
                PrefixClientClaims = client.PrefixClientClaims,
                RedirectUris = (ICollection<ClientRedirectUri>)client.RedirectUris.Select<string, ClientRedirectUri>((Func<string, ClientRedirectUri>)(x => new ClientRedirectUri()
                {
                    Uri = x
                })).ToList<ClientRedirectUri>(),
                RefreshTokenExpiration = client.RefreshTokenExpiration,
                RefreshTokenUsage = client.RefreshTokenUsage,
                RequireConsent = client.RequireConsent,
                SlidingRefreshTokenLifetime = client.SlidingRefreshTokenLifetime,
                UpdateAccessTokenOnRefresh = client.UpdateAccessTokenClaimsOnRefresh
            };
        }

        private static IdentityServer3.EntityFramework.Entities.Scope ToScopeEntity(IdentityServer3.Core.Models.Scope scope)
        {
            return new IdentityServer3.EntityFramework.Entities.Scope()
            {
                ClaimsRule = scope.ClaimsRule,
                Description = scope.Description,
                DisplayName = scope.DisplayName,
                Emphasize = scope.Emphasize,
                Enabled = scope.Enabled,
                IncludeAllClaimsForUser = scope.IncludeAllClaimsForUser,
                Name = scope.Name,
                Required = scope.Required,
                ScopeClaims = (ICollection<IdentityServer3.EntityFramework.Entities.ScopeClaim>)scope.Claims.Select<IdentityServer3.Core.Models.ScopeClaim, IdentityServer3.EntityFramework.Entities.ScopeClaim>((Func<IdentityServer3.Core.Models.ScopeClaim, IdentityServer3.EntityFramework.Entities.ScopeClaim>)(o => new IdentityServer3.EntityFramework.Entities.ScopeClaim()
                {
                    AlwaysIncludeInIdToken = o.AlwaysIncludeInIdToken,
                    Description = o.Description,
                    Name = o.Name
                })).ToList<IdentityServer3.EntityFramework.Entities.ScopeClaim>(),
                ShowInDiscoveryDocument = scope.ShowInDiscoveryDocument,
                Type = (int)scope.Type
            };
        }
    }
}
