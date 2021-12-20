using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers.Interfaces;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.WebApi.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers
{
    public class ElavonErrorLogMapper : IElavonErrorLogMapper, IWebApiMapper<ElavonErrorLogModel, ElavonErrorLogParameter, ElavonErrorLogResult, ElavonErrorLogModel>, IDependency, IExtension
    {
        public ElavonErrorLogParameter MapParameter(ElavonErrorLogModel apiParameter, HttpRequestMessage request)
        {
            ElavonErrorLogParameter parameter = new ElavonErrorLogParameter();           
            parameter.CustomerNumber = apiParameter.CustomerNumber;
            parameter.ElavonResponse = apiParameter.ElavonResponse;
            parameter.ElavonResponseFor = apiParameter.ElavonResponseFor;
            parameter.ErrorMessage = apiParameter.ErrorMessage;
            parameter.saveElavonResponse = apiParameter.saveElavonResponse;
            return parameter;
        }


        ElavonErrorLogModel IWebApiMapper<ElavonErrorLogModel, ElavonErrorLogParameter, ElavonErrorLogResult, ElavonErrorLogModel>.MapResult(ElavonErrorLogResult serviceResult, HttpRequestMessage request)
        {
            ElavonErrorLogModel result = new ElavonErrorLogModel();
            result.ErroLogResponse = serviceResult.ErrorLogResponse;
            return result;
        }
    }
}
