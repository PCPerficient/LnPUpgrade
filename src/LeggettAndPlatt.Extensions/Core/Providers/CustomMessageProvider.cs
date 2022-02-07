using Insite.Core.Providers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Core.Providers
{
    public class CustomMessageProvider : MessageProvider
    {
        public new static CustomMessageProvider Current { get; } = new CustomMessageProvider();
        public virtual string ElavonLevel3APiErrorMessage => GetMessage("LNP_Elavon_Level3API_Error_Message", "Something went wrong while placing the order, Please contact to Administrator.");
        public string ReCaptcha_RequiredErrorMessage => this.GetMessage(nameof(ReCaptcha_RequiredErrorMessage), "Captcha is required.");
    }
}
