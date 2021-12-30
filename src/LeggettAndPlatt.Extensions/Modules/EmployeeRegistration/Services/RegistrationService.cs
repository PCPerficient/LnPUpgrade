using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using Insite.Core.Services.Handlers;
using Insite.Core.Interfaces.Data;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services
{
    public class RegistrationService : ServiceBase, IInterceptable, IDependency, IRegistrationService
    {
        private readonly IHandlerFactory handlerFactory;
        public RegistrationService(IUnitOfWorkFactory unitOfWorkFactory, IHandlerFactory handlerFactory) : base(unitOfWorkFactory)
        {
            this.handlerFactory = handlerFactory;
        }

        public RegistrationResult CreateEmployeeUser(RegistrationParameter parameter)
        {
            return this.handlerFactory.GetHandler<IHandler<RegistrationParameter, RegistrationResult>>().Execute(this.UnitOfWork, parameter, new RegistrationResult());
        }
    }
}
