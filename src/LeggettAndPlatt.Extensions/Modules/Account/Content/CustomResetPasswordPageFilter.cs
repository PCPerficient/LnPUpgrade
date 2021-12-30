using Insite.Account.Content;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Security;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos;
using Insite.Data.Repositories.Interfaces;
using Insite.WebFramework.Content;
using Insite.WebFramework.Mvc;
using LeggettAndPlatt.Extensions.Common;
using LeggettAndPlatt.Extensions.ContentLibrary.Pages;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;

namespace LeggettAndPlatt.Extensions.Modules.Account.Content
{
    public class CustomResetPasswordPageFilter : IFilter<ResetPasswordPage>
    {
        private readonly Lazy<IActionResultFactory> actionResultFactory;
        private readonly Lazy<IAuthenticationService> authenticationService;
        protected readonly IUnitOfWork unitOfWork;
        private const string userProfileCustomPropertyName = "employeeUniqueIdOrClock";

        public CustomResetPasswordPageFilter(Lazy<IActionResultFactory> actionResultFactory, Lazy<IAuthenticationService> authenticationService, IUnitOfWorkFactory unitOfWorkFactory)
        {
            this.actionResultFactory = actionResultFactory;
            this.authenticationService = authenticationService;
            this.unitOfWork = unitOfWorkFactory.GetUnitOfWork();
        }

        public FilterResult Execute(ResetPasswordPage page)
        {
            if (this.authenticationService.Value.IsAuthenticated())
                return new FilterResult()
                {
                    DisplayLink = false,
                    ReplacementAction = this.actionResultFactory.Value.RedirectToMyAccountPage()
                };
            if (HttpContext.Current == null)
                return (FilterResult)null;
            NameValueCollection queryString = HttpContext.Current.Request.QueryString;
            string userName = queryString["username"];
            string str = HttpUtility.UrlDecode(queryString["resetToken"]);
            string resetToken = str != null ? str.Replace(" ", "+") : (string)null;
            if (userName.IsBlank() || resetToken.IsBlank())
                return new FilterResult()
                {
                    DisplayLink = false,
                    ReplacementAction = this.actionResultFactory.Value.Forbidden()
                };
            bool flag = true;
            if (((IEnumerable<string>)queryString.AllKeys).Contains<string>("reset"))
                flag = queryString["reset"].EqualsIgnoreCase("true");
            if (this.authenticationService.Value.VerifyPasswordResetTokenForUser(userName, resetToken))
            {
                bool isValid = IsUserValidEmployee(userName);
                if (!isValid)
                    return new FilterResult()
                    {
                        DisplayLink = false,
                        ReplacementAction = this.actionResultFactory.Value.RedirectTo<ContactCustomerServicePage>()
                    };

                return (FilterResult)null;
            }
            return new FilterResult()
            {
                DisplayLink = false,
                ReplacementAction = flag ? this.actionResultFactory.Value.RedirectToExpiredResetPasswordLinkPage() : this.actionResultFactory.Value.RedirectToExpiredAccountActivationLinkPage()
            };
        }

        #region PRFT Changes: Jira 25
        /// <summary>
        /// Gets UserProfile By Name and Verifies Against LNP Employee
        /// </summary>
        /// <param name="userName"></param>
        /// <returns></returns>
        private bool IsUserValidEmployee(string userName)
        {
            var context = SiteContext.Current.WebsiteDto;
            string WebsiteId = null;
            if (!string.IsNullOrEmpty(new EmployeeSettings().EmployeeWebsiteName.ToString()))
            {
                WebsiteId = new EmployeeSettings().EmployeeWebsiteName;
            }

            if ((context != null && WebsiteId != null) && context.Id.ToString().Equals(WebsiteId.ToString(), StringComparison.InvariantCultureIgnoreCase))
            {
                UserProfile byNaturalKey = this.unitOfWork.GetTypedRepository<IUserProfileRepository>().GetByNaturalKey((object)userName);
                RegistrationResult registrationResult = new RegistrationResult();
                RegistrationParameter registrationParam = GetEmpRegisrationParams(byNaturalKey);

                return EmpRegistrationHelper.IsUserValidEmployee(unitOfWork, registrationParam, out registrationResult, true);
            }
            return true;
        }

        private RegistrationParameter GetEmpRegisrationParams(UserProfile byNaturalKey)
        {
            if (byNaturalKey == null) return new RegistrationParameter();

            if (byNaturalKey.CustomProperties != null && byNaturalKey.CustomProperties.Any()
                && byNaturalKey.CustomProperties.FirstOrDefault(u => u.Name.Equals(userProfileCustomPropertyName, StringComparison.InvariantCultureIgnoreCase)) != null)
            {
                return new RegistrationParameter()
                {
                    Clock = byNaturalKey.CustomProperties.FirstOrDefault(u => u.Name.Equals(userProfileCustomPropertyName, StringComparison.InvariantCultureIgnoreCase)).Value,
                    Unique = byNaturalKey.CustomProperties.FirstOrDefault(u => u.Name.Equals(userProfileCustomPropertyName, StringComparison.InvariantCultureIgnoreCase)).Value,
                    Email = byNaturalKey.Email,
                    FirstName = byNaturalKey.FirstName,
                    LastName = byNaturalKey.LastName
                };
            }
            return new RegistrationParameter();
        }

        #endregion
    }
}