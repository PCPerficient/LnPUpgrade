using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Common.Services
{
    public interface ICustomPropertyService : IInterceptable, IDependency
    {
        CustomPropertyResult AddUpdateCustomProperty(CustomPropertyParameter parameter);
    }
}
