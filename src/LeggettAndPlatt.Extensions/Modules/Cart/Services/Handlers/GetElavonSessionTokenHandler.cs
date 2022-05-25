using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using LeggettAndPlatt.Extensions.CustomSettings;
using Insite.Cart.Services;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Services.Handlers;
using System;
using System.Collections.Specialized;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using LeggettAndPlatt.Extensions.Common;
using Insite.Core.Plugins.Cart;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using System.Linq;
using Insite.Common.Logging;
using System.Configuration;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers
{
    [DependencyName("GetElavonSessionTokenHandler")]
    public class GetElavonSessionTokenHandler : HandlerBase<ElavonSessionTokenParameter, ElavonSessionTokenResult>
    {
        private readonly ElavonSettings ElavonSettings;
        private readonly IEmailService EmailService;
        private readonly ICartService CartService;
        private readonly CustomPropertyHelper CustomPropertyHelper;
        private readonly ICartOrderProviderFactory CartOrderProviderFactory;

        public GetElavonSessionTokenHandler(ElavonSettings elavonSettings, ICartService cartService, IEmailService emailService, CustomPropertyHelper customPropertyHelper, ICartOrderProviderFactory cartOrderProviderFactory)
        {
            this.ElavonSettings = elavonSettings;
            this.CartService = cartService;
            this.EmailService = emailService;
            this.CustomPropertyHelper = customPropertyHelper;
            this.CartOrderProviderFactory = cartOrderProviderFactory;
        }

        public override int Order
        {
            get
            {
                return 550;
            }
        }

        public override ElavonSessionTokenResult Execute(IUnitOfWork unitOfWork, ElavonSessionTokenParameter parameter, ElavonSessionTokenResult result)
        {
            try
            {
             
                LogHelper.For((object)this).Info($"GetElavonSessionTokenHandler");
                //AppContext setting - false
                if (Convert.ToString(ConfigurationManager.AppSettings["ElavonTestApplication"]) == "true")
                {
                    LogHelper.For((object)this).Info($"GetElavonSessionTokenHandler Inside handler");
                    return this.NextHandler.Execute(unitOfWork, parameter, result);
                }
                LogHelper.For((object)this).Info($"GetElavonSessionTokenHandler Inside Actual handler");
                result.ElavonToken = GetElavonSessionToken(result);

                this.GetSystemListResult(unitOfWork, parameter, result);

                result.ElavonAcceptAVSResponseCode = ElavonSettings.ElavonAcceptAVSResponseCode;
                result.ElavonAcceptCVVResponseCode = ElavonSettings.ElavonAcceptCVVResponseCode;           
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                result.ElavonToken = "";
            }
          
            return result;
        }

        private string GetElavonSessionToken(ElavonSessionTokenResult result)
        {
            string tokenUrl = ElavonSettings.ElavonTestMode ? ElavonSettings.ElavonDemoTokenUrl : ElavonSettings.ElavonProdTokenUrl;

            WebClient client = new WebClient();
            var parameters = new NameValueCollection();

            decimal ssl_amount = 0;
            string ssl_transaction_type = "CCGETTOKEN";

            var orderTotal = this.GetOrderTotal();
            if (orderTotal > 0)
            {               
                ssl_amount = orderTotal;
            }

            parameters.Add("ssl_merchant_id", ElavonSettings.ElavonSSLMerchantId);
            parameters.Add("ssl_user_id", ElavonSettings.ElavonSSLUserId);
            parameters.Add("ssl_pin", ElavonSettings.ElavonSSLPinId);
            parameters.Add("ssl_transaction_type", ssl_transaction_type);
            parameters.Add("ssl_amount", ssl_amount.ToString());
            parameters.Add("ssl_vendor_id", ElavonSettings.ElavonVendorId);
            parameters.Add("ssl_vendor_app_name", ElavonSettings.ElavonSSLVendorAppName);
            parameters.Add("ssl_vendor_app_version", ElavonSettings.ElavonSSLVendorAppVersion.ToString());
          

            ServicePointManager.ServerCertificateValidationCallback = delegate (object s, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) { return true; };
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

            var response_data = client.UploadValues(tokenUrl, "post", parameters);
                      
            if (this.ElavonSettings.LogEvalonPaymentResponse)
            {
                string[] values = null;
                string strr = "";
                foreach (string key in parameters.Keys)
                {
                    values = parameters.GetValues(key);
                    foreach (string value in values)
                    {
                        strr = strr + "'" + key + " : " + value + "',";
                    }
                }
                LogHelper.For((object)this).Info((object)strr, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.GetElavonSessionTokenHandler - Elavon Session Token Generate Paramaters");
            }

            result.ElavonTransactionType = ssl_transaction_type;

            return UnicodeEncoding.UTF8.GetString(response_data);
        }

        private decimal GetOrderTotal()
        {
            decimal orderTotal = 0;
            ICartOrderProvider cartOrderProvider = this.CartOrderProviderFactory.GetCartOrderProvider();
            CustomerOrder customerOrder = cartOrderProvider.GetCartOrder();

            string isTaxTBD = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameIsTaxTBD, customerOrder);
            if (!string.IsNullOrEmpty(isTaxTBD) && isTaxTBD.Equals("true", StringComparison.InvariantCultureIgnoreCase))
            {
                orderTotal = 0;
            }
            else
            {
                orderTotal = CartService.GetCart(new Insite.Cart.Services.Parameters.GetCartParameter()).OrderGrandTotal;
            }

            return orderTotal;
        }

        public void GetSystemListResult(IUnitOfWork unitOfWork, ElavonSessionTokenParameter parameter, ElavonSessionTokenResult result)
        {
            var systemList = unitOfWork.GetTypedRepository<ISystemListRepository>().GetActiveSystemListValues("ElavonErrorMessageList").Select(s => new { s.Name, s.Description }).ToList();
            var dictionary = systemList.ToDictionary(x => x.Name.Replace(" ", "_").ToLower(), x => x.Description);
            result.ElavonResponseCodes = dictionary;

            var elavon3DS2ErrorCodesSystemList = unitOfWork.GetTypedRepository<ISystemListRepository>().GetActiveSystemListValues("Elavon3DS2ErrorCodes").Select(s => new { s.Name, s.Description }).ToList();
            var elavon3DS2ErrorCodesDictionary = elavon3DS2ErrorCodesSystemList.ToDictionary(x => x.Name.Replace(" ", "_").ToLower(), x => x.Description);
            result.Elavon3DS2ErrorCodes = elavon3DS2ErrorCodesDictionary;

            var elavonAVSResponseCodesSystemList = unitOfWork.GetTypedRepository<ISystemListRepository>().GetActiveSystemListValues("ElavonAVSResponseCodes").Select(s => new { s.Name, s.Description }).ToList();
            var elavonAVSResponseCodesDictionary = elavonAVSResponseCodesSystemList.ToDictionary(x => x.Name.Replace(" ", "_").ToLower(), x => x.Description);
            result.ElavonAVSResponseCodes = elavonAVSResponseCodesDictionary;

            this.NextHandler.Execute(unitOfWork, parameter, result);
        }
    }
}
