using Insite.ContentLibrary.Widgets;
using Insite.Core.Providers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Widgets
{
    class CaptchaContactUsForm : ContactUsForm
    {
        private string captchaRequiredErrorMessage;

        public string CaptchaIsRequiredErrorMessage => this.captchaRequiredErrorMessage ?? (this.captchaRequiredErrorMessage = MessageProvider.Current.GetMessage("ContactUsForm_CaptchIsRequiredErrorMessage", "Captcha is required."));
    }
}
