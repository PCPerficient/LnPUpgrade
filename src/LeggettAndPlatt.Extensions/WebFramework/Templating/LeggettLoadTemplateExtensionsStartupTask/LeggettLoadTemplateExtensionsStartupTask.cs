using DotLiquid;
using Insite.Core.BootStrapper;
using Insite.Core.Interfaces.BootStrapper;
using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.WebFramework.Templating.DotLiquidTags;
using Owin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;

namespace LeggettAndPlatt.Extensions.WebFramework.Templating.LeggettLoadTemplateExtensionsStartupTask
{
    [BootStrapperOrder(50)]
    public class LeggettLoadTemplateExtensionsStartupTask : IStartupTask,
    IMultiInstanceDependency,
    IDependency,
    IExtension
    {
        public void Run(IAppBuilder app, HttpConfiguration config)
        {
            
            Template.RegisterTag<HeaderStartScriptsTag>("headerStartScripts");
            Template.RegisterTag<HeaderEndScriptTags>("headerEndScripts");
            Template.RegisterTag<HeaderScripts>("headerScripts");
            Template.RegisterTag<ProductDetailPageScript>("pdpScript");
            Template.RegisterTag<AntiForgeryTag>("antiforgeryTag");
            Template.RegisterTag<AntiForgeryTagContent>("antiforgeryTagContent");

        }
    }
}
