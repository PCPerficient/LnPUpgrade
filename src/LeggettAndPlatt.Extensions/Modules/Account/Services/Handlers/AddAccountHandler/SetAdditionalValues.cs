using Insite.Account.Services.Parameters;
using Insite.Account.Services.Pipelines;
using Insite.Account.Services.Pipelines.Parameters;
using Insite.Account.Services.Pipelines.Results;
using Insite.Account.Services.Results;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.EnumTypes;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Interfaces.Plugins.Security;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Core.SystemSetting.Groups.SystemSettings;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos;
using Insite.Data.Repositories.Interfaces;
using System;
using System.Linq;
namespace LeggettAndPlatt.Extensions.Modules.Account.Services.Handlers.AddAccountHandler
{
    [DependencyName("SetAdditionalValues")]
    public sealed class SetAdditionalValues : HandlerBase<AddAccountParameter, AddAccountResult>
    {
        private readonly Lazy<IEmailService> emailService;
        private readonly Lazy<IAuthenticationService> authenticationService;
        private readonly Lazy<IAccountPipeline> accountPipeline;
        private readonly SecuritySettings securitySettings;

        public SetAdditionalValues(Lazy<IEmailService> emailService, Lazy<IAuthenticationService> authenticationService, Lazy<IAccountPipeline> accountPipeline, SecuritySettings securitySettings)
        {
            this.emailService = emailService;
            this.authenticationService = authenticationService;
            this.accountPipeline = accountPipeline;
            this.securitySettings = securitySettings;
        }

        public override int Order
        {
            get
            {
                return 1200;
            }
        }

        public override AddAccountResult Execute(IUnitOfWork unitOfWork, AddAccountParameter parameter, AddAccountResult result)
        {
            UserProfile userProfile1 = result.UserProfile;
            bool? nullable1 = parameter.IsSubscribed;
            if ((nullable1.HasValue ? (nullable1.GetValueOrDefault() ? 1 : 0) : 0) != 0)
                this.emailService.Value.SubscribeEmailToList("SubscriptionEmail", userProfile1.Email, unitOfWork);
            if (this.securitySettings.RestrictUsersToAssignedWebsites)
                userProfile1.Websites.Add(unitOfWork.GetRepository<Website>().Get(SiteContext.Current.WebsiteDto.Id));
            if (!result.IsUserAdministration)
            {
                if (parameter.Properties.ContainsKey("isEmployeeRegistration"))
                    userProfile1.ActivationStatus = Enum.GetName(typeof(UserActivationStatus), (object)UserActivationStatus.EmailSent);
                else
                    userProfile1.ActivationStatus = Enum.GetName(typeof(UserActivationStatus), (object)UserActivationStatus.Activated);

                if (parameter.Properties.ContainsKey("isEmployeeRegistration"))
                    parameter.Properties.Remove("isEmployeeRegistration");

                UserProfile userProfile2 = userProfile1;
                CurrencyDto currencyDto = SiteContext.Current.CurrencyDto;
                Guid? nullable2 = currencyDto != null ? new Guid?((currencyDto.Id)) : new Guid?();
                userProfile2.CurrencyId = nullable2;
            }
            if (result.IsUserAdministration)
            {
                UserProfile userProfile2 = userProfile1;
                bool? isApproved = parameter.IsApproved;
                nullable1 = isApproved.HasValue ? new bool?(!isApproved.GetValueOrDefault()) : new bool?();
                int num = nullable1.HasValue ? (nullable1.GetValueOrDefault() ? 1 : 0) : 0;
                userProfile2.IsDeactivated = num != 0;
                SetRoleResult setRoleResult = this.accountPipeline.Value.SetRole(new SetRoleParameter(userProfile1, parameter.Role));
                if (setRoleResult.ResultCode != ResultCode.Success)
                    return this.CreateErrorServiceResult<AddAccountResult>(result, setRoleResult.SubCode, setRoleResult.Message);
                GetRoleNameResult getRoleNameResult = this.accountPipeline.Value.GetRoleName(new GetRoleNameParameter(userProfile1));
                if (getRoleNameResult.ResultCode != ResultCode.Success)
                    return this.CreateErrorServiceResult<AddAccountResult>(result, getRoleNameResult.SubCode, getRoleNameResult.Message);
                GetRolesResult roles = this.accountPipeline.Value.GetRoles(new GetRolesParameter());
                if (roles.ResultCode != ResultCode.Success)
                    return this.CreateErrorServiceResult<AddAccountResult>(result, roles.SubCode, roles.Message);
                if (roles.RolesThatRequireApprover.Any<string>((Func<string, bool>)(o => o.EqualsIgnoreCase(getRoleNameResult.RoleName))) && !parameter.Approver.IsBlank() && (userProfile1.ApproverUserProfile == null || !parameter.Approver.EqualsIgnoreCase(userProfile1.ApproverUserProfile.UserName)))
                    userProfile1.ApproverUserProfile = unitOfWork.GetTypedRepository<IUserProfileRepository>().GetByUserName(parameter.Approver);
            }
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }
    }
}
