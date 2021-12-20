using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Vertex.Services.Interfaces;
using System;
using LeggettAndPlatt.Vertex.RequestModels;
using LeggettAndPlatt.Vertex.ResponseModels;
using LeggettAndPlatt.Vertex.LookupTaxAreas70Service;
using System.Net;
using System.Net.Security;
using System.Collections.Generic;
using System.Xml.Serialization;
using System.IO;
using System.ServiceModel;

namespace LeggettAndPlatt.Vertex.Services
{
    public class VertexAddressValidationService : IVertexAddressValidationService, IDependency
    {
        public VertexAddressValidationResponseModel ValidateAddress(VertexAddressValidationRequestModel addressValidationRequestModel)
        {
            return GetLookupTaxAreaReponseAddress(addressValidationRequestModel);
        }

        private VertexAddressValidationResponseModel GetLookupTaxAreaReponseAddress(VertexAddressValidationRequestModel addressValidationRequestModel)
        {

            VertexEnvelope vertexEnvelope = PrepareModel(addressValidationRequestModel);

            ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(
            delegate
            {
                return true;
            });


            BasicHttpBinding binding = new BasicHttpBinding();
            binding.Security.Mode = BasicHttpSecurityMode.Transport;
          
            if (!addressValidationRequestModel.VertexEndPoint.EndsWith("/"))
            {
                addressValidationRequestModel.VertexEndPoint = addressValidationRequestModel.VertexEndPoint + "/";
            }

            string vertexEndPoint = addressValidationRequestModel.VertexEndPoint + "vertex-ws/services/LookupTaxAreas70";

            EndpointAddress address =
               new EndpointAddress(vertexEndPoint);

            LookupTaxAreasWS70 lookupTaxAreasWS70 = new LookupTaxAreasWS70Client(binding, address);
            lookupTaxAreasRequest request = new lookupTaxAreasRequest(vertexEnvelope);
            lookupTaxAreasResponse response = lookupTaxAreasWS70.LookupTaxAreas70(request);

            TaxAreaResponseType taxAreaResponseType = (TaxAreaResponseType)response.VertexEnvelope.Item;
            VertexAddressValidationResponseModel addressValidationResponseModel = GetResponse(taxAreaResponseType);

            PopulateRequestAndResonseXML(addressValidationRequestModel, addressValidationResponseModel, request, response);

            return addressValidationResponseModel;
        }

        private VertexEnvelope PrepareModel(VertexAddressValidationRequestModel addressValidationRequestModel)
        {
            PostalAddressType postalAddressType = new PostalAddressType
            {
                StreetAddress1 = addressValidationRequestModel.StreetAddress1,
                //StreetAddress2 = addressValidationRequestModel.StreetAddress2,
                City = addressValidationRequestModel.City,
                MainDivision = addressValidationRequestModel.State,
                SubDivision = addressValidationRequestModel.County,
                PostalCode = addressValidationRequestModel.PostalCode,
                Country = addressValidationRequestModel.Country
            };

            TaxAreaLookupType taxAreaLookupType = new TaxAreaLookupType
            {
                asOfDate = DateTime.Now,
                Item = postalAddressType
            };

            TaxAreaRequestType taxAreaRequestType = new TaxAreaRequestType
            {
                TaxAreaLookup = taxAreaLookupType
            };

            VertexEnvelope vertexEnvelope = new VertexEnvelope
            {
                Login = new LoginType
                {
                    UserName = addressValidationRequestModel.UserName,
                    Password = addressValidationRequestModel.Password
                }
            };

            vertexEnvelope.Item = taxAreaRequestType;

            return vertexEnvelope;
        }

        private VertexAddressValidationResponseModel GetResponse(TaxAreaResponseType taxAreaResponseType)
        {
            VertexAddressValidationResponseModel addressValidationResponseModel = new VertexAddressValidationResponseModel();

            foreach (TaxAreaResultType taResult in taxAreaResponseType.TaxAreaResult)
            {

                if (taResult.AddressCleansingResultMessage != null)
                {
                    addressValidationResponseModel.ErrorMessage = "Error: Unable to validate address.";
                    break;
                }

                string taxAreaId = taResult.taxAreaId;

                addressValidationResponseModel.TaxAreaId = taxAreaId;

                foreach (PostalAddressType addr in taResult.PostalAddress)
                {
                    Correction correction = new Correction();
                    correction.StreetAddress1 = addr.StreetAddress1;
                    correction.StreetAddress2 = addr.StreetAddress2;
                    correction.City = addr.City;
                    correction.County = addr.SubDivision;
                    correction.State = addr.MainDivision;
                    correction.PostalCode = addr.PostalCode;
                    correction.Country = addr.Country;
                    addressValidationResponseModel.Corrections.Add(correction);
                    //Return only one suggested address
                    return addressValidationResponseModel;
                }
            }

            return addressValidationResponseModel;
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

        private void PopulateRequestAndResonseXML(VertexAddressValidationRequestModel addressValidationRequestModel, VertexAddressValidationResponseModel addressValidationResponseModel, lookupTaxAreasRequest request, lookupTaxAreasResponse response)
        {
            if (addressValidationRequestModel.EnableLog)
            {
                addressValidationResponseModel.RequestXml = SerializeObject(request);
                addressValidationResponseModel.ResponseXml = SerializeObject(response);
            }
        }

    }
}
