using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Vertex.Services.Interfaces;
using System;
using LeggettAndPlatt.Vertex.RequestModels;
using LeggettAndPlatt.Vertex.ResponseModels;
using LeggettAndPlatt.Vertex.CalculateTax70Service;
using System.Net;
using System.Net.Security;
using System.Xml.Serialization;
using System.IO;
using System.ServiceModel;
using System.Configuration;

namespace LeggettAndPlatt.Vertex.Services
{
    public class VertexTaxRateService : IVertexTaxRateService, IDependency
    {
        public VertexTaxRateResponseModel GetTaxRate(VertexTaxRateRequestModel taxRateRequestModel, bool isVertexTestMode)
        {
            return GetTaxRateReponse(taxRateRequestModel, isVertexTestMode);
        }

        private VertexTaxRateResponseModel GetTaxRateReponse(VertexTaxRateRequestModel taxRateRequestModel, bool isVertexTestMode)
        {
            VertexEnvelope vertexEnvelope = PrepareModel(taxRateRequestModel);

            ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(
              delegate
              {
                  return true;
              });

           
            BasicHttpBinding binding = new BasicHttpBinding();
            if (isVertexTestMode)
            {
                binding.Security.Mode = BasicHttpSecurityMode.None;
            }
            else
            {
                binding.Security.Mode = BasicHttpSecurityMode.Transport;
            }

            if (!taxRateRequestModel.VertexEndPoint.EndsWith("/"))
            {
                taxRateRequestModel.VertexEndPoint = taxRateRequestModel.VertexEndPoint + "/";
            }

            string vertexEndPoint = taxRateRequestModel.VertexEndPoint + "vertex-ws/services/CalculateTax70";

            EndpointAddress address =
               new EndpointAddress(vertexEndPoint);

            CalculateTaxWS70 calculateTaxWS70 = new CalculateTaxWS70Client(binding, address);
            calculateTaxRequest request = new calculateTaxRequest(vertexEnvelope);
            calculateTaxResponse response = calculateTaxWS70.calculateTax70(request);

            QuotationResponseType quoteResponse = (QuotationResponseType)response.VertexEnvelope.Item;

            VertexTaxRateResponseModel taxRateResponseModel = GetResponse(quoteResponse);

            PopulateRequestAndResonseXML(taxRateRequestModel, taxRateResponseModel, request, response);

            return taxRateResponseModel;
        }
        private VertexEnvelope PrepareModel(VertexTaxRateRequestModel taxRateRequestModel)
        {
            VertexEnvelope envelope = new VertexEnvelope
            {
                Login = new LoginType
                {
                    UserName = taxRateRequestModel.UserName,
                    Password = taxRateRequestModel.Password
                }
            };

            QuotationRequestType quoteRequest = new QuotationRequestType();
            quoteRequest.documentDate = DateTime.Today;
            quoteRequest.Currency = new CurrencyType { isoCurrencyCodeAlpha = taxRateRequestModel.CurrencyCode };

            quoteRequest.Customer = new CustomerType
            {
                CustomerCode = new CustomerCodeType
                {
                    // if you put in a valid customer it seems to always return 0 tax rate...which is what we want, i guess, since only exempt customers are setup in vertex
                    Value = !string.IsNullOrWhiteSpace(taxRateRequestModel.CustomerNumber) ? taxRateRequestModel.CustomerNumber.Trim() : string.Empty

                },
                Destination = new LocationType
                {
                    StreetAddress1 = taxRateRequestModel.StreetAddress1 ?? string.Empty,
                    StreetAddress2 = taxRateRequestModel.StreetAddress2 ?? string.Empty,
                    City = taxRateRequestModel.City ?? string.Empty,
                    Country = taxRateRequestModel.Country ?? string.Empty,
                    MainDivision = taxRateRequestModel.State ?? string.Empty,
                    PostalCode = taxRateRequestModel.Zip ?? string.Empty,
                }
            };

            int itemCount = taxRateRequestModel.LineItems.Count;
            LineItemQSIType[] items = new LineItemQSIType[itemCount];

            int i = 1;
            foreach (var lineItem in taxRateRequestModel.LineItems)
            {

                var sellerType = new SellerType
                {
                    Company = taxRateRequestModel.Company,
                    Division = lineItem.LegalEntity,
                    PhysicalOrigin = new LocationType
                    {
                        taxAreaId = lineItem.TaxAreaId
                    },
                    AdministrativeOrigin = new LocationType
                    {
                        taxAreaId = lineItem.TaxAreaId
                    },
                    Department = lineItem.Branch
                };


                FlexibleFieldsFlexibleCodeField flexField = new FlexibleFieldsFlexibleCodeField { fieldId = "1", Value = lineItem.TaxClass ?? string.Empty };

                LineItemQSIType item = new LineItemQSIType
                {
                    Quantity = new MeasureType { Value = lineItem.Qty, unitOfMeasure = "" },
                    UnitPrice = lineItem.UnitPrice,
                    UnitPriceSpecified = true,
                    Product = new Product { Value = lineItem.Sku },

                    FlexibleFields = new FlexibleFields
                    {
                        FlexibleCodeField = new FlexibleFieldsFlexibleCodeField[] { flexField }
                    },

                    Seller = sellerType
                };
                items[i - 1] = item;
                i++;
            }

            quoteRequest.LineItem = items;
            envelope.Item = quoteRequest;

            return envelope;
        }

        private VertexTaxRateResponseModel GetResponse(QuotationResponseType quoteResponse)
        {
            VertexTaxRateResponseModel taxRateResponseModel = new VertexTaxRateResponseModel();
            if (quoteResponse != null)
            {
                taxRateResponseModel.SubTotal = quoteResponse.SubTotal;
                taxRateResponseModel.TotalTax = quoteResponse.TotalTax;
                taxRateResponseModel.Total = quoteResponse.Total;

                foreach (LineItemQSOType lineItem in quoteResponse.LineItem)
                {
                    LineItemResponseModel lineItemResponseModel = new LineItemResponseModel();
                    lineItemResponseModel.Sku = lineItem.Product.Value;
                    lineItemResponseModel.UnitPrice = lineItem.UnitPrice;
                    lineItemResponseModel.Qty = Convert.ToInt32(lineItem.Quantity.Value);
                    lineItemResponseModel.TotalTax = lineItem.TotalTax;
                    taxRateResponseModel.LineItems.Add(lineItemResponseModel);
                }
            }
            return taxRateResponseModel;
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

        private void PopulateRequestAndResonseXML(VertexTaxRateRequestModel taxRateRequestModel, VertexTaxRateResponseModel taxRateResponseModel, calculateTaxRequest request, calculateTaxResponse response)
        {
            if (taxRateRequestModel.EnableLog)
            {
                taxRateResponseModel.RequestXml = SerializeObject(request);
                taxRateResponseModel.ResponseXml = SerializeObject(response);
            }
        }

    }
}
