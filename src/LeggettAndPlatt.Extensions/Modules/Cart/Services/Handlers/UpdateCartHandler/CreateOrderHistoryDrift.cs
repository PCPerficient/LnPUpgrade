using Insite.Cart.Services.Handlers.UpdateCartHandler;
using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Common.Helpers;
using Insite.Core.ApplicationDictionary;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Plugins.Utilities;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using LeggettAndPlatt.Extensions.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler
{
    [DependencyName("CreateOrderHistory")]
    public class CreateOrderHistoryDrift : HandlerBase<UpdateCartParameter, UpdateCartResult>
    {
        private readonly Lazy<IProductUtilities> productUtilities;
        private readonly IOrderLineUtilities orderLineUtilities;
        private readonly ICustomerOrderUtilities customerOrderUtilities;
        private readonly IEntityDefinitionProvider entityDefinitionProvider;
        private readonly IObjectToObjectMapper objectToObjectMapper;
        private readonly CustomPropertyHelper CustomPropertyHelper;
        public override int Order
        {
            get
            {
                return 3300;
            }
        }

        private List<string> CustomerOrderCustomPropertiesToCopy { get; set; }

        private List<string> OrderLineCustomPropertiesToCopy { get; set; }

        public CreateOrderHistoryDrift(Lazy<IProductUtilities> productUtilities, IOrderLineUtilities orderLineUtilities, ICustomerOrderUtilities customerOrderUtilities, IObjectToObjectMapper objectToObjectMapper, IEntityDefinitionProvider entityDefinitionProvider, CustomPropertyHelper customPropertyHelper)
        {
            this.productUtilities = productUtilities;
            this.orderLineUtilities = orderLineUtilities;
            this.customerOrderUtilities = customerOrderUtilities;
            this.objectToObjectMapper = objectToObjectMapper;
            this.entityDefinitionProvider = entityDefinitionProvider;
            this.CustomPropertyHelper = customPropertyHelper;
        }

        public override UpdateCartResult Execute(IUnitOfWork unitOfWork, UpdateCartParameter parameter, UpdateCartResult result)
        {
            if (!parameter.Status.EqualsIgnoreCase("Submitted"))
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            CustomerOrder customerOrder = result.GetCartResult.Cart;
            OrderHistory orderHistory = this.CreateOrderHistoryRecord(unitOfWork, customerOrder);
            foreach (CustomerOrderTax customerOrderTax in (IEnumerable<CustomerOrderTax>)customerOrder.CustomerOrderTaxes)
                this.AddOrderHistoryTax(orderHistory, customerOrderTax);
            unitOfWork.GetRepository<OrderHistory>().Insert(orderHistory);
            unitOfWork.Save();
            ICollection<CustomerProduct> customerProducts = this.GetCustomerProducts(unitOfWork, customerOrder);
            unitOfWork.SaveWithoutChangeTracking((Action)(() =>
            {
                foreach (OrderLine orderLine in (IEnumerable<OrderLine>)customerOrder.OrderLines)
                    this.AddOrderHistoryLine(unitOfWork, customerOrder, orderHistory, orderLine, customerProducts);
                foreach (CustomerOrderPromotion customerOrderPromotion in customerOrder.CustomerOrderPromotions.Where<CustomerOrderPromotion>((Func<CustomerOrderPromotion, bool>)(p => !p.OrderLineId.HasValue)))
                    this.AddOrderHistoryPromotion(unitOfWork, customerOrderPromotion, orderHistory.Id, new Guid?());
            }));
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }

        private OrderHistory CreateOrderHistoryRecord(IUnitOfWork unitOfWork, CustomerOrder customerOrder)
        {
            OrderHistory orderHistory = this.objectToObjectMapper.Map<CustomerOrder, OrderHistory>(customerOrder);
            orderHistory.Terms = customerOrder.TermsCode;
            orderHistory.WebOrderNumber = customerOrder.OrderNumber;
            orderHistory.OrderDiscountAmount = this.customerOrderUtilities.GetPromotionOrderDiscountTotal(customerOrder);
            orderHistory.ProductDiscountAmount = this.customerOrderUtilities.GetProductDiscountAmount(customerOrder);
            orderHistory.ProductTotal = this.customerOrderUtilities.GetProductTotal(customerOrder);
            orderHistory.Salesperson = customerOrder.Salesperson != null ? customerOrder.Salesperson.Name : string.Empty;
            orderHistory.ShipCode = string.IsNullOrEmpty(customerOrder.ShipVia?.ErpShipCode) ? (string.IsNullOrEmpty(customerOrder.ShipVia?.ShipCode) ? string.Empty : customerOrder.ShipVia.ShipCode) : customerOrder.ShipVia.ErpShipCode;
            orderHistory.CurrencyCode = customerOrder.Currency != null ? customerOrder.Currency.CurrencyCode : string.Empty;
            orderHistory.ShippingCharges -= this.customerOrderUtilities.GetPromotionShippingDiscountTotal(customerOrder);
            orderHistory.Status = unitOfWork.GetRepository<OrderStatusMapping>().GetTable().FirstOrDefault<OrderStatusMapping>((Expression<Func<OrderStatusMapping, bool>>)(x => x.IsDefault))?.ErpOrderStatus ?? string.Empty;
            this.SetCustomPropertiesToCopyToHistory();
            foreach (CustomProperty customProperty in customerOrder.CustomProperties.Where<CustomProperty>((Func<CustomProperty, bool>)(o => this.CustomerOrderCustomPropertiesToCopy.Contains(o.Name))))
                orderHistory.SetProperty(customProperty.Name, customProperty.Value);

            //PRFT Custom Code
            AddOrderHistoryCustomProperties(orderHistory, customerOrder);


            return orderHistory;
        }

        private void AddOrderHistoryTax(OrderHistory orderHistory, CustomerOrderTax customerOrderTax)
        {
            orderHistory.OrderHistoryTaxes.Add(new OrderHistoryTax()
            {
                TaxCode = customerOrderTax.TaxCode,
                TaxDescription = customerOrderTax.TaxDescription,
                TaxRate = customerOrderTax.TaxRate,
                TaxAmount = customerOrderTax.TaxAmount,
                SortOrder = customerOrderTax.SortOrder
            });
        }

        private ICollection<CustomerProduct> GetCustomerProducts(IUnitOfWork unitOfWork, CustomerOrder customerOrder)
        {
            if (customerOrder.Customer == null)
                return (ICollection<CustomerProduct>)null;
            Guid[] productIds = customerOrder.OrderLines.Select<OrderLine, Guid>((Func<OrderLine, Guid>)(x => x.ProductId)).ToArray<Guid>();
            return (ICollection<CustomerProduct>)unitOfWork.GetRepository<CustomerProduct>().GetTable().Where<CustomerProduct>((Expression<Func<CustomerProduct, bool>>)(x => x.CustomerId == customerOrder.CustomerId && productIds.Contains<Guid>(x.ProductId))).ToList<CustomerProduct>();
        }

        private void AddOrderHistoryLine(IUnitOfWork unitOfWork, CustomerOrder customerOrder, OrderHistory orderHistory, OrderLine orderLine, ICollection<CustomerProduct> customerProducts)
        {
            if (orderLine.Status == "ConfigurationInProgress")
                return;
            IRepository<OrderHistoryLine> repository = unitOfWork.GetRepository<OrderHistoryLine>();
            OrderHistoryLine inserted = repository.Create();
            inserted.OrderHistory = orderHistory;
            inserted.Status = orderLine.Status;
            inserted.Description = orderLine.Description;
            inserted.Notes = orderLine.Notes;
            inserted.QtyOrdered = orderLine.QtyOrdered;
            inserted.UnitOfMeasure = orderLine.UnitOfMeasure;
            inserted.CustomerNumber = customerOrder.CustomerNumber;
            inserted.CustomerProductNumber = this.GetCustomerProductNumber(customerProducts, orderLine);
            inserted.CustomerSequence = customerOrder.CustomerSequence;
            inserted.UnitDiscountAmount = this.orderLineUtilities.GetUnitDiscountAmount(orderLine);
            inserted.DiscountPercent = this.orderLineUtilities.GetOrderLineSavingsPercent(orderLine);
            inserted.InventoryQtyOrdered = orderLine.QtyOrdered;
            inserted.InventoryQtyShipped = orderLine.QtyShipped;
            OrderHistoryLine orderHistoryLine = inserted;
            DateTimeOffset? shipDate = orderLine.ShipDate;
            DateTime? nullable = shipDate.HasValue ? new DateTime?(shipDate.GetValueOrDefault().DateTime) : new DateTime?();
            orderHistoryLine.LastShipDate = nullable;
            inserted.LineNumber = (Decimal)orderLine.Line;
            inserted.LinePOReference = orderLine.CustomerPOLine;
            inserted.TotalRegularPrice = orderLine.TotalRegularPrice;
            inserted.TotalNetPrice = orderLine.TotalNetPrice;
            inserted.LineType = string.Empty;
            inserted.ProductErpNumber = orderLine.Product.ErpNumber;
            inserted.TotalDiscountAmount = this.orderLineUtilities.GetTotalDiscountAmount(orderLine);
            inserted.RmaQtyReceived = Decimal.Zero;
            inserted.RmaQtyRequested = Decimal.Zero;
            inserted.ReleaseNumber = (Decimal)orderLine.Release;
            inserted.RequiredDate = orderLine.DueDate;
            inserted.UnitNetPrice = orderLine.UnitNetPrice;
            inserted.UnitListPrice = orderLine.UnitListPrice;
            inserted.UnitCost = orderLine.UnitCost;
            inserted.UnitRegularPrice = orderLine.UnitRegularPrice;
            inserted.OrderLineOtherCharges = orderLine.OrderLineOtherCharges;
            inserted.Warehouse = orderLine.Warehouse != null ? orderLine.Warehouse.Name : string.Empty;
            this.SetCustomPropertiesToCopyToHistory();
            foreach (CustomProperty customProperty in orderLine.CustomProperties.Where<CustomProperty>((Func<CustomProperty, bool>)(o => this.OrderLineCustomPropertiesToCopy.Contains(o.Name))))
                inserted.SetProperty(customProperty.Name, customProperty.Value);

            //PRFT Custom Code
            AddOrderHistoryLineTaxAmount(inserted, customerOrder, orderLine);

            repository.Insert(inserted);
            CustomerOrderPromotion customerOrderPromotion = customerOrder.CustomerOrderPromotions.FirstOrDefault<CustomerOrderPromotion>((Func<CustomerOrderPromotion, bool>)(p =>
            {
                Guid? orderLineId = p.OrderLineId;
                Guid id = orderLine.Id;
                if (!orderLineId.HasValue)
                    return false;
                if (!orderLineId.HasValue)
                    return true;
                return orderLineId.GetValueOrDefault() == id;
            }));
            if (customerOrderPromotion != null)
                this.AddOrderHistoryPromotion(unitOfWork, customerOrderPromotion, orderHistory.Id, new Guid?(inserted.Id));
            DataSet dataset = this.productUtilities.Value.UpdateConfigDataSet(unitOfWork.GetRepository<Product>().Get(orderLine.ProductId), this.orderLineUtilities.GetSectionOptions(orderLine));
            if (dataset == null)
                return;
            inserted.ConfigDataSet = XmlDatasetManager.ConvertDatasetToXml(dataset);
        }

        private void AddOrderHistoryPromotion(IUnitOfWork unitOfWork, CustomerOrderPromotion customerOrderPromotion, Guid orderHistoryId, Guid? orderHistoryLineId = null)
        {
            IRepository<OrderHistoryPromotion> repository = unitOfWork.GetRepository<OrderHistoryPromotion>();
            OrderHistoryPromotion inserted = repository.Create();
            inserted.OrderHistoryId = orderHistoryId;
            inserted.OrderHistoryLineId = orderHistoryLineId;
            inserted.Amount = customerOrderPromotion.Amount;
            inserted.Name = customerOrderPromotion.Promotion.Name;
            inserted.PromotionId = customerOrderPromotion.PromotionId;
            repository.Insert(inserted);
        }

        private string GetCustomerProductNumber(ICollection<CustomerProduct> customerProducts, OrderLine orderLine)
        {
            if (orderLine.ProductId == Guid.Empty || orderLine.CustomerOrder.CustomerId == Guid.Empty || customerProducts == null)
                return string.Empty;
            CustomerProduct customerProduct = customerProducts.FirstOrDefault<CustomerProduct>((Func<CustomerProduct, bool>)(cp =>
            {
                if (cp.CustomerId == orderLine.CustomerOrder.CustomerId)
                    return cp.ProductId == orderLine.ProductId;
                return false;
            }));
            if (customerProduct != null)
                return customerProduct.Name;
            return string.Empty;
        }

        private void SetCustomPropertiesToCopyToHistory()
        {
            if (this.CustomerOrderCustomPropertiesToCopy != null)
                return;
            this.CustomerOrderCustomPropertiesToCopy = new List<string>();
            this.OrderLineCustomPropertiesToCopy = new List<string>();
            List<PropertyDefinitionDto> list1 = this.entityDefinitionProvider.GetByName("CustomerOrder", (string)null).Properties.Where<PropertyDefinitionDto>((Func<PropertyDefinitionDto, bool>)(o => o.IsCustomProperty)).ToList<PropertyDefinitionDto>();
            List<PropertyDefinitionDto> list2 = this.entityDefinitionProvider.GetByName("OrderLine", (string)null).Properties.Where<PropertyDefinitionDto>((Func<PropertyDefinitionDto, bool>)(o => o.IsCustomProperty)).ToList<PropertyDefinitionDto>();
            List<PropertyDefinitionDto> list3 = this.entityDefinitionProvider.GetByName("OrderHistory", (string)null).Properties.Where<PropertyDefinitionDto>((Func<PropertyDefinitionDto, bool>)(o => o.IsCustomProperty)).ToList<PropertyDefinitionDto>();
            List<PropertyDefinitionDto> list4 = this.entityDefinitionProvider.GetByName("OrderHistoryLine", (string)null).Properties.Where<PropertyDefinitionDto>((Func<PropertyDefinitionDto, bool>)(o => o.IsCustomProperty)).ToList<PropertyDefinitionDto>();
            CreateOrderHistoryDrift.AddValidPropertiesToList(list1, list3, this.CustomerOrderCustomPropertiesToCopy);
            List<PropertyDefinitionDto> target = list4;
            List<string> propertiesToCopy = this.OrderLineCustomPropertiesToCopy;
            CreateOrderHistoryDrift.AddValidPropertiesToList(list2, target, propertiesToCopy);
        }

        private static void AddValidPropertiesToList(List<PropertyDefinitionDto> source, List<PropertyDefinitionDto> target, List<string> list)
        {
            foreach (PropertyDefinitionDto propertyDefinitionDto in source)
            {
                PropertyDefinitionDto propertyDefinition = propertyDefinitionDto;
                if (target.Any<PropertyDefinitionDto>((Func<PropertyDefinitionDto, bool>)(o =>
                {
                    if (o.Name.EqualsIgnoreCase(propertyDefinition.Name))
                        return o.PropertyType == propertyDefinition.PropertyType;
                    return false;
                })))
                    list.Add(propertyDefinition.Name);
            }
        }

        private void AddOrderHistoryLineTaxAmount(OrderHistoryLine inserted, CustomerOrder customerOrder, OrderLine orderLine)
        {
            string isTaxTBD = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameIsTaxTBD, customerOrder);
            if (string.IsNullOrEmpty(isTaxTBD) || isTaxTBD.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                inserted.SetProperty(CustomPropertyConstants.customPropertyNameTaxAmount, Convert.ToString(orderLine.TaxAmount));
            }
        }


        private void AddOrderHistoryCustomProperties(OrderHistory inserted, CustomerOrder customerOrder)
        {
            string propertyBTFirstName = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameBtFirstName, customerOrder);
            if (string.IsNullOrEmpty(propertyBTFirstName) || propertyBTFirstName.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                inserted.SetProperty(CustomPropertyConstants.customPropertyNameBtFirstName, Convert.ToString(customerOrder.BTFirstName));
            }
            string propertySTFirstName = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameStFirstName, customerOrder);
            if (string.IsNullOrEmpty(propertySTFirstName) || propertySTFirstName.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                inserted.SetProperty(CustomPropertyConstants.customPropertyNameStFirstName, Convert.ToString(customerOrder.STFirstName));
            }
            string propertyBTLastName = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameBtLastName, customerOrder);
            if (string.IsNullOrEmpty(propertyBTLastName) || propertyBTLastName.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                inserted.SetProperty(CustomPropertyConstants.customPropertyNameBtLastName, Convert.ToString(customerOrder.BTLastName));
            }
            string propertySTLastName = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameStLastName, customerOrder);
            if (string.IsNullOrEmpty(propertySTLastName) || propertySTLastName.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                inserted.SetProperty(CustomPropertyConstants.customPropertyNameStLastName, Convert.ToString(customerOrder.STLastName));
            }
        }


    }
}
