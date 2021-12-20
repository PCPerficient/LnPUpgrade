using Insite.Common.Providers;
using Insite.ContentLibrary.Pages;
using Insite.ContentLibrary.Widgets;
using Insite.WebFramework.Content;
using System;

namespace LeggettAndPlatt.Extensions.ContentLibrary.Pages
{
    public class ContactCustomerServiceCreator : AbstractContentCreator<ContactCustomerServicePage>
    {
        protected override ContactCustomerServicePage Create()
        {
            DateTimeOffset now = DateTimeProvider.Current.Now;
            ContactCustomerServicePage contactCustomerService = this.InitializePageWithParentType<ContactCustomerServicePage>(typeof(HomePage), "Standard");
            contactCustomerService.Name = "Contact Customer Service";
            contactCustomerService.Title = "Contact Customer Service";
            contactCustomerService.Url = "/ContactCustomerService";
            contactCustomerService.ExcludeFromNavigation = true;
            contactCustomerService.ExcludeFromSignInRequired = true;
            this.SaveItem((ContentItemModel)contactCustomerService, now);

            //Added Rich Content
            RichContent richContents = this.InitializeWidget<RichContent>("Content", (ContentItemModel)contactCustomerService, "");
            richContents.Body = "<div>\r\n    <h2> Note to contact customer service. </h2></div>";
            this.SaveItem((ContentItemModel)richContents, now);

            return contactCustomerService;
        }
    }
}
