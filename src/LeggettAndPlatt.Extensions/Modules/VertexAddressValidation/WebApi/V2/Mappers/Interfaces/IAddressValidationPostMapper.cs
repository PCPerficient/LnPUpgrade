using Insite.Core.Interfaces.Dependency;
using Insite.Core.WebApi.Interfaces;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.Mappers.Interfaces
{
    public interface IAddressValidationPostMapper : IWebApiMapper<AddressValidationRequestModel, AddressValidationParameter, AddressValidationResult, AddressValidationResponseModel>, IDependency, IExtension
    {

    }
}
