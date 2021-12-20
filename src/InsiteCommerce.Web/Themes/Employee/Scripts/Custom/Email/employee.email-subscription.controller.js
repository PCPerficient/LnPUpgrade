var insite;
(function (insite) {
    var email;
    (function (email) {
        "use strict";
        var EmployeeEmailSubscriptionController = /** @class */ (function () {
            function EmployeeEmailSubscriptionController($element, $scope, sessionService) {
                this.$element = $element;
                this.$scope = $scope;
                this.sessionService = sessionService;
                this.submitted = false;
                this.$onInit();
            }
            EmployeeEmailSubscriptionController.prototype.$onInit = function () {
                var _this = this;
                this.$form = this.$element.find("form");
                this.$form.removeData("validator");
                this.$form.removeData("unobtrusiveValidation");
                $.validator.unobtrusive.parse(this.$form);
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
            };
            EmployeeEmailSubscriptionController.prototype.getSessionCompleted = function (session) {
                this.session = session;
            };
            EmployeeEmailSubscriptionController.prototype.getSessionFailed = function (error) {
            };
            EmployeeEmailSubscriptionController.prototype.submit = function ($event) {
                var _this = this;
                $event.preventDefault();
                if (!this.$form.valid()) {
                    return false;
                }
                this.$form.ajaxPost(function () {
                    _this.submitted = true;
                    _this.$scope.$apply();
                });
                return false;
            };
            EmployeeEmailSubscriptionController.$inject = ["$element", "$scope", "sessionService"];
            return EmployeeEmailSubscriptionController;
        }());
        email.EmployeeEmailSubscriptionController = EmployeeEmailSubscriptionController;
        angular
            .module("insite")
            .controller("EmployeeEmailSubscriptionController", EmployeeEmailSubscriptionController);
    })(email = insite.email || (insite.email = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.email-subscription.controller.js.map