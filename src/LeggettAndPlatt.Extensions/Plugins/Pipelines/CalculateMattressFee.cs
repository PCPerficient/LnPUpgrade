using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Plugins.Pipelines;
using Insite.Core.Plugins.Pipelines.Pricing.Parameters;
using Insite.Core.Plugins.Pipelines.Pricing.Results;

namespace LeggettAndPlatt.Extensions.Plugins.Pipelines
{
    public class CalculateMattressFee : IPipe<GetCartPricingParameter, GetCartPricingResult>
    {
        public int Order => 250;

        public GetCartPricingResult Execute(IUnitOfWork unitOfWork, GetCartPricingParameter parameter, GetCartPricingResult result)
        {
            if (SiteContext.Current.UserProfileDto == null && SiteContext.Current.RememberedUserProfileDto == null)
            {
                return result;
            }

            if (!parameter.CalculateShipping)
            {
                return result;
            }

            if (!decimal.TryParse(parameter.Cart.ShipTo.State.GetProperty("MattressFee", "0"), out var mattressFee) || mattressFee <= 0)
            {
                //Checks for property and removes previous calculation if not applicable
                parameter.Cart.OtherCharges = 0M;
                return result;
            }

            var totalQtyFeeRequired = 0M;
            foreach (var orderLine in parameter.Cart.OrderLines)
            { 
                if (bool.TryParse(orderLine.Product.GetProperty("IsMattress", "false"), out bool mattress))
                {
                    if (mattress == true)
                    {
                        totalQtyFeeRequired += orderLine.QtyOrdered;
                    }                
                }             
            }

            if (totalQtyFeeRequired <= 0)
            {
                //If product that triggered fee removed just prior to check out must reset othercharges property
                parameter.Cart.OtherCharges = 0M;
                return result;
            }

            parameter.Cart.OtherCharges = mattressFee * totalQtyFeeRequired;

            return result;
        }
    }
}
