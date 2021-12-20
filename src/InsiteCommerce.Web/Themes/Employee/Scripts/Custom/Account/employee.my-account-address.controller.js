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
    var account;
    (function (account) {
        "use strict";
        var EmployeeMyAccountAddressController = /** @class */ (function (_super) {
            __extends(EmployeeMyAccountAddressController, _super);
            function EmployeeMyAccountAddressController($location, $localStorage, customerService, websiteService, sessionService, queryString, spinnerService, addressValidationService, coreService, custompropertyservice, $rootScope) {
                var _this = _super.call(this, $location, $localStorage, customerService, websiteService, sessionService, queryString, $rootScope) || this;
                _this.$location = $location;
                _this.$localStorage = $localStorage;
                _this.customerService = customerService;
                _this.websiteService = websiteService;
                _this.sessionService = sessionService;
                _this.queryString = queryString;
                _this.spinnerService = spinnerService;
                _this.addressValidationService = addressValidationService;
                _this.coreService = coreService;
                _this.custompropertyservice = custompropertyservice;
                _this.$rootScope = $rootScope;
                _this.defaultShipToAddress = {};
                return _this;
            }
            EmployeeMyAccountAddressController.prototype.checkSelectedShipTo = function () {
                if (this.billToAndShipToAreSameCustomer()) {
                    this.isReadOnly = true;
                }
                else {
                    this.isReadOnly = false;
                }
                if (this.onlyOneCountryToSelect()) {
                    this.selectFirstCountryForAddress(this.shipTo);
                    this.setStateRequiredRule("st", this.shipTo);
                }
                this.updateAddressFormValidation();
                this.SetDefaultShipTo();
            };
            EmployeeMyAccountAddressController.prototype.getSessionCompleted = function (session) {
                var shipTo = session.shipTo.oneTimeAddress ? null : session.shipTo;
                this.getBillTo(session.shipTo);
            };
            EmployeeMyAccountAddressController.prototype.getBillToCompleted = function (billTo, selectedShipTo) {
                var _this = this;
                this.billTo = billTo;
                this.websiteService.getCountries("states").then(function (countryCollection) {
                    _this.getCountriesCompleted(countryCollection, selectedShipTo);
                    _this.SetDefaultShipTo();
                }, function (error) { _this.getCountriesFailed(error); });
            };
            EmployeeMyAccountAddressController.prototype.SetDefaultShipTo = function () {
                this.defaultShipToAddress.address1 = this.shipTo.address1;
                this.defaultShipToAddress.city = this.shipTo.city;
                this.defaultShipToAddress.country = this.shipTo.country;
                this.defaultShipToAddress.state = this.shipTo.state;
                this.defaultShipToAddress.postalCode = this.shipTo.postalCode;
            };
            EmployeeMyAccountAddressController.prototype.save = function () {
                var valid = angular.element("#addressForm").validate().form();
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
            };
            EmployeeMyAccountAddressController.prototype.VerifyAddressByVertex = function () {
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
            };
            EmployeeMyAccountAddressController.prototype.IsAddressIsNew = function () {
                return this.shipTo.isNew;
            };
            EmployeeMyAccountAddressController.prototype.GetCustomerVertexCheckedStatus = function () {
                var result = "";
                if (this.shipTo && this.shipTo.properties["vertexChecked"])
                    result = this.shipTo.properties["vertexChecked"];
                return result;
            };
            EmployeeMyAccountAddressController.prototype.IsAddressModified = function () {
                var result = false;
                if (this.shipTo.address1.toLowerCase() != this.defaultShipToAddress.address1.toLowerCase())
                    return true;
                if (this.shipTo.city.toLowerCase() != this.defaultShipToAddress.city.toLowerCase())
                    return true;
                if (this.shipTo.country.abbreviation.toLowerCase() != this.defaultShipToAddress.country.abbreviation.toLowerCase())
                    return true;
                if (this.shipTo.state.name.toLowerCase() != this.defaultShipToAddress.state.name.toLowerCase())
                    return true;
                if (this.shipTo.postalCode.toLowerCase() != this.defaultShipToAddress.postalCode.toLowerCase())
                    return true;
                return result;
            };
            EmployeeMyAccountAddressController.prototype.CallToVertex = function () {
                var _this = this;
                var addressRequestModel = {};
                addressRequestModel.streetAddress1 = this.shipTo.address1;
                addressRequestModel.streetAddress2 = "";
                addressRequestModel.city = this.shipTo.city;
                addressRequestModel.county = "";
                addressRequestModel.countryId = this.shipTo.country.id;
                if (this.shipTo.state && this.shipTo.state.id)
                    addressRequestModel.stateId = this.shipTo.state.id;
                addressRequestModel.postalCode = this.shipTo.postalCode;
                this.addressValidationService.validateAddress(addressRequestModel).then(function (addressValidationResponseModel) {
                    _this.AddressValidationCompleted(addressValidationResponseModel);
                }, function (error) { _this.AddressValidationFailed(error); });
            };
            EmployeeMyAccountAddressController.prototype.AddressValidationCompleted = function (addressValidationResponseModel) {
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
            };
            EmployeeMyAccountAddressController.prototype.IsRemoteAddressSame = function (remoteSuggestedAddress) {
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
            };
            EmployeeMyAccountAddressController.prototype.AddressValidationFailed = function (error) {
                this.coreService.displayModal(angular.element("#divConfirmationPopup"));
            };
            EmployeeMyAccountAddressController.prototype.ContinueWithAddress = function () {
                this.coreService.closeModal("#divConfirmationPopup");
                this.setCustomerCustomProperty("NoResponseFromVertex");
            };
            EmployeeMyAccountAddressController.prototype.CancelAddress = function () {
                this.coreService.closeModal("#divConfirmationPopup");
                this.HideSpinner();
                return;
            };
            EmployeeMyAccountAddressController.prototype.ShowSpinner = function () {
                this.spinnerService.show();
            };
            EmployeeMyAccountAddressController.prototype.HideSpinner = function () {
                this.spinnerService.hide();
            };
            EmployeeMyAccountAddressController.prototype.setCustomerCustomProperty = function (vertexCheckedStatus) {
                this.shipTo.properties["vertexChecked"] = vertexCheckedStatus;
                this.UpdateCustomerBillTo();
            };
            EmployeeMyAccountAddressController.prototype.CustomPropertyFailed = function (error) {
                this.HideSpinner();
                return;
            };
            EmployeeMyAccountAddressController.prototype.selectedAddress = function (selectedAddressModel) {
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
            };
            EmployeeMyAccountAddressController.prototype.verifiedBillTo = function (suggestedBillTo) {
                if (suggestedBillTo) {
                    if (suggestedBillTo.streetAddress1) {
                        this.billTo.address1 = suggestedBillTo.streetAddress1;
                    }
                    if (suggestedBillTo.city) {
                        this.billTo.city = suggestedBillTo.city;
                    }
                    if (suggestedBillTo.state) {
                        this.billTo.state = this.billTo.country.states.filter(function (x) { return x.id == suggestedBillTo.state.id; })[0];
                    }
                    if (suggestedBillTo.postalCode) {
                        this.billTo.postalCode = suggestedBillTo.postalCode;
                    }
                }
            };
            EmployeeMyAccountAddressController.prototype.verifiedShipTo = function (suggestedShipTo) {
                if (suggestedShipTo) {
                    if (suggestedShipTo.streetAddress1) {
                        this.shipTo.address1 = suggestedShipTo.streetAddress1;
                    }
                    if (suggestedShipTo.city) {
                        this.shipTo.city = suggestedShipTo.city;
                    }
                    if (suggestedShipTo.state) {
                        this.shipTo.state = this.shipTo.country.states.filter(function (x) { return x.id == suggestedShipTo.state.id; })[0];
                    }
                    if (suggestedShipTo.postalCode) {
                        this.shipTo.postalCode = suggestedShipTo.postalCode;
                    }
                }
            };
            EmployeeMyAccountAddressController.prototype.UpdateCustomerBillTo = function () {
                var _this = this;
                this.HideSpinner();
                this.customerService.updateBillTo(this.billTo).then(function (billTo) { _this.updateBillToCompleted(billTo); }, function (error) { _this.updateBillToFailed(error); });
            };
            EmployeeMyAccountAddressController.$inject = ["$location",
                "$localStorage",
                "customerService",
                "websiteService",
                "sessionService",
                "queryString",
                "spinnerService",
                "addressValidationService",
                "coreService",
                "custompropertyservice",
                "$rootScope"];
            return EmployeeMyAccountAddressController;
        }(account.MyAccountAddressController));
        account.EmployeeMyAccountAddressController = EmployeeMyAccountAddressController;
        angular
            .module("insite")
            .controller("MyAccountAddressController", EmployeeMyAccountAddressController);
    })(account = insite.account || (insite.account = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.my-account-address.controller.js.map