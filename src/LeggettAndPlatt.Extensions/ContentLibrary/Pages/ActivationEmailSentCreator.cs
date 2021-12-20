using Insite.Common.Providers;
using Insite.ContentLibrary.Pages;
using Insite.ContentLibrary.Widgets;
using Insite.WebFramework.Content;
using System;

namespace LeggettAndPlatt.Extensions.ContentLibrary.Pages
{
    public class ActivationEmailSentCreator : AbstractContentCreator<ActivationEmailSentPage>
    {
        protected override ActivationEmailSentPage Create()
        {
            DateTimeOffset now = DateTimeProvider.Current.Now;
            ActivationEmailSentPage activationEmailSent = this.InitializePageWithParentType<ActivationEmailSentPage>(typeof(HomePage), "Standard");
            activationEmailSent.Name = "Activation Email Sent";
            activationEmailSent.Title = "Activation Email Sent";
            activationEmailSent.Url = "/ActivationEmailSent";
            activationEmailSent.ExcludeFromNavigation = true;
            activationEmailSent.ExcludeFromSignInRequired = true;
            this.SaveItem((ContentItemModel)activationEmailSent, now);

            //Added Rich Content
            RichContent richContents = this.InitializeWidget<RichContent>("Content", (ContentItemModel)activationEmailSent, "");
            richContents.Body = "<div>\r\n    <h2> Activation Email Sent.Check Email. </h2></div>";
            this.SaveItem((ContentItemModel)richContents, now);

            return activationEmailSent;
        }
    }
}
