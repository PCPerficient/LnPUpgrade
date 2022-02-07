using Insite.Common.Helpers;
using Insite.Common.Providers;
using Insite.Core.Context;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Utilities;
using Insite.Core.SystemSetting.Groups.SystemSettings;
using Insite.Data.Entities.Dtos;
using LeggettAndPlatt.Extensions.CustomSettings;
using Newtonsoft.Json;
using System;
using System.IO;
using System.Net;
using System.Reflection;

namespace LeggettAndPlatt.Extensions.Plugins.ReCaptcha
{
    class ReCaptchaService : IReCaptchaService, IDependency, IExtension
    {
        private const string VerifyUrl = "https://www.google.com/recaptcha/api/siteverify";
        private readonly ICookieManager cookieManager;
        protected readonly RecaptchaSetting reCaptchSetting;
        public ReCaptchaService(ICookieManager cookieManager, RecaptchaSetting googleReCaptchSetting)
        {
            this.cookieManager = cookieManager;
            this.reCaptchSetting = googleReCaptchSetting;
        }

        public virtual bool ValidateRequest(string location)
        {
            UserProfileDto userProfileDto = SiteContext.Current.UserProfileDto ?? SiteContext.Current.RememberedUserProfileDto;
            if (userProfileDto != null && !userProfileDto.IsGuest || (this.CheckVerified() || !this.NeedToCheckReCaptchaOnServerSideForLocation(location)))
                return true;
            int num = this.VerifyReCaptchaResponse() ? 1 : 0;
            if (num == 0)
                return num != 0;
            this.SetVerified();
            return num != 0;
        }

        public virtual bool CheckVerified()
        {
            try
            {
                if ((DateTimeOffset)DateTime.Parse(EncryptionHelper.DecryptAes(this.cookieManager.Get("g-recaptcha-verified"))).AddDays(1.0) > DateTimeProvider.Current.Now.ToUniversalTime())
                    return true;
            }
            catch
            {
                return false;
            }
            return false;
        }

        public virtual void SetVerified()
        {
            DateTimeOffset dateTimeOffset = DateTimeProvider.Current.Now;
            dateTimeOffset = dateTimeOffset.ToUniversalTime();
            this.cookieManager.Add("g-recaptcha-verified", EncryptionHelper.EncryptAes(dateTimeOffset.ToString()));
        }

        private bool VerifyReCaptchaResponse()
        {
            string str1 = this.cookieManager.Get("g-recaptcha-response");
            if (str1.IsBlank())
                return false;
            string str2 = "secret=" + this.reCaptchSetting.ReCaptchaSecretKey + "&response=" + str1;
            HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create("https://www.google.com/recaptcha/api/siteverify");
            httpWebRequest.Method = "POST";
            httpWebRequest.ContentLength = (long)str2.Length;
            httpWebRequest.ContentType = "application/x-www-form-urlencoded";
            using (StreamWriter streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
                streamWriter.Write(str2);
            using (HttpWebResponse response = (HttpWebResponse)httpWebRequest.GetResponse())
            {
                using (Stream responseStream = response.GetResponseStream())
                {
                    using (StreamReader streamReader = new StreamReader(responseStream))
                        return ((ReCaptchaResponse)JsonConvert.DeserializeObject<ReCaptchaResponse>(streamReader.ReadToEnd())).Success;
                }
            }
        }

        public virtual bool NeedToCheckReCaptchaOnClientSideForLocation(string location)
        {
            if (!this.reCaptchSetting.EnableReCaptcha || this.reCaptchSetting.ReCaptchaSiteKey.IsBlank())
            {
                return false;
            }
              
            return true;
        }

        public virtual bool NeedToCheckReCaptchaOnServerSideForLocation(string location)
        {
            if (!this.NeedToCheckReCaptchaOnClientSideForLocation(location) || this.reCaptchSetting.ReCaptchaSecretKey.IsBlank())
                return false;
            string name = "CheckReCaptchaFor" + location + "OnServerSide";
            PropertyInfo property = this.reCaptchSetting.GetType().GetProperty(name);
            return !(property == (PropertyInfo)null) && (bool)property.GetValue((object)this.reCaptchSetting);
        }
    }
}
