
module insite.account {
    "use strict";
    import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
    import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;
    import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
    import CustomPropertyRequestModel = LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels.CustomPropertyRequestModel;
    import CustomPropertyResponseModel = LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels.CustomPropertyResponseModel;

    export class EmployeeMyAccountAddressController extends MyAccountAddressController {

        suggestedAddressList: AddressValidationResponseModel;
        defaultShipToAddress = {} as Insite.Customers.WebApi.V1.ApiModels.ShipToModel;
        vaidationSetting: any;
        static $inject = ["$location",
            "$localStorage",
            "customerService",
            "websiteService",
            "sessionService",
            "queryString",
            "spinnerService",
            "addressValidationService",
            "coreService",
            "custompropertyservice",
            "$rootScope",
            "settingsService"];

        constructor(
            protected $location: ng.ILocaleService,
            protected $localStorage: common.IWindowStorage,
            protected customerService: customers.ICustomerService,
            protected websiteService: websites.IWebsiteService,
            protected sessionService: account.ISessionService,
            protected queryString: common.IQueryStringService,
            protected spinnerService: core.ISpinnerService,
            protected addressValidationService: addressvalidation.IAddressValidationService,
            protected coreService: core.ICoreService,
            protected custompropertyservice: customproperty.ICustomPropertyService,
            protected $rootScope: ng.IRootScopeService,
            protected settingsService: core.ISettingsService) {
            super($location, $localStorage, customerService, websiteService, sessionService, queryString, $rootScope);
            this.settingsService.getSettings().then(
                (settingsCollection: core.SettingsCollection) => {

                    this.getSettingsCompleted(settingsCollection);
                },
                (error: any) => { this.getSettingsFailed(error); });
        }
        protected getSettingsCompleted(settingsCollection: any): void {
          
            this.vaidationSetting = settingsCollection.validationSetting;
        }
        protected getSettingsFailed(error: any): void {
        }

        checkSelectedShipTo(): void {
            if (this.billToAndShipToAreSameCustomer()) {
                this.isReadOnly = true;
            } else {
                this.isReadOnly = false;
            }

            if (this.onlyOneCountryToSelect()) {
                this.selectFirstCountryForAddress(this.shipTo);
                this.setStateRequiredRule("st", this.shipTo);
            }
            this.updateAddressFormValidation();
            this.SetDefaultShipTo();
        }

        protected getSessionCompleted(session: SessionModel): void {
            const shipTo = session.shipTo.oneTimeAddress ? null : session.shipTo;
            this.getBillTo(session.shipTo);

        }
        protected getBillToCompleted(billTo: BillToModel, selectedShipTo?: ShipToModel): void {
            this.billTo = billTo;

            this.websiteService.getCountries("states").then(
                (countryCollection: CountryCollectionModel) => {
                    this.getCountriesCompleted(countryCollection, selectedShipTo);
                    this.SetDefaultShipTo();
                },
                (error: any) => { this.getCountriesFailed(error); });
        }
        SetDefaultShipTo(): void {
            this.defaultShipToAddress.address1 = this.shipTo.address1;
            this.defaultShipToAddress.city = this.shipTo.city;
            this.defaultShipToAddress.country = this.shipTo.country;
            this.defaultShipToAddress.state = this.shipTo.state;
            this.defaultShipToAddress.postalCode = this.shipTo.postalCode;
        }
        save(): void {
            let valid = angular.element("#addressForm").validate().form();
            if (this.notValidateCrossSiteScripting()) {
                valid = false;
                this.coreService.displayModal(angular.element("#invalidAddressErrorPopup"));
            }
            if ($(`#ststate`).val() == "") {
                $(`#ststateValidationMsg`).css('display', 'block');
                valid = false;
            }
           
            if (!valid) {
                angular.element("html, body").animate({
                    scrollTop: angular.element(".error:visible").offset().top
                }, 300);

                return;
            }
            //PRFT Code start
            this.spinnerService.show();
            this.VerifyAddressByVertex();
            //PRFT code end
        }
        showHideStateValidationMessage(): void {
          
            if ($(`#ststate`).val() == "") {
                $(`#ststateValidationMsg`).css('display', 'block');

            }
            else {
                $(`#ststateValidationMsg`).css('display', 'none');
            }
        }

        VerifyAddressByVertex(): void {
            this.spinnerService.show();
            var isAddressNew = this.IsAddressIsNew();
            var isAddressModified = this.IsAddressModified();
            var propertyStatus = this.GetCustomerVertexCheckedStatus();

            if (isAddressNew || isAddressModified || propertyStatus == "NoResponseFromVertex" || propertyStatus == "") // vertex call..
            {
                this.CallToVertex();
            }
            else if (propertyStatus == "VertexSuggested") // Continue checkout
            {
                this.setCustomerCustomProperty("VertexSuggested");
            }
            else if (propertyStatus == "KeepUserSelected") {
                this.setCustomerCustomProperty("KeepUserSelected");
            }
        }
        IsAddressIsNew(): boolean {
            return this.shipTo.isNew;
        }
        protected GetCustomerVertexCheckedStatus(): string {
            var result = "";
            if (this.shipTo && this.shipTo.properties["vertexChecked"])
                result = this.shipTo.properties["vertexChecked"];
            return result;
        }
        IsAddressModified(): boolean {
            var shipToState = this.shipTo.state != null ? this.shipTo.state.name.toLowerCase() : "";
            var defaultShipToState = this.defaultShipToAddress.state != null ? this.defaultShipToAddress.state.name.toLowerCase() : "";
            var shipToCountry = this.shipTo.country != null ? this.shipTo.country.abbreviation.toLowerCase() : "";
            var defaultShipToCountry = this.defaultShipToAddress.country != null ? this.defaultShipToAddress.country.abbreviation.toLowerCase() : "";

            var result = false;
            if (this.shipTo.address1.toLowerCase() != this.defaultShipToAddress.address1.toLowerCase())
                return true;
            if (this.shipTo.city.toLowerCase() != this.defaultShipToAddress.city.toLowerCase())
                return true;
            if (shipToCountry != defaultShipToCountry)
                return true;
            if (shipToState !=defaultShipToState)
                return true;
            if (this.shipTo.postalCode.toLowerCase() != this.defaultShipToAddress.postalCode.toLowerCase())
                return true;
            return result;
        }

        CallToVertex(): void {
            const addressRequestModel = {} as AddressValidationRequestModel;
            addressRequestModel.streetAddress1 = this.shipTo.address1;
            addressRequestModel.streetAddress2 = "";
            addressRequestModel.city = this.shipTo.city;
            addressRequestModel.county = "";
            addressRequestModel.countryId = this.shipTo.country.id;
            if (this.shipTo.state && this.shipTo.state.id)
                addressRequestModel.stateId = this.shipTo.state.id;
            addressRequestModel.postalCode = this.shipTo.postalCode;

            this.addressValidationService.validateAddress(addressRequestModel).then(
                (addressValidationResponseModel: AddressValidationResponseModel) => {
                    this.AddressValidationCompleted(addressValidationResponseModel);
                },
                (error: any) => { this.AddressValidationFailed(error); });
        }
        protected AddressValidationCompleted(addressValidationResponseModel: AddressValidationResponseModel): void {
            if (addressValidationResponseModel && addressValidationResponseModel.errorMessage && addressValidationResponseModel.errorMessage.length > 0) {
                this.AddressValidationFailed(addressValidationResponseModel.errorMessage);
            }
            else if (!addressValidationResponseModel.addressSuggestions || addressValidationResponseModel.addressSuggestions.length == 0) {
                this.setCustomerCustomProperty("NoResponseFromVertex");
            }
            else {
                var correctedAddress = addressValidationResponseModel.addressSuggestions[0];
                var isRemoteAddSame = this.IsRemoteAddressSame(correctedAddress);

                if (!isRemoteAddSame) {
                    this.suggestedAddressList = addressValidationResponseModel;
                    this.coreService.displayModal(angular.element("#myAccountAddressValidationPopup"));
                }
                else {
                    this.setCustomerCustomProperty("VertexSuggested");
                }
            }
        }
        IsRemoteAddressSame(remoteSuggestedAddress: AddressSuggestion): boolean {
            var result = true;
            if (this.shipTo.address1.toLowerCase() != remoteSuggestedAddress.streetAddress1.toLowerCase())
                return false;
            if (this.shipTo.city.toLowerCase() != remoteSuggestedAddress.city.toLowerCase())
                return false;
            if (this.shipTo.country.abbreviation.toLowerCase() != remoteSuggestedAddress.country.abbreviation.toLowerCase())
                return false;
            if (this.shipTo.state.name.toLowerCase() != remoteSuggestedAddress.state.name.toLowerCase())
                return false;
            if (this.shipTo.postalCode.toLowerCase() != remoteSuggestedAddress.postalCode.toLowerCase())
                return false;

            return result;
        }
        protected AddressValidationFailed(error: any): void {
            this.coreService.displayModal(angular.element("#divConfirmationPopup"));
        }
        ContinueWithAddress(): void {
            this.coreService.closeModal("#divConfirmationPopup");
            this.setCustomerCustomProperty("NoResponseFromVertex");
        }
        CancelAddress(): void {
            this.coreService.closeModal("#divConfirmationPopup");
            this.HideSpinner();
            return;
        }
        protected ShowSpinner(): void {
            this.spinnerService.show();
        }
        protected HideSpinner(): void {
            this.spinnerService.hide();
        }
        setCustomerCustomProperty(vertexCheckedStatus: string): void {
            this.shipTo.properties["vertexChecked"] = vertexCheckedStatus;
            this.UpdateCustomerBillTo();
        }
        protected CustomPropertyFailed(error: ng.IHttpPromiseCallbackArg<any>): void {
            this.HideSpinner();
            return;
        }
        selectedAddress(selectedAddressModel: AddressSuggestion): void {
            this.ShowSpinner();
            if (this.shipTo.id == this.billTo.id) {
                this.verifiedShipTo(selectedAddressModel);
                this.verifiedBillTo(selectedAddressModel);
            }
            else
                this.verifiedShipTo(selectedAddressModel);

            this.coreService.closeModal("#myAccountAddressValidationPopup");

            if (selectedAddressModel.isRequestedAddress) {
                this.setCustomerCustomProperty("KeepUserSelected");
            }
            else {
                this.setCustomerCustomProperty("VertexSuggested");
            }
        }
        verifiedBillTo(suggestedBillTo: AddressSuggestion): void {
            if (suggestedBillTo) {
                if (suggestedBillTo.streetAddress1) {
                    this.billTo.address1 = suggestedBillTo.streetAddress1;
                }
                if (suggestedBillTo.city) {
                    this.billTo.city = suggestedBillTo.city;
                }
                if (suggestedBillTo.state) {
                    this.billTo.state = this.billTo.country.states.filter(x => x.id == suggestedBillTo.state.id)[0];
                }
                if (suggestedBillTo.postalCode) {
                    this.billTo.postalCode = suggestedBillTo.postalCode;
                }
            }
        }
        verifiedShipTo(suggestedShipTo: AddressSuggestion): void {
            if (suggestedShipTo) {
                if (suggestedShipTo.streetAddress1) {
                    this.shipTo.address1 = suggestedShipTo.streetAddress1;
                }
                if (suggestedShipTo.city) {
                    this.shipTo.city = suggestedShipTo.city;
                }
                if (suggestedShipTo.state) {
                    this.shipTo.state = this.shipTo.country.states.filter(x => x.id == suggestedShipTo.state.id)[0];
                }
                if (suggestedShipTo.postalCode) {
                    this.shipTo.postalCode = suggestedShipTo.postalCode;
                }
            }
        }

        protected UpdateCustomerBillTo(): void {
            this.HideSpinner();
            
            this.customerService.updateBillTo(this.billTo).then(
                (billTo: BillToModel) => { this.updateBillToCompleted(billTo); },
                (error: any) => { this.updateBillToFailed(error); });
        }
        notValidateCrossSiteScripting(): boolean {

            return (this.containsSpecialChars(this.billTo.firstName)
                || this.containsSpecialChars(this.billTo.lastName)
                || this.containsSpecialChars(this.billTo.address1)
                || this.containsSpecialChars(this.billTo.address2)
                || this.containsSpecialChars(this.billTo.city)
                || this.containsSpecialChars(this.billTo.postalCode)
                || this.containsSpecialChars(this.billTo.phone)
                || this.containsSpecialChars(this.billTo.email)
                || this.containsSpecialChars(this.shipTo.firstName)
                || this.containsSpecialChars(this.shipTo.lastName)
                || this.containsSpecialChars(this.shipTo.address1)
                || this.containsSpecialChars(this.shipTo.address2)
                || this.containsSpecialChars(this.shipTo.city)
                || this.containsSpecialChars(this.shipTo.postalCode)
                || this.containsSpecialChars(this.shipTo.phone)
                || this.containsSpecialChars(this.shipTo.email)
            );

        }
        containsSpecialChars(str) {
            const specialChars = new RegExp(`[${this.vaidationSetting.specialCharecters}]`);
            return specialChars.test(str);
        }
    }
    angular
        .module("insite")
        .controller("MyAccountAddressController", EmployeeMyAccountAddressController);
}