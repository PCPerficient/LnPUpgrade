using LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.Cart.Services.Results;
using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services
{
    public interface IElavonService : IInterceptable, IDependency/*, ISettingsService<GetCartSettingsResult>, ISettingsService*/
    {
        ElavonSessionTokenResult GetElavonSessionToken(ElavonSessionTokenParameter parameter);

        ElavonErrorLogResult AddElavonErrorLog(ElavonErrorLogParameter parameter);
    }
}
