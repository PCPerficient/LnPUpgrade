using Insite.Core.Interfaces.Dependency;
using Insite.Core.WebApi.Interfaces;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.Mappers.Interfaces
{
    public interface IRegistrationPostMapper : IWebApiMapper<RegistrationModel, RegistrationParameter, RegistrationResult, RegistrationResultModel>, IDependency, IExtension
    {
    }
}
