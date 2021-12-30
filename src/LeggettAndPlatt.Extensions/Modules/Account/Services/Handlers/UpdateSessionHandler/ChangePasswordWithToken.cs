using Insite.Account.Services.Parameters;
using Insite.Account.Services.Results;
using Insite.Common.Extensions;
using Insite.Common.Providers;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.EnumTypes;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Interfaces.Plugins.Security;
using Insite.Core.Providers;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using LeggettAndPlatt.Extensions.Common;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Web;

namespace LeggettAndPlatt.Extensions.Modules.Account.Services.Handlers.UpdateSessionHandler
{
    [DependencyName("ChangePasswordWithToken")]
    public sealed class ChangePasswordWithToken : HandlerBase<UpdateSessionParameter, UpdateSessionResult>
    {
        private readonly IEmailService EmailService;
        private readonly EmailHelper EmailHelper;

        private readonly Lazy<IAuthenticationService> authenticationService;

        public ChangePasswordWithToken(Lazy<IAuthenticationService> authenticationService, IEmailService emailService, EmailHelper emailHelper)
        {
            this.authenticationService = authenticationService;
            this.EmailService = emailService;
            this.EmailHelper = emailHelper;
        }

        public override int Order
        {
            get
            {
                return 800;
            }
        }

        public override UpdateSessionResult Execute(IUnitOfWork unitOfWork, UpdateSessionParameter parameter, UpdateSessionResult result)
        {
            if (parameter.ResetToken.IsBlank() || parameter.NewPassword.IsBlank())
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            if (parameter.UserName.IsBlank())
                return this.CreateErrorServiceResult<UpdateSessionResult>(result, SubCode.AccountServiceUserProfileNotFound, MessageProvider.Current.User_Not_Found);
            if (!this.authenticationService.Value.IsValidPassword(parameter.NewPassword))
                return this.CreateErrorServiceResult<UpdateSessionResult>(result, SubCode.AccountServicePasswordDoesNotMeetComplexity, MessageProvider.Current.ChangePasswordInfo_Password_Not_Meet_Requirements);
            if (!this.authenticationService.Value.ResetPasswordForUser(parameter.UserName, parameter.NewPassword, parameter.ResetToken))
                return this.CreateErrorServiceResult<UpdateSessionResult>(result, SubCode.AccountServiceUnableToChangePassword, MessageProvider.Current.ChangePasswordInfo_Unable_To_Change_Password);
            UserProfile byNaturalKey = unitOfWork.GetTypedRepository<IUserProfileRepository>().GetByNaturalKey((object)parameter.UserName);
            if (byNaturalKey == null)
                return this.CreateErrorServiceResult<UpdateSessionResult>(result, SubCode.AccountServiceAccountDoesNotExist, MessageProvider.Current.Forgot_Password_Error);
            this.authenticationService.Value.UnlockUser(parameter.UserName);
            byNaturalKey.PasswordChangedOn = DateTimeProvider.Current.Now;
            byNaturalKey.IsPasswordChangeRequired = false;
            byNaturalKey.ActivationStatus = UserActivationStatus.Activated.ToString();
            this.SendResetPassSuccessMail(parameter, unitOfWork);
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }

        private void SendResetPassSuccessMail(UpdateSessionParameter parameter, IUnitOfWork unitOfWork)
        {

            UserProfile userProfile;
            var userEmail = "";
            if (!parameter.Email.IsBlank())
            {
                userEmail = parameter.Email;
            }
            else
            {
                userProfile = unitOfWork.GetTypedRepository<IUserProfileRepository>().GetByNaturalKey((object)parameter.UserName);
                userEmail = userProfile.Email;
            }

            if (!userEmail.IsBlank())
            {
                dynamic obj = new ExpandoObject();
                obj.ApiModle = "Reset Password Success Email";
                obj.MailSubject = "Reset Password Success Email";
                obj.JsonInput = string.Empty;
                obj.JsonOutput = string.Empty;
                obj.UserEmail = userEmail;
                obj.AdditionalInfo = "Your Password has Successfully Reset";
                obj.ContentBaseUrl = HttpContext.Current.Request.ActualUrl().GetLeftPart(UriPartial.Authority);
                obj.ContactUsUrl = obj.ContentBaseUrl + "/ContactUs/";
                obj.LoginURL = obj.ContentBaseUrl + "/MyAccount/SignIn/";
                this.EmailHelper.ResetPassSuccessEmailToUser(obj, this.EmailService);
            }
        }
    }
}
