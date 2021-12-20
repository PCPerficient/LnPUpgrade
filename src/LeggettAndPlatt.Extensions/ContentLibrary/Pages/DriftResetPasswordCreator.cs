using LeggettAndPlatt.Extensions.ContentLibrary.Widgets;
using Insite.Common.Providers;
using Insite.ContentLibrary.Pages;
using Insite.WebFramework.Content;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.ContentLibrary.Pages
{
    public class DriftResetPasswordCreator : AbstractContentCreator<DriftResetPasswordPage>
    {
        protected override DriftResetPasswordPage Create()
        {
            try
            {
                DateTimeOffset now = DateTimeProvider.Current.Now;
                DriftResetPasswordPage driftResetPassPage = this.InitializePageWithParentType<DriftResetPasswordPage>(typeof(HomePage));
                driftResetPassPage.Title = "Reset Password Page";
                driftResetPassPage.Name = "DriftResetPasswordPage";
                driftResetPassPage.Url = "/Reset-Password-Page";
                driftResetPassPage.ExcludeFromNavigation = true;
                driftResetPassPage.ExcludeFromSignInRequired = true;
                this.SaveItem(driftResetPassPage, now);

                return driftResetPassPage;
            }
            catch (Exception ex)
            {

                throw ex;
            }
          
        }
    }
}
