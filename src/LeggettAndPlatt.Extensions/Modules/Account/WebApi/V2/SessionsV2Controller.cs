using Insite.Account.Services;
using Insite.Account.Services.Parameters;
using Insite.Account.Services.Results;
using Insite.Account.WebApi.V1.ApiModels;
using Insite.Account.WebApi.V1.Mappers.Interfaces;
using Insite.Core.Attributes;
using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi;
using LeggettAndPlatt.Extensions.Extensions;
using System;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace LeggettAndPlatt.Extensions.Modules.Account.WebApi.V2
{
    [RoutePrefix("api/v2/sessions")]
    public class SessionsV2Controller : BaseApiController
    {
        private readonly IDeleteSessionMapper deleteSessionMapper;
        private readonly IGetSessionMapper getSessionMapper;
        private readonly IPatchSessionMapper patchSessionMapper;
        private readonly IPostSessionMapper postSessionMapper;
        private readonly ISessionService sessionService;

        public SessionsV2Controller(
          ICookieManager cookieManager,
          ISessionService sessionService,
          IGetSessionMapper getSessionMapper,
          IPostSessionMapper postSessionMapper,
          IPatchSessionMapper patchSessionMapper,
          IDeleteSessionMapper deleteSessionMapper)
          : base(cookieManager)
        {
            this.sessionService = sessionService;
            this.getSessionMapper = getSessionMapper;
            this.postSessionMapper = postSessionMapper;
            this.patchSessionMapper = patchSessionMapper;
            this.deleteSessionMapper = deleteSessionMapper;
        }



        [Authorize]
        [Route]
        [ValidateAntiForgeryAngular]
        [ResponseType(typeof(SessionModel))]
        public async Task<IHttpActionResult> Post([FromBody] SessionModel model) => await this.ExecuteAsync<IPostSessionMapper, SessionModel, AddSessionParameter, AddSessionResult, SessionModel>(this.postSessionMapper, new Func<AddSessionParameter, AddSessionResult>(this.sessionService.AddSession), model);

    }
}
