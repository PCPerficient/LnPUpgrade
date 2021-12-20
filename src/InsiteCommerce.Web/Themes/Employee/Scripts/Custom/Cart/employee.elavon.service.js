var insite;
(function (insite) {
    var elavon;
    (function (elavon) {
        "use strict";
        var ElavonService = /** @class */ (function () {
            function ElavonService($http, $rootScope, $q, coreService, httpWrapperService) {
                this.$http = $http;
                this.$rootScope = $rootScope;
                this.$q = $q;
                this.coreService = coreService;
                this.httpWrapperService = httpWrapperService;
                this.elavonSessionTokenUrl = "/api/v2/getelavonsessiontoken";
                this.elavonErrorLogUrl = "/api/v1/elavonerrorlog";
                this.init();
            }
            ElavonService.prototype.init = function () {
            };
            ElavonService.prototype.elavonErrorLog = function (errorLogModel) {
                var _this = this;
                return this.httpWrapperService.executeHttpRequest(this, this.$http({ method: "Put", url: this.elavonErrorLogUrl, data: errorLogModel, bypassErrorInterceptor: true }), function (response) { _this.elavonErrorLogCompleted(response); }, this.elavonErrorLogFailed);
            };
            ElavonService.prototype.elavonErrorLogCompleted = function (response) {
            };
            ElavonService.prototype.elavonErrorLogFailed = function (error) {
            };
            ElavonService.prototype.getElavonSessionToken = function () {
                var num = new Date();
                var number = num.getSeconds();
                var url = this.elavonSessionTokenUrl + "/" + number;
                return this.httpWrapperService.executeHttpRequest(this, this.$http({ method: "GET", url: url }), this.getElavonSessionTokenCompleted, this.getElavonSessionTokenFailed);
            };
            ElavonService.prototype.getElavonSessionTokenCompleted = function (response) {
            };
            ElavonService.prototype.getElavonSessionTokenFailed = function (error) {
            };
            ElavonService.$inject = ["$http", "$rootScope", "$q", "coreService", "httpWrapperService"];
            return ElavonService;
        }());
        elavon.ElavonService = ElavonService;
        angular
            .module("insite")
            .service("elavonService", ElavonService);
    })(elavon = insite.elavon || (insite.elavon = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.elavon.service.js.map