var insite;
(function (insite) {
    var account;
    (function (account) {
        "use strict";
        var RegistrationService = /** @class */ (function () {
            function RegistrationService($http, $window, httpWrapperService) {
                this.$http = $http;
                this.$window = $window;
                this.httpWrapperService = httpWrapperService;
                this.serviceUri = "/api/v2/registration";
            }
            RegistrationService.prototype.createAccount = function (registrationModel) {
                return this.httpWrapperService.executeHttpRequest(this, this.$http({ method: "GET", url: this.serviceUri, params: registrationModel }), this.createAccountCompleted, this.createAccountFailed);
            };
            RegistrationService.prototype.createAccountCompleted = function (response) {
            };
            RegistrationService.prototype.createAccountFailed = function (error) {
            };
            RegistrationService.$inject = ["$http", "$window", "httpWrapperService"];
            return RegistrationService;
        }());
        account.RegistrationService = RegistrationService;
        angular
            .module("insite")
            .service("registrationService", RegistrationService);
    })(account = insite.account || (insite.account = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.account.service.js.map