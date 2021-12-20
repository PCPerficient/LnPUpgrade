using Insite.Websites.WebApi.V1.ApiModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels
{
    public class AddressSuggestion
    {
        public string StreetAddress1 { get; set; }
        public string StreetAddress2 { get; set; }
        public string City { get; set; }
        public StateModel State { get; set; }
        public string County { get; set; }
        public CountryModel Country { get; set; }
        public string PostalCode { get; set; }
        public bool IsRequestedAddress { get; set; }

    }
}
