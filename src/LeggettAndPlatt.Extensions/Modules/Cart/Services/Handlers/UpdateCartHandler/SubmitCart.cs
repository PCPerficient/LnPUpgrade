using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Pipelines;
using Insite.Cart.Services.Results;
using Insite.Common.Providers;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Cart;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Plugins.Pipelines;
using Insite.Core.Plugins.Pipelines.Pricing;
using Insite.Core.Plugins.Pipelines.Pricing.Parameters;
using Insite.Core.Plugins.Pipelines.Pricing.Results;
using Insite.Core.Plugins.PromotionEngine;
using Insite.Core.Providers;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Core.SystemSetting.Groups.OrderManagement;
using Insite.Core.SystemSetting.Groups.Shipping;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler
{
    [DependencyName("SubmitCart")]
    public sealed class SubmitCart : HandlerBase<UpdateCartParameter, UpdateCartResult>
    {
        private readonly Lazy<ICartOrderProviderFactory> cartOrderProviderFactory;
        private readonly Lazy<IPromotionEngine> promotionEngine;
        private readonly Lazy<IProductUtilities> productUtilities;
        private readonly ICustomerOrderUtilities customerOrderUtilities;
        private readonly ICartPipeline cartPipeline;
        private readonly IPricingPipeline pricingPipeline;
        private readonly OrderManagementGeneralSettings orderManagementGeneralSettings;
        private readonly ShippingGeneralSettings shippingGeneralSettings;
        private readonly RfqSettings rfqSettings;

        public List<string> CanSubmitCartStatuses => new List<string>()
    {
      "Cart",
      "QuoteProposed",
      "Saved",
      "PunchOut",
      "PunchOutOrderRequest",
      "AwaitingApproval"
    };

        public SubmitCart(
          Lazy<IPromotionEngine> promotionEngine,
          Lazy<IProductUtilities> productUtilities,
          Lazy<ICartOrderProviderFactory> cartOrderProviderFactory,
          ICustomerOrderUtilities customerOrderUtilities,
          ICartPipeline cartPipeline,
          ShippingGeneralSettings shippingGeneralSettings,
          RfqSettings rfqSettings,
          IPricingPipeline pricingPipeline,
          OrderManagementGeneralSettings orderManagementGeneralSettings)
        {
            this.promotionEngine = promotionEngine;
            this.productUtilities = productUtilities;
            this.cartOrderProviderFactory = cartOrderProviderFactory;
            this.customerOrderUtilities = customerOrderUtilities;
            this.cartPipeline = cartPipeline;
            this.shippingGeneralSettings = shippingGeneralSettings;
            this.rfqSettings = rfqSettings;
            this.pricingPipeline = pricingPipeline;
            this.orderManagementGeneralSettings = orderManagementGeneralSettings;
        }

        public override int Order => 2300;

        public override UpdateCartResult Execute(
          IUnitOfWork unitOfWork,
          UpdateCartParameter parameter,
          UpdateCartResult result)
        {
            if (!parameter.Status.EqualsIgnoreCase("Submitted"))
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            if (SiteContext.Current.UserProfileDto == null)
                return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartServiceSignInTimedOut, MessageProvider.Current.ReviewAndPay_SignIn_TimedOut);
            CustomerOrder cart = result.GetCartResult.Cart;
            if (!cart.OrderLines.Any<OrderLine>())
                return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartServiceNoOrderLines, MessageProvider.Current.Cart_NoOrderLines);
            if (result.GetCartResult.HasRestrictedProducts)
                return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartServiceHasRestrictedOrderLine, MessageProvider.Current.Cart_ProductsCannotBePurchased);
            if (result.GetCartResult.RequiresPoNumber && result.GetCartResult.ShowPoNumber && (cart.CustomerPO.IsBlank() && !parameter.IsPayPal))
                return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartServiceCustomerPoRequired, MessageProvider.Current.ReviewAndPay_PONumber_Required);
            if (!this.shippingGeneralSettings.AllowEmptyShipping && cart.ShipVia == null)
                return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartServiceInvalidShipVia, MessageProvider.Current.Checkout_Invalid_Shipping_Selection);
            if (cart.Status.EqualsIgnoreCase("QuoteRequested"))
            {
                if (cart.Type == "Quote")
                    return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartAlreadySubmitted, "This Quote has already been Requested and can not be requested again");
                cart.Type = "Quote";
            }
            if (!this.CanSubmitCartStatuses.Contains(cart.Status))
                return this.CreateErrorServiceResult<UpdateCartResult>(result, SubCode.CartAlreadySubmitted, "This Order has already been Submitted and can not be submitted again");
            if (cart.Status.EqualsIgnoreCase("QuoteProposed"))
            {
                GetCartPricingResult cartPricing = this.pricingPipeline.GetCartPricing(new GetCartPricingParameter(cart)
                {
                    CalculateOrderTotal = false
                });
                if (cartPricing.ResultCode != ResultCode.Success)
                    return this.CreateErrorServiceResult<UpdateCartResult>(result, cartPricing.SubCode, cartPricing.Message);
                cart.QuoteExpirationDate = new DateTimeOffset?(cart.QuoteExpirationDate ?? (DateTimeOffset)DateTimeProvider.Current.Now.Date.AddDays((double)(this.rfqSettings.QuoteExpireDays + 1)).AddMinutes(-1.0));
                this.promotionEngine.Value.ClearPromotions(cart);
            }
            // PRFT Custom Code - Start - generating the customer Order number in the previous handler .
            //  this.SetCustomerOrderNumber(unitOfWork, cart);
            //PRFT Custom Code - END
            this.SetCustomerOrderInfo(unitOfWork, cart);
            cart.Status = "Submitted";
            if (cart.Type == "Order")
            {
                List<OrderLine> list = cart.OrderLines.Where<OrderLine>((Func<OrderLine, bool>)(line => this.productUtilities.Value.IsQuoteRequired(line.Product))).ToList<OrderLine>();
                this.MoveQuotedCartLinesBackToCart(cart, (IList<OrderLine>)list);
            }
            unitOfWork.Save();
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }

        private void MoveQuotedCartLinesBackToCart(CustomerOrder cart, IList<OrderLine> quotedCartLines)
        {
            CustomerOrder cartOrder = this.cartOrderProviderFactory.Value.GetCartOrderProvider().GetOrCreateCartOrder();
            foreach (OrderLine quotedCartLine in (IEnumerable<OrderLine>)quotedCartLines)
            {
                PipelineHelper.VerifyResults((PipeResultBase)this.cartPipeline.RemoveCartLine(new Insite.Cart.Services.Pipelines.Parameters.RemoveCartLineParameter()
                {
                    Cart = cart,
                    CartLine = quotedCartLine
                }));
                PipelineHelper.VerifyResults((PipeResultBase)this.cartPipeline.AddCartLine(new Insite.Cart.Services.Pipelines.Parameters.AddCartLineParameter()
                {
                    Cart = cartOrder,
                    CartLine = quotedCartLine
                }));
            }
        }

       

        private void SetCustomerOrderInfo(IUnitOfWork unitOfWork, CustomerOrder customerOrder)
        {
            if (customerOrder.PlacedByUserProfile == null)
            {
                customerOrder.PlacedByUserProfile = unitOfWork.GetRepository<UserProfile>().Get(SiteContext.Current.UserProfileDto.Id);
                customerOrder.PlacedByUserName = SiteContext.Current.UserProfileDto.UserName;
            }
            customerOrder.OrderDate = DateTimeProvider.Current.Now;
            if (!customerOrder.RequestedShipDate.HasValue)
                customerOrder.RequestedShipDate = new DateTimeOffset?(customerOrder.OrderDate);
            if (customerOrder.CurrencyId.HasValue || SiteContext.Current.CurrencyDto == null)
                return;
            this.customerOrderUtilities.SetCurrency(customerOrder, SiteContext.Current.CurrencyDto.Id);
        }
    }
}
