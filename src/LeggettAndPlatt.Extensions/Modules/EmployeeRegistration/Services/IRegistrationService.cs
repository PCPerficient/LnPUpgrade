using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services
{
    public interface IRegistrationService : IInterceptable, IDependency
    {
        RegistrationResult CreateEmployeeUser(RegistrationParameter parameter);
    }
}
