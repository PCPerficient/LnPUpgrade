using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using System;
using System.Dynamic;
using System.Linq;
using Insite.Common.Logging;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Common;
using Insite.Data.Repositories.Interfaces;
using Insite.Core.Localization;
using Newtonsoft.Json.Linq;
using Insite.Core.Context;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers
{
    [DependencyName("AddElavonErrorLogHandler")]
    public class AddElavonErrorLogHandler : HandlerBase<ElavonErrorLogParameter, ElavonErrorLogResult>
    {
        private readonly IEmailService EmailService;
        protected readonly ElavonSettings ElavonSettings;
        protected readonly EmailHelper EmailHelper;
        private readonly IEntityTranslationService entityTranslationService;


        public AddElavonErrorLogHandler(IEmailService emailService, ElavonSettings elavonSettings, EmailHelper emailHelper, IEntityTranslationService entityTranslationService)
        {
            this.EmailService = emailService;
            this.ElavonSettings = elavonSettings;
            this.EmailHelper = emailHelper;
            this.entityTranslationService = entityTranslationService;
        }

        public override int Order
        {
            get
            {
                return 650;
            }
        }

        public override ElavonErrorLogResult Execute(IUnitOfWork unitOfWork, ElavonErrorLogParameter parameter, ElavonErrorLogResult result)
        {
            result.ErrorLogResponse = false;
            if (parameter != null && this.ElavonSettings.LogEvalonPaymentResponse)
            {     
                if (parameter.ElavonResponseFor.Equals("approval", StringComparison.InvariantCultureIgnoreCase))
                {
                    LogHelper.For((object)this).Info((object)parameter.ElavonResponse, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.AddElavonErrorLogHandler - Elavon Response");
                }
                else
                {
                    LogHelper.For((object)this).Error((object)parameter.ElavonResponse, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.AddElavonErrorLogHandler - Elavon Response");
                }
                result.ErrorLogResponse = true;
            }

            if (parameter != null && this.ElavonSettings.SentEmailEvalonPaymentFailuer)
            {               
                if (parameter.ElavonResponseFor.Equals("declined", StringComparison.InvariantCultureIgnoreCase))
                {
                    this.SendFailuerMail(parameter);
                }
            }

            if (parameter.saveElavonResponse)
            {
                this.SaveElavonResponse(parameter, unitOfWork);
            }

            return result;
        }

        private void SendFailuerMail(ElavonErrorLogParameter parameter)
        {

            dynamic obj = new ExpandoObject();
            obj.ApiModle = "Elavon Payment Failure Mail";
            obj.MailSubject = "Elavon Payment Failure Mail";
            obj.JsonInput = "Website = " + SiteContext.Current.WebsiteDto.Name + ", Elavon Pin = " + SettingHelper.GetSSLPinForElavonErrorEmail();
            obj.JsonOutput = string.Empty;
            obj.AdditionalInfo = parameter.ElavonResponse;

            this.EmailHelper.ErrorEmail(obj, this.EmailService);
        }

        private void SaveElavonResponse(ElavonErrorLogParameter parameter, IUnitOfWork unitOfWork)
        {
            var obj = JObject.Parse(parameter.ElavonResponse);
            var errorResponseMessage = obj["ssl_result_message"];

            Guid systemListId = unitOfWork.GetTypedRepository<ISystemListRepository>().GetTable().FirstOrDefault(x => x.Name.Equals("ElavonErrorMessageList", StringComparison.InvariantCultureIgnoreCase)).Id;

            IRepository<SystemListValue> repository = unitOfWork.GetRepository<SystemListValue>();
            SystemListValue systemListValue = new SystemListValue();
            if (systemListId != Guid.Empty)
            {
                systemListValue.SystemListId = systemListId;
                systemListValue.Name = errorResponseMessage.ToString();
                systemListValue.Description = errorResponseMessage.ToString();
                systemListValue.AdditionalInfo = "";
                systemListValue.DeactivateOn = null;
                SystemListValue inserted = systemListValue;
                repository.Insert(inserted);
                unitOfWork.Save();
            }

        }
    }
}