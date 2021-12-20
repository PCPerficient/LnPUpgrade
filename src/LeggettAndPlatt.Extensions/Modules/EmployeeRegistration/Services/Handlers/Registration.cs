#region Import
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services.Handlers;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using Insite.Account.Services.Parameters;
using Insite.Account.Services.Results;
using System;
using System.Linq;
using Insite.Account.Emails;
using Insite.Data.Entities.Dtos.Interfaces;
using Insite.Data.Repositories.Interfaces;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Context;
using Insite.Data.Entities;
using Insite.Account.SystemSettings;
using Insite.Core.Services;
using System.Data;
using System.Data.SqlClient;
using Insite.Core.Interfaces.Providers;
using Insite.Common.Logging;
using Insite.Core.Providers;
using LeggettAndPlatt.Extensions.Common;
using LeggettAndPlatt.Extensions.CustomSettings;
using System.Dynamic;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Interfaces.EnumTypes;
#endregion

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Handlers
{
    [DependencyName("EmployeeRegistration")]
    public class Registration : HandlerBase<RegistrationParameter, RegistrationResult>
    {
        private readonly IHandlerFactory handlerFactory;
        protected readonly IAccountActivationEmail AccountActivationEmail;
        protected readonly IWebsiteUtilities WebsiteUtilities;
        protected readonly StorefrontSecuritySettings StorefrontSecuritySettings;
        private const string userProfileCustomPropertyName = "employeeUniqueIdOrClock";
        private const string lnpIsUserAlreadyRegisteredSPName = "LNPIsUserAlreadyRegistered";
        private IUnitOfWork unitOfWork;
        private readonly EmailHelper EmailHelper;
        protected readonly CommonSettings CommonSettings;
        protected readonly IEmailService EmailService;

        public override int Order
        {
            get
            {
                return 500;
            }
        }

        public Registration(IHandlerFactory handlerFactory, IAccountActivationEmail accountActivationEmail, IWebsiteUtilities websiteUtilities, StorefrontSecuritySettings storefrontSecuritySettings, EmailHelper emailHelper, CommonSettings commonSettings, IEmailService emailService)
        {
            this.handlerFactory = handlerFactory;
            this.AccountActivationEmail = accountActivationEmail;
            this.WebsiteUtilities = websiteUtilities;
            this.StorefrontSecuritySettings = storefrontSecuritySettings;
            this.EmailHelper = emailHelper;
            this.CommonSettings = commonSettings;
            this.EmailService = emailService;
        }

        public override RegistrationResult Execute(IUnitOfWork unitOfWork, RegistrationParameter parameter, RegistrationResult result)
        {
            this.unitOfWork = unitOfWork;
            RegistrationResult registrationResult = new RegistrationResult();
            EmployeeSettings settings = new EmployeeSettings();
            string inputFieldTitleAndValue = string.Empty;

            string userName = parameter.Email;
            string userEmail = parameter.Email;
            string uniqueOrClockId = !string.IsNullOrEmpty(parameter.Clock) ? parameter.Clock : parameter.Unique;

            try
            {
                /* Verifies User From LNPEmployee 
                * To Confirm When User Is Valid Employee 
                * Based On Clock,Unique And Last Name
                */
                bool isUserValidEmployee = EmpRegistrationHelper.IsUserValidEmployee(unitOfWork, parameter, out registrationResult);
                if (!isUserValidEmployee) return registrationResult;

                /* Verifies When The Clock Or Unique Id */
                string activationStatus = string.Empty;
                bool isUserDeactivated = false;
                bool isUniqueIDExistInUserProfile = DoesUniqueIDExistInUserProfile(parameter, out registrationResult, out activationStatus, out isUserDeactivated);

                //Create New User
                if (!isUniqueIDExistInUserProfile)
                    return CreateAndCommunicateUser(parameter, settings);
                else
                {
                    registrationResult.IsRegistered = false;
                    //Verifies User Is User Deactivated
                    if (isUserDeactivated)
                    {
                        EmpRegistrationHelper.SetEmpRedirectUrlProperty(registrationResult, EmpRegistrationConstantsHelper.RegistrationRedirectUrl, settings.ContactCustomerServiceUrl);
                        return registrationResult;
                    }

                    //If User If Not Deactivated Then Get The Error Based On Activation Status
                    GetMessageByActivationStatus(registrationResult, activationStatus, settings);
                    return registrationResult;
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Info("Employee Registration Log : " + ex.ToString());
                registrationResult.IsRegistered = false;
                registrationResult.ErrorMessage = MessageProvider.Current.GetMessage("LNP_Account_ExceptionError_Msg", "An error has occurred. We apologize for the inconvenience.");
                this.SendExceptionEmail("Employee Account Creation: " + ex.ToString());
                return registrationResult;
            }
        }

        #region Private Methods
        /// <summary>
        /// Get Message By Activation Status
        /// </summary>
        /// <param name="registrationResult"></param>
        /// <param name="activationStatus"></param>
        private void GetMessageByActivationStatus(RegistrationResult registrationResult, string activationStatus, EmployeeSettings settings)
        {
            if (activationStatus.Equals(Enum.GetName(typeof(UserActivationStatus), (object)UserActivationStatus.Activated), StringComparison.InvariantCultureIgnoreCase))
                EmpRegistrationHelper.SetEmpRedirectUrlProperty(registrationResult, EmpRegistrationConstantsHelper.RegistrationRedirectUrl, settings.ResetPasswordOrLoginUrl);
            else if (activationStatus.Equals(Enum.GetName(typeof(UserActivationStatus), (object)UserActivationStatus.EmailSent), StringComparison.InvariantCultureIgnoreCase))
                EmpRegistrationHelper.SetEmpRedirectUrlProperty(registrationResult, EmpRegistrationConstantsHelper.RegistrationRedirectUrl, settings.ActivationEmailSentUrl);
            else if (activationStatus.Equals(Enum.GetName(typeof(UserActivationStatus), (object)UserActivationStatus.EmailNotSent), StringComparison.InvariantCultureIgnoreCase))
                EmpRegistrationHelper.SetEmpRedirectUrlProperty(registrationResult, EmpRegistrationConstantsHelper.RegistrationRedirectUrl, settings.ContactCustomerServiceUrl);
            else
                registrationResult.ErrorMessage = MessageProvider.Current.GetMessage("LNP_Account_ExceptionError_Msg", "An error has occurred. We apologize for the inconvenience.");
        }

        /// <summary>
        /// Create New User And Sent Mail
        /// </summary>
        /// <param name="parameter"></param>
        /// <returns></returns>
        private RegistrationResult CreateAndCommunicateUser(RegistrationParameter parameter, EmployeeSettings settings)
        {
            RegistrationResult registrationResult = new RegistrationResult();
            Guid websiteId = SiteContext.Current.WebsiteDto.Id;
            AddAccountResult accountResult = CreateAccount(parameter);
            string uniqueOrClockId = !string.IsNullOrEmpty(parameter.Clock) ? parameter.Clock : parameter.Unique;

            if (accountResult != null
                    && accountResult.ResultCode == ResultCode.Success
                    && accountResult.UserProfile != null)
            {
                this.RemoveSession();
                this.AddUpdateUserProfileCustomProperty(accountResult.UserProfile, uniqueOrClockId);
                this.AccountActivationEmail.Send((IUserProfile)unitOfWork.GetTypedRepository<IUserProfileRepository>().GetByUserName(parameter.Email), this.WebsiteUtilities.GenerateUriWithDefaultDomain((IWebsite)unitOfWork.GetTypedRepository<IWebsiteRepository>().Get(websiteId), "", "").ToString(), new Guid?(websiteId));

                registrationResult.IsRegistered = true;
                EmpRegistrationHelper.SetEmpRedirectUrlProperty(registrationResult, EmpRegistrationConstantsHelper.RegistrationRedirectUrl, settings.ActivationEmailSentUrl);
                return registrationResult;
            }
            else
            {
                registrationResult.IsRegistered = false;
                registrationResult.ErrorMessage = accountResult.Message;
                return registrationResult;
            }
        }

        #endregion

        #region Helper Method Start
        /// <summary>
        /// To send email on error occur. 
        /// </summary>
        private void SendExceptionEmail(string error)
        {
            if (this.CommonSettings.ExceptionErrorEmailActive)
            {
                string subject = "Employee - Store Registration : Failed On " + DateTime.Now;
                dynamic obj = new ExpandoObject();
                obj.ApiModle = string.Empty;
                obj.MailSubject = subject;
                obj.JsonInput = string.Empty;
                obj.JsonOutput = string.Empty;
                obj.AdditionalInfo = error;

                this.EmailHelper.ErrorEmail(obj, this.EmailService);
            }
        }


        /// <summary>
        /// Is unique number or clock id already used or not
        /// </summary>
        private bool DoesUniqueIDExistInUserProfile(RegistrationParameter parameter, out RegistrationResult registrationResult, out string activationStatus, out bool isUserDeactivated)
        {
            bool result = false;
            activationStatus = string.Empty;
            isUserDeactivated = false;
            registrationResult = new RegistrationResult();
            string uniqueOrClockId = !string.IsNullOrEmpty(parameter.Clock) ? parameter.Clock : parameter.Unique;

            using (SqlConnection connection = new SqlConnection(ConnectionStringProvider.Current.ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(lnpIsUserAlreadyRegisteredSPName, connection);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LastName", parameter.LastName);
                cmd.Parameters.AddWithValue("@UniqueIdOrClock", uniqueOrClockId);

                cmd.Parameters.Add("@Result", SqlDbType.Bit);
                cmd.Parameters.Add("@ActivationStatus", SqlDbType.NVarChar, 100);
                cmd.Parameters.Add("@IsUserDeactivated", SqlDbType.Bit);

                cmd.Parameters["@Result"].Direction = ParameterDirection.Output;
                cmd.Parameters["@IsUserDeactivated"].Direction = ParameterDirection.Output;
                cmd.Parameters["@ActivationStatus"].Direction = ParameterDirection.Output;
                connection.Open();
                cmd.ExecuteNonQuery();
                result = Convert.ToBoolean(cmd.Parameters["@Result"].Value.ToString());

                if (cmd.Parameters["@ActivationStatus"].Value != null && !string.IsNullOrEmpty(cmd.Parameters["@ActivationStatus"].Value.ToString()))
                    activationStatus = cmd.Parameters["@ActivationStatus"].Value.ToString();
                if (cmd.Parameters["@IsUserDeactivated"].Value != null && !string.IsNullOrEmpty(cmd.Parameters["@IsUserDeactivated"].Value.ToString()))
                    isUserDeactivated = Convert.ToBoolean(cmd.Parameters["@IsUserDeactivated"].Value.ToString());

                connection.Close();
                if (result)
                {
                    registrationResult.IsRegistered = false;
                    registrationResult.ErrorMessage = MessageProvider.Current.GetMessage("LNP_Account_AlreadyRegister_UsingUniqueClock_Msg", "Registration for Clock Number or Unique ID is already done. Please try using different details.");
                    return true;
                }
            }
            return result;
        }

        private void RemoveSession()
        {
            this.handlerFactory.GetHandler<IHandler<RemoveSessionParameter, RemoveSessionResult>>().Execute(this.unitOfWork, new RemoveSessionParameter(), new RemoveSessionResult());
        }

        private AddAccountResult CreateAccount(RegistrationParameter parameter)
        {
            return this.handlerFactory.GetHandler<IHandler<AddAccountParameter, AddAccountResult>>().Execute(this.unitOfWork, GetAddAccountParameter(parameter), new AddAccountResult());
        }

        private AddAccountParameter GetAddAccountParameter(RegistrationParameter parameter)
        {
            AddAccountParameter addAccountParameter = new AddAccountParameter(parameter.Email, parameter.Email, null, true);
            addAccountParameter.Properties.Add("isEmployeeRegistration", "1");
            addAccountParameter.FirstName = parameter.FirstName;
            addAccountParameter.LastName = parameter.LastName;
            return addAccountParameter;
        }
        /// <summary>
        /// Add Clock Number or Unique ID in custom table
        /// </summary>
        private void AddUpdateUserProfileCustomProperty(UserProfile userProfile, string uniqueOrClockId)
        {
            var customProperty = userProfile.CustomProperties.FirstOrDefault(u => u.Name.Equals(userProfileCustomPropertyName, StringComparison.InvariantCultureIgnoreCase));       
            if (customProperty != null)
            {
                customProperty.Value = uniqueOrClockId;
                this.unitOfWork.Save();
            }
            else
            {
                userProfile.SetProperty(userProfileCustomPropertyName, uniqueOrClockId);
                this.unitOfWork.Save();
            }
        }

        #endregion Helper Method End

    }
}
