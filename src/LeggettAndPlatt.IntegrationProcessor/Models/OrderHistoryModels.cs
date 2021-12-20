using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.IntegrationProcessor.Models
{
    public class OrderHistoryModel
    {
        public string EnterpriseCode { get; set; }
        public string OrderNo { get; set; }
        public string OrderDate { get; set; }
        public string Status { get; set; }
        public string CustomerContactID { get; set; }
        public string BillToID { get; set; }
        public string OriginalTotalAmount { get; set; }
        public string BTAddressLine1 { get; set; }
        public string BTAddressLine2 { get; set; }
        public string BTCity { get; set; }
        public string BTCompany { get; set; }
        public string BTCountry { get; set; }
        public string BTDayPhone { get; set; }
        public string BTEMailID { get; set; }
        public string BTFirstName { get; set; }
        public string BTLastName { get; set; }
        public string BTState { get; set; }
        public string BTZipCode { get; set; }
        public string STAddressLine1 { get; set; }
        public string STAddressLine2 { get; set; }
        public string STCity { get; set; }
        public string STCompany { get; set; }
        public string STCountry { get; set; }
        public string STDayPhone { get; set; }
        public string STEMailID { get; set; }
        public string STFirstName { get; set; }
        public string STLastName { get; set; }
        public string STState { get; set; }
        public string STZipCode { get; set; }
        public string GrandShippingCharges { get; set; }
        public string GrandTax { get; set; }
        public string GrandTotal { get; set; }
        public string LineSubTotal { get; set; }
    }

    public class OrderHistoryLineModel
    {
        public string ExtendedPrice { get; set; }
        public string LineTotal { get; set; }
        public string UnitPrice { get; set; }
        public string Tax { get; set; }
        public string ItemDesc { get; set; }
        public string ItemID { get; set; }
        public string UnitOfMeasure { get; set; }
        public string UnitCost { get; set; }
        public string OrderedQty { get; set; }
        public string OriginalOrderedQty { get; set; }
        public string PrimeLineNo { get; set; }
        public string Status { get; set; }
        public string SubLineNo { get; set; }
        public string OrderNo { get; set; }
    }



    public class ShipmentModel
    {
        public string ShipmentNo { get; set; }
        public string ActualShipmentDate { get; set; }
        public string OrderNumber { get; set; }
    }

    public class ShipmentPackageModel
    {
        public string CarrierServiceCode { get; set; }
        public string SCAC { get; set; }
        public string TrackingNo { get; set; }
        public string ShipmentNo { get; set; }

        public string PackageNo { get; set; }

        public string TrackingUrl { get; set; }
    }

    public class ShipmentPackageLineModel
    {
        public string TrackingNo { get; set; }
        public string ItemDesc { get; set; }
        public string PrimeLineNo { get; set; }
        public string OrderNumber { get; set; }
        public string ShipmentLineNo { get; set; }
        public string Quantity { get; set; }
        public string ItemID { get; set; }
    }
}
