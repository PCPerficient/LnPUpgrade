using Insite.Common.Dependencies;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Websites.Services.Parameters;
using Insite.Websites.Services.Results;
using LeggettAndPlatt.Extensions.Common;
using System;
using System.Globalization;
using System.Linq;

namespace LeggettAndPlatt.Extensions.Modules.Websites.Services.Handlers.GetSettingsCollectionHandler
{
    [DependencyName("GetSettingsCollection")]

    public sealed class GetSettingsCollectionDrift : HandlerBase<GetSettingsCollectionParameter, GetSettingsCollectionResult>
    {

        private readonly IDependencyLocator dependencyLocator;

        public override int Order
        {
            get
            {
                return 500;
            }
        }

        public GetSettingsCollectionDrift(IDependencyLocator dependencyLocator)
        {
            this.dependencyLocator = dependencyLocator;
        }

        public override GetSettingsCollectionResult Execute(IUnitOfWork unitOfWork, GetSettingsCollectionParameter parameter, GetSettingsCollectionResult result)
        {
            foreach (ISettingsService<ResultBase> settingsService in Enumerable.ToList<ISettingsService<ResultBase>>(Enumerable.Where<ISettingsService<ResultBase>>(Enumerable.Select<ISettingsService, ISettingsService<ResultBase>>(this.dependencyLocator.GetAllInstances<ISettingsService>(), (Func<ISettingsService, ISettingsService<ResultBase>>)(x => x as ISettingsService<ResultBase>)), (Func<ISettingsService<ResultBase>, bool>)(x => x != null))))
            {
                string name = settingsService.GetType().Name;
                string str = name.EndsWith("Service", true, CultureInfo.InvariantCulture) ? name.Substring(0, name.LastIndexOf("Service", StringComparison.Ordinal)) : name;
                GetSettingsParameter parameter1 = new GetSettingsParameter();
                ResultBase settings = settingsService.GetSettings(parameter1);
                result.SettingsCollection.Add(string.Format("{0}Settings", (object)str), (object)settings);
            }

            result.SettingsCollection.Add("navigationLinksSetting", SettingHelper.GetNavigationLinks());
            result.SettingsCollection.Add("elavonSetting", SettingHelper.GetElavonSetting());
            result.SettingsCollection.Add("AbandonedCartSetting", SettingHelper.GetAbandonedCartSetting());
            result.SettingsCollection.Add("shippingDisplay", SettingHelper.GetShippingDisplay());

            return result;
        }

    }
}
