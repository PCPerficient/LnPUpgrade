var insite;
(function (insite) {
    var layout;
    (function (layout) {
        "use strict";
        var EmployeeTopNavController = /** @class */ (function () {
            function EmployeeTopNavController($scope, $window, $attrs, sessionService, websiteService, coreService, settingsService, deliveryMethodPopupService) {
                this.$scope = $scope;
                this.$window = $window;
                this.$attrs = $attrs;
                this.sessionService = sessionService;
                this.websiteService = websiteService;
                this.coreService = coreService;
                this.settingsService = settingsService;
                this.deliveryMethodPopupService = deliveryMethodPopupService;
                this.$onInit();
            }
            EmployeeTopNavController.prototype.$onInit = function () {
                var _this = this;
                this.setNavigation();
                this.dashboardUrl = this.$attrs.dashboardUrl;
                // TODO ISC-4406
                // TODO ISC-2937 SPA kill all of the things that depend on broadcast for session and convert them to this, assuming we can properly cache this call
                // otherwise determine some method for a child to say "I expect my parent to have a session, and I want to use it" broadcast will not work for that
                this.getSession();
                this.getSettings();
                this.$scope.$on("sessionUpdated", function (event, session) {
                    _this.onSessionUpdated(session);
                });
                this.$scope.$on("updateHeaderSession", function () {
                    _this.getSession();
                });
            };
            EmployeeTopNavController.prototype.onSessionUpdated = function (session) {
                this.session = session;
            };
            EmployeeTopNavController.prototype.setNavigation = function () {
                if (!$('#MyAccountMainMenu').is(':empty')) {
                    this.navidationMenu = $('#MyAccountMainMenu').html();
                }
            };
            EmployeeTopNavController.prototype.getSession = function () {
                var _this = this;
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
            };
            EmployeeTopNavController.prototype.getSessionCompleted = function (session) {
                this.session = session;
                this.getWebsite("languages,currencies");
            };
            EmployeeTopNavController.prototype.getSessionFailed = function (error) {
            };
            EmployeeTopNavController.prototype.getSettings = function () {
                var _this = this;
                this.settingsService.getSettings().then(function (settingsCollection) { _this.getSettingsCompleted(settingsCollection); }, function (error) { _this.getSettingsFailed(error); });
            };
            EmployeeTopNavController.prototype.getSettingsCompleted = function (settingsCollection) {
                this.accountSettings = settingsCollection.accountSettings;
            };
            EmployeeTopNavController.prototype.getSettingsFailed = function (error) {
            };
            EmployeeTopNavController.prototype.getWebsite = function (expand) {
                var _this = this;
                this.websiteService.getWebsite(expand).then(function (website) { _this.getWebsiteCompleted(website); }, function (error) { _this.getWebsitedFailed(error); });
            };
            EmployeeTopNavController.prototype.getWebsiteCompleted = function (website) {
                var _this = this;
                this.languages = website.languages.languages.filter(function (l) { return l.isLive; });
                this.currencies = website.currencies.currencies;
                this.checkCurrentPageForMessages();
                angular.forEach(this.languages, function (language) {
                    if (language.id === _this.session.language.id) {
                        _this.session.language = language;
                    }
                });
                angular.forEach(this.currencies, function (currency) {
                    if (currency.id === _this.session.currency.id) {
                        _this.session.currency = currency;
                    }
                });
            };
            EmployeeTopNavController.prototype.getWebsitedFailed = function (error) {
            };
            EmployeeTopNavController.prototype.setLanguage = function (languageId) {
                var _this = this;
                languageId = languageId ? languageId : this.session.language.id;
                this.sessionService.setLanguage(languageId).then(function (session) { _this.setLanguageCompleted(session); }, function (error) { _this.setLanguageFailed(error); });
            };
            EmployeeTopNavController.prototype.setLanguageCompleted = function (session) {
                if (this.$window.location.href.indexOf("AutoSwitchContext") === -1) {
                    if (this.$window.location.href.indexOf("?") === -1) {
                        this.$window.location.href = this.$window.location.href + "?AutoSwitchContext=false";
                    }
                    else {
                        this.$window.location.href = this.$window.location.href + "&AutoSwitchContext=false";
                    }
                }
                else {
                    this.$window.location.reload();
                }
            };
            EmployeeTopNavController.prototype.setLanguageFailed = function (error) {
            };
            EmployeeTopNavController.prototype.setCurrency = function (currencyId) {
                var _this = this;
                currencyId = currencyId ? currencyId : this.session.currency.id;
                this.sessionService.setCurrency(currencyId).then(function (session) { _this.setCurrencyCompleted(session); }, function (error) { _this.setCurrencyFailed(error); });
            };
            EmployeeTopNavController.prototype.setCurrencyCompleted = function (session) {
                this.$window.location.reload();
            };
            EmployeeTopNavController.prototype.setCurrencyFailed = function (error) {
            };
            EmployeeTopNavController.prototype.signOut = function (returnUrl) {
                var _this = this;
                this.sessionService.signOut().then(function (signOutResult) { _this.signOutCompleted(signOutResult, returnUrl); }, function (error) { _this.signOutFailed(error); });
            };
            EmployeeTopNavController.prototype.signOutCompleted = function (signOutResult, returnUrl) {
                this.$window.location.href = returnUrl;
            };
            EmployeeTopNavController.prototype.signOutFailed = function (error) {
            };
            EmployeeTopNavController.prototype.checkCurrentPageForMessages = function () {
                var currentUrl = this.coreService.getCurrentPath();
                var index = currentUrl.indexOf(this.dashboardUrl.toLowerCase());
                var show = index === -1 || (index + this.dashboardUrl.length !== currentUrl.length);
                if (!show && this.session.hasRfqUpdates) {
                    this.closeQuoteInformation();
                }
            };
            EmployeeTopNavController.prototype.closeQuoteInformation = function () {
                this.session.hasRfqUpdates = false;
                var session = {};
                session.hasRfqUpdates = false;
                this.updateSession(session);
            };
            EmployeeTopNavController.prototype.updateSession = function (session) {
                var _this = this;
                this.sessionService.updateSession(session).then(function (sessionResult) { _this.updateSessionCompleted(sessionResult); }, function (error) { _this.updateSessionFailed(error); });
            };
            EmployeeTopNavController.prototype.updateSessionCompleted = function (session) {
            };
            EmployeeTopNavController.prototype.updateSessionFailed = function (error) {
            };
            EmployeeTopNavController.prototype.openDeliveryMethodPopup = function () {
                this.deliveryMethodPopupService.display({
                    session: this.session
                });
            };
            EmployeeTopNavController.$inject = ["$scope", "$window", "$attrs", "sessionService", "websiteService", "coreService", "settingsService", "deliveryMethodPopupService"];
            return EmployeeTopNavController;
        }());
        layout.EmployeeTopNavController = EmployeeTopNavController;
        angular
            .module("insite")
            .controller("EmployeeTopNavController", EmployeeTopNavController);
    })(layout = insite.layout || (insite.layout = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.top-nav.controller.js.map