using LeggettAndPlatt.Extensions.Modules.Cart.Services;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers.Interfaces;
using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1
{
    [RoutePrefix("api/v1/elavonerrorlog")]
    public class ElavonErroLogV1Controller : BaseApiController
    {
        private readonly IElavonService ElavonService;
        private readonly IElavonErrorLogMapper ElavonErrorLogMapper;
        public ElavonErroLogV1Controller(ICookieManager cookieManager, IElavonService elavonService, IElavonErrorLogMapper elavonErrorLogMapper)
        : base(cookieManager)
        {
            this.ElavonService = elavonService;
            this.ElavonErrorLogMapper = elavonErrorLogMapper;
        }

        [HttpPut]
        [Route]
        public async Task<IHttpActionResult> Put([FromBody] ElavonErrorLogModel elavonErrorLogModel)
        {
            return await this.ExecuteAsync<IElavonErrorLogMapper, ElavonErrorLogModel, ElavonErrorLogParameter, ElavonErrorLogResult, ElavonErrorLogModel>(this.ElavonErrorLogMapper, new Func<ElavonErrorLogParameter, ElavonErrorLogResult>(this.ElavonService.AddElavonErrorLog), elavonErrorLogModel);
        }
    }
}
