using Insite.Core.WebApi;
using Insite.Websites.WebApi.V1.ApiModels;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels
{
    public class AddressValidationRequestModel  : BaseModel
    {
        public string StreetAddress1 { get; set; }
        public string StreetAddress2 { get; set; }
        public string City { get; set; }
        public string StateId { get; set; }
        public string County { get; set; }
        public string CountryId { get; set; }
        public string PostalCode { get; set; }
    }
}
