using Insite.Plugins.Emails;
using System;
using System.Collections.Generic;
using System.Linq;
using Insite.Core.Localization;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.SystemSetting.Groups.SiteConfigurations;
using Insite.WebFramework.Templating;
using Insite.Core.Interfaces.Data;
using Insite.Common;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using LeggettAndPlatt.PinPointe.Services.Interfaces;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.PinPointe.Models;
using Newtonsoft.Json;
using Insite.Common.Logging;
using Insite.Data.Extensions;
using System.Linq.Expressions;

using System.Dynamic;
using LeggettAndPlatt.Extensions.Common;
using Insite.Core.Interfaces.Plugins.Caching;

namespace LeggettAndPlatt.Extensions.Plugins.Emails
{
    public class EmailServiceDrift : EmailService
    {
        protected readonly IPinPointeService PinPointeService;
        protected readonly PinPointeSettings PinPointeSettings;
        protected readonly EmailHelper EmailHelper;
        protected readonly Lazy<IPerRequestCacheManager> PerRequestCacheManager;

        public EmailServiceDrift(IEmailTemplateUtilities emailTemplateUtilities, IContentManagerUtilities contentManagerUtilities, IEntityTranslationService entityTranslationService, EmailsSettings emailsSettings, Lazy<IEmailTemplateRenderer> emailTemplateRenderer, Lazy<IPerRequestCacheManager> perRequestCacheManager, PinPointeSettings pinPointeSettings, IPinPointeService pinPointeService, EmailHelper emailHelper)
            : base(emailTemplateUtilities, contentManagerUtilities, entityTranslationService, emailsSettings, emailTemplateRenderer, perRequestCacheManager)
        {
            this.PinPointeService = pinPointeService;
            this.PinPointeSettings = pinPointeSettings;
            this.EmailHelper = emailHelper;
        }

        public override void SubscribeEmailToList(string emailListName, string email, IUnitOfWork unitOfWork)
        {
            if (!RegularExpressionLibrary.IsValidEmail(email))
                throw new ArgumentException(string.Format("Email address: {0} is not a valid email address.", (object)email));
            EmailList subscriptionEmailList = this.GetOrCreateSubscriptionEmailList(emailListName, unitOfWork);
            IEmailSubscriberRepository typedRepository = unitOfWork.GetTypedRepository<IEmailSubscriberRepository>();
            EmailSubscriber byEmailAddress = typedRepository.GetByEmailAddress(email);
            if (byEmailAddress == null)
            {
                byEmailAddress = typedRepository.Create();
                byEmailAddress.Email = email;
                typedRepository.Insert(byEmailAddress);
            }
            subscriptionEmailList.EmailSubscribers.Add(byEmailAddress);
            unitOfWork.Save();

            //Custom code for PinPointe
            bool isUnSubscriber = IsUnSubscriber(email);
            if (isUnSubscriber)
            {
                DeleteSubscriberFromList(email);
            }
            PinPointeAddSubscriber(email);
        }

        public override void UnsubscribeEmailFromAllLists(string email, IUnitOfWork unitOfWork)
        {
            IEmailSubscriberRepository typedRepository = unitOfWork.GetTypedRepository<IEmailSubscriberRepository>();
            EmailSubscriber emailSubscriber = typedRepository.GetByEmailAddress(email);
            if (emailSubscriber == null)
                return;
            
            typedRepository.Delete(emailSubscriber);
            unitOfWork.Save();

            //Custom code for PinPointe
            PinPointeUnsubscribeSubscriber(email);
        }

        #region PinePointe
        private bool PinPointeAddSubscriber(string email)
        {
            PinPointeRequestModel pinPointeRequestModel = CreatePinPointeRequestModel(email, "AddSubscriberToList");
            bool result = false;
            try
            {
                PinPointeResponseModel pinPointeResponseModel = this.PinPointeService.AddSubscriberToList(pinPointeRequestModel, this.PinPointeSettings.PostURL);
                if (pinPointeResponseModel != null && pinPointeResponseModel.Status.Equals("Success", StringComparison.InvariantCultureIgnoreCase))
                {
                    result = true;
                }

                if (this.PinPointeSettings.PinpointErrorEmails && !result)
                {
                    string additionalInfo = "Pin Pointe Add Email Subscription for Email " + email + " is Failed";

                    PrepareAndSendEmail(pinPointeRequestModel, pinPointeResponseModel, additionalInfo);
                }

                if (this.PinPointeSettings.EnableLog)
                {
                    string pinPointeResponse = JsonConvert.SerializeObject(pinPointeResponseModel);
                    LogHelper.For((object)this).Info("PinPointe Add Subscriber Log : " + pinPointeResponse);
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                if (this.PinPointeSettings.PinpointErrorEmails)
                {
                    string additionalInfo = "Pin Pointe Add Email Subscription for Email " + email + " is Failed";

                    PrepareAndSendEmail(pinPointeRequestModel, null, additionalInfo, ex.ToString());
                }
            }
            return result;

        }
        private PinPointeRequestModel CreatePinPointeRequestModel(string email, string requestMethod)
        {
            PinPointeRequestModel pinPointeRequestModel = new PinPointeRequestModel();
            pinPointeRequestModel.UserName = this.PinPointeSettings.UserName;
            pinPointeRequestModel.UserToken = this.PinPointeSettings.UserToken;
            pinPointeRequestModel.RequestType = "subscribers";
            pinPointeRequestModel.RequestMethod = requestMethod;
            pinPointeRequestModel.Details = new PinPointeRequestDetails()
            {
                EmailAddress = email,
                AddToAutoresponders = "false",
                MailingList = this.PinPointeSettings.MailingList,
                Format = "html",
                Confirmed = "true",
                CustomFields = new PinPointeRequestCustomFields()
                {
                    Item = new PinPointeRequestCustomFieldsItem()
                    {
                        FieldId = "30",
                        Value = "Website Signup"
                    }
                },
                Tag = this.PinPointeSettings.Tag
            };

            return pinPointeRequestModel;
        }

        private bool PinPointeUnsubscribeSubscriber(string email)
        {
            PinPonteUnSubscriberRequestModel pinPonteUnSubscriberRequestModel = CreatePinPointeUnSubscriberRequestModel(email);
            bool result = false;
            try
            {
                PinPointeResponseModel pinPointeResponseModel = this.PinPointeService.UnsubscribeSubscriberFromList(pinPonteUnSubscriberRequestModel, this.PinPointeSettings.PostURL);
                if (pinPointeResponseModel != null && pinPointeResponseModel.Status.Equals("Success", StringComparison.InvariantCultureIgnoreCase))
                {
                    result = true;
                }

                if (this.PinPointeSettings.PinpointErrorEmails && !result)
                {
                    string additionalInfo = "Pin Pointe UnSubscriber Email " + email + " is Failed";

                    PrepareAndSendEmail(pinPonteUnSubscriberRequestModel, pinPointeResponseModel, additionalInfo);
                }

                if (this.PinPointeSettings.EnableLog)
                {
                    string pinPointeResponse = JsonConvert.SerializeObject(pinPointeResponseModel);
                    LogHelper.For((object)this).Info("PinPointe UnSubscriber Log : " + pinPointeResponse);
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                if (this.PinPointeSettings.PinpointErrorEmails)
                {
                    string additionalInfo = "Pin Pointe UnSubscriber for Email " + email + " is Failed";
                    PrepareAndSendEmail(pinPonteUnSubscriberRequestModel, null, additionalInfo, ex.ToString());
                }
            }
            return result;
        }

        private PinPonteUnSubscriberRequestModel CreatePinPointeUnSubscriberRequestModel(string email)
        {
            PinPonteUnSubscriberRequestModel pinPonteDeleteSubscriberRequestModel = new PinPonteUnSubscriberRequestModel();
            pinPonteDeleteSubscriberRequestModel.UserName = this.PinPointeSettings.UserName;
            pinPonteDeleteSubscriberRequestModel.UserToken = this.PinPointeSettings.UserToken;
            pinPonteDeleteSubscriberRequestModel.RequestType = "subscribers";
            pinPonteDeleteSubscriberRequestModel.RequestMethod = "UnsubscribeSubscriber";
            pinPonteDeleteSubscriberRequestModel.Details = new PinPointeUnSubscriberDetails()
            {
                EmailAddress = email,
                List = this.PinPointeSettings.MailingList
            };

            return pinPonteDeleteSubscriberRequestModel;
        }

        private void SendPinPointErrorEmail(string JsonInput, string JsonOutput, string AdditionalInfo)
        {
            dynamic obj1 = new ExpandoObject();
            obj1.ApiModle = "Pinpoint Newsletter Subscription Error";
            obj1.MailSubject = "Pinpoint Error Email";
            obj1.JsonInput = JsonInput;
            obj1.JsonOutput = JsonOutput;
            obj1.AdditionalInfo = AdditionalInfo;

            this.EmailHelper.ErrorEmail(obj1, this);
        }

        private bool IsUnSubscriber(string email)
        {
            bool result = false;
            PinPointeRequestModel pinPointeRequestModel = CreatePinPointeRequestModel(email, "IsUnSubscriber");
            try
            {
                PinPointeResponseModel pinPointeResponseModel = this.PinPointeService.IsUnSubscriber(pinPointeRequestModel, this.PinPointeSettings.PostURL);
                if (pinPointeResponseModel != null && pinPointeResponseModel.Status.Equals("Success", StringComparison.InvariantCultureIgnoreCase))
                {
                    result = true;
                }

                if (this.PinPointeSettings.EnableLog)
                {
                    string pinPointeResponse = JsonConvert.SerializeObject(pinPointeResponseModel);
                    LogHelper.For((object)this).Info("PinPointe IsUnSubscriber Log : " + pinPointeResponse);
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                if (this.PinPointeSettings.PinpointErrorEmails)
                {
                    string additionalInfo = "Pin Pointe IsUnSubscriber for Email " + email + " is Failed";

                    PrepareAndSendEmail(pinPointeRequestModel, null, additionalInfo, ex.ToString());
                }
            }

            return result;
        }

        private bool DeleteSubscriberFromList(string email)
        {
            bool result = false;
            PinPonteDeleteSubscriberRequestModel pinPonteDeleteSubscriberRequestModel = CreatePinPointeDeleteRequestModel(email, "DeleteSubscriber");
            try
            {
                PinPointeResponseModel pinPointeResponseModel = this.PinPointeService.DeleteSubscriberFromList(pinPonteDeleteSubscriberRequestModel, this.PinPointeSettings.PostURL);
                if (pinPointeResponseModel != null && pinPointeResponseModel.Status.Equals("Success", StringComparison.InvariantCultureIgnoreCase))
                {
                    result = true;
                }

                if (this.PinPointeSettings.PinpointErrorEmails && !result)
                {
                    string additionalInfo = "Pin Pointe DeleteSubscriber Email " + email + " is Failed";

                    PrepareAndSendEmail(pinPonteDeleteSubscriberRequestModel, pinPointeResponseModel, additionalInfo);
                }

                if (this.PinPointeSettings.EnableLog)
                {
                    string pinPointeResponse = JsonConvert.SerializeObject(pinPointeResponseModel);
                    LogHelper.For((object)this).Info("PinPointe DeleteSubscriber Log : " + pinPointeResponse);
                }
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                if (this.PinPointeSettings.PinpointErrorEmails)
                {
                    string additionalInfo = "Pin Pointe DeleteSubscriber for Email " + email + " is Failed";

                    PrepareAndSendEmail(pinPonteDeleteSubscriberRequestModel, null, additionalInfo, ex.ToString());
                }
            }

            return result;
        }

        private PinPonteDeleteSubscriberRequestModel CreatePinPointeDeleteRequestModel(string email, string requestMethod)
        {
            PinPonteDeleteSubscriberRequestModel pinPonteDeleteSubscriberRequestModel = new PinPonteDeleteSubscriberRequestModel();
            pinPonteDeleteSubscriberRequestModel.UserName = this.PinPointeSettings.UserName;
            pinPonteDeleteSubscriberRequestModel.UserToken = this.PinPointeSettings.UserToken;
            pinPonteDeleteSubscriberRequestModel.RequestType = "subscribers";
            pinPonteDeleteSubscriberRequestModel.RequestMethod = requestMethod;
            pinPonteDeleteSubscriberRequestModel.Details = new PinPointeDeleteSubscriberDetails()
            {
                EmailAddress = email,
                List = this.PinPointeSettings.MailingList
            };

            return pinPonteDeleteSubscriberRequestModel;
        }

        private void PrepareAndSendEmail(object requestModel, object responseModel, string additionalInfo, string exceptionMessage = "")
        {
            string jsonInput = JsonConvert.SerializeObject(requestModel);
            if (string.IsNullOrEmpty(exceptionMessage))
            {
                exceptionMessage = JsonConvert.SerializeObject(responseModel);
            }
            this.SendPinPointErrorEmail(jsonInput, exceptionMessage, additionalInfo);
        }
        #endregion
    }
}

