using Insite.Common.Providers;
using Insite.ContentLibrary.Pages;
using Insite.ContentLibrary.Widgets;
using Insite.WebFramework.Content;
using System;

namespace LeggettAndPlatt.Extensions.ContentLibrary.Pages
{
    public class ResetPasswordOrLoginCreator : AbstractContentCreator<ResetPasswordOrLoginPage>
    {
        protected override ResetPasswordOrLoginPage Create()
        {
            DateTimeOffset now = DateTimeProvider.Current.Now;
            ResetPasswordOrLoginPage resetPasswordOrLogin = this.InitializePageWithParentType<ResetPasswordOrLoginPage>(typeof(HomePage), "Standard");
            resetPasswordOrLogin.Name = "ResetPassword Or Login";
            resetPasswordOrLogin.Title = "ResetPassword Or Login";
            resetPasswordOrLogin.Url = "/ResetPasswordOrLogin";
            resetPasswordOrLogin.ExcludeFromNavigation = true;
            resetPasswordOrLogin.ExcludeFromSignInRequired = true;
            this.SaveItem((ContentItemModel)resetPasswordOrLogin, now);

            //Added Rich Content
            RichContent richContents = this.InitializeWidget<RichContent>("Content", (ContentItemModel)resetPasswordOrLogin, "");
            richContents.Body = "<div>\r\n    <h2> Display friendly error Message B  to re-set password, contact support.</h2></div>";
            this.SaveItem((ContentItemModel)richContents, now);

            return resetPasswordOrLogin;
        }
    }
}
