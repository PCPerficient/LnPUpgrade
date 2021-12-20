using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels;
using LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.Mappers.Interfaces;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.Mappers.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.Mappers
{
    public class CustomPropertyPostMapper : ICustomPropertyPostMapper, IDependency, IExtension
    {
        public CustomPropertyParameter MapParameter(CustomPropertyRequestModel apiParameter, HttpRequestMessage request)
        {
            CustomPropertyParameter parameter = new CustomPropertyParameter();
            parameter.ObjectName = apiParameter.ObjectName;
            parameter.PropertyName = apiParameter.PropertyName;
            parameter.PropertyValue = apiParameter.PropertyValue;
            return parameter;
        }

        public CustomPropertyResponseModel MapResult(CustomPropertyResult serviceResult, HttpRequestMessage request)
        {
            CustomPropertyResponseModel model = new CustomPropertyResponseModel();
            model.Result = serviceResult.Result;
            return model;
        }

    }
}
