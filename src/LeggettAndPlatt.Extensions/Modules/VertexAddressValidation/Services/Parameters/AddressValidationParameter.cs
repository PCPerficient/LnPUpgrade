using Insite.Core.Services;
using Insite.Websites.WebApi.V1.ApiModels;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters
{
    public class AddressValidationParameter : ParameterBase
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
