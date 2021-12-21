using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Plugins.PaymentGateway;
using Insite.Core.Plugins.PaymentGateway.Dtos;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Core.SystemSetting.Groups.OrderManagement;
using Insite.Data.Entities;
using Insite.Payments.Services;
using Insite.Payments.Services.Parameters;
using Insite.Payments.Services.Results;
using System;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler
{
    [DependencyName("ProcessCreditCardTransactions")]
    public class DriftProcessCreditCardTransactions : HandlerBase<UpdateCartParameter, UpdateCartResult>
    {
        private readonly Lazy<IPaymentService> paymentService;
        private readonly ICustomerOrderUtilities customerOrderUtilities;
        private readonly PaymentSettings paymentSettings;
        private readonly CheckoutSettings checkoutSettings;

        public override int Order
        {
            get
            {
                return 2800;
            }
        }

        public DriftProcessCreditCardTransactions(Lazy<IPaymentService> paymentService, ICustomerOrderUtilities customerOrderUtilities, PaymentSettings paymentSettings, CheckoutSettings checkoutSettings)
        {
            this.checkoutSettings = checkoutSettings;
            this.paymentService = paymentService;
            this.customerOrderUtilities = customerOrderUtilities;
            this.paymentSettings = paymentSettings;
        }

        public override UpdateCartResult Execute(IUnitOfWork unitOfWork, UpdateCartParameter parameter, UpdateCartResult result)
        {
            if (!parameter.Status.EqualsIgnoreCase("Submitted"))
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            CustomerOrder cart = result.GetCartResult.Cart;
            Decimal orderTotalDue;
            if (parameter.CreditCard == null || !parameter.IsPayPal && parameter.CreditCard.CardNumber.IsBlank() && parameter.PaymentProfileId.IsBlank() || (orderTotalDue = this.customerOrderUtilities.GetOrderTotalDue(cart)) <= Decimal.Zero)
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            if (parameter.IsPayPal)
            {
                parameter.CreditCard = parameter.CreditCard ?? new CreditCardDto();
                parameter.CreditCard.CardType = "PayPal";
                parameter.CreditCard.CardHolderName = parameter.PayPalPayerId;
                parameter.CreditCard.SecurityCode = parameter.PayPalToken;
            }
            if (!this.paymentSettings.SubmitSaleTransaction && this.checkoutSettings.IncreaseCreditCardAuthorizationAmount && this.checkoutSettings.AmountOfIncrease > 0M)
            {
                if (this.checkoutSettings.IncreaseCreditCardAuthorizationType == IncreaseType.Amount)
                    orderTotalDue += this.checkoutSettings.AmountOfIncrease;
                else
                    orderTotalDue *= 1M + this.checkoutSettings.AmountOfIncrease / 100M;
            }

            IPaymentService paymentService1 = this.paymentService.Value;

            AddPaymentTransactionParameter parameter1 = new AddPaymentTransactionParameter();
            parameter1.TransactionType = this.paymentSettings.SubmitSaleTransaction ? TransactionType.Sale : TransactionType.Authorization;
            parameter1.ReferenceNumber = cart.OrderNumber;
            Insite.Data.Entities.Currency currency1 = cart.Currency;
            parameter1.CurrencyCode = (currency1 != null ? currency1.CurrencyCode : (string)null) ?? string.Empty;
            parameter1.CreditCard = parameter.CreditCard;
            parameter1.PaymentProfileId = parameter.PaymentProfileId;
            parameter1.Amount = orderTotalDue;


            AddPaymentTransactionResult transactionResult = paymentService1.AddPaymentTransaction(parameter1);

            if (transactionResult.ResultCode != ResultCode.Success)
                return this.CreateErrorServiceResult<UpdateCartResult>(result, transactionResult.SubCode, transactionResult.Message);
            if (transactionResult.CreditCardTransaction != null && result.Properties.ContainsKey("ElavonRespMessage"))
            {
                transactionResult.CreditCardTransaction.CustomerOrderId = new Guid?(cart.Id);
              
                transactionResult.CreditCardTransaction.ResponseString = result.Properties["ElavonRespMessage"];
                transactionResult.CreditCardTransaction.OrigId = result.Properties["ElavonResponseType"];
            }
            if (parameter.StorePaymentProfile && parameter.PaymentMethod != null && parameter.PaymentMethod.IsCreditCard)
            {
                IPaymentService paymentService2 = this.paymentService.Value;
                AddPaymentProfileParameter parameter2 = new AddPaymentProfileParameter();
                parameter2.BillToId = new Guid?(cart.CustomerId);
                Insite.Data.Entities.Currency currency2 = cart.Currency;
                parameter2.CurrencyCode = currency2 != null ? currency2.CurrencyCode : (string)null;
                parameter2.CreditCard = parameter.CreditCard;
                paymentService2.AddPaymentProfile(parameter2);
            }
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }
    }
}
