//using Insite.Core.Localization;
//using Insite.Core.Plugins.EntityUtilities;
//using Insite.Core.SystemSetting.Groups.SiteConfigurations;
//using Insite.WebFramework.Templating;
//using LeggettAndPlatt.Extensions.CustomSettings;
//using LeggettAndPlatt.Extensions.Plugins.Emails;
//using LeggettAndPlatt.PinPointe.Models;
//using LeggettAndPlatt.PinPointe.Services.Interfaces;
//using LeggettAndPlatt.Test.TestBaseHelper;
//using Moq;
//using NUnit.Framework;
//using System;
//using LeggettAndPlatt.Extensions.Common;
//using System.Collections.Generic;
//using System.Linq;
//using System.Reflection;
//using Insite.Plugins.Emails;
//using System.Text;
//using System.Threading.Tasks;
//using Insite.Core.Interfaces.Data;
//using Insite.Core.Interfaces.Plugins.Emails;

namespace LeggettAndPlatt.Test.Plugins.Emails
{
    //[TestFixture]
    //public class EmailServiceDriftTest : TestBase
    //{
    //    private EmailServiceDrift emailServiceDrift;
    //    private Mock<PinPointeSettings> pinPointeSettings;
    //    private Mock<IPinPointeService> pinPointeService;

    //    private string userEmail;
    //    public override void SetUp()
    //    {
    //        var emailTemplateUtilities = new Mock<IEmailTemplateUtilities>();
    //        var contentManagerUtilities = new Mock<IContentManagerUtilities>();
    //        var entityTranslationService = new Mock<IEntityTranslationService>();

    //        var commonSettings = new Mock<CommonSettings>();
    //        var orderSettings = new Mock<OrderSettings>();
    //        var emailService = new Mock<IEmailService>();
    //        var unitOfWorkFactory = new Mock<IUnitOfWorkFactory>();
    //        var emailsSettings = new Mock<EmailsSettings>();
    //        var emailHelper = new EmailHelper(commonSettings.Object, unitOfWorkFactory.Object, orderSettings.Object);

    //        var emailTemplateRenderer = new Mock<Lazy<IEmailTemplateRenderer>>();
    //        pinPointeSettings = new Mock<PinPointeSettings>();
    //        pinPointeService = new Mock<IPinPointeService>();

    //        //pinPointeSettings.Setup(x => x.PinpointErrorEmails).Returns(true);
    //        userEmail = "abc@gmail.com";

    //        SetupPinPointeService(userEmail);

    //        emailServiceDrift = new EmailServiceDrift(emailTemplateUtilities.Object, contentManagerUtilities.Object, entityTranslationService.Object, emailsSettings.Object, emailTemplateRenderer.Object, pinPointeSettings.Object, pinPointeService.Object, emailHelper);
    //    }

    //    [TestCase]
    //    public void PinPointeAddSubscriber_UserEmail_ReturnsTrue()
    //    {
    //        var output = typeof(EmailServiceDrift)
    //            .GetMethod("PinPointeAddSubscriber", BindingFlags.NonPublic | BindingFlags.Instance)
    //            .Invoke(emailServiceDrift, new object[1] { userEmail });

    //        Assert.That(output, Is.EqualTo(true));
    //    }


    //    [TestCase]
    //    public void PinPointeAddSubscriber_UserEmailEmpty_ReturnsFalse()
    //    {
    //        var output = typeof(EmailServiceDrift)
    //            .GetMethod("PinPointeAddSubscriber", BindingFlags.NonPublic | BindingFlags.Instance)
    //            .Invoke(emailServiceDrift, new object[1] { "" });

    //        Assert.That(output, Is.EqualTo(false));
    //    }

    //    [TestCase]
    //    public void PinPointeUnsubscribeSubscriber_UserEmail_ReturnsTrue()
    //    {
    //        var output = typeof(EmailServiceDrift)
    //            .GetMethod("PinPointeUnsubscribeSubscriber", BindingFlags.NonPublic | BindingFlags.Instance)
    //            .Invoke(emailServiceDrift, new object[1] { userEmail });

    //        Assert.That(output, Is.EqualTo(true));
    //    }

    //    [TestCase]
    //    public void PinPointeUnsubscribeSubscriber_UserEmailEmpty_ReturnsFalse()
    //    {
    //        var output = typeof(EmailServiceDrift)
    //            .GetMethod("PinPointeUnsubscribeSubscriber", BindingFlags.NonPublic | BindingFlags.Instance)
    //            .Invoke(emailServiceDrift, new object[1] { "" });

    //        Assert.That(output, Is.EqualTo(false));
    //    }



    //    private void SetupPinPointeService(string userEmail)
    //    {
    //        PinPointeResponseModel pinPointeResponseModel = new PinPointeResponseModel() { Status = "Success" };
    //        PinPointeResponseModel pinPointeResponseModelfail = new PinPointeResponseModel() { Status = "Fail" };

    //        pinPointeService.Setup(s => s.AddSubscriberToList(It.IsAny<PinPointeRequestModel>(), It.IsAny<string>())).Returns(pinPointeResponseModel);
    //        pinPointeService.Setup(s => s.AddSubscriberToList(It.Is<PinPointeRequestModel>(x => x.Details.EmailAddress.Equals("")), It.IsAny<string>())).Returns(pinPointeResponseModelfail);

    //        pinPointeService.Setup(s => s.UnsubscribeSubscriberFromList(It.IsAny<PinPonteUnSubscriberRequestModel>(), It.IsAny<string>())).Returns(pinPointeResponseModel);
    //        pinPointeService.Setup(s => s.UnsubscribeSubscriberFromList(It.Is<PinPonteUnSubscriberRequestModel>(x => x.Details.EmailAddress.Equals("")), It.IsAny<string>())).Returns(pinPointeResponseModelfail);

    //    }


    //}
}
