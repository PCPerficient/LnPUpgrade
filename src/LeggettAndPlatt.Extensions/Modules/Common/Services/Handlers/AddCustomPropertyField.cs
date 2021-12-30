using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services.Handlers;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Core.Interfaces.Data;
using Insite.Data.Entities;
using Insite.Core.Context;
using Insite.Core.Plugins.Cart;
using LeggettAndPlatt.Extensions.Common;
using Insite.Common.Logging;

namespace LeggettAndPlatt.Extensions.Modules.Common.Services.Handlers
{
    [DependencyName("AddCustomPropertyField")]
    public class AddCustomPropertyField : HandlerBase<CustomPropertyParameter, CustomPropertyResult>
    {
        private readonly ICartOrderProviderFactory cartOrderProviderFactory;

        public AddCustomPropertyField(ICartOrderProviderFactory cartOrderProviderFactory)
        {
            this.cartOrderProviderFactory = cartOrderProviderFactory;
        }
        public override int Order
        {
            get
            {
                return 500;
            }
        }
        public override CustomPropertyResult Execute(IUnitOfWork unitOfWork, CustomPropertyParameter parameter, CustomPropertyResult result)
        {
            return AddUpdateCustomerOrderCustomProperty(unitOfWork, parameter);
        }

        private CustomPropertyResult AddUpdateCustomerOrderCustomProperty(IUnitOfWork unitOfWork, CustomPropertyParameter parameter)
        {
            CustomPropertyResult status = new CustomPropertyResult();
            status.Result = true;
            try
            {
                switch (parameter.ObjectName)
                {
                    case CustomPropertyConstants.customPropertyCustomerOrderObjectName:
                        ICartOrderProvider cartOrderProvider = this.cartOrderProviderFactory.GetCartOrderProvider();
                        CustomerOrder customerOrder = cartOrderProvider.GetCartOrder();
                        var CustomerOrderProperty = customerOrder.CustomProperties.FirstOrDefault(u => u.Name.Equals(parameter.PropertyName, StringComparison.InvariantCultureIgnoreCase));
                        SetCustomProperty(unitOfWork, CustomerOrderProperty, customerOrder, parameter);
                        break;
                    case CustomPropertyConstants.customPropertyCustomerObjectName:
                        Customer customer = SiteContext.Current.ShipTo;
                        var customerCustomProperty = customer.CustomProperties.FirstOrDefault(u => u.Name.Equals(parameter.PropertyName, StringComparison.InvariantCultureIgnoreCase));
                        SetCustomProperty(unitOfWork, customerCustomProperty, customer, parameter);
                        break;
                }
                return status;
            }
            catch(Exception ex)
            {
                LogHelper.For((object)this).Info("Add/Update Custom Property : " + ex.ToString());
                status.Result = false;
                return status;
            }
        }
        public void SetCustomProperty(IUnitOfWork unitOfWork,dynamic customProperty, dynamic obj, CustomPropertyParameter parameter)
        {
            if (customProperty != null)
            {
                customProperty.Value = parameter.PropertyValue;
                unitOfWork.Save();
            }
            else
            {
                obj.SetProperty(parameter.PropertyName, parameter.PropertyValue);
                unitOfWork.Save();
            }
        }
    }
}
