using Insite.Cart.Services.Dtos;
using Insite.Cart.Services.Results;
using Insite.Cart.WebApi.V1.ApiModels;
using Insite.Core.Interfaces.Localization;
using Insite.Core.Plugins.Utilities;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Core.WebApi;
using Insite.Core.WebApi.Interfaces;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos.Interfaces;
using System;
using System.Collections.Generic;
using System.Net.Http;
using Insite.Cart.WebApi.V1.Mappers;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers
{
    public class DriftGetCartCollectionMapper : GetCartCollectionMapper
    {
        public DriftGetCartCollectionMapper(IObjectToObjectMapper objectToObjectMapper, IUrlHelper urlHelper, ICurrencyFormatProvider currencyFormatProvider, ITranslationLocalizer translationLocalizer) : base(objectToObjectMapper, urlHelper, currencyFormatProvider, translationLocalizer)
        {
        }
        public override CartCollectionModel MapResult(GetCartCollectionResult serviceResult, HttpRequestMessage request)
        {
            CartCollectionModel cartCollectionModel1 = new CartCollectionModel();
            cartCollectionModel1.Uri = this.GetLink(serviceResult, request, serviceResult.Page);
            cartCollectionModel1.Pagination = new PaginationModel((PagingResultBase)serviceResult);
            CartCollectionModel cartCollectionModel2 = cartCollectionModel1;
            if (serviceResult.Page > 1)
                cartCollectionModel2.Pagination.PrevPageUri = this.GetLink(serviceResult, request, serviceResult.Page - 1);
            if (serviceResult.Page < serviceResult.TotalPages)
                cartCollectionModel2.Pagination.NextPageUri = this.GetLink(serviceResult, request, serviceResult.Page + 1);
            foreach (CustomerOrder cart in (IEnumerable<CustomerOrder>)serviceResult.Carts)
            {
                CartModel cartModel = this.ObjectToObjectMapper.Map<CustomerOrder, CartModel>(cart);
                CartPriceDto cartPriceDto;
                serviceResult.CartPrices.TryGetValue(cart.Id, out cartPriceDto);
                cartModel.ShipToLabel = cart.ShipTo.FirstName + " " + cart.ShipTo.LastName;
                cartModel.OrderSubTotal = cartPriceDto != null ? cartPriceDto.OrderSubTotal : Decimal.Zero;
                cartModel.OrderSubTotalDisplay = this.CurrencyFormatProvider.GetString(cartModel.OrderSubTotal, (ICurrency)cart.Currency);
                cartModel.OrderGrandTotal = cartPriceDto != null ? cartPriceDto.OrderGrandTotal : Decimal.Zero;
                cartModel.OrderGrandTotalDisplay = this.CurrencyFormatProvider.GetString(cartModel.OrderGrandTotal, (ICurrency)cart.Currency);
                cartModel.ShippingAndHandling = cartPriceDto != null ? cartPriceDto.ShippingAndHandling : Decimal.Zero;
                cartModel.ShippingAndHandlingDisplay = this.CurrencyFormatProvider.GetString(cartModel.ShippingAndHandling, (ICurrency)cart.Currency);
                cartModel.TotalTax = cartPriceDto != null ? cartPriceDto.TotalTax : Decimal.Zero;
                cartModel.TotalTaxDisplay = this.CurrencyFormatProvider.GetString(cartModel.TotalTax, (ICurrency)cart.Currency);
                cartModel.TypeDisplay = this.TranslationLocalizer.TranslateLabel(cart.Type);
                cartModel.StatusDisplay = this.TranslationLocalizer.TranslateLabel(cart.Status);
                foreach (CustomerOrderTaxDto customerOrderTax in (IEnumerable<CustomerOrderTaxDto>)cartModel.CustomerOrderTaxes)
                {
                    customerOrderTax.TaxCode = this.TranslationLocalizer.TranslateLabel(customerOrderTax.TaxCode);
                    customerOrderTax.TaxDescription = this.TranslationLocalizer.TranslateLabel(customerOrderTax.TaxDescription);
                    customerOrderTax.TaxAmountDisplay = this.CurrencyFormatProvider.GetString(customerOrderTax.TaxAmount, (ICurrency)cart.Currency);
                }
                cartModel.Uri = this.UrlHelper.Link("CartV1", (object)new
                {
                    cartid = cartModel.Id
                }, request);
                cartModel.CartLinesUri = this.UrlHelper.Link("CartLinesV1", (object)new
                {
                    cartid = cartModel.Id
                }, request);
                HandlerBase.CopyCustomPropertiesToResult((EntityBase)cart, (IPropertiesDictionary)cartModel, (List<string>)null);
                cartCollectionModel2.Carts.Add(cartModel);
            }
            return cartCollectionModel2;
        }
    }
}