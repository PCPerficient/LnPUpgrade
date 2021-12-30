using Insite.Cart.WebApi.V1.Mappers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Cart.WebApi.V1.Mappers.Interfaces;
using Insite.Core.Interfaces.Localization;
using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi.Interfaces;
using Insite.Data.Entities;
using Insite.Cart.WebApi.V1.ApiModels;
using Insite.Cart.Services.Results;
using System.Net.Http;
using Insite.Cart.Services.Dtos;
using Insite.Data.Entities.Dtos.Interfaces;
using Insite.Core.Services;
using Insite.Core.Interfaces.Data;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers
{
    //public class GetCartMapperDrift : GetCartMapper
    //{
    //    protected readonly IUnitOfWork UnitOfWork;
    //    public GetCartMapperDrift(ICurrencyFormatProvider currencyFormatProvider, Insite.Customers.WebApi.V1.Mappers.Interfaces.IGetBillToMapper getBillToMapper, Insite.Customers.WebApi.V1.Mappers.Interfaces.IGetShipToMapper getShipToMapper, IGetCartLineCollectionMapper getCartLineCollectionMapper, IObjectToObjectMapper objectToObjectMapper, IUrlHelper urlHelper, IRouteDataProvider routeDataProvider, ITranslationLocalizer translationLocalizer, IUnitOfWorkFactory unitOfWorkFactory) : base(currencyFormatProvider, getBillToMapper, getShipToMapper, getCartLineCollectionMapper, objectToObjectMapper, urlHelper, routeDataProvider, translationLocalizer)
    //    {
    //        this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
    //    }

    //    public override CartModel MapResult(GetCartResult serviceResult, HttpRequestMessage request)
    //    {
    //        CustomerOrder cart = serviceResult.Cart;
    //        CartModel destination = this.ObjectToObjectMapper.Map<GetCartResult, CartModel>(serviceResult);
    //        this.ObjectToObjectMapper.Map<CustomerOrder, CartModel>(cart, destination);
    //        if (cart.ShipVia != null)
    //            this.ObjectToObjectMapper.Map<Carrier, CarrierDto>(cart.ShipVia.Carrier, destination.Carrier);
    //        destination.SalespersonName = cart.Salesperson?.Name ?? string.Empty;
    //        destination.InitiatedByUserName = cart.InitiatedByUserProfile?.UserName ?? string.Empty;
    //        destination.OrderSubTotal = serviceResult.OrderSubTotal;
    //        destination.OrderSubTotalDisplay = this.CurrencyFormatProvider.GetString(destination.OrderSubTotal, (ICurrency)cart.Currency);
    //        destination.OrderSubTotalWithOutProductDiscounts = serviceResult.OrderSubTotalWithOutProductDiscounts;
    //        destination.OrderSubTotalWithOutProductDiscountsDisplay = this.CurrencyFormatProvider.GetString(destination.OrderSubTotalWithOutProductDiscounts, (ICurrency)cart.Currency);
    //        destination.OrderGrandTotal = serviceResult.OrderGrandTotal;
    //        destination.OrderGrandTotalDisplay = this.CurrencyFormatProvider.GetString(destination.OrderGrandTotal, (ICurrency)cart.Currency);
    //        destination.ShippingAndHandling = serviceResult.ShippingAndHandling;
    //        destination.ShippingAndHandlingDisplay = this.CurrencyFormatProvider.GetString(destination.ShippingAndHandling, (ICurrency)cart.Currency);
    //        destination.TotalTax = serviceResult.TotalTax;
    //        destination.TotalTaxDisplay = this.CurrencyFormatProvider.GetString(destination.TotalTax, (ICurrency)cart.Currency);
    //        destination.TypeDisplay = this.TranslationLocalizer.TranslateLabel(cart.Type);
    //        destination.StatusDisplay = this.TranslationLocalizer.TranslateLabel(cart.Status);
    //        destination.CurrencySymbol = serviceResult.CurrencySymbol;
    //        CartModel cartModel1 = destination;
    //        DateTimeOffset? requestedDeliveryDate1 = serviceResult.RequestedDeliveryDate;
    //        DateTimeOffset valueOrDefault;
    //        string str;
    //        if (!requestedDeliveryDate1.HasValue)
    //        {
    //            str = (string)null;
    //        }
    //        else
    //        {
    //            valueOrDefault = requestedDeliveryDate1.GetValueOrDefault();
    //            str = valueOrDefault.ToString();
    //        }
    //        cartModel1.RequestedDeliveryDate = str;
    //        CartModel cartModel2 = destination;
    //        DateTimeOffset? requestedDeliveryDate2 = serviceResult.RequestedDeliveryDate;
    //        DateTime? nullable;
    //        if (!requestedDeliveryDate2.HasValue)
    //        {
    //            nullable = new DateTime?();
    //        }
    //        else
    //        {
    //            valueOrDefault = requestedDeliveryDate2.GetValueOrDefault();
    //            nullable = new DateTime?(valueOrDefault.Date);
    //        }
    //        cartModel2.RequestedDeliveryDateDisplay = nullable;
    //        if (cart.Status.EqualsIgnoreCase("Cart"))
    //            destination.Id = this.RouteDataProvider.GetRouteValue(request, "cartid");
    //        if (serviceResult.GetBillToResult != null)
    //            destination.BillTo = this.GetBillToMapper.MapResult(serviceResult.GetBillToResult, request);
    //        if (serviceResult.GetShipToResult != null)
    //        {
    //            destination.ShipTo = this.GetShipToMapper.MapResult(serviceResult.GetShipToResult, request);
    //            destination.ShipToLabel = serviceResult.GetShipToResult.Label;
    //        }
    //        foreach (CustomerOrderTaxDto customerOrderTax in (IEnumerable<CustomerOrderTaxDto>)destination.CustomerOrderTaxes)
    //        {
    //            customerOrderTax.TaxCode = this.TranslationLocalizer.TranslateLabel(customerOrderTax.TaxCode);
    //            customerOrderTax.TaxDescription = this.TranslationLocalizer.TranslateLabel(customerOrderTax.TaxDescription);
    //            customerOrderTax.TaxAmountDisplay = this.CurrencyFormatProvider.GetString(customerOrderTax.TaxAmount, (ICurrency)cart.Currency);
    //        }
    //        destination.Uri = this.UrlHelper.Link("CartV1", (object)new
    //        {
    //            cartid = destination.Id
    //        }, request);
    //        destination.CartLinesUri = this.UrlHelper.Link("CartLinesV1", (object)new
    //        {
    //            cartid = destination.Id
    //        }, request);
    //        CartLineCollectionModel lineCollectionModel = this.GetCartLineCollectionMapper.MapResult(serviceResult, request);
    //        if (lineCollectionModel != null)
    //            destination.CartLines = lineCollectionModel.CartLines;
    //        destination.Messages = (ICollection<string>)serviceResult.Messages.Select<ResultMessage, string>((Func<ResultMessage, string>)(m => m.Message)).ToList<string>();
    //        destination.CreditCardBillingAddress = serviceResult.CreditCardBillingAddress;

    //        if (destination.BillTo != null && destination.BillTo.Country != null)
    //        {
    //            string countryIsoCode3 = GetBillingAddressCountryCode(destination.BillTo.Country.Id);
    //            destination.Properties.Add("billingAddressCountryCode", countryIsoCode3);
    //        }

    //        //add other charges to view after calculatemattressfee pipeline
    //        if(cart.OtherCharges > 0)
    //        {
    //            destination.Properties.Add("OtherCharges", cart.OtherCharges.ToString("C"));
    //        }
    //        return destination;
    //    }

    //    private string GetBillingAddressCountryCode(string countryId)
    //    {
    //        string countryIsoCode3 = string.Empty;
    //        Country country = this.UnitOfWork.GetRepository<Country>().Get(countryId);
    //        if (country != null)
    //        {
    //            countryIsoCode3 = country.IsoCode3;
    //        }
    //        return countryIsoCode3;
    //    }
    //}
}
