using Insite.Catalog.Services.Dtos;
using Insite.Common.Helpers;
using Insite.Core.Interfaces.Localization;
using Insite.Core.Localization;
using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi.Interfaces;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos.Interfaces;
using Insite.Order.Services.Dtos;
using Insite.Order.Services.Results;
using Insite.Order.WebApi.V1.ApiModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Net.Http;
using Insite.Order.WebApi.V1.Mappers;
using Insite.Core.Interfaces.Data;

namespace LeggettAndPlatt.Extensions.Modules.Order.WebApi.V1.Mappers
{
    public class GetOrderMapperDrift : GetOrderMapper
    {
      
        public IUnitOfWork UnitOfWork;

        public GetOrderMapperDrift(ICurrencyFormatProvider currencyFormatProvider, IUrlHelper urlHelper, IObjectToObjectMapper objectToObjectMapper, ITranslationLocalizer translationLocalizer, IEntityTranslationService entityTranslationService, IUnitOfWorkFactory unitOfWorkFactory) : base(currencyFormatProvider, urlHelper, objectToObjectMapper, translationLocalizer, entityTranslationService)
        {          
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
        }

        public override OrderModel MapResult(GetOrderResult serviceResult, HttpRequestMessage request)
        {
            if (serviceResult == null)
                throw new ArgumentNullException(nameof(serviceResult));
            if (serviceResult.OrderHistory == null)
                return (OrderModel)null;
            OrderModel orderModel1 = this.ObjectToObjectMapper.Map<OrderHistory, OrderModel>(serviceResult.OrderHistory);
            orderModel1.CanAddToCart = serviceResult.CanAddToCart;
            orderModel1.CanAddAllToCart = serviceResult.CanAddAllToCart;
            orderModel1.Properties = serviceResult.Properties;
            Currency currency = serviceResult.Currency;
            orderModel1.CurrencySymbol = currency?.CurrencySymbol;
            orderModel1.OrderDiscountAmountDisplay = this.CurrencyFormatProvider.GetString(orderModel1.OrderDiscountAmount, (ICurrency)currency);
            orderModel1.ProductDiscountAmountDisplay = this.CurrencyFormatProvider.GetString(orderModel1.ProductDiscountAmount, (ICurrency)currency);
            orderModel1.OrderGrandTotalDisplay = this.CurrencyFormatProvider.GetString(orderModel1.OrderTotal, (ICurrency)currency);
            orderModel1.OrderSubTotal = orderModel1.ProductTotal - orderModel1.ProductDiscountAmount;
            orderModel1.OrderSubTotalDisplay = this.CurrencyFormatProvider.GetString(orderModel1.OrderSubTotal, (ICurrency)currency);
            orderModel1.OtherChargesDisplay = this.CurrencyFormatProvider.GetString(orderModel1.OtherCharges, (ICurrency)currency);
            orderModel1.ProductTotalDisplay = this.CurrencyFormatProvider.GetString(orderModel1.ProductTotal, (ICurrency)currency);
            orderModel1.ShippingChargesDisplay = this.CurrencyFormatProvider.GetString(orderModel1.ShippingCharges, (ICurrency)currency);
            orderModel1.HandlingChargesDisplay = this.CurrencyFormatProvider.GetString(orderModel1.HandlingCharges, (ICurrency)currency);
            orderModel1.ShippingAndHandlingDisplay = this.CurrencyFormatProvider.GetString(orderModel1.ShippingCharges + orderModel1.HandlingCharges, (ICurrency)currency);
            orderModel1.TotalTaxDisplay = this.CurrencyFormatProvider.GetString(orderModel1.TaxAmount, (ICurrency)currency);
            orderModel1.ShowTaxAndShipping = serviceResult.ShowTaxAndShipping;
            OrderModel orderModel2 = orderModel1;
            DateTimeOffset? requestedDeliveryDate = serviceResult.OrderHistory.RequestedDeliveryDate;

            DateTime? nullable = requestedDeliveryDate.HasValue ? new DateTime?(requestedDeliveryDate.GetValueOrDefault().Date) : new DateTime?();
            orderModel2.RequestedDeliveryDateDisplay = nullable;
            orderModel1.ShipViaDescription = serviceResult.ShipViaDescription;
            orderModel1.StatusDisplay = serviceResult.OrderStatusMapping == null ? this.TranslationLocalizer.TranslateLabel(orderModel1.Status) : this.ObjectToObjectMapper.Map<OrderStatusMapping, OrderStatusMappingModel>(serviceResult.OrderStatusMapping).DisplayName;
            string str1 = orderModel1.WebOrderNumber.IsBlank() ? orderModel1.ErpOrderNumber : orderModel1.WebOrderNumber;
            orderModel1.Uri = request == null ? string.Empty : this.UrlHelper.Link("OrderV1", (object)new
            {
                orderId = str1
            }, request);
            foreach (GetOrderLineResult getOrderLineResult in (IEnumerable<GetOrderLineResult>)serviceResult.GetOrderLineResults)
            {
                OrderLineModel orderLineModel = new OrderLineModel();
                if (getOrderLineResult.ProductDto != null)
                {
                    this.ObjectToObjectMapper.Map<ProductDto, OrderLineModel>(getOrderLineResult.ProductDto, orderLineModel);
                    orderLineModel.ProductUri = getOrderLineResult.ProductDto.ProductDetailUrl;
                    orderLineModel.IsActiveProduct = getOrderLineResult.ProductDto.IsActive;
                }
                this.ObjectToObjectMapper.Map<OrderHistoryLine, OrderLineModel>(getOrderLineResult.OrderHistoryLine, orderLineModel);
                orderLineModel.UnitOfMeasureDisplay = (string)null;
                orderLineModel.UnitOfMeasureDescription = (string)null;
                ProductDto productDto = getOrderLineResult.ProductDto;
                ProductUnitOfMeasureDto unitOfMeasureDto1;
                if (productDto == null)
                {
                    unitOfMeasureDto1 = (ProductUnitOfMeasureDto)null;
                }
                else
                {
                    List<ProductUnitOfMeasureDto> productUnitOfMeasures = productDto.ProductUnitOfMeasures;
                    unitOfMeasureDto1 = productUnitOfMeasures != null ? productUnitOfMeasures.FirstOrDefault<ProductUnitOfMeasureDto>((Func<ProductUnitOfMeasureDto, bool>)(x => x.UnitOfMeasure == orderLineModel.UnitOfMeasure)) : (ProductUnitOfMeasureDto)null;
                }
                ProductUnitOfMeasureDto unitOfMeasureDto2 = unitOfMeasureDto1;
                if (unitOfMeasureDto2 != null)
                {
                    orderLineModel.UnitOfMeasureDisplay = unitOfMeasureDto2.UnitOfMeasureDisplay;
                    orderLineModel.UnitOfMeasureDescription = unitOfMeasureDto2.Description;
                }
                orderLineModel.SectionOptions = getOrderLineResult.SectionOptions;
                orderLineModel.TotalRegularPriceDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.TotalRegularPrice, (ICurrency)currency);
                orderLineModel.UnitDiscountAmountDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.UnitDiscountAmount, (ICurrency)currency);
                orderLineModel.TotalDiscountAmountDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.TotalDiscountAmount, (ICurrency)currency);
                orderLineModel.ExtendedUnitNetPrice = NumberHelper.RoundCurrency(orderLineModel.UnitNetPrice * orderLineModel.QtyOrdered);
                orderLineModel.ExtendedUnitNetPriceDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.ExtendedUnitNetPrice, (ICurrency)currency);
                orderLineModel.UnitNetPriceDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.UnitNetPrice, (ICurrency)currency);
                orderLineModel.UnitListPriceDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.UnitListPrice, (ICurrency)currency);
                orderLineModel.UnitRegularPriceDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.UnitRegularPrice, (ICurrency)currency);
                orderLineModel.UnitCostDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.UnitCost, (ICurrency)currency);
                orderLineModel.OrderLineOtherChargesDisplay = this.CurrencyFormatProvider.GetString(orderLineModel.OrderLineOtherCharges, (ICurrency)currency);
                orderLineModel.MediumImagePath = this.UrlHelper.CreateCdnLinkIfCdnIsEnabled(orderLineModel.MediumImagePath);
                orderLineModel.Properties = getOrderLineResult.Properties;
                orderModel1.OrderLines.Add(orderLineModel);
            }
            foreach (OrderHistoryPromotion historyPromotion in (IEnumerable<OrderHistoryPromotion>)serviceResult.OrderHistory.OrderHistoryPromotions)
            {
                OrderPromotionModel orderPromotionModel1 = new OrderPromotionModel();
                orderPromotionModel1.Id = historyPromotion.Id.ToString();
                OrderPromotionModel orderPromotionModel2 = orderPromotionModel1;
                string str2;
                if (historyPromotion.Promotion.DisplayMessage.IsBlank())
                    str2 = this.EntityTranslationService.TranslateProperty<Promotion>(historyPromotion.Promotion, (Expression<Func<Promotion, string>>)(o => o.Name));
                else
                    str2 = this.EntityTranslationService.TranslateProperty<Promotion>(historyPromotion.Promotion, (Expression<Func<Promotion, string>>)(o => o.DisplayMessage));
                orderPromotionModel2.Name = str2;
                orderPromotionModel1.Amount = historyPromotion.Amount;
                orderPromotionModel1.AmountDisplay = this.CurrencyFormatProvider.GetString(historyPromotion.Amount ?? Decimal.Zero, (ICurrency)currency);
                orderPromotionModel1.OrderHistoryLineId = historyPromotion.OrderHistoryLineId;
                orderPromotionModel1.PromotionResultType = historyPromotion.Promotion.PromotionResults.FirstOrDefault<PromotionResult>()?.PromotionResultType;
                OrderPromotionModel orderPromotionModel3 = orderPromotionModel1;
                orderModel1.OrderPromotions.Add(orderPromotionModel3);
            }
            if (serviceResult.Shipments != null)
                orderModel1.ShipmentPackages = (ICollection<ShipmentPackageDto>)serviceResult.Shipments.SelectMany<ShipmentDto, ShipmentPackageDto>((Func<ShipmentDto, IEnumerable<ShipmentPackageDto>>)(s => (IEnumerable<ShipmentPackageDto>)s.ShipmentPackages)).OrderByDescending<ShipmentPackageDto, DateTime>((Func<ShipmentPackageDto, DateTime>)(s => s.ShipmentDate)).ToList<ShipmentPackageDto>();
            if (serviceResult.ReturnReasons != null)
                orderModel1.ReturnReasons = serviceResult.ReturnReasons;
            foreach (OrderHistoryTaxDto orderHistoryTax in (IEnumerable<OrderHistoryTaxDto>)orderModel1.OrderHistoryTaxes)
            {
                orderHistoryTax.TaxCode = this.TranslationLocalizer.TranslateLabel(orderHistoryTax.TaxCode);
                orderHistoryTax.TaxDescription = this.TranslationLocalizer.TranslateLabel(orderHistoryTax.TaxDescription);
                orderHistoryTax.TaxAmountDisplay = this.CurrencyFormatProvider.GetString(orderHistoryTax.TaxAmount, (ICurrency)currency);
            }
            //PRFT Custom Code START
            if (!string.IsNullOrEmpty(orderModel1.ShipToState) && orderModel1.ShipToState.Length > 2)
            {
                State state = this.UnitOfWork.GetRepository<State>().GetTable().FirstOrDefault(x => x.Name.Equals(orderModel1.ShipToState));
                if (state != null)
                {                
                    orderModel1.ShipToState = state.Abbreviation;
                }
            }
            if (!string.IsNullOrEmpty(orderModel1.BillToState) && orderModel1.BillToState.Length > 2)
            {
                State state = this.UnitOfWork.GetRepository<State>().GetTable().FirstOrDefault(x => x.Name.Equals(orderModel1.BillToState));
                if (state != null)
                {
                    orderModel1.BillToState = state.Abbreviation;
                }              
            }
            //PRFT Custom Code END
            return orderModel1;
        }
    }
}
