using IdentityServer3.AspNetIdentity;
using IdentityServer3.Core.Models;
using Insite.Common.Dependencies;
using Insite.Common.Logging;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Providers;
using Insite.Core.Security;
using Insite.Core.Services;
using Insite.Customers.Services;
using Insite.Customers.Services.Parameters;
using Insite.Customers.Services.Results;
using Insite.Data.Entities;
using Insite.IdentityServer.AspNetIdentity;
using Insite.Plugins.Security;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using RemoteActiveDirectory;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;

namespace LeggettAndPlatt.Extensions.Identity
{   
    public class CustomUserService : AspNetIdentityUserService<IdentityUser, string>
    {
        protected readonly ICustomerService CustomerService;

        public CustomUserService(IdentityUserManager userManager, IUnitOfWorkFactory unitOfWorkFactory)
          : base((UserManager<IdentityUser, string>)userManager, (Func<string, string>)null)
        {
            this.CustomerService = DependencyLocator.Current.GetInstance<ICustomerService>();
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
        }

        protected IUnitOfWork UnitOfWork { get; set; }

        /// <summary>The authenticate external async.</summary>
        /// <param name="ctx">The ctx.</param>
        /// <returns>The <see cref="T:System.Threading.Tasks.Task" />.</returns>
        public override async Task AuthenticateExternalAsync(ExternalAuthenticationContext ctx)
        {
           // UserService userService = this;
            List<Claim> userClaims = ctx.ExternalIdentity.Claims.ToList<Claim>();
            Claim claim1 = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "email"));
            if (claim1 == null || claim1.Value == null)
            {
                HttpContext.Current.Items[(object)"externalAuthenticateErrorMessage"] = (object)"Unable to determine email from external provider. Email is required for creating an account.";
                throw new InvalidOperationException("Unable to determine email from external provider. Email is required for creating an account.");
            }
            if (ctx.SignInMessage.ClientId == "isc_admin_ext")
            {
                ctx.ExternalIdentity.ProviderId = AdminUserNameHelper.AddPrefix(ctx.ExternalIdentity.ProviderId);
                string userName = claim1.Value;
                Claim claim2 = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "name"));
                if (claim2 != null && claim2.Value != null)
                {
                    userName = claim2.Value;
                    userClaims.Remove(claim2);
                }
                userClaims.Add(new Claim("name", AdminUserNameHelper.AddPrefix(userName)));
                string str = AdminUserNameHelper.AddPrefix(claim1.Value);
                userClaims.Remove(claim1);
                userClaims.Add(new Claim("email", str));
                ctx.ExternalIdentity.Claims = (IEnumerable<Claim>)userClaims;
            }
            // ISSUE: reference to a compiler-generated method
            //await userService.\u003C\u003En__0(ctx);
            await base.AuthenticateExternalAsync(ctx);
            if (ctx.AuthenticateResult.IsError)
            {
                HttpContext.Current.Items[(object)"externalAuthenticateErrorMessage"] = (object)ctx.AuthenticateResult.ErrorMessage;
                throw new InvalidOperationException(ctx.AuthenticateResult.ErrorMessage);
            }
            IdentityUser user = await this.userManager.FindByIdAsync(ctx.AuthenticateResult.User.Claims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "sub"))?.Value);
            if (ctx.SignInMessage.ClientId == "isc_admin_ext")
            {
                string userName = AdminUserNameHelper.RemovePrefix(user.UserName);
                if (this.UnitOfWork.GetRepository<AdminUserProfile>().GetTable().SingleOrDefault<AdminUserProfile>((Expression<Func<AdminUserProfile, bool>>)(o => o.UserName == userName)) == null)
                    this.CreateAdminUserProfile(userClaims, user);
            }
            else if (this.UnitOfWork.GetRepository<UserProfile>().GetTable().SingleOrDefault<UserProfile>((Expression<Func<UserProfile, bool>>)(o => o.UserName == user.UserName)) == null)
                this.CreateUserProfile(userClaims, user);
            foreach (Claim claim2 in (await this.userManager.GetRolesAsync(user.Id)).Select<string, Claim>((Func<string, Claim>)(o => new Claim("role", o))))
                ((ClaimsIdentity)ctx.AuthenticateResult.User.Identity).AddClaim(claim2);
            if (ctx.AuthenticateResult.User.Claims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name")) == null)
                ((ClaimsIdentity)ctx.AuthenticateResult.User.Identity).AddClaim(new Claim("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", user.UserName));
            Dictionary<string, string> dictionary = ctx.SignInMessage.AcrValues.Where<string>((Func<string, bool>)(o => o.Split(':').Length == 2)).ToDictionary<string, string, string>((Func<string, string>)(o => o.Split(':')[0]?.ToLower()), (Func<string, string>)(o => o.Split(':')[1]?.ToLower()));
            if (!dictionary.ContainsKey("returnurl"))
                return;
            ((ClaimsIdentity)ctx.AuthenticateResult.User.Identity).AddClaim(new Claim("partial_login_return_url", dictionary["returnurl"]));
        }

        /// <summary>The authenticate local async.</summary>
        /// <param name="ctx">The ctx.</param>
        /// <returns>The <see cref="T:System.Threading.Tasks.Task" />.</returns>
        public override async Task AuthenticateLocalAsync(LocalAuthenticationContext ctx)
        {
            //UserService userService = this;
            try
            {
                RemoteValidationService validationService = new RemoteValidationService();
                string str = ctx.UserName;
                string userLockedOutMessage;
                string userNamePasswordCombinationMessage;
                if (str.StartsWith(AdminUserNameHelper.AdminUserNamePrefix))
                {
                    str = AdminUserNameHelper.RemovePrefix(str);
                    userLockedOutMessage = "Account is locked out";
                    userNamePasswordCombinationMessage = "Invalid Username/Password combination";
                }
                else
                {
                    userLockedOutMessage = MessageProvider.Current.SignInInfo_UserLockedOut;
                    userNamePasswordCombinationMessage = MessageProvider.Current.SignInInfo_UserNamePassword_Combination;
                }
                IEnumerable<Claim> claims;
                LocalAuthenticationContext authenticationContext;
                string subject;
                if (validationService.IsRemotelyManagedUserName(ctx.UserName))
                {
                    ValidationResult validationResult = validationService.ValidateUser(str, ctx.Password);
                    if (!validationResult.WasSuccessful)
                    {
                        ctx.AuthenticateResult = new AuthenticateResult(validationResult.SubCode == RemoteActiveDirectory.SubCode.LockedOut ? userLockedOutMessage : userNamePasswordCombinationMessage);
                    }
                    else
                    {
                        validationService.UpdateUserProfile(str, ctx.Password);
                        IdentityUser user1 = await this.userManager.FindByNameAsync(ctx.UserName);
                        claims = await this.GetClaimsForAuthenticateResult(user1);
                        authenticationContext = ctx;
                        subject = user1.Id;
                        authenticationContext.AuthenticateResult = new AuthenticateResult(subject, await this.GetDisplayNameForAccountAsync(user1.Id), claims, "idsrv", (string)null);
                        authenticationContext = (LocalAuthenticationContext)null;
                        subject = (string)null;
                    }
                }
                else
                {
                    IdentityUser user = await this.userManager.FindByNameAsync(ctx.UserName);
                    if (user == null)
                    {
                        ctx.AuthenticateResult = new AuthenticateResult(userNamePasswordCombinationMessage);
                    }
                    else
                    {                       
                        if (await this.userManager.CheckPasswordAsync(user, ctx.Password))
                        {
                            bool flag = this.userManager.SupportsUserLockout;
                            if (flag)
                                flag = await this.userManager.IsLockedOutAsync(user.Id);
                            if (flag)
                                ctx.AuthenticateResult = new AuthenticateResult(userLockedOutMessage);
                            else
                            {
                                if (this.userManager.SupportsUserLockout)
                                    this.userManager.ResetAccessFailedCount<IdentityUser, string>(user.Id);
                                AuthenticateResult authenticateResult = await this.PostAuthenticateLocalAsync(user, ctx.SignInMessage);
                                if (authenticateResult != null)
                                {
                                    ctx.AuthenticateResult = authenticateResult;
                                }
                                else
                                {
                                    claims = await this.GetClaimsForAuthenticateResult(user);
                                    authenticationContext = ctx;
                                    subject = user.Id;
                                    authenticationContext.AuthenticateResult = new AuthenticateResult(subject, await this.GetDisplayNameForAccountAsync(user.Id), claims, "idsrv", (string)null);
                                    authenticationContext = (LocalAuthenticationContext)null;
                                    subject = (string)null;
                                }
                            }
                        }
                        else
                        {
                            if (this.userManager.SupportsUserLockout)
                            {
                                IdentityResult identityResult = await this.userManager.AccessFailedAsync(user.Id);
                            }
                            ctx.AuthenticateResult = new AuthenticateResult(userNamePasswordCombinationMessage);
                            userLockedOutMessage = (string)null;
                            userNamePasswordCombinationMessage = (string)null;
                            user = (IdentityUser)null;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)("There was an exception attempting to log in: " + ex.Message), ex, (string)null, (object)null);
                throw;
            }
        }

        /// <summary>The instantiate new user from external provider async.</summary>
        /// <param name="provider">The provider.</param>
        /// <param name="providerId">The provider id.</param>
        /// <param name="claims">The claims.</param>
        /// <returns>The <see cref="T:System.Threading.Tasks.Task" />.</returns>
        protected override async Task<IdentityUser> InstantiateNewUserFromExternalProviderAsync(
          string provider,
          string providerId,
          IEnumerable<Claim> claims)
        {
            List<Claim> list = claims.ToList<Claim>();
            string name = list.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "name"))?.Value;
            string email = list.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "email"))?.Value;
            string firstName = list.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "given_name"))?.Value ?? string.Empty;
            string lastName = list.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "family_name"))?.Value ?? string.Empty;
            string userName = this.GenerateUserName(name, email, firstName, lastName);
            IdentityUser result = new IdentityUser();
            result.UserName = userName;
            result.Email = email;
            return await Task.FromResult<IdentityUser>(result);
        }

        /// <summary>The try get existing user from external provider claims async.</summary>
        /// <param name="provider">The provider.</param>
        /// <param name="claims">The claims.</param>
        /// <returns>The <see cref="T:System.Threading.Tasks.Task" />.</returns>
        protected override async Task<IdentityUser> TryGetExistingUserFromExternalProviderClaimsAsync(
          string provider,
          IEnumerable<Claim> claims)
        {
            //UserService userService = this;
            string email = claims.ToList<Claim>().SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "email"))?.Value;
            if (string.IsNullOrWhiteSpace(email))
                return (IdentityUser)null;
            return await this.userManager.Users.FirstOrDefaultAsync<IdentityUser>((Expression<Func<IdentityUser, bool>>)(o => string.Compare(o.Email, email, StringComparison.InvariantCultureIgnoreCase) == 0));
        }

        private void CreateUserProfile(List<Claim> userClaims, IdentityUser user)
        {
            string str = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "email"))?.Value;
            UserProfile inserted = new UserProfile()
            {
                UserName = user.UserName,
                Email = str,
                FirstName = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "given_name"))?.Value ?? string.Empty,
                LastName = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "family_name"))?.Value ?? string.Empty,
                CurrencyId = new Guid?(SiteContext.Current.CurrencyDto.Id)
            };
            this.UnitOfWork.GetRepository<UserProfile>().Insert(inserted);
            this.UnitOfWork.Save();
            AddBillToResult addBillToResult = this.CustomerService.AddBillTo(new AddBillToParameter()
            {
                Email = str
            });
            if (addBillToResult.ResultCode != ResultCode.Error)
            {
                inserted.Customers.Add(addBillToResult.BillTo);
                this.UnitOfWork.Save();
            }
            inserted.Websites.Add(this.UnitOfWork.GetRepository<Website>().Get(SiteContext.Current.WebsiteDto.Id));
            this.UnitOfWork.Save();
        }

        private void CreateAdminUserProfile(List<Claim> userClaims, IdentityUser user)
        {
            string identityUserName = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "email"))?.Value;
            this.UnitOfWork.GetRepository<AdminUserProfile>().Insert(new AdminUserProfile()
            {
                UserName = AdminUserNameHelper.RemovePrefix(user.UserName),
                Email = AdminUserNameHelper.RemovePrefix(identityUserName),
                FirstName = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "given_name"))?.Value ?? string.Empty,
                LastName = userClaims.SingleOrDefault<Claim>((Func<Claim, bool>)(o => o.Type == "family_name"))?.Value ?? string.Empty
            });
            this.UnitOfWork.Save();
            this.userManager.AddToRole<IdentityUser, string>(user.Id, "ISC_User");
        }

        private string GenerateUserName(string name, string email, string firstName, string lastName)
        {
            string username = name;
            if (string.IsNullOrWhiteSpace(username) || this.UsernameInUse(username))
            {
                username = email;
                if (string.IsNullOrWhiteSpace(username) || this.UsernameInUse(username))
                {
                    username = string.Format("{0}{1}", (object)firstName.FirstOrDefault<char>(), (object)lastName);
                    if (this.UsernameInUse(username))
                    {
                        for (int index = 1; index < 100; ++index)
                        {
                            if (!this.UsernameInUse(username + (object)index))
                                return username + (object)index;
                        }
                        throw new Exception("Unable to generate a username for email = " + email + ", first name = " + firstName + ", last name = " + lastName);
                    }
                }
            }
            return username.ToLower();
        }

        private bool UsernameInUse(string username)
        {
            return this.userManager.Users.Any<IdentityUser>((Expression<Func<IdentityUser, bool>>)(o => o.UserName == username));
        }
    }
}
