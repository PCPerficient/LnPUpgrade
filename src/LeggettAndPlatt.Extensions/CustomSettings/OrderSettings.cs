using Insite.Core.SystemSetting;
using Insite.Core.SystemSetting.Groups;
namespace LeggettAndPlatt.Extensions.CustomSettings
{
    [SettingsGroup(PrimaryGroupName = "Custom Settings", Label = "OMS Order Settings")]
    public class OrderSettings : BaseSettingsGroup
    {

        [SettingsField(DisplayName = "Send Order Confirmation Email From Insite", 
            Description = "Send Order Confirmation Email From Insite",
            IsGlobal = false)]

        public virtual bool SendOrderEmail
        {
            get
            {
                return this.GetValue<bool>(false, nameof(SendOrderEmail));
            }
        }

        [SettingsField(DisplayName = "OMS Customer ID",
        Description = "OMS Customer ID Parameter Value : WebsiteSettings.OMS_CustomerID - 'CONWEBC' for DRIFT Site. and 'EMPWEBC' for Employee Store.",
        IsGlobal = false)]

        public virtual string DepartmentCode
        {
            get
            {
                return this.GetValue<string>("CONWEBC", nameof(DepartmentCode));
            }
        }

        [SettingsField(DisplayName = "OMS Allocation Rule ID",
        Description = "If order is from DRIFT site then value should be 'LP_D_SCH' , if order is from Employee site then value should be 'LP_E_SCH'",
        IsGlobal = false)]

        public virtual string AllocationRuleID
        {
            get
            {
                return this.GetValue<string>("LP_D_SCH", nameof(AllocationRuleID));
            }
        }

        [SettingsField(DisplayName = "OMS Validate Item",
       Description = "OMS Validate Item Parameter Value",
       IsGlobal = false)]

        public virtual string ValidateItem
        {
            get
            {
                return this.GetValue<string>("Y", nameof(ValidateItem));
            }
        }

        [SettingsField(DisplayName = "OMS ByPass Pricing",
        Description = "OMS ByPass Pricing Parameter Value",
        IsGlobal = false)]

        public virtual string ByPassPricing
        {
            get
            {
                return this.GetValue<string>("Y", nameof(ByPassPricing));
            }
        }

        [SettingsField(DisplayName = "OMS Authorize Client",
        Description = "OMS Authorize Client Parameter Value",
        IsGlobal = false)]

        public virtual string AuthorizedClient
        {
            get
            {
                return this.GetValue<string>("InsiteCommerce", nameof(AuthorizedClient));
            }
        }

        [SettingsField(DisplayName = "OMS Document Type",
        Description = "OMS Document Type Parameter Value",
        IsGlobal = false)]

        public virtual string DocumentType
        {
            get
            {
                return this.GetValue<string>("0001", nameof(DocumentType));
            }
        }

        [SettingsField(DisplayName = "OMS Enterprise Code",
        Description = "OMS Enterprise Code Parameter Value - 'LP_DRIFT_STORE' for the DRIFT Site, and 'LP_EMP_STORE' for the Employee Store",
        IsGlobal = false)]
        public virtual string EnterpriseCode
        {
            get
            {
                return this.GetValue<string>("LP_DRIFT_STORE", nameof(EnterpriseCode));
            }
        }

        [SettingsField(DisplayName = "OMS Entry Type",
        Description = "OMS Entry Type Parameter Value - WEB for both DRIFT and Employee Store",
        IsGlobal = false)]
        public virtual string EntryType
        {
            get
            {
                return this.GetValue<string>("WEB", nameof(EntryType));
            }
        }

        [SettingsField(
        DisplayName = "OMS Payment Status",
        Description = "OMS Payment Status Parameter Value - AUTHORIZED if pre-auth successfully obtained from Elavon. Otherwise for $0 Auth condition do not send this field in the order submit",
        IsGlobal = false)]
        public virtual string PaymentStatus
        {
            get
            {
                return this.GetValue<string>("AUTHORIZED", nameof(PaymentStatus));
            }
        }

        [SettingsField(DisplayName = "OMS Payment Rule Id",
        Description = "OMS Payment Rule Id Parameter Value - 'LP_DRIFT_PR1' for the DRIFT Site and 'LP_EMP_PR1' for the Employee Store",
        IsGlobal = false)]

        public virtual string PaymentRuleId
        {
            get
            {
                return this.GetValue<string>("LP_DRIFT_PR1", nameof(PaymentRuleId));
            }
        }

        [SettingsField(DisplayName = "OMS Payment Type",
        Description = "OMS Payment Type Parameter Value",
        IsGlobal = false)]

        public virtual string PaymentType
        {
            get
            {
                return this.GetValue<string>("CREDIT_CARD", nameof(PaymentType));
            }
        }
        [SettingsField(DisplayName = "OMS Charge Type",
            Description = "OMS Charge Type Parameter Value",
            IsGlobal = false)]

        public virtual string ChargeType
        {
            get
            {
                return this.GetValue<string>("AUTHORIZATION", nameof(ChargeType));
            }
        }
        [SettingsField(DisplayName = "OMS Carrier Service Code",
            Description = "OMS Carrier Service Code Parameter Value",
            IsGlobal = false)]

        public virtual string CarrierServiceCode
        {
            get
            {
                return this.GetValue<string>("TBD", nameof(CarrierServiceCode));
            }
        }

        [SettingsField(DisplayName = "OMS Delivery Method",
         Description = "OMS Delivery Method Parameter Value",
         IsGlobal = false)]

        public virtual string DeliveryMethod
        {
            get
            {
                return this.GetValue<string>("TBD", nameof(DeliveryMethod));
            }
        }

        [SettingsField(DisplayName = "OMS Item Group Code",
        Description = "OMS Item Group Code Parameter Value can be different based on the environments. Set to DEV for development, TEST for test and PROD for production.",
        IsGlobal = false)]

        public virtual string ItemGroupCode
        {
            get
            {
                return this.GetValue<string>("DEV", nameof(ItemGroupCode));
            }
        }

        [SettingsField(DisplayName = "OMS Line Type",
       Description = "OMS Line Type Parameter Value",
       IsGlobal = false)]

        public virtual string LineType
        {
            get
            {
                return this.GetValue<string>("DTC", nameof(LineType));
            }
        }


        [SettingsField(DisplayName = "OMS Charge Category",
        Description = "OMS Charge Category Parameter Value",
        IsGlobal = false)]

        public virtual string ChargeCategory
        {
            get
            {
                return this.GetValue<string>("Sales", nameof(ChargeCategory));
            }
        }
        [SettingsField(DisplayName = "OMS Tax Name",
        Description = "OMS Tax Name Parameter Value",
        IsGlobal = false)]

        public virtual string TaxName
        {
            get
            {
                return this.GetValue<string>("SalesTax", nameof(TaxName));
            }
        }

        [SettingsField(DisplayName = "OMS Tax Charge Name",
        Description = "OMS Tax Charge Name Parameter Value",
        IsGlobal = false)]

        public virtual string ChargeName
        {
            get
            {
                return this.GetValue<string>("Sales", nameof(ChargeName));
            }
        }

        [SettingsField(DisplayName = "OMS Product Class",
        Description = "OMS Product Class Parameter Value",
        IsGlobal = false)]

        public virtual string ProductClass
        {
            get
            {
                return this.GetValue<string>("GOOD", nameof(ProductClass));
            }
        }

        [SettingsField(DisplayName = "OMS Taxable Flag",
        Description = "OMS Taxable Flag Parameter Value",
        IsGlobal = false)]

        public virtual string TaxableFlag
        {
            get
            {
                return this.GetValue<string>("Y", nameof(TaxableFlag));
            }
        }

        [SettingsField(DisplayName = "OMS Is Price Locked",
        Description = "OMS Is Price Locked Parameter Value",
        IsGlobal = false)]

        public virtual string IsPriceLocked
        {
            get
            {
                return this.GetValue<string>("Y", nameof(IsPriceLocked));
            }
        }

    }
}
