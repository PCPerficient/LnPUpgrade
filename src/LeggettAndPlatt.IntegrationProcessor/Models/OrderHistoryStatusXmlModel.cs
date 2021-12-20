using System;
using System.Xml.Serialization;
using System.Collections.Generic;

namespace LeggettAndPlatt.IntegrationProcessor.Models
{
    [XmlRoot(ElementName = "PersonInfoShipTo")]
    public class OrderHistoryStatusPersonInfoShipToModel
    {
        [XmlAttribute(AttributeName = "AddressLine1")]
        public string AddressLine1 { get; set; }
        [XmlAttribute(AttributeName = "AddressLine2")]
        public string AddressLine2 { get; set; }
        [XmlAttribute(AttributeName = "City")]
        public string City { get; set; }
        [XmlAttribute(AttributeName = "Company")]
        public string Company { get; set; }
        [XmlAttribute(AttributeName = "Country")]
        public string Country { get; set; }
        [XmlAttribute(AttributeName = "DayPhone")]
        public string DayPhone { get; set; }
        [XmlAttribute(AttributeName = "EMailID")]
        public string EMailID { get; set; }
        [XmlAttribute(AttributeName = "FirstName")]
        public string FirstName { get; set; }
        [XmlAttribute(AttributeName = "LastName")]
        public string LastName { get; set; }
        [XmlAttribute(AttributeName = "State")]
        public string State { get; set; }
        [XmlAttribute(AttributeName = "ZipCode")]
        public string ZipCode { get; set; }
    }

    [XmlRoot(ElementName = "PersonInfoBillTo")]
    public class OrderHistoryStatusPersonInfoBillToModel
    {
        [XmlAttribute(AttributeName = "AddressLine1")]
        public string AddressLine1 { get; set; }
        [XmlAttribute(AttributeName = "AddressLine2")]
        public string AddressLine2 { get; set; }
        [XmlAttribute(AttributeName = "City")]
        public string City { get; set; }
        [XmlAttribute(AttributeName = "Company")]
        public string Company { get; set; }
        [XmlAttribute(AttributeName = "Country")]
        public string Country { get; set; }
        [XmlAttribute(AttributeName = "DayPhone")]
        public string DayPhone { get; set; }
        [XmlAttribute(AttributeName = "EMailID")]
        public string EMailID { get; set; }
        [XmlAttribute(AttributeName = "FirstName")]
        public string FirstName { get; set; }
        [XmlAttribute(AttributeName = "LastName")]
        public string LastName { get; set; }
        [XmlAttribute(AttributeName = "State")]
        public string State { get; set; }
        [XmlAttribute(AttributeName = "ZipCode")]
        public string ZipCode { get; set; }
    }

    [XmlRoot(ElementName = "LineOverallTotals")]
    public class LineOverallTotals
    {
        [XmlAttribute(AttributeName = "ExtendedPrice")]
        public string ExtendedPrice { get; set; }
        [XmlAttribute(AttributeName = "LineTotal")]
        public string LineTotal { get; set; }
        [XmlAttribute(AttributeName = "UnitPrice")]
        public string UnitPrice { get; set; }
        [XmlAttribute(AttributeName = "Tax")]
        public string Tax { get; set; }
    }

    [XmlRoot(ElementName = "Item")]
    public class OrderHistoryStatusItemModel
    {
        [XmlAttribute(AttributeName = "ItemShortDesc")]
        public string ItemShortDesc { get; set; }
        [XmlAttribute(AttributeName = "ItemID")]
        public string ItemID { get; set; }
        [XmlAttribute(AttributeName = "UnitCost")]
        public string UnitCost { get; set; }
        [XmlAttribute(AttributeName = "UnitOfMeasure")]
        public string UnitOfMeasure { get; set; }
    }

    [XmlRoot(ElementName = "Shipment")]
    public class Shipment
    {
        [XmlAttribute(AttributeName = "ShipmentNo")]
        public string ShipmentNo { get; set; }
        [XmlAttribute(AttributeName = "ActualShipmentDate")]
        public string ActualShipmentDate { get; set; }
        [XmlAttribute(AttributeName = "SCAC")]
        public string SCAC { get; set; }
    }

    [XmlRoot(ElementName = "Extn")]
    public class ExtnTracking
    {
        [XmlAttribute(AttributeName = "ExtnTrackingURL")]
        public string ExtnTrackingURL { get; set; }

       
    }

    [XmlRoot(ElementName = "ShipmentLine")]
    public class ShipmentLine
    {
        [XmlAttribute(AttributeName = "ItemDesc")]
        public string ItemDesc { get; set; }
        [XmlAttribute(AttributeName = "OrderNo")]
        public string OrderNo { get; set; }
        [XmlAttribute(AttributeName = "PrimeLineNo")]
        public string PrimeLineNo { get; set; }
        [XmlAttribute(AttributeName = "Quantity")]
        public string Quantity { get; set; }
        [XmlAttribute(AttributeName = "ShipmentLineNo")]
        public string ShipmentLineNo { get; set; }
        [XmlAttribute(AttributeName = "SubLineNo")]
        public string SubLineNo { get; set; }
    }

   
    [XmlRoot(ElementName = "ContainerDetail")]
    public class ContainerDetail
    {
        [XmlElement(ElementName = "ShipmentLine")]
        public ShipmentLine ShipmentLine { get; set; }
        [XmlAttribute(AttributeName = "Quantity")]
        public string Quantity { get; set; }
    }

    [XmlRoot(ElementName = "ContainerDetails")]
    public class ContainerDetails
    {
        [XmlElement(ElementName = "ContainerDetail")]
        public ContainerDetail ContainerDetail { get; set; }
    }

    [XmlRoot(ElementName = "Container")]
    public class Container
    {
        [XmlElement(ElementName = "Extn")]
        public ExtnTracking ExtnTracking { get; set; }
        [XmlElement(ElementName = "Shipment")]
        public Shipment Shipment { get; set; }
        [XmlElement(ElementName = "ContainerDetails")]
        public ContainerDetails ContainerDetails { get; set; }
        [XmlAttribute(AttributeName = "CarrierServiceCode")]
        public string CarrierServiceCode { get; set; }
        [XmlAttribute(AttributeName = "SCAC")]
        public string SCAC { get; set; }
        [XmlAttribute(AttributeName = "TrackingNo")]
        public string TrackingNo { get; set; }
    }

    [XmlRoot(ElementName = "Containers")]
    public class Containers
    {
        [XmlElement(ElementName = "Container")]
        public List<Container> Container { get; set; }
    }


    [XmlRoot(ElementName = "OrderLine")]
    public class OrderHistoryStatusOrderLineModel
    {
        [XmlElement(ElementName = "LineOverallTotals")]
        public LineOverallTotals LineOverallTotals { get; set; }
        [XmlElement(ElementName = "Item")]
        public OrderHistoryStatusItemModel Item { get; set; }
        [XmlElement(ElementName = "Containers")]
        public Containers Containers { get; set; }
        [XmlAttribute(AttributeName = "OrderedQty")]
        public string OrderedQty { get; set; }
        [XmlAttribute(AttributeName = "OriginalOrderedQty")]
        public string OriginalOrderedQty { get; set; }
        [XmlAttribute(AttributeName = "PrimeLineNo")]
        public string PrimeLineNo { get; set; }
        [XmlAttribute(AttributeName = "Status")]
        public string Status { get; set; }
        [XmlAttribute(AttributeName = "SubLineNo")]
        public string SubLineNo { get; set; }
    }

    [XmlRoot(ElementName = "OrderLines")]
    public class OrderHistoryStatusOrderLinesModel
    {
        [XmlElement(ElementName = "OrderLine")]
        public List<OrderHistoryStatusOrderLineModel> OrderLine { get; set; }
    }

    [XmlRoot(ElementName = "OverallTotals")]
    public class OverallTotals
    {
        [XmlAttribute(AttributeName = "GrandShippingCharges")]
        public string GrandShippingCharges { get; set; }
        [XmlAttribute(AttributeName = "GrandTax")]
        public string GrandTax { get; set; }
        [XmlAttribute(AttributeName = "GrandTotal")]
        public string GrandTotal { get; set; }
        [XmlAttribute(AttributeName = "LineSubTotal")]
        public string LineSubTotal { get; set; }
    }

    [XmlRoot(ElementName = "Order", Namespace = "http://Leggett.BizTalk.ECOM.Schemas.OMS.ORDERSTATUSUPDATE")]
    public class OrderHistoryStatusXmlOrderModel
    {
        [XmlElement(ElementName = "PersonInfoShipTo",Namespace ="")]
        public OrderHistoryStatusPersonInfoShipToModel PersonInfoShipTo { get; set; }
        [XmlElement(ElementName = "PersonInfoBillTo", Namespace = "")]
        public OrderHistoryStatusPersonInfoBillToModel PersonInfoBillTo { get; set; }
        [XmlElement(ElementName = "OrderLines", Namespace = "")]
        public OrderHistoryStatusOrderLinesModel OrderLines { get; set; }
        [XmlElement(ElementName = "OverallTotals", Namespace = "")]
        public OverallTotals OverallTotals { get; set; }
        [XmlAttribute(AttributeName = "DocumentType")]
        public string DocumentType { get; set; }
        [XmlAttribute(AttributeName = "EnterpriseCode")]
        public string EnterpriseCode { get; set; }
        [XmlAttribute(AttributeName = "OrderNo")]
        public string OrderNo { get; set; }
        [XmlAttribute(AttributeName = "OrderDate")]
        public string OrderDate { get; set; }

        [XmlAttribute(AttributeName = "Status")]
        public string Status { get; set; }

        [XmlAttribute(AttributeName = "CustomerContactID")]
        public string CustomerContactID { get; set; }
        [XmlAttribute(AttributeName = "BillToID")]
        public string BillToID { get; set; }
        [XmlAttribute(AttributeName = "OriginalTotalAmount")]
        public string OriginalTotalAmount { get; set; }

        [XmlAttribute(AttributeName = "ns0", Namespace = "http://www.w3.org/2000/xmlns/")]
        public string Ns0 { get; set; }

    }

}
