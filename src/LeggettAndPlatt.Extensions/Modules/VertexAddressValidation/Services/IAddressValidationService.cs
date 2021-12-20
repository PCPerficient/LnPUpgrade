using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services
{
    public interface IAddressValidationService : IInterceptable, IDependency
    {
        AddressValidationResult ValidateAddress(AddressValidationParameter parameter);
    }
}
