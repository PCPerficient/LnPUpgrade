using IdentityServer3.Core.Configuration;
using IdentityServer3.Core.Services;
using Insite.Common.Dependencies;
using Insite.Core.Interfaces.Data;
using Insite.IdentityServer;
using Insite.IdentityServer.AspNetIdentity;
using Insite.Plugins.Data;
using LeggettAndPlatt.Extensions.Identity;
using System;

namespace LeggettAndPlatt.Extensions.Modules.IdentityServer
{
    public static class CustomUserServiceExtensions
    {
        public static void ConfigureUserService(this IdentityServerServiceFactory factory, string connectionString)
        {
            factory.UserService = new Registration<IUserService, CustomUserService>();
            factory.Register(new Registration<IDependencyLocator>(DependencyLocator.Current));
            factory.Register(new Registration<IUnitOfWorkFactory, UnitOfWorkFactory>());
            factory.Register(new Registration<IdentityUserManager>());
            factory.Register(new Registration<IdentityUserStore>());
            factory.Register(new Registration<IdentityDbContext>(resolver => new IdentityDbContext(connectionString)));
        }
    }
}
