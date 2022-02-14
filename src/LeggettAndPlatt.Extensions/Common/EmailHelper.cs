using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using System;
using System.Collections.Generic;
using LeggettAndPlatt.Extensions.CustomSettings;
using Insite.Plugins.Emails;
using Insite.Core.Interfaces.Plugins.Emails;
using System.Linq;

namespace LeggettAndPlatt.Extensions.Common
{
    public class EmailHelper
    {
        protected readonly IUnitOfWorkFactory UnitOfWorkFactory;
        protected readonly IUnitOfWork UnitOfWork;
        protected readonly CommonSettings CommonSettings;
        protected readonly OrderSettings OrderSettings;
        public EmailHelper(CommonSettings commonSetting, IUnitOfWorkFactory unitOfWorkFactory, OrderSettings orderSettings)
        {
            this.UnitOfWorkFactory = unitOfWorkFactory;
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.CommonSettings = commonSetting;
            this.OrderSettings = orderSettings;
        }

        public void ErrorEmail(dynamic obj1, IEmailService emailService)
        {
            EmailList byName = this.UnitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName("ErrorEmails", "Error occured in application", "");
            Guid? id = SiteContext.Current.WebsiteDto?.Id;
            List<string> emailList = new List<string>();
            emailList.Add(this.CommonSettings.ErrorEmailsSendTo);

            SendEmailListParameter sendEmailListParameter = new SendEmailListParameter();
            sendEmailListParameter.EmailListId = byName.Id;
            sendEmailListParameter.ToAddresses = emailList;
            sendEmailListParameter.UnitOfWork = this.UnitOfWork;
            sendEmailListParameter.Subject = obj1.MailSubject;
            sendEmailListParameter.TemplateWebsiteId = id;
            sendEmailListParameter.TemplateModel = obj1;
            sendEmailListParameter.Attachments = null;

            emailService.SendEmailList(sendEmailListParameter);
        }

        /// <summary>
        /// We are getting the enterprise code from OMS setting and concating enterprise code to email template name
        /// </summary>
        /// <param name="obj1"></param>
        /// <param name="emailService"></param>
        public void ResetPassSuccessEmailToUser(dynamic obj1, IEmailService emailService)
        {
            Guid? id = SiteContext.Current.WebsiteDto?.Id;
            string enterpriseCode = this.OrderSettings.EnterpriseCode;
            string emailListName = String.Format("{0}_ResetPassSuccess_List", enterpriseCode);
            EmailList emailListObj = this.UnitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName(emailListName, "Reset Password Success Email", "");
            List<string> emailList = new List<string>();
            emailList.Add(obj1.UserEmail);

            SendEmailListParameter sendEmailListParameter = new SendEmailListParameter();
            sendEmailListParameter.EmailListId = emailListObj.Id;
            sendEmailListParameter.ToAddresses = emailList;
            sendEmailListParameter.UnitOfWork = this.UnitOfWork;
            sendEmailListParameter.Subject = obj1.MailSubject;
            sendEmailListParameter.TemplateWebsiteId = id;
            sendEmailListParameter.TemplateModel = obj1;
            sendEmailListParameter.Attachments = null;

            emailService.SendEmailList(sendEmailListParameter);
        }
    }
}
