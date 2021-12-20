using Insite.Core.Interfaces.Dependency;
using Insite.Core.WebApi.Interfaces;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.Mappers.Interfaces
{
    public interface ICustomPropertyPostMapper : IWebApiMapper<CustomPropertyRequestModel, CustomPropertyParameter, CustomPropertyResult, CustomPropertyResponseModel>, IDependency, IExtension
    {

    }
}
