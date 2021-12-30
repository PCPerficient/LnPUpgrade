using Insite.Core.WebApi;
using System.Collections.Generic;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels
{
    public class AddressValidationResponseModel : BaseModel
    {
        public List<AddressSuggestion> AddressSuggestions { get; set; }
        public AddressSuggestion RequestAddress { get; set; }
        public string ErrorMessage { get; set; }
        public string ExceptionMsg { get; set; }
        public string ResponseTime { get; set; }
    }
}
