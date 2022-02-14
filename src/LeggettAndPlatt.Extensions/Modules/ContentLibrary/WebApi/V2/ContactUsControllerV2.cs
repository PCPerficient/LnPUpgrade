using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Localization;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using Insite.WebFramework.Mvc;
using LeggettAndPlatt.Extensions.Extensions;
using System;
using System.Dynamic;
using System.Linq.Expressions;
using System.Reflection;
using System.Web.Mvc;

namespace LeggettAndPlatt.Extensions.Modules.ContentLibrary.WebApi.V2
{
    public class ContactUsController : BaseController
    {
        protected readonly IEmailService EmailService;

        protected readonly IEntityTranslationService EntityTranslationService;

        public ContactUsController(IUnitOfWorkFactory unitOfWorkFactory, IEmailService emailService, IEntityTranslationService entityTranslationService) : base(unitOfWorkFactory)
        {
            this.EmailService = emailService;
            this.EntityTranslationService = entityTranslationService;
        }

        private void SendEmail(string firstName, string lastName, string message, string topic, string emailAddress, string emailTo)
        {
            dynamic expandoObjects = new ExpandoObject();
            expandoObjects.FirstName = firstName;
            expandoObjects.LastName = lastName;
            expandoObjects.Email = emailAddress;
            expandoObjects.Topic = topic;
            expandoObjects.Message = message;
            EmailList orCreateByName = this.UnitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName("ContactUsTemplate", "Contact Us", "");
            IEmailService emailService = this.EmailService;
            Guid id = orCreateByName.Id;
            string[] strArrays = emailTo.Split(new char[] { ',' });
            IEntityTranslationService entityTranslationService = this.EntityTranslationService;
            ParameterExpression parameterExpression = Expression.Parameter(typeof(EmailList), "o");

            SendEmailListParameter sendEmailListParameter = new SendEmailListParameter();
            sendEmailListParameter.EmailListId = id;
            sendEmailListParameter.ToAddresses = strArrays;
            sendEmailListParameter.UnitOfWork = this.UnitOfWork;
            sendEmailListParameter.Subject = string.Format("{0}: {1}", entityTranslationService.TranslateProperty<EmailList>(orCreateByName, Expression.Lambda<Func<EmailList, string>>(Expression.Property(parameterExpression, (MethodInfo)MethodBase.GetMethodFromHandle(typeof(EmailList).GetMethod("get_Subject").MethodHandle)), new ParameterExpression[] { parameterExpression })), topic);
            sendEmailListParameter.TemplateWebsiteId = SiteContext.Current.WebsiteDto?.Id;
            sendEmailListParameter.TemplateModel = expandoObjects;
            sendEmailListParameter.Attachments = null;

            emailService.SendEmailList(sendEmailListParameter);
        }

        [ValidateAntiForgeryForContent]
        [HttpPost]
        public virtual ActionResult Submit(string firstName, string lastName, string message, string topic, string emailAddress, string emailTo)
        {
            this.SendEmail(firstName, lastName, message, topic, emailAddress, emailTo);
            return base.Json(new { Success = true });
        }
    }
}
