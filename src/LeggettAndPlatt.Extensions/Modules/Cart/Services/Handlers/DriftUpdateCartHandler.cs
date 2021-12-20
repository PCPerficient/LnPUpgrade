using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Providers;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using System;
using System.Linq;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers
{
    [DependencyName("DriftUpdateCartHandler")]
    public class DriftUpdateCartHandler : HandlerBase<UpdateCartParameter, UpdateCartResult>
    {
        public override int Order
        {
            get
            {
                return 400;
            }
        }

        public override UpdateCartResult Execute(IUnitOfWork unitOfWork, UpdateCartParameter parameter, UpdateCartResult result)
        {

            if (parameter.Properties.Any() && parameter.Properties.ContainsKey("ElavonRespMessage") && !string.IsNullOrEmpty(parameter.Properties["ElavonRespMessage"].ToString()))
            {
                result.Properties.Add("ElavonRespMessage", parameter.Properties["ElavonRespMessage"].ToString());
                parameter.Properties.Remove("ElavonRespMessage");
            }

            if (parameter.Properties.Any() && parameter.Properties.ContainsKey("billingAddressCountryCode"))
            {
                parameter.Properties.Remove("billingAddressCountryCode");
            }
            //corrects unauthorized attempt to change property error on cart update
            if (parameter.Properties.Any() && parameter.Properties.ContainsKey("otherCharges"))
            {
                parameter.Properties.Remove("otherCharges");
            }
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }

    }
}
