using System;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services
{
    public class ElavonService : ServiceBase, IElavonService, IInterceptable, IDependency/*, ISettingsService<GetCartSettingsResult>, ISettingsService*/
    {
        protected readonly IHandlerFactory HandlerFactory;
        public ElavonService(IUnitOfWorkFactory unitOfWorkFactory, IHandlerFactory handlerFactory)
      : base(unitOfWorkFactory)
        {
            this.HandlerFactory = handlerFactory;
        }

        [Transaction]
        public ElavonSessionTokenResult GetElavonSessionToken(ElavonSessionTokenParameter parameter)
        {
            return this.HandlerFactory.GetHandler<IHandler<ElavonSessionTokenParameter, ElavonSessionTokenResult>>().Execute(this.UnitOfWork, parameter, new ElavonSessionTokenResult());
        }

        [Transaction]
        public ElavonErrorLogResult AddElavonErrorLog(ElavonErrorLogParameter parameter)
        {
            return this.HandlerFactory.GetHandler<IHandler<ElavonErrorLogParameter, ElavonErrorLogResult>>().Execute(this.UnitOfWork, parameter, new ElavonErrorLogResult());
        }

    }
}
