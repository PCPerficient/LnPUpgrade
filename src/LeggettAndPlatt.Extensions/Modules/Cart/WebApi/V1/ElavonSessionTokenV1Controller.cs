using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

using LeggettAndPlatt.Extensions.Modules.Cart.Services;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels;
using LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.Mappers.Interfaces;
using System.Net.Http;
using System.Net;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1
{
    [RoutePrefix("api/v2/getelavonsessiontoken")]
    public class ElavonSessionTokenV1Controller : BaseApiController
    {
        private readonly IElavonService ElavonService;
        private readonly IElavonSessionTokenMapper ElavonSessionTokenMapper;

        public ElavonSessionTokenV1Controller(ICookieManager cookieManager, IElavonService elavonService, IElavonSessionTokenMapper elavonSessionTokenMapper)
        : base(cookieManager)
        {
            this.ElavonService = elavonService;
            this.ElavonSessionTokenMapper = elavonSessionTokenMapper;
        }
        [HttpGet]
        [Route("{number}", Name = "ElavonTokenV2")]
        public async Task<IHttpActionResult> Get(string number)
        {
            ElavonSessionTokenModel elavonSessionTokenModel = new ElavonSessionTokenModel();
            return await this.ExecuteAsync<IElavonSessionTokenMapper, ElavonSessionTokenModel, ElavonSessionTokenParameter, ElavonSessionTokenResult, ElavonSessionTokenModel>(this.ElavonSessionTokenMapper, new Func<ElavonSessionTokenParameter, ElavonSessionTokenResult>(this.ElavonService.GetElavonSessionToken), elavonSessionTokenModel);
        }
    }
}
