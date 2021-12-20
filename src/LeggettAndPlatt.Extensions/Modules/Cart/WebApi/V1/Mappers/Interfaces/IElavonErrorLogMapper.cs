using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.WebApi.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers.Interfaces
{
    public interface IElavonErrorLogMapper : IWebApiMapper<ElavonErrorLogModel, ElavonErrorLogParameter, ElavonErrorLogResult, ElavonErrorLogModel>, IDependency, IExtension
    {

    }
}
