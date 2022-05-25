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
    public class ElavonSessionTokenMapper : IElavonSessionTokenMapper, IWebApiMapper<ElavonSessionTokenModel, ElavonSessionTokenParameter, ElavonSessionTokenResult, ElavonSessionTokenModel>, IDependency, IExtension
    {
        public ElavonSessionTokenParameter MapParameter(ElavonSessionTokenModel apiParameter, HttpRequestMessage request)
        {
            ElavonSessionTokenParameter parameter = new ElavonSessionTokenParameter();
            //parameter.ElavonErrorMessage = apiParameter.ElavonErrorMessage;
            //parameter.ElavonTransactionResponseMessage = apiParameter.ElavonTransactionResponseMessage;
            return parameter;
        }

        public ElavonSessionTokenModel MapResult(ElavonSessionTokenResult serviceResult, HttpRequestMessage request)
        {
            ElavonSessionTokenModel result = new ElavonSessionTokenModel();
            result.ElavonToken = serviceResult.ElavonToken;
            result.ElavonResponseCodes = serviceResult.ElavonResponseCodes;
            result.ElavonAcceptAVSResponseCode = serviceResult.ElavonAcceptAVSResponseCode;
            result.ElavonAcceptCVVResponseCode = serviceResult.ElavonAcceptCVVResponseCode;
            result.ElavonTransactionType = serviceResult.ElavonTransactionType;
            result.Elavon3DS2ErrorCodes = serviceResult.Elavon3DS2ErrorCodes;
            result.ElavonAVSResponseCodes = serviceResult.ElavonAVSResponseCodes;
            return result;
        }
    }
}
