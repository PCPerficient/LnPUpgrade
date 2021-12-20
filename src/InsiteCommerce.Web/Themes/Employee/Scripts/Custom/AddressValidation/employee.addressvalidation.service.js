var insite;
(function (insite) {
    var addressvalidation;
    (function (addressvalidation) {
        "use strict";
        var AddressValidationService = /** @class */ (function () {
            function AddressValidationService($http, $window, httpWrapperService) {
                this.$http = $http;
                this.$window = $window;
                this.httpWrapperService = httpWrapperService;
                this.serviceUri = "/api/v2/address/validation";
            }
            AddressValidationService.prototype.validateAddress = function (addressValidationModel) {
                return this.httpWrapperService.executeHttpRequest(this, this.$http({ method: "GET", url: this.serviceUri, params: addressValidationModel }), this.validateAddressCompleted, this.validateAddressFailed);
            };
            AddressValidationService.prototype.validateAddressCompleted = function (response) {
            };
            AddressValidationService.prototype.validateAddressFailed = function (error) {
            };
            AddressValidationService.$inject = ["$http", "$window", "httpWrapperService"];
            return AddressValidationService;
        }());
        addressvalidation.AddressValidationService = AddressValidationService;
        angular
            .module("insite")
            .service("addressValidationService", AddressValidationService);
    })(addressvalidation = insite.addressvalidation || (insite.addressvalidation = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.addressvalidation.service.js.map