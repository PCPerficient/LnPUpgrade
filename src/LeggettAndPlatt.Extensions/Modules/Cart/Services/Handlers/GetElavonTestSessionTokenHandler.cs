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
    [DependencyName("GetElavonTestSessionTokenHandler")]
    public class GetElavonTestSessionTokenHandler : HandlerBase<ElavonSessionTokenParameter, ElavonSessionTokenResult>
    {
        private readonly ElavonSettings ElavonSettings;
        private readonly IEmailService EmailService;
        private readonly ICartService CartService;
        private readonly CustomPropertyHelper CustomPropertyHelper;
        private readonly ICartOrderProviderFactory CartOrderProviderFactory;

        public GetElavonTestSessionTokenHandler(ElavonSettings elavonSettings, ICartService cartService, IEmailService emailService, CustomPropertyHelper customPropertyHelper, ICartOrderProviderFactory cartOrderProviderFactory)
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
                return 560;
            }
        }

        public override ElavonSessionTokenResult Execute(IUnitOfWork unitOfWork, ElavonSessionTokenParameter parameter, ElavonSessionTokenResult result)
        {
            try
            {
                LogHelper.For((object)this).Info($"Test GetElavonSessionTokenHandler Inside Test handler call");
                result.ElavonToken = GetElavonSessionToken(result);

                this.GetSystemListResult(unitOfWork, parameter, result);

                result.ElavonAcceptAVSResponseCode = ElavonSettings.ElavonAcceptAVSResponseCode;
                result.ElavonAcceptCVVResponseCode = ElavonSettings.ElavonAcceptCVVResponseCode;
            }
            catch (Exception ex)
            {
                LogHelper.For((object)this).Info($"Test GetElavonSessionTokenHandler Inside Test handler call exception");
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                result.ElavonToken = "";
            }

            return result;
        }

        private string GetElavonSessionToken(ElavonSessionTokenResult result)
        {
            string tokenUrl = "https://api.demo.convergepay.com/hosted-payments/transaction_token";
            WebClient client = new WebClient();
            var parameters = new NameValueCollection();

            decimal ssl_amount = 0;
            string ssl_transaction_type = "CCSALE";


            ssl_amount = 100;
            parameters.Add("ssl_merchant_id", "508933");
            parameters.Add("ssl_user_id", "omsapiuser");
            parameters.Add("ssl_pin", "QPQB2SZD1JC9ZMR4OKRADB40BHDWQLUFWL59AMB1VT5PS2Z96UPLQPK1647SDUTY");
            parameters.Add("ssl_transaction_type", ssl_transaction_type);
            parameters.Add("ssl_amount", ssl_amount.ToString());

            LogHelper.For((object)this).Info($"Test GetElavonTestSessionTokenHandler TokenUrl {tokenUrl}");

         //   LogHelper.For((object)this).Info($"Test GetElavonTestSessionTokenHandler Parameters {parameters}");

            LogHelper.For((object)this).Info((object)tokenUrl, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.GetElavonTestSessionTokenHandler - Elavon Session Token Url");

         //  LogHelper.For((object)this).Info((object)parameters, "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.GetElavonTestSessionTokenHandler - Elavon Session Token Generate Paramaters");


            ServicePointManager.ServerCertificateValidationCallback = delegate (object s, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) { return true; };
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

            var response_data = client.UploadValues(tokenUrl, "post", parameters);
           //  LogHelper.For((object)this).Info((object)UnicodeEncoding.UTF8.GetString(response_data), "LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.GetElavonTestSessionTokenHandler - Elavon Session Token Response");
            LogHelper.For((object)this).Info($"Test GetElavonTestSessionTokenHandler Parameters {UnicodeEncoding.UTF8.GetString(response_data)}");
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
            this.NextHandler.Execute(unitOfWork, parameter, result);
        }
    }
}
