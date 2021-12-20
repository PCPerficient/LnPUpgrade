
using DotLiquid;
using DotLiquid.NamingConventions;
using Insite.Core.BootStrapper;
using Insite.Core.Interfaces.BootStrapper;
using Insite.Core.Interfaces.Dependency;
using Insite.WebFramework.Templating;
using Insite.WebFramework.Templating.DotLiquidTags;
using Owin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web.Http;
using LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags;



namespace LeggettAndPlatt.Extensions.WebFramework.Templating.LeggettLoadTemplateExtensionsStartupTask
{
    [BootStrapperOrder(50)]
    public class LeggettLoadTemplateExtensionsStartupTask :
    IStartupTask,
    IMultiInstanceDependency,
    IDependency,
    IExtension
    {
        public void Run(IAppBuilder app, HttpConfiguration config)
        {
            Template.NamingConvention = (INamingConvention)new CSharpNamingConvention();
            Template.RegisterTag<NavigationMenuTag>("navigationMenu");
            Template.RegisterTag<AccountNavigationMenuTag>("accountNavigationMenuTag");
            Template.RegisterTag<UrlForPageTag>("urlForPage");
            Template.RegisterTag<UrlForTag>("urlFor");
            Template.RegisterTag<ZoneTag>("zone");
            Template.RegisterTag<TemplateZoneTag>("templateZone");
            Template.RegisterTag<SiteMessageTag>("siteMessage");
            Template.RegisterTag<TranslateTag>("translate");
            Template.RegisterTag<ThemedPartialTag>("themedPartial");
            Template.RegisterTag<PartialViewTag>("partialView");
            Template.RegisterTag<PhoneRegexTag>("phoneRegex");
            Template.RegisterTag<EmailRegexTag>("emailRegex");
            Template.RegisterTag<AntiForgeryTag>("antiforgeryTag");

            //foreach (Assembly dependencyAssembly in AssemblyLocator.GetPotentialDependencyAssemblies())
            //{
            //    foreach (Type type in ((IEnumerable<Type>)dependencyAssembly.GetTypes()).Where<Type>((Func<Type, bool>)(o => o.IsEnum && ((IEnumerable<object>)o.GetCustomAttributes(typeof(AllowEnumInTemplate), false)).Any<object>())))
            //        Template.RegisterSafeType(type, (Func<object, object>)(o => (object)o.ToString()));
            //}
        }
    }
}
