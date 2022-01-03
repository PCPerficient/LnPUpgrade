using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Pipelines;
using Insite.TaxCalculator.Vertex.Clients.Versions.v70.Pipelines.Parameters;
using Insite.TaxCalculator.Vertex.Clients.Versions.v70.Pipelines.Results;
using Insite.TaxCalculator.Vertex.VertexCalculateTax70;
using System.ServiceModel;
using System.ServiceModel.Description;

namespace LeggettAndPlatt.Extensions.Plugins.Tax
{
    public sealed class CreateVertexTaxProxyClient :
     IPipe<CalculateVertexTaxParameter, CalculateVertexTaxResult>,
     IMultiInstanceDependency,
     IDependency,
     IInterceptable,
     IExtension
    {
        private const string VertexCalculateTaxUrl = "https://10.21.9.59:8443/vertex-ws/services/CalculateTax70";

        public int Order => 200;

        public CalculateVertexTaxResult Execute(
          IUnitOfWork unitOfWork,
          CalculateVertexTaxParameter parameter,
          CalculateVertexTaxResult result)
        {
            result.VertexTaxProxyClient = (CalculateTaxWS70)CreateVertexTaxProxyClient.GetVertexProxyClient(parameter.VertexTaxSettings.LogTransactions);
            return result;
        }

        private static CalculateTaxWS70Client GetVertexProxyClient(
          bool logTransactions)
        {
            CalculateTaxWS70Client calculateTaxWs70Client = new CalculateTaxWS70Client();
            calculateTaxWs70Client.Endpoint.Address = new EndpointAddress("https://10.21.9.59:8443/vertex-ws/services/CalculateTax70");
            calculateTaxWs70Client.Endpoint.EndpointBehaviors.Add((IEndpointBehavior)new VertexMessageLoggingInspector(logTransactions));
            return calculateTaxWs70Client;
        }
    }
}
