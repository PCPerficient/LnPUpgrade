using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Common.Services.Results;
using Insite.Core.Interfaces.Data;
using Insite.Core.Services.Handlers;

namespace LeggettAndPlatt.Extensions.Modules.Common.Services
{
    public class CustomPropertyService : ServiceBase, IInterceptable, IDependency, ICustomPropertyService
    {
        private readonly IHandlerFactory handlerFactory;

        public CustomPropertyService(IUnitOfWorkFactory unitOfWorkFactory, IHandlerFactory handlerFactory) : base(unitOfWorkFactory)
        {
            this.handlerFactory = handlerFactory;
        }
        public CustomPropertyResult AddUpdateCustomProperty(CustomPropertyParameter parameter)
        {
            return this.handlerFactory.GetHandler<IHandler<CustomPropertyParameter, CustomPropertyResult>>().Execute(this.UnitOfWork, parameter, new CustomPropertyResult());
        }
    }
}
