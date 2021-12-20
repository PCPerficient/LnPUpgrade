using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace LeggettAndPlatt.PinPointe.Models
{
    [XmlRoot("xmlrequest")]
    public class PinPonteUnSubscriberRequestModel
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
        public PinPointeUnSubscriberDetails Details { get; set; }
    }
    public class PinPointeUnSubscriberDetails
    {
        [XmlElement("emailaddress")]
        public string EmailAddress { get; set; }

        [XmlElement("list")]
        public string List { get; set; }

    }
}
