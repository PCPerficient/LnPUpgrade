using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler.Elavon
{
    [XmlRoot(ElementName = "product")]
    public class ElavonProduct
    {
        [XmlElement(ElementName = "ssl_line_Item_commodity_code")]
        public string Ssl_line_Item_commodity_code { get; set; }

        [XmlElement(ElementName = "ssl_line_item_description")]
        public string Ssl_line_item_description { get; set; }

        [XmlElement(ElementName = "ssl_line_Item_discount_indicator")]
        public string Ssl_line_Item_discount_indicator { get; set; }
        [XmlElement(ElementName = "ssl_line_item_discount_amount")]
        public string Ssl_line_item_discount_amount { get; set; }

        [XmlElement(ElementName = "ssl_line_Item_extended_total")]
        public string Ssl_line_Item_extended_total { get; set; }

        [XmlElement(ElementName = "ssl_line_Item_product_code")]
        public string Ssl_line_Item_product_code { get; set; }

        [XmlElement(ElementName = "ssl_line_Item_quantity")]
        public string Ssl_line_Item_quantity { get; set; }
        [XmlElement(ElementName = "ssl_line_Item_unit_of_measure")]
        public string Ssl_line_Item_unit_of_measure { get; set; }
        [XmlElement(ElementName = "ssl_line_Item_unit_cost")]
        public string Ssl_line_Item_unit_cost { get; set; }

        [XmlElement(ElementName = "ssl_line_Item_total")]
        public string Ssl_Line_Item_Total { get; set; }
        //Elavon 3DS Integration

        [XmlElement(ElementName = "ssl_line_Item_tax_indicator")]
        public string Ssl_line_Item_tax_indicator { get; set; }
        [XmlElement(ElementName = "ssl_line_Item_tax_rate")]
        public string Ssl_line_Item_tax_rate { get; set; }
        [XmlElement(ElementName = "ssl_line_Item_tax_amount")]
        public string Ssl_line_Item_tax_amount { get; set; }
        [XmlElement(ElementName = "ssl_line_Item_tax_type")]
        public string Ssl_line_Item_tax_type { get; set; }
        [XmlElement(ElementName = "ssl_line_Item_alternative_tax")]
        public string Ssl_line_Item_alternative_tax { get; set; }


    }

    [XmlRoot(ElementName = "LineItemProducts")]
    public class LineItemProducts
    {
        [XmlElement(ElementName = "product")]
        public List<ElavonProduct> Product { get; set; }
    }

    [XmlRoot(ElementName = "txn")]
    public class Txn
    {
        [XmlElement(ElementName = "ssl_merchant_ID")]
        public string Ssl_merchant_ID { get; set; }
        [XmlElement(ElementName = "ssl_entry_mode")]
        public int Ssl_entry_mode { get; set; }
        [XmlElement(ElementName = "ssl_merchant_initiated_unscheduled")]
        public string Ssl_merchant_initiated_unscheduled { get; set; }
        [XmlElement(ElementName = "ssl_user_id")]
        public string Ssl_user_id { get; set; }
        [XmlElement(ElementName = "ssl_pin")]
        public string Ssl_pin { get; set; }
        [XmlElement(ElementName = "ssl_vendor_id")]
        public string Ssl_vendor_id { get; set; }

        [XmlElement(ElementName = "ssl_vendor_app_name")]
        public string Ssl_vendor_app_name { get; set; }

        [XmlElement(ElementName = "ssl_vendor_app_version")]
        public string Ssl_vendor_app_version { get; set; }

        [XmlElement(ElementName = "ssl_transaction_type")]
        public string Ssl_transaction_type { get; set; }
        [XmlElement(ElementName = "ssl_token")]
        public string Ssl_token { get; set; }
        [XmlElement(ElementName = "ssl_amount")]
        public string Ssl_amount { get; set; }
        [XmlElement(ElementName = "ssl_salestax")]
        public string Ssl_salestax { get; set; }
        [XmlElement(ElementName = "ssl_customer_code")]
        public string Ssl_customer_code { get; set; }
        [XmlElement(ElementName = "ssl_discount_amount")]
        public string Ssl_discount_amount { get; set; }
        [XmlElement(ElementName = "ssl_duty_amount")]
        public string Ssl_duty_amount { get; set; }
        [XmlElement(ElementName = "ssl_shipping_amount")]
        public string Ssl_shipping_amount { get; set; }
        [XmlElement(ElementName = "ssl_level3_indicator")]
        public string Ssl_level3_indicator { get; set; }

       

        [XmlElement(ElementName = "errorCode")]
        public string ErrorCode { get; set; }

        [XmlElement(ElementName = "errorName")]
        public string ErrorName { get; set; }

        [XmlElement(ElementName = "errorMessage")]
        public string ErrorMessage { get; set; }

        [XmlElement(ElementName = "ssl_result")]
        public string Ssl_Result { get; set; }

        [XmlElement(ElementName = "ssl_approval_code")]
        public string Ssl_Approval_Code { get; set; }

        [XmlElement(ElementName = "ssl_freight_tax_amount")]
        public string Ssl_Freight_Tax_Amount { get; set; }

        //Elavon 3DS Integration
        [XmlElement(ElementName = "ssl_salestax_indicator")]
        public string Ssl_Salestax_Indicator { get; set; }
        [XmlElement(ElementName = "ssl_invoice_number")]
        public string Ssl_Invoice_Number { get; set; }
        [XmlElement(ElementName = "ssl_ship_to_zip")]
        public string Ssl_Ship_To_Zip { get; set; }
        [XmlElement(ElementName = "ssl_ship_to_country")]
        public string Ssl_ship_to_country { get; set; }
        [XmlElement(ElementName = "ssl_ship_from_postal_code")]
        public string Ssl_ship_from_postal_code { get; set; }
        [XmlElement(ElementName = "ssl_national_tax_indicator")]
        public string Ssl_national_tax_indicator { get; set; }
        [XmlElement(ElementName = "ssl_national_tax_amount")]
        public string Ssl_national_tax_amount { get; set; }
        [XmlElement(ElementName = "ssl_order_date")]
        public string Ssl_order_date { get; set; }
        [XmlElement(ElementName = "ssl_other_tax")]
        public string Ssl_other_tax { get; set; }
        [XmlElement(ElementName = "ssl_summary_commodity_code")]
        public string Ssl_summary_commodity_code { get; set; }
        [XmlElement(ElementName = "ssl_merchant_vat_number")]
        public string Ssl_merchant_vat_number { get; set; }
        [XmlElement(ElementName = "ssl_customer_vat_number")]
        public string Ssl_customer_vat_number { get; set; }
       
        [XmlElement(ElementName = "ssl_vat_invoice_number")]
        public string Ssl_vat_invoice_number { get; set; }
        [XmlElement(ElementName = "ssl_tracking_number")]
        public string Ssl_tracking_number { get; set; }
        [XmlElement(ElementName = "ssl_shipping_company")]
        public string Ssl_shipping_company { get; set; }
        [XmlElement(ElementName = "ssl_other_fees")]
        public string Ssl_other_fees { get; set; }
        [XmlElement(ElementName = "LineItemProducts")]
        public LineItemProducts LineItemProducts { get; set; }
    }
}
