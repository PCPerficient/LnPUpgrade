namespace LeggettAndPlatt.Vertex.RequestModels
{
    public class VertexAddressValidationRequestModel : VertexLoginRequestModel
    {
        public string StreetAddress1 { get; set; }
        public string StreetAddress2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string County { get; set; }
        public string Country { get; set; }
        public string PostalCode { get; set; }
        public bool EnableLog { get; set; }
    }
}
