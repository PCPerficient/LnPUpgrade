using LeggettAndPlatt.Extensions.CustomSettings;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;

namespace LeggettAndPlatt.Extensions.Common
{
    public class GoogleRecaptchaValidator
    {
        protected readonly RecaptchaSetting _googleCaptchSetting;
        public GoogleRecaptchaValidator(RecaptchaSetting googleReCaptchSetting)
        {
            this._googleCaptchSetting = googleReCaptchSetting;
        }

        public bool ValidateGoogleReCaptcha(string gRecaptchaResponse)
        {
            HttpClient httpClient = new HttpClient();
            var res = httpClient.GetAsync($"{this._googleCaptchSetting.GoogleReCaptchaUrl}?secret={this._googleCaptchSetting.SecretKey}&response={ gRecaptchaResponse}").Result;
            if (res.StatusCode != HttpStatusCode.OK)
                return false;

            string JSONres = res.Content.ReadAsStringAsync().Result;
            dynamic JSONdata = JObject.Parse(JSONres);
            return JSONdata.success == "true";
        }
    }
}