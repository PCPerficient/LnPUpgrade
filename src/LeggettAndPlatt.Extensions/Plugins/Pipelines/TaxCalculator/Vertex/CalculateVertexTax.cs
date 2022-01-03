using Insite.Common.Logging;
using Insite.Core.Exceptions;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Pipelines;
using Insite.Data.Entities;
using Insite.TaxCalculator.Vertex.Clients.Versions.v70.Pipelines.Parameters;
using Insite.TaxCalculator.Vertex.Clients.Versions.v70.Pipelines.Results;
using Insite.TaxCalculator.Vertex.VertexCalculateTax70;
using LeggettAndPlatt.Extensions.Common;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Vertex.RequestModels;
using LeggettAndPlatt.Vertex.ResponseModels;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Xml.Serialization;

namespace LeggettAndPlatt.Extensions.Plugins.Pipelines.TaxCalculator.Vertex
{
    public sealed class CalculateVertexTax : IPipe<CalculateVertexTaxParameter, CalculateVertexTaxResult>, IMultiInstanceDependency, IDependency, IInterceptable, IExtension
    {
        public readonly string[] addressErrorMessages = new string[] { "The LocationRole being added is invalid.", "No tax areas were found during the lookup." };
       
        public int Order
        {
            get
            {
                return 300;
            }
        }

        public CalculateVertexTax()
        {
           
        }

        public CalculateVertexTaxResult Execute(IUnitOfWork unitOfWork, CalculateVertexTaxParameter parameter, CalculateVertexTaxResult result)
        {
            calculateTaxResponse _calculateTaxResponse;
            calculateTaxRequest _calculateTaxRequest = new calculateTaxRequest()
            {
                VertexEnvelope = result.VertexEnvelope
            };
            try
            {
                _calculateTaxResponse = result.VertexTaxProxyClient.calculateTax70(_calculateTaxRequest);


            }
            catch (Exception exception) when (this.addressErrorMessages.Any<string>((string e) => exception.Message.StartsWith(e, StringComparison.InvariantCultureIgnoreCase)))
            {
                LogHelper.For(this).Error(string.Concat("Invalid Address Error running Vertex calculateTax70 method: ", exception.Message), exception, "TaxCalculator_Vertex", null);
                throw new HttpException(400, typeof(InvalidAddressException).ToString());
            }
            catch (Exception exception2)
            {
                Exception exception1 = exception2;
                LogHelper.For(this).Error(string.Concat("Error running Vertex calculateTax70 method: ", exception1.Message), exception1, "TaxCalculator_Vertex", null);
                throw;
            }
            QuotationResponseType item = _calculateTaxResponse.VertexEnvelope.Item as QuotationResponseType;
            if (item == null)
            {
                throw new Exception("An unexpected response has been received for this Vertex tax calculation request.");
            }
            //PRFT Custom Code - START
            AddVertexLog(_calculateTaxRequest, _calculateTaxResponse,parameter);
            //ToDo - Verify after build on server if taxcode2 value in DB.
        //    SetOrderLineTaxFromVertaxResponse(item, parameter.CustomerOrder);
            //PRFT Custom Code END

            result.TaxAmount = item.TotalTax;
            return result;
        }

    

        private void AddVertexLog(calculateTaxRequest calculateTaxRequest, calculateTaxResponse calculateTaxResponse, CalculateVertexTaxParameter parameter)
        {
            if(parameter.VertexTaxSettings.LogTransactions)
            {
                LogHelper.For((object)this).Info("Vertex Tax Request: " + SerializeObject(calculateTaxRequest));

                LogHelper.For((object)this).Info("Vertex Tax Response: " + SerializeObject(calculateTaxResponse));
            }
        }

        #region Private Methods
      

        private void SetOrderLineTaxFromVertaxResponse(QuotationResponseType quoteResponse, CustomerOrder customerOrder)
        {
            foreach (var item in quoteResponse.LineItem)
            {
                var orderLine = customerOrder.OrderLines.FirstOrDefault(o => o.Product.ErpNumber.Equals(item.Product.Value, StringComparison.InvariantCultureIgnoreCase));
                if (orderLine != null)
                {
                    orderLine.TaxAmount = item.TotalTax;
                    decimal taxPercantageRound = 0;
                    if (item.TotalTax > 0)
                    {
                        decimal taxPercantage = (item.TotalTax / (orderLine.TotalNetPrice));
                        taxPercantageRound = Decimal.Round(Convert.ToDecimal(taxPercantage), 2, MidpointRounding.AwayFromZero);
                    }
                    orderLine.TaxCode2 = Convert.ToString(taxPercantageRound);
                }
            }
        }

        private string SerializeObject(object value)
        {
            XmlSerializer xmlSerializer = new XmlSerializer(value.GetType());
            StringWriter stringWriter1 = new StringWriter();
            StringWriter stringWriter2 = stringWriter1;
            object o = value;
            xmlSerializer.Serialize((TextWriter)stringWriter2, o);
            return stringWriter1.ToString();
        }

        
        #endregion
    }
}
