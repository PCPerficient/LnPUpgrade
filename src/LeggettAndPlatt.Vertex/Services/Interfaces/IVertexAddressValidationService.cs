using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Vertex.RequestModels;
using LeggettAndPlatt.Vertex.ResponseModels;

namespace LeggettAndPlatt.Vertex.Services.Interfaces
{
    public interface IVertexAddressValidationService : IDependency
    {
        VertexAddressValidationResponseModel ValidateAddress(VertexAddressValidationRequestModel addressValidationRequestModel,bool isVertexTestMode);
    }
}
