using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Data.Repositories.Interfaces;
using Insite.WebFramework.Mvc;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace LeggettAndPlatt.Extensions.Controllers
{
    public class CaptchaContactUsController : BaseController
    {
        protected readonly IEmailService EmailService;

        public CaptchaContactUsController(IUnitOfWorkFactory unitOfWorkFactory, IEmailService emailService) : base(unitOfWorkFactory)
        {
            this.EmailService = emailService;
        }

        [HttpPost]
        public ActionResult Submit(string firstName, string lastName, string captcha, string message, string topic, string emailAddress, string emailTo)
        {
            bool result = this.SendEmail(firstName, lastName, captcha, message, topic, emailAddress, emailTo);

            return this.Json(new { Success = result });
        }
        private bool SendEmail(string firstName, string lastName, string captcha, string message, string topic, string emailAddress, string emailTo)
        {
            dynamic emailModel = new ExpandoObject();
            emailModel.FirstName = firstName;
            emailModel.LastName = lastName;
            emailModel.Recaptcha = captcha;
            emailModel.Email = emailAddress;
            emailModel.Topic = topic;
            emailModel.Message = message;
            
            RecaptchaResult result = ReCaptcha.GetReCaptchaResponse(emailModel.Recaptcha, "6LcWkL8UAAAAAKOqaayJQ2idkwJOT_Wez1vv9iyq");

            if (result.Result == RecaptchaResponse.Success)
            {
                var emailList = this.UnitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName("ContactUsTemplate", "Contact Us");

                SendEmailListParameter sendEmailListParameter = new SendEmailListParameter();
                sendEmailListParameter.EmailListId = emailList.Id;
                sendEmailListParameter.ToAddresses = emailTo.Split(',');
                sendEmailListParameter.UnitOfWork = this.UnitOfWork;
                sendEmailListParameter.Subject = "Contact Us Submission: " + topic;
                sendEmailListParameter.TemplateWebsiteId = SiteContext.Current.WebsiteDto?.Id;
                sendEmailListParameter.TemplateModel = emailModel;
                sendEmailListParameter.Attachments = null;

                this.EmailService.SendEmailList(sendEmailListParameter);
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
