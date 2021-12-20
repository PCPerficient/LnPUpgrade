using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services
{
    public class AddressValidationService : ServiceBase, IInterceptable, IDependency, IAddressValidationService
    {
        private readonly IHandlerFactory handlerFactory;
        public AddressValidationService(IUnitOfWorkFactory unitOfWorkFactory, IHandlerFactory handlerFactory) : base(unitOfWorkFactory)
        {
            this.handlerFactory = handlerFactory;
        }

        public AddressValidationResult ValidateAddress(AddressValidationParameter parameter)
        {
            return this.handlerFactory.GetHandler<IHandler<AddressValidationParameter, AddressValidationResult>>().Execute(this.UnitOfWork, parameter, new AddressValidationResult());
        }
    }
}
