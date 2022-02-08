using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(Label = "Elavon Settings", PrimaryGroupName = "Custom Settings")]
    public class ElavonSettings : BaseSettingsGroup
    {

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Demo token URL", DisplayName = "Elavon Demo Token Url", IsGlobal = false)]
        public virtual string ElavonDemoTokenUrl
        {
            get
            {
                return this.GetValue<string>("https://demo.convergepay.com/hosted-payments/transaction_token", nameof(ElavonDemoTokenUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Prod token URL", DisplayName = "Elavon Prod Token Url", IsGlobal = false)]
        public virtual string ElavonProdTokenUrl
        {
            get
            {
                return this.GetValue<string>("https://www.convergepay.com/hosted-payments/transaction_token", nameof(ElavonProdTokenUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Demo transaction URL", DisplayName = "Elavon Demo Transaction Url", IsGlobal = false)]
        public virtual string ElavonDemoTransactionUrl
        {
            get
            {
                return this.GetValue<string>("https://demo.convergepay.com/hosted-payments/Checkout.js", nameof(ElavonDemoTransactionUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Prod transaction URL", DisplayName = "Elavon Prod Transaction Url", IsGlobal = false)]
        public virtual string ElavonProdTransactionUrl
        {
            get
            {
                return this.GetValue<string>("https://www.convergepay.com/hosted-payments/Checkout.js", nameof(ElavonProdTransactionUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon XML API Demo URL", DisplayName = "Elavon XML API Demo URL", IsGlobal = false)]
        public virtual string ElavonXMLAPIDemoUrl
        {
            get
            {
                return this.GetValue<string>("https://api.demo.convergepay.com/VirtualMerchantDemo/processxml.do", nameof(ElavonXMLAPIDemoUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon XML API Production URL", DisplayName = "Elavon XML API Production URL", IsGlobal = false)]
        public virtual string ElavonXMLAPIProductionUrl
        {
            get
            {
                return this.GetValue<string>("https://api.convergepay.com/VirtualMerchant/processxml.do", nameof(ElavonXMLAPIProductionUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon SSL Merchant Id", DisplayName = "Elavon Merchant Id", IsGlobal = false)]
        public virtual string ElavonSSLMerchantId
        {
            get
            {
                return this.GetValue<string>("508933", nameof(ElavonSSLMerchantId));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon SSL User Id", DisplayName = "Elavon User Id", IsGlobal = false)]
        public virtual string ElavonSSLUserId
        {
            get
            {
                return this.GetValue<string>("apiUser", nameof(ElavonSSLUserId));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon SSL Pin Id", DisplayName = "Elavon Pin Id", IsGlobal = false)]
        public virtual string ElavonSSLPinId
        {
            get
            {
                return this.GetValue<string>("9BRNV0IQSHIH2RQE2GFUXAFIJH3LPYYW1MR9WP2PQMQCKK3NOYQ5CT1SSV8LZHMT", nameof(ElavonSSLPinId));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Vendor Id", DisplayName = "Elavon Vendor Id", IsGlobal = false)]
        public virtual string ElavonVendorId
        {
            get
            {
                return this.GetValue<string>("LEG00EC0", nameof(ElavonVendorId));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Vendor App Name", DisplayName = "Elavon Vendor App Name", IsGlobal = false)]
        public virtual string ElavonSSLVendorAppName
        {
            get
            {
                return this.GetValue<string>("InsiteCommerce", nameof(ElavonSSLVendorAppName));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Vendor App Version", DisplayName = "Elavon Vendor App Version", IsGlobal = false)]
        public virtual double ElavonSSLVendorAppVersion
        {
            get
            {
                return this.GetValue<double>(4.4, nameof(ElavonSSLVendorAppVersion));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Toggle, Description = "If set to On, system will connet to Elavon demo url", DisplayName = "Elavon Test Mode", IsGlobal = false)]
        public virtual bool ElavonTestMode
        {
            get
            {
                return this.GetValue<bool>(true, nameof(ElavonTestMode));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Toggle, Description = "If set to On, system will log Elavon Payment Response in both case (Success/Failure)", DisplayName = "Log Elavon Payment Response", IsGlobal = false)]
        public virtual bool LogEvalonPaymentResponse
        {
            get
            {
                return this.GetValue<bool>(true, nameof(LogEvalonPaymentResponse));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Toggle, Description = "If set to On, system will send email for Payment Failure Error", DisplayName = "Sent Email Elavon Payment Failure", IsGlobal = false)]
        public virtual bool SentEmailEvalonPaymentFailuer
        {
            get
            {
                return this.GetValue<bool>(true, nameof(SentEmailEvalonPaymentFailuer));
            }
        }


        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Accept AVS ResponseCode", DisplayName = "Elavon Accept AVS ResponseCode", IsGlobal = false)]
        public virtual string ElavonAcceptAVSResponseCode
        {
            get
            {
                return this.GetValue<string>("A,W,X,Y,Z", nameof(ElavonAcceptAVSResponseCode));
            }
        }


        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Accept CVV ResponseCode AllCardTypes", DisplayName = "Elavon Accept CVV ResponseCode", IsGlobal = false)]
        public virtual string ElavonAcceptCVVResponseCode
        {
            get
            {
                return this.GetValue<string>("M", nameof(ElavonAcceptCVVResponseCode));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Comma separated special character that will remove before sending Level 3 data to Elavon", DisplayName = "Special Characters", IsGlobal = false)]
        public virtual string SpecialCharacters
        {
            get
            {
                return this.GetValue<string>("®,™,©,&", nameof(SpecialCharacters));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Demo 3DS2 JS URL", DisplayName = "Elavon Demo 3DS2 JS Url", IsGlobal = false)]
        public virtual string ElavonDemo3DS2JSUrl
        {
            get
            {
                return this.GetValue<string>("https://dev.libs.fraud.eu.elavonaws.com/0.9.8/3ds2-web-sdk.min.js", nameof(ElavonDemo3DS2JSUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Prod 3DS2 JS URL", DisplayName = "Elavon Prod 3DS2 JS Url", IsGlobal = false)]
        public virtual string ElavonProd3DS2JSUrl
        {
            get
            {
                return this.GetValue<string>("https://libs.fraud.elavongateway.com/sdk-web-js/1.0.5/3ds2-web-sdk.min.js", nameof(ElavonProd3DS2JSUrl));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Demo 3DS2 Gateway", DisplayName = "Elavon Demo 3DS2 Gateway", IsGlobal = false)]
        public virtual string ElavonDemo3DS2Gateway
        {
            get
            {
                return this.GetValue<string>("https://uat.gw.fraud.eu.elavonaws.com/3ds2", nameof(ElavonDemo3DS2Gateway));
            }
        }

        [SettingsField(ControlType = SystemSettingControlType.Text, Description = "Elavon Prod 3DS2 Gateway", DisplayName = "Elavon Prod 3DS2 Gateway", IsGlobal = false)]
        public virtual string ElavonProd3DS2Gateway
        {
            get
            {
                return this.GetValue<string>("https://gw.fraud.elavongateway.com/3ds2", nameof(ElavonProd3DS2Gateway));
            }
        }
    }
}
