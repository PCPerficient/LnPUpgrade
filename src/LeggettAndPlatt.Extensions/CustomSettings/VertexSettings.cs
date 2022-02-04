using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "Vertex Settings")]
    public class VertexSettings : BaseSettingsGroup
    {
        [SettingsField(DisplayName = "Vertex End Point", Description = "Vertex End Point", IsGlobal = false)]
        public virtual string VertexEndPoint => this.GetValue("https://10.21.9.59:8443/", "VertexEndPoint");

        [SettingsField(DisplayName = "Vertex User Name", Description = "Vertex User Name", IsGlobal = false)]
        public virtual string VertexUserName => this.GetValue("lpuvtinsite1c", "VertexUserName");

        [SettingsField(DisplayName = "Vertex Password", Description = "Vertex Password", IsGlobal = false)]
        public virtual string VertexPassword => this.GetValue("ISC1v#99", "VertexPassword");

        [SettingsField(DisplayName = "Vertex Company", Description = "Seller Company name for calculate Tax", IsGlobal = false)]
        public virtual string VertexCompany => this.GetValue("00", "VertexCompany");

        [SettingsField(DisplayName = "Legal Entity", Description = "Seller Division for calculate Tax", IsGlobal = false)]
        public virtual string LegalEntity => this.GetValue("05", "LegalEntity");

        [SettingsField(DisplayName = "Tax Area Id", Description = "Seller TaxAreaId for calculate Tax", IsGlobal = false)]
        public virtual string TaxAreaId => this.GetValue("250810620", "TaxAreaId");

        [SettingsField(DisplayName = "Branch", Description = "Seller Branch for calculate Tax", IsGlobal = false)]
        public virtual string Branch => this.GetValue("0908", "Branch");

        [SettingsField(DisplayName = "Vertex Enable Log", Description = "Vertex Enable Log for debugging", IsGlobal = false)]
        public virtual bool VertexEnableLog => this.GetValue(true, "VertexEnableLog");

        [SettingsField(ControlType = SystemSettingControlType.Toggle, Description = "If set to On, system will connet to Vertex demo url", DisplayName = "Vertex Test Mode", IsGlobal = false)]
        public virtual bool VertexTestMode
        {
            get
            {
                return this.GetValue<bool>(true, nameof(VertexTestMode));
            }
        }
        [SettingsField(ControlType = SystemSettingControlType.Toggle, Description = "If tax free, no call to vertex and tax return 0", DisplayName = "Vertex Tax Free Tax Code", IsGlobal = false)]
        public virtual bool VertexTaxFreeTaxCode
        {
            get
            {
                return this.GetValue<bool>(true, nameof(VertexTaxFreeTaxCode));
            }
        }
    }
}
