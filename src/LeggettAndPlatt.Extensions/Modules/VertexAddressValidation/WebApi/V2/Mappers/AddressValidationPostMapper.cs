using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.Mappers.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.Mappers
{
    public class AddressValidationPostMapper : IAddressValidationPostMapper, IDependency, IExtension
    {
        public AddressValidationParameter MapParameter(AddressValidationRequestModel apiParameter, HttpRequestMessage request)
        {
            AddressValidationParameter addressValidationParameter = new AddressValidationParameter();
            addressValidationParameter.StreetAddress1 = apiParameter.StreetAddress1;
            addressValidationParameter.StreetAddress2 = apiParameter.StreetAddress2;
            addressValidationParameter.City = apiParameter.City;
            addressValidationParameter.StateId = apiParameter.StateId;
            addressValidationParameter.CountryId = apiParameter.CountryId;
            addressValidationParameter.PostalCode = apiParameter.PostalCode;
            return addressValidationParameter;
        }

        public AddressValidationResponseModel MapResult(AddressValidationResult serviceResult, HttpRequestMessage request)
        {
            AddressValidationResponseModel model = new AddressValidationResponseModel();
            model.AddressSuggestions = serviceResult.AddressSuggestions;
            model.RequestAddress = serviceResult.RequestAddress;
            model.ErrorMessage = serviceResult.ErrorMessage;
            model.ExceptionMsg = serviceResult.ExceptionMsg;
            model.ResponseTime = serviceResult.ResponseTime;
            return model;
        }
    }
}
