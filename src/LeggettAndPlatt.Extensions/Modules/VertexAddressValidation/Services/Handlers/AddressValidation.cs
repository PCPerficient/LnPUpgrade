using Insite.Common.Logging;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using Insite.Websites.WebApi.V1.ApiModels;
using LeggettAndPlatt.Extensions.Common;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Results;
using LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels;
using LeggettAndPlatt.Vertex.RequestModels;
using LeggettAndPlatt.Vertex.ResponseModels;
using LeggettAndPlatt.Vertex.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Linq.Expressions;

namespace LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.Services.Handlers
{
    [DependencyName("VertexAddressValidation")]
    public class AddressValidation : HandlerBase<AddressValidationParameter, AddressValidationResult>
    {
        private readonly IHandlerFactory handlerFactory;
        private readonly IVertexAddressValidationService addressValidationService;
        protected readonly CommonSettings CommonSettings;
        protected readonly EmailHelper EmailHelper;
        protected readonly IEmailService EmailService;

        IUnitOfWork unitOfWork;
        private readonly VertexSettings VertexSettings;
        public override int Order
        {
            get
            {
                return 500;
            }
        }
        public AddressValidation(IHandlerFactory handlerFactory, IVertexAddressValidationService addressValidationService,
            VertexSettings vertexSettings,
            CommonSettings commonSettings,
            EmailHelper emailHelper,
            IEmailService emailService)
        {
            this.handlerFactory = handlerFactory;
            this.addressValidationService = addressValidationService;
            this.VertexSettings = vertexSettings;
            this.CommonSettings = commonSettings;
            this.EmailHelper = emailHelper;
            this.EmailService = emailService;
        }
        public override AddressValidationResult Execute(IUnitOfWork unitOfWork, AddressValidationParameter parameter, AddressValidationResult result)
        {
            this.unitOfWork = unitOfWork;
            AddressValidationResult validationResult = new AddressValidationResult();
            try
            {
                VertexAddressValidationRequestModel request = GetVertexAddressValidationRequestModel(parameter);
                VertexAddressValidationResponseModel vertexAddressResponseModel = this.addressValidationService.ValidateAddress(request,this.VertexSettings.VertexTestMode);
                AddAddressLog(vertexAddressResponseModel);
                return GetAddressValidationResult(vertexAddressResponseModel, parameter);
            }
            catch(Exception ex)
            {
                LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                this.SendExceptionEmail("Vertex Address Error: " + ex.ToString());
                result.ErrorMessage = ex.ToString();
                return result;
            }
        }

        #region Helper Method
        private void AddAddressLog(VertexAddressValidationResponseModel responseModel)
        {
            if (VertexSettings.VertexEnableLog)
            {
                LogHelper.For((object)this).Info("Vertex Address Request: " + responseModel.RequestXml);

                LogHelper.For((object)this).Info("Vertex Address Response: " + responseModel.ResponseXml);
            }
        }
        private void SendExceptionEmail(string error)
        {
            if (this.CommonSettings.ExceptionErrorEmailActive)
            {
                string subject = "Vertex - Address Validation : Failed On " + DateTime.Now;
                dynamic obj = new ExpandoObject();
                obj.ApiModle = string.Empty;
                obj.MailSubject = subject;
                obj.JsonInput = string.Empty;
                obj.JsonOutput = string.Empty;
                obj.AdditionalInfo = error;

                this.EmailHelper.ErrorEmail(obj, this.EmailService);
            }
        }
       
        private VertexAddressValidationRequestModel GetVertexAddressValidationRequestModel(AddressValidationParameter parameter)
        {
            VertexAddressValidationRequestModel model = new VertexAddressValidationRequestModel();
            model.StreetAddress1 = parameter.StreetAddress1;
            model.StreetAddress2 = string.Empty;
            model.City = parameter.City;
            model.State = GetStateAbbreviation(parameter.CountryId,parameter.StateId);
            model.County = string.Empty;
            model.Country = GetCountryIsoCode3(parameter.CountryId);
            model.PostalCode = parameter.PostalCode;
            model.UserName = this.VertexSettings.VertexUserName;
            model.Password = this.VertexSettings.VertexPassword;
            model.EnableLog = VertexSettings.VertexEnableLog;
            model.VertexEndPoint = VertexSettings.VertexEndPoint;
            return model;
        }
        private string GetCountryIsoCode3(string countryId)
        {
            Guid id = new Guid(countryId);
            Country country = this.unitOfWork.GetRepository<Country>().GetTable().FirstOrDefault<Country>((Expression<Func<Country, bool>>)(c => c.Id == id));
            return country.IsoCode3;
        }
        private string GetStateAbbreviation(string countryId,string stateId)
        {
            Guid id = new Guid(stateId);
            Guid cId = new Guid(countryId);
            State state = this.unitOfWork.GetRepository<State>().GetTable().FirstOrDefault<State>((Expression<Func<State, bool>>)(s => s.CountryId == cId && s.Id == id));
            return state.Abbreviation;
        }

        private AddressValidationResult GetAddressValidationResult(VertexAddressValidationResponseModel parameter, AddressValidationParameter requestAddressParameter)
        {
            AddressValidationResult result = new AddressValidationResult();
            List<AddressSuggestion> suggestionList = GetSuggestedAddressList(parameter.Corrections);
            result.AddressSuggestions = suggestionList;
            result.RequestAddress = GetRequestedAddress(requestAddressParameter);
            result.ErrorMessage = parameter.ErrorMessage;
            result.ExceptionMsg = parameter.ExceptionMsg;
            result.ResponseTime = parameter.ResponseTime;
            return result;
        }
        private AddressSuggestion GetRequestedAddress(AddressValidationParameter requestAddressParameter)
        {
            Guid countryId = new Guid(requestAddressParameter.CountryId);
            Country country = this.unitOfWork.GetRepository<Country>().GetTable().FirstOrDefault<Country>((Expression<Func<Country, bool>>)(c => c.Id == countryId));
            Guid stateId = new Guid(requestAddressParameter.StateId);
            State state = this.unitOfWork.GetRepository<State>().GetTable().FirstOrDefault<State>((Expression<Func<State, bool>>)(s => s.Id == stateId));

            AddressSuggestion requestAddress = new AddressSuggestion();
            requestAddress.StreetAddress1 = requestAddressParameter.StreetAddress1;
            requestAddress.StreetAddress2 = requestAddressParameter.StreetAddress2;
            requestAddress.City = requestAddressParameter.City;
            requestAddress.State = new StateModel() { Id = state.Id.ToString(), Abbreviation = state.Abbreviation, Name = state.Name };
            requestAddress.County = string.Empty;
            requestAddress.Country = GetCountryModelForAbbreviation(country.Abbreviation);//new CountryModel() { Id = country.Id.ToString(), Abbreviation = country.Abbreviation, Name = country.Name };
            requestAddress.PostalCode = requestAddressParameter.PostalCode;
            requestAddress.IsRequestedAddress = true;
            return requestAddress;
        }
        private List<AddressSuggestion> GetSuggestedAddressList(List<Correction> correctionList)
        {
            List<AddressSuggestion> suggestedAddressList = new List<AddressSuggestion>();
            foreach (Correction item in correctionList)
            {
                AddressSuggestion suggestion = new AddressSuggestion();
                suggestion.StreetAddress1 = item.StreetAddress1 ?? string.Empty;
                suggestion.StreetAddress2 = item.StreetAddress2 ?? string.Empty;
                suggestion.City = item.City ?? string.Empty;
                suggestion.State = GetStateModel(item.Country, item.State);
                suggestion.County = item.County;
                suggestion.Country = GetCountryModelForIsoCode3(item.Country);
                suggestion.PostalCode = item.PostalCode ?? string.Empty;
                suggestion.IsRequestedAddress = false;
                suggestedAddressList.Add(suggestion);
            }
            return suggestedAddressList;
        }
        private CountryModel GetCountryModelForIsoCode3(string abbreviation)
        {
            CountryModel countryModel = new CountryModel();
            Country country = this.unitOfWork.GetRepository<Country>().GetTable().FirstOrDefault<Country>((Expression<Func<Country, bool>>)(c => c.IsoCode3 == abbreviation));

            if (country != null)
            {
                countryModel.Id = Convert.ToString(country.Id);
                countryModel.Abbreviation = country.Abbreviation;
                countryModel.Name = country.Name;
            }
            return countryModel;
        }
        private CountryModel GetCountryModelForAbbreviation(string abbreviation)
        {
            CountryModel countryModel = new CountryModel();
            Country country = this.unitOfWork.GetRepository<Country>().GetTable().FirstOrDefault<Country>((Expression<Func<Country, bool>>)(c => c.Abbreviation == abbreviation));

            if (country != null)
            {
                countryModel.Id = Convert.ToString(country.Id);
                countryModel.Abbreviation = country.Abbreviation;
                countryModel.Name = country.Name;
            }
            return countryModel;
        }

        private List<StateModel> GetCountryState(ICollection<State> states)
        {
            List<StateModel> stateList = new List<StateModel>();
            if (states != null)
            {
                foreach (State s in states)
                {
                    var state = new StateModel()
                    {
                        Id = s.Id.ToString(),
                        Name = s.Name,
                        Abbreviation = s.Abbreviation

                    };
                    stateList.Add(state);
                }
            }
            return stateList;
        }
        private StateModel GetStateModel(string countryCode, string stateCode)
        {
            StateModel stateModel = new StateModel();
            Country country = this.unitOfWork.GetRepository<Country>().GetTable().FirstOrDefault<Country>((Expression<Func<Country, bool>>)(c => c.IsoCode3 == countryCode));
            State state = this.unitOfWork.GetRepository<State>().GetTable().FirstOrDefault<State>((Expression<Func<State, bool>>)(c => c.CountryId == country.Id && c.Abbreviation == stateCode));
            if (state != null)
            {
                stateModel.Id = Convert.ToString(state.Id);
                stateModel.Abbreviation = state.Abbreviation;
                stateModel.Name = state.Name;
            }
            return stateModel;
        }
        #endregion Helper Method.
    }
}
