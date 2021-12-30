using Insite.Core.Services;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results
{
    public class AddressValidationResult : ResultBase
    {
        public List<AddressSuggestion> AddressSuggestions { get; set; }
        public AddressSuggestion RequestAddress { get; set; }
        public string ErrorMessage { get; set; }
        public string ExceptionMsg { get; set; }
        public string ResponseTime { get; set; }
    }
}
