using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.Mappers.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2
{
    [RoutePrefix("api/v2/address/validation")]
    public class AddressValidationV2Controller : BaseApiController
    {
        private readonly IAddressValidationPostMapper validationMapper;
        private readonly IAddressValidationService validationService;
        public AddressValidationV2Controller(ICookieManager cookieManager, IAddressValidationPostMapper validationMapper, IAddressValidationService validationService) : base(cookieManager)
        {
            this.validationMapper = validationMapper;
            this.validationService = validationService;
        }

        [HttpGet]
        [Route]
        [ResponseType(typeof(AddressValidationResponseModel))]
        public async Task<IHttpActionResult> Get([FromUri] AddressValidationRequestModel requestModel)
        {
            return await this.ExecuteAsync<IAddressValidationPostMapper, AddressValidationRequestModel, AddressValidationParameter, AddressValidationResult, AddressValidationResponseModel>(this.validationMapper, new Func<AddressValidationParameter, AddressValidationResult>(this.validationService.ValidateAddress), requestModel);
        }
    }
}
