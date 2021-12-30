using System.Xml.Serialization;

namespace LeggettAndPlatt.PinPointe.Models
{
    [XmlRoot("xmlrequest")]
    public class PinPonteDeleteSubscriberRequestModel
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
        public PinPointeDeleteSubscriberDetails Details { get; set; }
    }
    public class PinPointeDeleteSubscriberDetails
    {
        [XmlElement("emailaddress")]
        public string EmailAddress { get; set; }

        [XmlElement("list")]
        public string List { get; set; }

    }
}
