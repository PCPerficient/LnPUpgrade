using Insite.Core.Plugins.Utilities;
using Insite.Core.WebApi;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.Mappers.Interfaces;
using System;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2
{
    [RoutePrefix("api/v2/registration")]
    public class RegistrationV2Controller : BaseApiController
    {
        private readonly IRegistrationPostMapper registrationMapper;
        private readonly IRegistrationService registrationService;
        public RegistrationV2Controller(ICookieManager cookieManager, IRegistrationPostMapper registrationMapper, IRegistrationService registrationService) : base(cookieManager)
        {
            this.registrationMapper = registrationMapper;
            this.registrationService = registrationService;
        }

        [HttpGet]
        [Route]
        [ResponseType(typeof(RegistrationResultModel))]
        public async Task<IHttpActionResult> Get([FromUri] RegistrationModel registrationModel)
        {
           return await this.ExecuteAsync<IRegistrationPostMapper,RegistrationModel,RegistrationParameter,RegistrationResult,RegistrationResultModel>(this.registrationMapper, new Func<RegistrationParameter, RegistrationResult>(this.registrationService.CreateEmployeeUser), registrationModel);
        }
    }
}
