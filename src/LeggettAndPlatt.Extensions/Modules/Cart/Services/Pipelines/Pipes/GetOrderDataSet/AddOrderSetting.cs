using Insite.Cart.Services.Pipelines.Parameters;
using Insite.Cart.Services.Pipelines.Results;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Pipelines;
using LeggettAndPlatt.Extensions.CustomSettings;
using System.Collections.Generic;
using System.Data;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Pipelines.Pipes.GetOrderDataSet
{
    public class AddOrderSetting : IPipe<GetCartDataSetParameter, GetCartDataSetResult>, IMultiInstanceDependency, IDependency, IExtension
    { 
        private readonly OrderSettings OrderSettings;
        DataTable OrderSettingDataTable = null;
        List<string> OrderSetingColumns = new List<string>(new string[] {
        "AllocationRuleID",
        "DepartmentCode",
        "ValidateItem",
        "ByPassPricing",
        "AuthorizedClient",
        "DocumentType",
        "EnterpriseCode",
        "PaymentStatus",
        "PaymentRuleId",
        "PaymentType",
        "EntryType",
        "ChargeType",
        "CarrierServiceCode",
        "DeliveryMethod",
        "ItemGroupCode",
        "LineType",
        "ChargeCategory",
        "TaxName",
        "ChargeName",
        "ProductClass",
        "IsPriceLocked",
        "TaxableFlag"
    });
        public int Order
        {
            get
            {
                return 610;
            }
        }

        public AddOrderSetting(OrderSettings orderSettings)
        {       
            this.OrderSettings = orderSettings;
           
        }

        public GetCartDataSetResult Execute(IUnitOfWork unitOfWork, GetCartDataSetParameter parameter, GetCartDataSetResult result)
        {
            this.OrderSettings.OverrideCurrentWebsite(parameter.Cart.WebsiteId);
            this.OrderSettingDataTable = new DataTable("OrderSetting");
            AddOrderSettingColumns();
            AddOrderSettingColumnValues();
            result.DataSet.Tables.Add(this.OrderSettingDataTable);
            return result;
        }

        private void AddOrderSettingColumns()
        {
            DataColumn dataColumn;

            foreach (var column in this.OrderSetingColumns)
            {
                dataColumn = new DataColumn();
                dataColumn.DataType = System.Type.GetType("System.String");
                dataColumn.ColumnName = column;
                dataColumn.Caption = column;
                dataColumn.ReadOnly = true;
                dataColumn.Unique = false;
                this.OrderSettingDataTable.Columns.Add(dataColumn);
            }
        }
        private void AddOrderSettingColumnValues()
        {
            DataRow dataRow = this.OrderSettingDataTable.NewRow();
            dataRow["AllocationRuleID"] = this.OrderSettings.AllocationRuleID;
            dataRow["DepartmentCode"] = this.OrderSettings.DepartmentCode;
            dataRow["ValidateItem"] = this.OrderSettings.ValidateItem; 
            dataRow["ByPassPricing"] = this.OrderSettings.ByPassPricing;
            dataRow["AuthorizedClient"] = this.OrderSettings.AuthorizedClient;
            dataRow["DocumentType"] = this.OrderSettings.DocumentType;
            dataRow["EnterpriseCode"] = this.OrderSettings.EnterpriseCode;
            dataRow["PaymentStatus"] = this.OrderSettings.PaymentStatus;
            dataRow["PaymentType"] = this.OrderSettings.PaymentType;
            dataRow["PaymentRuleId"] = this.OrderSettings.PaymentRuleId; 
            dataRow["EntryType"] = this.OrderSettings.EntryType;
            dataRow["ChargeType"] = this.OrderSettings.ChargeType;
            dataRow["CarrierServiceCode"] = this.OrderSettings.CarrierServiceCode;
            dataRow["DeliveryMethod"] = this.OrderSettings.DeliveryMethod;
            dataRow["ItemGroupCode"] = this.OrderSettings.ItemGroupCode;
            dataRow["LineType"] = this.OrderSettings.LineType;
            dataRow["ChargeCategory"] = this.OrderSettings.ChargeCategory;
            dataRow["TaxName"] = this.OrderSettings.TaxName;
            dataRow["ChargeName"] = this.OrderSettings.ChargeName;
            dataRow["ProductClass"] = this.OrderSettings.ProductClass;
            dataRow["IsPriceLocked"] = this.OrderSettings.IsPriceLocked;
            dataRow["TaxableFlag"] = this.OrderSettings.TaxableFlag;
            
            this.OrderSettingDataTable.Rows.Add(dataRow);
        }
    }
}

