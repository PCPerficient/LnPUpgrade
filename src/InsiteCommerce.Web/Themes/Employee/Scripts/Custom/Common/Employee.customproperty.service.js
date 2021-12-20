var insite;
(function (insite) {
    var customproperty;
    (function (customproperty) {
        "use strict";
        var CustomPropertyService = /** @class */ (function () {
            function CustomPropertyService($http, httpWrapperService) {
                this.$http = $http;
                this.httpWrapperService = httpWrapperService;
                this.serviceUri = "/api/v2/CustomerOrder/CustomProperty";
            }
            CustomPropertyService.prototype.addUpdateCustomerOrderCustomProperty = function (requestModel) {
                return this.httpWrapperService.executeHttpRequest(this, this.$http.post(this.serviceUri, requestModel), this.AddUpdateCustomPropertyCompleted, this.AddUpdateCustomPropertyFailed);
            };
            CustomPropertyService.prototype.AddUpdateCustomPropertyCompleted = function (response) {
            };
            CustomPropertyService.prototype.AddUpdateCustomPropertyFailed = function (error) {
            };
            CustomPropertyService.$inject = ["$http", "httpWrapperService"];
            return CustomPropertyService;
        }());
        customproperty.CustomPropertyService = CustomPropertyService;
        angular
            .module("insite")
            .service("custompropertyservice", CustomPropertyService);
    })(customproperty = insite.customproperty || (insite.customproperty = {}));
})(insite || (insite = {}));
//# sourceMappingURL=Employee.customproperty.service.js.map