using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Vertex.RequestModels;
using LeggettAndPlatt.Vertex.ResponseModels;

namespace LeggettAndPlatt.Vertex.Services.Interfaces
{
    public interface IVertexTaxRateService : IDependency
    {
        VertexTaxRateResponseModel GetTaxRate(VertexTaxRateRequestModel taxRateRequestModel,bool isVertexTestMode);
    }
}
