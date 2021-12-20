using System.Collections.Generic;

namespace LeggettAndPlatt.Vertex.ResponseModels
{
    public class VertexAddressValidationResponseModel
    {
        public VertexAddressValidationResponseModel()
        {
            Corrections = new List<Correction>();
        }
        public List<Correction> Corrections { get; set; }
        public string ErrorMessage { get; set; }
        public string ExceptionMsg { get; set; }
        public string ResponseTime { get; set; }
        public string TaxAreaId { get; set; }
        public string RequestXml { get; set; }
        public string ResponseXml { get; set; }
    }

    public class Correction
    {
        public string StreetAddress1 { get; set; }
        public string StreetAddress2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string County { get; set; }
        public string Country { get; set; }
        public string PostalCode { get; set; }
    }
}
