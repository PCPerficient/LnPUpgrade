var insite;
(function (insite) {
    var account;
    (function (account_1) {
        "use strict";
        var CreateEmployeeAccountController = /** @class */ (function () {
            function CreateEmployeeAccountController(accountService, sessionService, coreService, settingsService, queryString, accessToken, spinnerService, $q, registrationService) {
                this.accountService = accountService;
                this.sessionService = sessionService;
                this.coreService = coreService;
                this.settingsService = settingsService;
                this.queryString = queryString;
                this.accessToken = accessToken;
                this.spinnerService = spinnerService;
                this.$q = $q;
                this.registrationService = registrationService;
                this.clockOrUniqueError = false;
                this.isUserRegistered = false;
                this.init();
            }
            CreateEmployeeAccountController.prototype.init = function () {
                var _this = this;
                this.returnUrl = this.queryString.get("returnUrl");
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
                this.settingsService.getSettings().then(function (settingsCollection) { _this.getSettingsCompleted(settingsCollection); }, function (error) { _this.getSettingsFailed(error); });
            };
            CreateEmployeeAccountController.prototype.getSessionCompleted = function (session) {
                this.session = session;
            };
            CreateEmployeeAccountController.prototype.getSessionFailed = function (error) {
            };
            CreateEmployeeAccountController.prototype.getSettingsCompleted = function (settingsCollection) {
                this.settings = settingsCollection.accountSettings;
            };
            CreateEmployeeAccountController.prototype.getSettingsFailed = function (error) {
            };
            CreateEmployeeAccountController.prototype.createAccount = function () {
                var _this = this;
                this.createError = "";
                this.clockOrUniqueError = false;
                this.isUserRegistered = false;
                var valid = $("#createAccountForm").validate().form();
                if (!valid) {
                    return;
                }
                if (this.validateUniqueOrClock()) {
                    this.spinnerService.show("mainLayout", true);
                    var account_2 = {
                        firstName: this.firstName,
                        lastName: this.lastName,
                        email: this.email,
                        uniqueOrClock: this.clockOrUnique
                    };
                    this.registrationService.createAccount(account_2).then(function (registrationResultModel) {
                        if (registrationResultModel.isRegistered) {
                            _this.isUserRegistered = true;
                            _this.clearField();
                            var redirectUrl = _this.getEmployeeRedirectUrlPath(registrationResultModel);
                            if (redirectUrl != "") {
                                _this.coreService.redirectToPath(redirectUrl);
                            }
                        }
                        else {
                            var redirectUrl = _this.getEmployeeRedirectUrlPath(registrationResultModel);
                            if (redirectUrl != "") {
                                _this.coreService.redirectToPath(redirectUrl);
                            }
                            else {
                                _this.createError = registrationResultModel.errorMessage;
                            }
                        }
                        _this.spinnerService.hide("mainLayout");
                    }, function (error) { _this.createError = error.message; _this.spinnerService.hide("mainLayout"); });
                }
                else
                    this.spinnerService.hide("mainLayout");
            };
            CreateEmployeeAccountController.prototype.getEmployeeRedirectUrlPath = function (registrationResultModel) {
                if (registrationResultModel.properties['registrationRedirectUrl'] != null && registrationResultModel.properties['registrationRedirectUrl'] != '') {
                    var redirectUrl = registrationResultModel.properties['registrationRedirectUrl'].toString();
                    return redirectUrl;
                }
                return "";
            };
            CreateEmployeeAccountController.prototype.clearField = function () {
                this.firstName = "";
                this.lastName = "";
                this.email = "";
                this.clockOrUnique = "";
            };
            CreateEmployeeAccountController.prototype.validateUniqueOrClock = function () {
                var result = false;
                var uniqueOrClockId = this.clockOrUnique;
                if (uniqueOrClockId.length.toString() == "4")
                    result = true;
                if (uniqueOrClockId.length.toString() == "7")
                    result = this.isNumber(uniqueOrClockId);
                if (!result)
                    this.clockOrUniqueError = true;
                return result;
            };
            CreateEmployeeAccountController.prototype.isNumber = function (n) {
                return !isNaN(n - n);
            };
            CreateEmployeeAccountController.$inject = [
                "accountService",
                "sessionService",
                "coreService",
                "settingsService",
                "queryString",
                "accessToken",
                "spinnerService",
                "$q",
                "registrationService"
            ];
            return CreateEmployeeAccountController;
        }());
        account_1.CreateEmployeeAccountController = CreateEmployeeAccountController;
        angular
            .module("insite")
            .controller("CreateEmployeeAccountController", CreateEmployeeAccountController);
    })(account = insite.account || (insite.account = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.create-account.controller.js.map