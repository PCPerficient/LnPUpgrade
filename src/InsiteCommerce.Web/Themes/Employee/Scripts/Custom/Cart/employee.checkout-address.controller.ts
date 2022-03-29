import SessionService = insite.account.ISessionService;
import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;
import StateModel = Insite.Websites.WebApi.V1.ApiModels.StateModel;
import CustomPropertyRequestModel = LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels.CustomPropertyRequestModel;
import CustomPropertyResponseModel = LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels.CustomPropertyResponseModel;

module insite.cart {
    "use strict";
   // import SessionService = insite.account.ISessionService;
    //import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
    //import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
    //import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;
   
    export class EmployeeCheckoutAddressController extends CheckoutAddressController {

        suggestedAddressList: AddressValidationResponseModel;
        continueUri: string;
        isAddressValid: boolean = true;
        defaultShipToAddress = {} as Insite.Customers.WebApi.V1.ApiModels.ShipToModel;
        vaidationSetting: any;
        static $inject = [
            "$scope",
            "$window",
            "cartService",
            "customerService",
            "websiteService",
            "coreService",
            "queryString",
            "accountService",
            "settingsService",
            "$timeout",
            "$q",
            "sessionService",
            "$localStorage",
            "$attrs",
            "$rootScope",
            "addressValidationService",
            "custompropertyservice",
            "spinnerService"
        ];

        constructor(
            protected $scope: ICartScope,
            protected $window: ng.IWindowService,
            protected cartService: ICartService,
            protected customerService: customers.ICustomerService,
            protected websiteService: websites.IWebsiteService,
            protected coreService: core.ICoreService,
            protected queryString: common.IQueryStringService,
            protected accountService: account.IAccountService,
            protected settingsService: core.ISettingsService,
            protected $timeout: ng.ITimeoutService,
            protected $q: ng.IQService,
            protected sessionService: SessionService,
            protected $localStorage: common.IWindowStorage,
            protected $attrs: ICheckoutAddressControllerAttributes,
            protected $rootScope: ng.IRootScopeService,
            protected addressValidationService: addressvalidation.IAddressValidationService,
            protected custompropertyservice: customproperty.ICustomPropertyService,
            protected spinnerService: core.ISpinnerService) {
            super($scope, $window, cartService, customerService, websiteService, coreService, queryString, accountService, settingsService, $timeout, $q, sessionService, $localStorage,$attrs,$rootScope,spinnerService);
        }


        $onInit(): void {         
            this.$localStorage.remove("placeOrderAttempt");

            this.cartId = this.queryString.get("cartId");
            this.reviewAndPayUrl = this.$attrs.reviewAndPayUrl;
            const referringPath = this.coreService.getReferringPath();
            this.editMode = referringPath && referringPath.toLowerCase().indexOf(this.reviewAndPayUrl.toLowerCase()) !== -1;

            this.websiteService.getAddressFields().then(
                (model: AddressFieldCollectionModel) => { this.getAddressFieldsCompleted(model); });

            this.accountService.getAccount().then(
                (account: AccountModel) => { this.getAccountCompleted(account); },
                (error: any) => { this.getAccountFailed(error); });

            this.settingsService.getSettings().then(
                (settingsCollection: core.SettingsCollection) => {
                    console.log(settingsCollection);
                    this.getSettingsCompleted(settingsCollection);
                },
                (error: any) => { this.getSettingsFailed(error); });

            this.sessionService.getSession().then(
                (session: SessionModel) => { this.getSessionCompleted(session); },
                (error: any) => { this.getSessionFailed(error); });

            this.$scope.$on("sessionUpdated", (event, session) => {
                this.onSessionUpdated(session);
            });
        }
        protected getSettingsCompleted(settingsCollection: any): void {
            this.customerSettings = settingsCollection.customerSettings;
            this.enableWarehousePickup = settingsCollection.accountSettings.enableWarehousePickup;
            this.vaidationSetting = settingsCollection.validationSetting;
        }
        protected getCartCompleted(cart: CartModel): void {
            this.cartService.expand = "";
            this.cart = cart;
            if (this.cart.shipTo) {
                this.initialShipToId = this.cart.shipTo.id;
            }
            this.enableEditModeIfRequired();

            // for reviewAndPayUrl case
            const initAutocomplete = this.editMode;
            this.spinnerService.show();

            //this.initialShipToId = this.cart.shipTo.id;
            this.defaultShipToAddress = this.cart.shipTo;
            this.websiteService.getCountries("states").then(
                (countryCollection: CountryCollectionModel) => { this.getCountriesCompleted(countryCollection, initAutocomplete); },
                (error: any) => { this.getCountriesFailed(error); });
        }
        checkSelectedShipTo(): void {
            if (this.billToAndShipToAreSameCustomer()) {
                this.selectedShipTo = this.cart.billTo as any as ShipToModel;
                this.isReadOnly = true;
            } else {
                this.isReadOnly = false;
            }

            if (this.onlyOneCountryToSelect()) {
                this.selectFirstCountryForAddress(this.selectedShipTo);
                this.setStateRequiredRule("st", this.selectedShipTo);
            }
            this.defaultShipToAddress = this.selectedShipTo;
            this.updateAddressFormValidation();
        }
        continueCheckout(continueUri: string, cartUri: string): void {
            let valid = $("#addressForm").validate().form();
            
            if ($(`#ststate`).val() == "") {
                $(`#ststateValidationMsg`).css('display', 'block');
                valid = false;
            }
            if (this.notValidateCrossSiteScripting()) {
                valid = false;
                this.coreService.displayModal(angular.element("#invalidAddressErrorPopup"));
            }
            if (!valid) {
                angular.element("html, body").animate({
                    scrollTop: angular.element(".error:visible").offset().top
                }, 300);
                return;
            }

            //this.continueCheckoutInProgress = true;
            this.cartUri = cartUri;

            if (this.cartId) {
                continueUri += `?cartId=${this.cartId}`;
            }

            // if no changes, redirect to next step
            //if (this.$scope.addressForm.$pristine) {
            //    this.coreService.redirectToPath(continueUri);
            //    return;
            //}

            // if the ship to has been changed, set the shipvia to null so it isn't set to a ship via that is no longer valid
            if (this.cart.shipTo && this.cart.shipTo.id !== this.selectedShipTo.id) {
                this.cart.shipVia = null;
            }
            //Prft custom code : start
            this.continueUri = continueUri;
            this.VerifyAddressByVertex(continueUri);
        }
        protected GetCustomerVertexCheckedStatus(): string {
            var result = "";
            
            if (this.selectedShipTo && this.selectedShipTo.properties["vertexChecked"])
                result = this.selectedShipTo.properties["vertexChecked"];
            return result;
        }
        IsAddressModified(): boolean {
            var result = false;
            if (this.selectedShipTo.address1.toLowerCase() != this.defaultShipToAddress.address1.toLowerCase())
                return true;
            if (this.selectedShipTo.city.toLowerCase() != this.defaultShipToAddress.city.toLowerCase())
                return true;
            if (this.selectedShipTo.country.abbreviation.toLowerCase() != this.defaultShipToAddress.country.abbreviation.toLowerCase())
                return true;
            if (this.selectedShipTo.state.name.toLowerCase() != this.defaultShipToAddress.state.name.toLowerCase())
                return true;
            if (this.selectedShipTo.postalCode.toLowerCase() != this.defaultShipToAddress.postalCode.toLowerCase())
                return true;
            return result;
        }

        IsRemoteAddressSame(remoteSuggestedAddress: AddressSuggestion): boolean {
            var result = true;
            if (this.selectedShipTo.address1.toLowerCase() != remoteSuggestedAddress.streetAddress1.toLowerCase())
                return false;
            if (this.selectedShipTo.city.toLowerCase() != remoteSuggestedAddress.city.toLowerCase())
                return false;
            if (this.selectedShipTo.country.abbreviation.toLowerCase() != remoteSuggestedAddress.country.abbreviation.toLowerCase())
                return false;
            if (this.selectedShipTo.state.name.toLowerCase() != remoteSuggestedAddress.state.name.toLowerCase())
                return false;
            if (this.selectedShipTo.postalCode.toLowerCase() != remoteSuggestedAddress.postalCode.toLowerCase())
                return false;

            return result;
        }

        IsAddressIsNew(): boolean {
            return this.selectedShipTo.isNew;
        }

        VerifyAddressByVertex(continueUri: string): void {
            this.spinnerService.show();
            var isAddressNew = this.IsAddressIsNew();
            var isAddressModified = this.IsAddressModified();
            var propertyStatus = this.GetCustomerVertexCheckedStatus();

            if (isAddressNew || isAddressModified || propertyStatus == "NoResponseFromVertex" || propertyStatus == "") // vertex call..
            {
                this.CallToVertex(continueUri);
            }
            else if (propertyStatus == "VertexSuggested") // Continue checkout
            {
                this.setCustomerOrderProperty(true, "VertexSuggested");
            }
            else if (propertyStatus == "KeepUserSelected") {
                this.setCustomerOrderProperty(true, "KeepUserSelected");
            }
        }

        CallToVertex(continueUri: string): void {
            
            const addressRequestModel = {} as AddressValidationRequestModel;
            addressRequestModel.streetAddress1 = this.selectedShipTo.address1;
            addressRequestModel.streetAddress2 = "";
            addressRequestModel.city = this.selectedShipTo.city;
            addressRequestModel.county = "";
            addressRequestModel.countryId = this.selectedShipTo.country.id;
            if (this.selectedShipTo.state && this.selectedShipTo.state.id)
                addressRequestModel.stateId = this.selectedShipTo.state.id;
            addressRequestModel.postalCode = this.selectedShipTo.postalCode;
           
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
                this.setCustomerOrderProperty(false, "NoResponseFromVertex");
            }
            else {
                var correctedAddress = addressValidationResponseModel.addressSuggestions[0];
                var isRemoteAddSame = this.IsRemoteAddressSame(correctedAddress);

                if (!isRemoteAddSame) {
                    this.suggestedAddressList = addressValidationResponseModel;
                    this.coreService.displayModal(angular.element("#addressValidationPopup"));
                }
                else {
                    this.setCustomerOrderProperty(true, "VertexSuggested");
                }
            }
        }

        protected AddressValidationFailed(error: any): void {
            this.coreService.displayModal(angular.element("#divConfirmationPopup"));
        }
        ContinueWithAddress(): void {
            this.coreService.closeModal("#divConfirmationPopup");
            this.setCustomerOrderProperty(false, "NoResponseFromVertex");
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
        selectedAddress(selectedAddressModel: AddressSuggestion): void {
            this.spinnerService.show();
            if (this.selectedShipTo.id === this.cart.billTo.id) {
                this.verifiedShipTo(selectedAddressModel);
                this.verifiedBillTo(selectedAddressModel);
            }
            else
                this.verifiedShipTo(selectedAddressModel);

            this.coreService.closeModal("#addressValidationPopup");

            if (selectedAddressModel.isRequestedAddress) {
                this.setCustomerOrderProperty(true, "KeepUserSelected");
            }
            else {
                this.setCustomerOrderProperty(true, "VertexSuggested");
            }
        }
        setCustomerOrderProperty(isAddressVerified: boolean, vertexCheckedStatus: string): void {
            var addressVerified = isAddressVerified ? "true" : "false";
            const requestModel = {} as CustomPropertyRequestModel;
            requestModel.objectName = "CustomerOrder";
            requestModel.propertyName = "isAddressVerified";
            requestModel.propertyValue = addressVerified;
            this.custompropertyservice.addUpdateCustomerOrderCustomProperty(requestModel).then(
                (customPropertyResponseModel: CustomPropertyResponseModel) => {
                    this.setCustomerCustomProperty(vertexCheckedStatus);
                },
                (error: any) => { this.CustomPropertyFailed(error); });
        }
        setCustomerCustomProperty(vertexCheckedStatus: string): void {
            const requestModel = {} as CustomPropertyRequestModel;
            requestModel.objectName = "Customer";
            requestModel.propertyName = "vertexChecked";
            requestModel.propertyValue = vertexCheckedStatus;

            this.custompropertyservice.addUpdateCustomerOrderCustomProperty(requestModel).then(
                (customPropertyResponseModel: CustomPropertyResponseModel) => {
                    this.selectedShipTo.properties["vertexChecked"] = vertexCheckedStatus;
                    this.UpdateBillToAddress();
                },
                (error: any) => { this.CustomPropertyFailed(error); });
        }
        protected UpdateBillToAddress(): void {
           
            this.HideSpinner();
            this.customerService.updateBillTo(this.cart.billTo).then(
                (billTo: BillToModel) => { this.updateBillToCompleted(billTo, this.continueUri); },
                (error: any) => { this.updateBillToFailed(error); });
        }
        protected CustomPropertyFailed(error: ng.IHttpPromiseCallbackArg<any>): void {
            this.HideSpinner();
            return;
        }

        verifiedBillTo(suggestedBillTo: AddressSuggestion): void {
            if (suggestedBillTo) {
                if (suggestedBillTo.streetAddress1) {
                    this.cart.billTo.address1 = suggestedBillTo.streetAddress1;
                }
                if (suggestedBillTo.city) {
                    this.cart.billTo.city = suggestedBillTo.city;
                }
                if (suggestedBillTo.state) {
                    this.cart.billTo.state = this.cart.billTo.country.states.filter(x => x.id == suggestedBillTo.state.id)[0];
                }
                if (suggestedBillTo.postalCode) {
                    this.cart.billTo.postalCode = suggestedBillTo.postalCode;
                }
            }
        }
        verifiedShipTo(suggestedShipTo: AddressSuggestion): void {
            if (suggestedShipTo) {
                if (suggestedShipTo.streetAddress1) {
                    this.selectedShipTo.address1 = suggestedShipTo.streetAddress1;
                }
                if (suggestedShipTo.city) {
                    this.selectedShipTo.city = suggestedShipTo.city;
                }
                if (suggestedShipTo.state) {
                    this.selectedShipTo.state = this.selectedShipTo.country.states.filter(x => x.id == suggestedShipTo.state.id)[0];
                }
                if (suggestedShipTo.postalCode) {
                    this.selectedShipTo.postalCode = suggestedShipTo.postalCode;
                }
            }
        }
        notValidateCrossSiteScripting(): boolean{    
                       
            return (this.containsSpecialChars(this.cart.billTo.firstName)
                || this.containsSpecialChars(this.cart.billTo.lastName)
                || this.containsSpecialChars(this.cart.billTo.address1)
                || this.containsSpecialChars(this.cart.billTo.address2)
                || this.containsSpecialChars(this.cart.billTo.city)
                || this.containsSpecialChars(this.cart.billTo.postalCode)
                || this.containsSpecialChars(this.cart.billTo.phone)
                || this.containsSpecialChars(this.cart.billTo.email)
                || this.containsSpecialChars(this.selectedShipTo.firstName)
                || this.containsSpecialChars(this.selectedShipTo.lastName)
                || this.containsSpecialChars(this.selectedShipTo.address1)
                || this.containsSpecialChars(this.selectedShipTo.address2)
                || this.containsSpecialChars(this.selectedShipTo.city)
                || this.containsSpecialChars(this.selectedShipTo.postalCode)
                || this.containsSpecialChars(this.selectedShipTo.phone)
                || this.containsSpecialChars(this.selectedShipTo.email)
            );

        }
        containsSpecialChars(str) {    
            const specialChars = new RegExp(`[${this.vaidationSetting.specialCharecters}]`);         
            return specialChars.test(str);
        }

    }

    angular
        .module("insite")
        .controller("CheckoutAddressController", EmployeeCheckoutAddressController);
}