using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers
{
    [DependencyName("CopyCustomPropertiesToResultDrift")]
    public class CopyCustomPropertiesToResultDrift : HandlerBase<GetCartParameter, GetCartResult>
    {
        public override int Order
        {
            get
            {
                return 1810;
            }
        }

        public override GetCartResult Execute(IUnitOfWork unitOfWork, GetCartParameter parameter, GetCartResult result)
        {
            HandlerBase.CopyCustomPropertiesToResult((EntityBase)result.Cart, (IPropertiesDictionary)result, (List<string>)null);
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }
    }
}
