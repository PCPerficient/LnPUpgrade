using System.Collections.Generic;
using LeggettAndPlatt.Extensions.CustomSettings;

namespace LeggettAndPlatt.Extensions.Common
{
    public static class SettingHelper
    {
        public static Dictionary<string, string> GetNavigationLinks()
        {
            NavigationSetting navigationSetting = new CustomSettings.NavigationSetting();
            Dictionary<string, string> customProperty = new Dictionary<string, string>();

            customProperty.Add("navigationLinks", navigationSetting.DisplayBreadcrumbsInPDP.ToString());

            return customProperty;
        }

        public static Dictionary<string, string> GetElavonSetting()
        {
            ElavonSettings elavonSetting = new ElavonSettings();
            Dictionary<string, string> customProperty = new Dictionary<string, string>();

            customProperty.Add("elavonSettingPaymentFailuerMail", elavonSetting.SentEmailEvalonPaymentFailuer.ToString());
            customProperty.Add("logEvalonPaymentResponse", elavonSetting.LogEvalonPaymentResponse.ToString());

            return customProperty;
        }

        public static Dictionary<string, string> GetAbandonedCartSetting()
        {
            AbandonedCartSetting abandonedCartSetting = new AbandonedCartSetting();
            Dictionary<string, string> customProperty = new Dictionary<string, string>();

            customProperty.Add("abandonedCartIntervalTimeInSecond", abandonedCartSetting.AbandonedCartIntervalTimeInSecond.ToString());
            customProperty.Add("abandonedCartNoOfTimesPopupPrompt", abandonedCartSetting.AbandonedCartNoOfTimesPopupPrompt.ToString());
            customProperty.Add("abandonedCartPopupPageURL", abandonedCartSetting.AbandonedCartPopupPageURL.ToString());
            customProperty.Add("disabledAbandonedCartPopup", abandonedCartSetting.DisabledAbandonedCartPopup.ToString());

            return customProperty;
        }

        public static Dictionary<string, string> GetShippingDisplay()
        {
            CommonSettings commonSetting = new CustomSettings.CommonSettings();
            Dictionary<string, string> customProperty = new Dictionary<string, string>();

            customProperty.Add("shippingDisplay", commonSetting.DisableShippingDisplay.ToString());
            customProperty.Add("promotionCodeFormDisplay", commonSetting.DisplayPromotionCodeFormReviewAndPayPage.ToString());

            return customProperty;
        }

        public static string GetSSLPinForElavonErrorEmail()
        {
            ElavonSettings elavonSetting = new ElavonSettings();

            string elavonSSLPin = elavonSetting.ElavonSSLPinId;
            string elavonMaskedPin = string.Concat(elavonSSLPin.Substring(0, 4), new string('*', elavonSSLPin.Length - 8), elavonSSLPin.Substring(elavonSSLPin.Length - 4));
                  
            return elavonMaskedPin;
        }
    }
}
