using System.Xml.Serialization;

namespace LeggettAndPlatt.PinPointe.Models
{
    [XmlRoot("response")]
    public class PinPointeResponseModel
    {
        [XmlElement("status")]
        public string Status { get; set; }

        [XmlElement("data")]
        public string Data { get; set; }

        [XmlElement("version")]
        public string Version { get; set; }

        [XmlElement("elapsed")]
        public string Elapsed { get; set; }

        [XmlElement("errormessage")]
        public string ErrorMessage { get; set; }

        [XmlElement("errordetail")]
        public string ErrorDetail { get; set; }

        public string RequestXML { get; set; }
    }
}
