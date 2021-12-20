/* 
 Licensed under the Apache License, Version 2.0

 http://www.apache.org/licenses/LICENSE-2.0
 */
using System;
using System.Xml.Serialization;
using System.Collections.Generic;
namespace LeggettAndPlatt.IntegrationProcessor.Models
{


    [XmlRoot(ElementName = "Extn")]
    public class Extn
    {
        [XmlAttribute(AttributeName = "ExtnIsTaxed")]
        public string ExtnIsTaxed { get; set; }
    }

    [XmlRoot(ElementName = "PriceInfo", Namespace = "")]
    public class PriceInfo
    {
        [XmlAttribute(AttributeName = "Currency")]
        public string Currency { get; set; }
    }

    [XmlRoot(ElementName = "PersonInfoBillTo", Namespace = "")]
    public class PersonInfoBillTo
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

        [XmlAttribute(AttributeName = "OtherPhone")]
        public string OtherPhone { get; set; }

        [XmlAttribute(AttributeName = "State")]
        public string State { get; set; }

        [XmlAttribute(AttributeName = "ZipCode")]
        public string ZipCode { get; set; }

        [XmlAttribute(AttributeName = "PersonID")]
        public string PersonID { get; set; }

    }

    [XmlRoot(ElementName = "PersonInfoShipTo", Namespace = "")]
    public class PersonInfoShipTo
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

        [XmlAttribute(AttributeName = "OtherPhone")]
        public string OtherPhone { get; set; }
        
        [XmlAttribute(AttributeName = "State")]
        public string State { get; set; }

        [XmlAttribute(AttributeName = "ZipCode")]
        public string ZipCode { get; set; }

        [XmlAttribute(AttributeName = "PersonID")]
        public string PersonID { get; set; }
    }

    [XmlRoot(ElementName = "PaymentDetails", Namespace = "")]
    public class PaymentDetails
    {
        [XmlAttribute(AttributeName = "AuthAmount")]
        public string AuthAmount { get; set; }

        [XmlAttribute(AttributeName = "AuthCode")]
        public string AuthCode { get; set; }

        [XmlAttribute(AttributeName = "AuthorizationExpirationDate")]
        public string AuthorizationExpirationDate { get; set; }

        [XmlAttribute(AttributeName = "AuthorizationID")]
        public string AuthorizationID { get; set; }

        [XmlAttribute(AttributeName = "ChargeType")]
        public string ChargeType { get; set; }

        [XmlAttribute(AttributeName = "ProcessedAmount")]
        public string ProcessedAmount { get; set; }

        [XmlAttribute(AttributeName = "RequestAmount")]
        public string RequestAmount { get; set; }

        [XmlAttribute(AttributeName = "MaxChargeLimit")]
        public string MaxChargeLimit { get; set; }

        [XmlAttribute(AttributeName = "RequestId")]
        public string RequestId { get; set; }
    }

    [XmlRoot(ElementName = "PaymentMethod", Namespace = "")]
    public class PaymentMethod
    {
        [XmlElement(ElementName = "PaymentDetails")]
        public PaymentDetails PaymentDetails { get; set; }

        [XmlElement(ElementName = "PersonInfoBillTo")]
        public PersonInfoBillTo PersonInfoBillTo { get; set; }

        [XmlAttribute(AttributeName = "CreditCardExpDate")]
        public string CreditCardExpDate { get; set; }

        [XmlAttribute(AttributeName = "CreditCardName")]
        public string CreditCardName { get; set; }

        [XmlAttribute(AttributeName = "CreditCardNo")]
        public string CreditCardNo { get; set; }

        [XmlAttribute(AttributeName = "CreditCardType")]
        public string CreditCardType { get; set; }

        [XmlAttribute(AttributeName = "DisplayCreditCardNo")]
        public string DisplayCreditCardNo { get; set; }

        [XmlAttribute(AttributeName = "FirstName")]
        public string FirstName { get; set; }

        [XmlAttribute(AttributeName = "LastName")]
        public string LastName { get; set; }

        [XmlAttribute(AttributeName = "MaxChargeLimit")]
        public string MaxChargeLimit { get; set; }

        [XmlAttribute(AttributeName = "PaymentReference1")]
        public string PaymentReference1 { get; set; }

        [XmlAttribute(AttributeName = "PaymentType")]
        public string PaymentType { get; set; }

        [XmlAttribute(AttributeName = "UnlimitedCharges")]
        public string UnlimitedCharges { get; set; }
    }

    [XmlRoot(ElementName = "PaymentMethods")]
    public class PaymentMethods
    {
        [XmlElement(ElementName = "PaymentMethod")]
        public List<PaymentMethod> PaymentMethod { get; set; }
    }

    [XmlRoot(ElementName = "Item", Namespace = "")]
    public class Item
    {
        

        [XmlAttribute(AttributeName = "ItemID")]
        public string ItemID { get; set; }


        [XmlAttribute(AttributeName = "ProductClass")]
        public string ProductClass { get; set; }

        [XmlAttribute(AttributeName = "UnitCost")]
        public string UnitCost { get; set; }

        [XmlAttribute(AttributeName = "UnitOfMeasure")]
        public string UnitOfMeasure { get; set; }
    }

    [XmlRoot(ElementName = "LinePriceInfo")]
    public class LinePriceInfo
    {
        [XmlAttribute(AttributeName = "IsPriceLocked")]
        public string IsPriceLocked { get; set; }

        [XmlAttribute(AttributeName = "ListPrice")]
        public string ListPrice { get; set; }

        [XmlAttribute(AttributeName = "RetailPrice")]
        public string RetailPrice { get; set; }

        [XmlAttribute(AttributeName = "TaxableFlag")]
        public string TaxableFlag { get; set; }

        [XmlAttribute(AttributeName = "UnitPrice")]
        public string UnitPrice { get; set; }

    }

    [XmlRoot(ElementName = "LineTax", Namespace = "")]
    public class LineTax
    {
        [XmlAttribute(AttributeName = "Tax")]
        public string Tax { get; set; }

        [XmlAttribute(AttributeName = "ChargeCategory")]
        public string ChargeCategory { get; set; }

        [XmlAttribute(AttributeName = "ChargeName")]
        public string ChargeName { get; set; }

        [XmlAttribute(AttributeName = "TaxName")]
        public string TaxName { get; set; }

        [XmlAttribute(AttributeName = "TaxPercentage")]
        public string TaxPercentage { get; set; }       
        
    }

    [XmlRoot(ElementName = "LineTaxes", Namespace = "")]
    public class LineTaxes
    {
        [XmlElement(ElementName = "LineTax")]
        public List<LineTax> LineTax { get; set; }
    }

    [XmlRoot(ElementName = "OrderLine", Namespace = "")]
    public class OrderLine
    {
        [XmlElement(ElementName = "Item")]
        public Item Item { get; set; }

        [XmlElement(ElementName = "LinePriceInfo")]
        public LinePriceInfo LinePriceInfo { get; set; }

        [XmlElement(ElementName = "LineTaxes")]
        public LineTaxes LineTaxes { get; set; }

        [XmlAttribute(AttributeName = "CarrierServiceCode")]
        public string CarrierServiceCode { get; set; }

        [XmlAttribute(AttributeName = "DeliveryMethod")]
        public string DeliveryMethod { get; set; }

        [XmlAttribute(AttributeName = "ItemGroupCode")]
        public string ItemGroupCode { get; set; }

        [XmlAttribute(AttributeName = "LineType")]
        public string LineType { get; set; }

        [XmlAttribute(AttributeName = "OrderedQty")]
        public string OrderedQty { get; set; }

        [XmlAttribute(AttributeName = "PrimeLineNo")]
        public string PrimeLineNo { get; set; }
    }

    [XmlRoot(ElementName = "OrderLines")]
    public class OrderLines
    {
        [XmlElement(ElementName = "OrderLine", Namespace = "")]
        public List<OrderLine> OrderLine { get; set; }
    }

    [XmlRoot(ElementName = "Order", Namespace = "http://Leggett.BizTalk.ECOM.Schemas.Insite.Order")]
    public class Order
    {
        
        [XmlElement(ElementName = "PriceInfo", Namespace = "")]
        public PriceInfo PriceInfo { get; set; }

        [XmlElement(ElementName = "Extn", Namespace = "")]
        public Extn Extn { get; set; }

        [XmlElement(ElementName = "PersonInfoBillTo", Namespace = "")]
        public PersonInfoBillTo PersonInfoBillTo { get; set; }

        [XmlElement(ElementName = "PersonInfoShipTo", Namespace = "")]
        public PersonInfoShipTo PersonInfoShipTo { get; set; }

        [XmlElement(ElementName = "PaymentMethods", Namespace = "")]
        public PaymentMethods PaymentMethods { get; set; }

        [XmlElement(ElementName = "OrderLines", Namespace = "")]
        public OrderLines OrderLines { get; set; }
        
        [XmlAttribute(AttributeName = "AllocationRuleID")]
        public string AllocationRuleID { get; set; }

        [XmlAttribute(AttributeName = "DepartmentCode")]
        public string DepartmentCode { get; set; }

        [XmlAttribute(AttributeName = "BypassPricing")]
        public string BypassPricing { get; set; }

        [XmlAttribute(AttributeName = "AuthorizedClient")]
        public string AuthorizedClient { get; set; }

        [XmlAttribute(AttributeName = "DocumentType")]
        public string DocumentType { get; set; }

        [XmlAttribute(AttributeName = "EnterpriseCode")]
        public string EnterpriseCode { get; set; }

        [XmlAttribute(AttributeName = "CustomerContactID")]
        public string CustomerContactID { get; set; }

        [XmlAttribute(AttributeName = "BillToID")]
        public string BillToID { get; set; }

        [XmlAttribute(AttributeName = "AllAddressesVerified")]
        public string AllAddressesVerified { get; set; }

        [XmlAttribute(AttributeName = "ShipToID")]
        public string ShipToID { get; set; }

        [XmlAttribute(AttributeName = "PaymentStatus")]
        public string PaymentStatus { get; set; }

        [XmlAttribute(AttributeName = "EntryType")]
        public string EntryType { get; set; }

        [XmlAttribute(AttributeName = "OrderDate")]
        public string OrderDate { get; set; }

        [XmlAttribute(AttributeName = "OrderNo")]
        public string OrderNo { get; set; }

        [XmlAttribute(AttributeName = "OrderType")]
        public string OrderType { get; set; }

        [XmlAttribute(AttributeName = "PaymentRuleId")]
        public string PaymentRuleId { get; set; }
        [XmlAttribute(AttributeName = "ValidateItem")]
        public string ValidateItem { get; set; }

        [XmlAttribute(AttributeName = "CustomerPhoneNo")]
        public string CustomerPhoneNo { get; set; }
        
        [XmlAttribute(AttributeName = "CustomerFirstName")]
        public string CustomerFirstName { get; set; }

        [XmlAttribute(AttributeName = "CustomerLastName")]
        public string CustomerLastName { get; set; }

        [XmlAttribute(AttributeName = "CustomerEMailID")]
        public string CustomerEMailID { get; set; }

        [XmlAttribute(AttributeName = "CustomerZipCode")]
        public string CustomerZipCode { get; set; }

        [XmlAttribute(AttributeName = "OtherCharges")]
        public string OtherCharges { get; set; }
    }

}
