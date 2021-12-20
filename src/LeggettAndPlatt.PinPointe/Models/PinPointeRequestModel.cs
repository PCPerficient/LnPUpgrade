using System.Xml.Serialization;

namespace LeggettAndPlatt.PinPointe.Models
{
    [XmlRoot("xmlrequest")]
    public class PinPointeRequestModel
    {
        [XmlElement("username")]
        public string UserName { get; set; }

        [XmlElement("usertoken")]
        public string UserToken { get; set; }

        [XmlElement("requesttype")]
        public string RequestType { get; set; }

        [XmlElement("requestmethod")]
        public string RequestMethod { get; set; }

        [XmlElement("details")]
        public PinPointeRequestDetails Details { get; set; }
    }

    public class PinPointeRequestDetails
    {
        [XmlElement("emailaddress")]
        public string EmailAddress { get; set; }

        [XmlElement("add_to_autoresponders")]
        public string AddToAutoresponders { get; set; }

        [XmlElement("mailinglist")]
        public string MailingList { get; set; }

        [XmlElement("format")]
        public string Format { get; set; }

        [XmlElement("confirmed")]
        public string Confirmed { get; set; }

        [XmlElement("customfields")]
        public PinPointeRequestCustomFields CustomFields { get; set; }

        [XmlElement("tag")]
        public string Tag { get; set; }
    }

    public class PinPointeRequestCustomFields
    {
        [XmlElement("item")]
        public PinPointeRequestCustomFieldsItem Item { get; set; }
    }

    public class PinPointeRequestCustomFieldsItem
    {
        [XmlElement("fieldid")]
        public string FieldId { get; set; }

        [XmlElement("value")]
        public string Value { get; set; }
    }
}
