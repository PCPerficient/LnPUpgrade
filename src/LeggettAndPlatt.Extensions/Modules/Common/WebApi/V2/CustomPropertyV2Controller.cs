using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using Insite.Core.Plugins.Utilities;
using System.Web.Http.Description;
using LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels;
using LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.Mappers.Interfaces;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Common.Services;

namespace LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2
{
    [RoutePrefix("api/v2/CustomerOrder/CustomProperty")]
    public class CustomPropertyV2Controller : BaseApiController
    {
        private readonly ICustomPropertyPostMapper customPropertyPostMapper;
        private readonly ICustomPropertyService customPropertyService;
        public CustomPropertyV2Controller(ICookieManager cookieManager, ICustomPropertyPostMapper customPropertyPostMapper, ICustomPropertyService customPropertyService) : base(cookieManager)
        {
            this.customPropertyPostMapper = customPropertyPostMapper;
            this.customPropertyService = customPropertyService;
        }

        [Route]
        [HttpPost]
        [ResponseType(typeof(CustomPropertyResponseModel))]
        public async Task<IHttpActionResult> Post([FromBody] CustomPropertyRequestModel apiModel)
        {
            return await this.ExecuteAsync<ICustomPropertyPostMapper, CustomPropertyRequestModel, CustomPropertyParameter, CustomPropertyResult, CustomPropertyResponseModel>(this.customPropertyPostMapper, new Func<CustomPropertyParameter, CustomPropertyResult>(this.customPropertyService.AddUpdateCustomProperty), apiModel);
        }
    }
}
