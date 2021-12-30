using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.PaymentGateway;
using Insite.Core.Plugins.PaymentGateway.Dtos;
using Insite.Core.Plugins.PaymentGateway.Parameters;
using Insite.Core.Plugins.PaymentGateway.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Plugins.PaymentGateway
{
    [DependencyName("Elavon")]
    public class PaymentGatewayElavon : IPaymentGateway, IDependency
    {

        public bool SupportsStoredPaymentProfiles
        {
            get
            {
                return true;
            }
        }

        public bool SupportsReversalTransaction => throw new NotImplementedException();

        public SubmitTransactionResult SubmitTransaction(SubmitTransactionParameter parameter)
        {           
            return new SubmitTransactionResult()
            {
                Success = true,
                ResponseNumber = "0",
                ResponseToken = Guid.NewGuid().ToString()
            };
        }

        public GetStoredPaymentProfileResult GetStoredPaymentProfile(GetStoredPaymentProfileParameter parameter)
        {
            return new GetStoredPaymentProfileResult()
            {
                Success = true,
                PaymentProfile = new PaymentProfileDto()
                {
                    PaymentProfileId = Guid.NewGuid().ToString(),
                    CardType = "VISA",
                    MaskedCardNumber = "XXXX-XXXX-XXXX-4444",
                    Expiration = "12/2999"
                }
            };
        }

        public StorePaymentProfileResult StorePaymentProfile(StorePaymentProfileParameter parameter)
        {
            return new StorePaymentProfileResult()
            {
                Success = true,
                CustomerProfileId = Guid.NewGuid().ToString(),
                PaymentProfileId = Guid.NewGuid().ToString()
            };
        }

        public RemoveStoredPaymentProfileResult RemoveStoredPaymentProfile(RemoveStoredPaymentProfileParameter parameter)
        {
            return new RemoveStoredPaymentProfileResult()
            {
                Success = true
            };
        }
    }
}
