using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Providers;
using Insite.WebFramework.Mvc;
using LeggettAndPlatt.Extensions.Extensions;
using System;
using System.Runtime.CompilerServices;
using System.Web.Mvc;

namespace LeggettAndPlatt.Extensions.Modules.ContentLibrary.WebApi.V2
{
    public class EmailController : BaseController
    {
        protected readonly IEmailService EmailService;

        public EmailController(IUnitOfWorkFactory unitOfWorkFactory, IEmailService emailService) : base(unitOfWorkFactory)
        {
            this.EmailService = emailService;
        }

        [ValidateAntiForgeryForContent]
        [HttpPost]
        public ActionResult SubscribeToList(string emailAddress)
        {
            this.EmailService.SubscribeEmailToList("SubscriptionEmail", emailAddress, this.UnitOfWork);
            return null;
        }

        [HttpGet]
        public virtual ActionResult Unsubscribe(string emailAddress)
        {
            ViewBag.Email = emailAddress;
            return base.View();
        }

        [ActionName("Unsubscribe")]
        [HttpPost]
        public virtual ActionResult UnsubscribePost(string emailAddress)
        {
            this.EmailService.UnsubscribeEmailFromList("SubscriptionEmail", emailAddress ?? string.Empty, this.UnitOfWork);
            ViewBag.Message = MessageProvider.Current.Email_Unsubscribe_Success;
            return base.View("Unsubscribe");
        }
    }
}
