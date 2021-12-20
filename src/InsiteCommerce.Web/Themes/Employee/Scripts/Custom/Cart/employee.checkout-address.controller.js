var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var insite;
(function (insite) {
    var cart;
    (function (cart_1) {
        "use strict";
        // import SessionService = insite.account.ISessionService;
        //import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
        //import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
        //import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;
        var EmployeeCheckoutAddressController = /** @class */ (function (_super) {
            __extends(EmployeeCheckoutAddressController, _super);
            function EmployeeCheckoutAddressController($scope, $window, cartService, customerService, websiteService, coreService, queryString, accountService, settingsService, $timeout, $q, sessionService, $localStorage, $attrs, $rootScope, addressValidationService, custompropertyservice, spinnerService) {
                var _this = _super.call(this, $scope, $window, cartService, customerService, websiteService, coreService, queryString, accountService, settingsService, $timeout, $q, sessionService, $localStorage, $attrs, $rootScope, spinnerService) || this;
                _this.$scope = $scope;
                _this.$window = $window;
                _this.cartService = cartService;
                _this.customerService = customerService;
                _this.websiteService = websiteService;
                _this.coreService = coreService;
                _this.queryString = queryString;
                _this.accountService = accountService;
                _this.settingsService = settingsService;
                _this.$timeout = $timeout;
                _this.$q = $q;
                _this.sessionService = sessionService;
                _this.$localStorage = $localStorage;
                _this.$attrs = $attrs;
                _this.$rootScope = $rootScope;
                _this.addressValidationService = addressValidationService;
                _this.custompropertyservice = custompropertyservice;
                _this.spinnerService = spinnerService;
                _this.isAddressValid = true;
                _this.defaultShipToAddress = {};
                return _this;
            }
            EmployeeCheckoutAddressController.prototype.$onInit = function () {
                var _this = this;
                this.$localStorage.remove("placeOrderAttempt");
                this.cartId = this.queryString.get("cartId");
                this.reviewAndPayUrl = this.$attrs.reviewAndPayUrl;
                var referringPath = this.coreService.getReferringPath();
                this.editMode = referringPath && referringPath.toLowerCase().indexOf(this.reviewAndPayUrl.toLowerCase()) !== -1;
                this.websiteService.getAddressFields().then(function (model) { _this.getAddressFieldsCompleted(model); });
                this.accountService.getAccount().then(function (account) { _this.getAccountCompleted(account); }, function (error) { _this.getAccountFailed(error); });
                this.settingsService.getSettings().then(function (settingsCollection) { _this.getSettingsCompleted(settingsCollection); }, function (error) { _this.getSettingsFailed(error); });
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
                this.$scope.$on("sessionUpdated", function (event, session) {
                    _this.onSessionUpdated(session);
                });
            };
            EmployeeCheckoutAddressController.prototype.getCartCompleted = function (cart) {
                var _this = this;
                this.cartService.expand = "";
                this.cart = cart;
                if (this.cart.shipTo) {
                    this.initialShipToId = this.cart.shipTo.id;
                }
                this.enableEditModeIfRequired();
                // for reviewAndPayUrl case
                var initAutocomplete = this.editMode;
                this.spinnerService.show();
                //this.initialShipToId = this.cart.shipTo.id;
                this.defaultShipToAddress = this.cart.shipTo;
                this.websiteService.getCountries("states").then(function (countryCollection) { _this.getCountriesCompleted(countryCollection, initAutocomplete); }, function (error) { _this.getCountriesFailed(error); });
            };
            EmployeeCheckoutAddressController.prototype.checkSelectedShipTo = function () {
                if (this.billToAndShipToAreSameCustomer()) {
                    this.selectedShipTo = this.cart.billTo;
                    this.isReadOnly = true;
                }
                else {
                    this.isReadOnly = false;
                }
                if (this.onlyOneCountryToSelect()) {
                    this.selectFirstCountryForAddress(this.selectedShipTo);
                    this.setStateRequiredRule("st", this.selectedShipTo);
                }
                this.defaultShipToAddress = this.selectedShipTo;
                this.updateAddressFormValidation();
            };
            EmployeeCheckoutAddressController.prototype.continueCheckout = function (continueUri, cartUri) {
                var valid = $("#addressForm").validate().form();
                if (!valid) {
                    angular.element("html, body").animate({
                        scrollTop: angular.element(".error:visible").offset().top
                    }, 300);
                    return;
                }
                //this.continueCheckoutInProgress = true;
                this.cartUri = cartUri;
                if (this.cartId) {
                    continueUri += "?cartId=" + this.cartId;
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
            };
            EmployeeCheckoutAddressController.prototype.GetCustomerVertexCheckedStatus = function () {
                var result = "";
                if (this.selectedShipTo && this.selectedShipTo.properties["vertexChecked"])
                    result = this.selectedShipTo.properties["vertexChecked"];
                return result;
            };
            EmployeeCheckoutAddressController.prototype.IsAddressModified = function () {
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
            };
            EmployeeCheckoutAddressController.prototype.IsRemoteAddressSame = function (remoteSuggestedAddress) {
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
            };
            EmployeeCheckoutAddressController.prototype.IsAddressIsNew = function () {
                return this.selectedShipTo.isNew;
            };
            EmployeeCheckoutAddressController.prototype.VerifyAddressByVertex = function (continueUri) {
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
            };
            EmployeeCheckoutAddressController.prototype.CallToVertex = function (continueUri) {
                var _this = this;
                var addressRequestModel = {};
                addressRequestModel.streetAddress1 = this.selectedShipTo.address1;
                addressRequestModel.streetAddress2 = "";
                addressRequestModel.city = this.selectedShipTo.city;
                addressRequestModel.county = "";
                addressRequestModel.countryId = this.selectedShipTo.country.id;
                if (this.selectedShipTo.state && this.selectedShipTo.state.id)
                    addressRequestModel.stateId = this.selectedShipTo.state.id;
                addressRequestModel.postalCode = this.selectedShipTo.postalCode;
                this.addressValidationService.validateAddress(addressRequestModel).then(function (addressValidationResponseModel) {
                    _this.AddressValidationCompleted(addressValidationResponseModel);
                }, function (error) { _this.AddressValidationFailed(error); });
            };
            EmployeeCheckoutAddressController.prototype.AddressValidationCompleted = function (addressValidationResponseModel) {
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
            };
            EmployeeCheckoutAddressController.prototype.AddressValidationFailed = function (error) {
                this.coreService.displayModal(angular.element("#divConfirmationPopup"));
            };
            EmployeeCheckoutAddressController.prototype.ContinueWithAddress = function () {
                this.coreService.closeModal("#divConfirmationPopup");
                this.setCustomerOrderProperty(false, "NoResponseFromVertex");
            };
            EmployeeCheckoutAddressController.prototype.CancelAddress = function () {
                this.coreService.closeModal("#divConfirmationPopup");
                this.HideSpinner();
                return;
            };
            EmployeeCheckoutAddressController.prototype.ShowSpinner = function () {
                this.spinnerService.show();
            };
            EmployeeCheckoutAddressController.prototype.HideSpinner = function () {
                this.spinnerService.hide();
            };
            EmployeeCheckoutAddressController.prototype.selectedAddress = function (selectedAddressModel) {
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
            };
            EmployeeCheckoutAddressController.prototype.setCustomerOrderProperty = function (isAddressVerified, vertexCheckedStatus) {
                var _this = this;
                var addressVerified = isAddressVerified ? "true" : "false";
                var requestModel = {};
                requestModel.objectName = "CustomerOrder";
                requestModel.propertyName = "isAddressVerified";
                requestModel.propertyValue = addressVerified;
                this.custompropertyservice.addUpdateCustomerOrderCustomProperty(requestModel).then(function (customPropertyResponseModel) {
                    _this.setCustomerCustomProperty(vertexCheckedStatus);
                }, function (error) { _this.CustomPropertyFailed(error); });
            };
            EmployeeCheckoutAddressController.prototype.setCustomerCustomProperty = function (vertexCheckedStatus) {
                var _this = this;
                var requestModel = {};
                requestModel.objectName = "Customer";
                requestModel.propertyName = "vertexChecked";
                requestModel.propertyValue = vertexCheckedStatus;
                this.custompropertyservice.addUpdateCustomerOrderCustomProperty(requestModel).then(function (customPropertyResponseModel) {
                    _this.selectedShipTo.properties["vertexChecked"] = vertexCheckedStatus;
                    _this.UpdateBillToAddress();
                }, function (error) { _this.CustomPropertyFailed(error); });
            };
            EmployeeCheckoutAddressController.prototype.UpdateBillToAddress = function () {
                var _this = this;
                this.HideSpinner();
                this.customerService.updateBillTo(this.cart.billTo).then(function (billTo) { _this.updateBillToCompleted(billTo, _this.continueUri); }, function (error) { _this.updateBillToFailed(error); });
            };
            EmployeeCheckoutAddressController.prototype.CustomPropertyFailed = function (error) {
                this.HideSpinner();
                return;
            };
            EmployeeCheckoutAddressController.prototype.verifiedBillTo = function (suggestedBillTo) {
                if (suggestedBillTo) {
                    if (suggestedBillTo.streetAddress1) {
                        this.cart.billTo.address1 = suggestedBillTo.streetAddress1;
                    }
                    if (suggestedBillTo.city) {
                        this.cart.billTo.city = suggestedBillTo.city;
                    }
                    if (suggestedBillTo.state) {
                        this.cart.billTo.state = this.cart.billTo.country.states.filter(function (x) { return x.id == suggestedBillTo.state.id; })[0];
                    }
                    if (suggestedBillTo.postalCode) {
                        this.cart.billTo.postalCode = suggestedBillTo.postalCode;
                    }
                }
            };
            EmployeeCheckoutAddressController.prototype.verifiedShipTo = function (suggestedShipTo) {
                if (suggestedShipTo) {
                    if (suggestedShipTo.streetAddress1) {
                        this.selectedShipTo.address1 = suggestedShipTo.streetAddress1;
                    }
                    if (suggestedShipTo.city) {
                        this.selectedShipTo.city = suggestedShipTo.city;
                    }
                    if (suggestedShipTo.state) {
                        this.selectedShipTo.state = this.selectedShipTo.country.states.filter(function (x) { return x.id == suggestedShipTo.state.id; })[0];
                    }
                    if (suggestedShipTo.postalCode) {
                        this.selectedShipTo.postalCode = suggestedShipTo.postalCode;
                    }
                }
            };
            EmployeeCheckoutAddressController.$inject = [
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
            return EmployeeCheckoutAddressController;
        }(cart_1.CheckoutAddressController));
        cart_1.EmployeeCheckoutAddressController = EmployeeCheckoutAddressController;
        angular
            .module("insite")
            .controller("CheckoutAddressController", EmployeeCheckoutAddressController);
    })(cart = insite.cart || (insite.cart = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.checkout-address.controller.js.map