var insite;
(function (insite) {
    var layout;
    (function (layout) {
        "use strict";
        var EmployeeHeaderController = /** @class */ (function () {
            function EmployeeHeaderController($scope, $timeout, cartService, sessionService, $window, settingsService, coreService, ipCookie, $localStorage, deliveryMethodPopupService) {
                this.$scope = $scope;
                this.$timeout = $timeout;
                this.cartService = cartService;
                this.sessionService = sessionService;
                this.$window = $window;
                this.settingsService = settingsService;
                this.coreService = coreService;
                this.ipCookie = ipCookie;
                this.$localStorage = $localStorage;
                this.deliveryMethodPopupService = deliveryMethodPopupService;
                this.isVisibleSearchInput = false;
                this.abandonedCartNoOfTimesPopupPrompt = "0";
                this.popupPromptCount = 0;
                this.$onInit();
            }
            EmployeeHeaderController.prototype.$onInit = function () {
                var _this = this;
                this.$scope.$on("cartLoaded", function (event, cart) {
                    _this.onCartLoaded(cart);
                });
                // use a short timeout to wait for anything else on the page to call to load the cart
                this.$timeout(function () {
                    if (!_this.cartService.cartLoadCalled) {
                        _this.getCart();
                    }
                }, 20);
                this.getSession();
                this.getSettings();
                // set min-width of the Search label
                angular.element(".header-b2c .header-zone.rt .sb-search").css("min-width", angular.element(".search-label").outerWidth());
                angular.element(".header-b2c .mega-nav .top-level-item").hover(function (event) {
                    var target = angular.element(event.target);
                    if (target.hasClass("top-level-item")) {
                        target.addClass("hover");
                    }
                    else {
                        target.parents(".top-level-item").first().addClass("hover");
                    }
                }, function (event) {
                    var target = angular.element(event.target);
                    if (target.hasClass("top-level-item")) {
                        target.removeClass("hover");
                    }
                    else {
                        target.parents(".top-level-item").first().removeClass("hover");
                    }
                });
                angular.element(".header-b2c .mega-nav .sub-item").hover(function (event) {
                    var target = angular.element(event.target);
                    if (target.hasClass("sub-item")) {
                        target.addClass("hover");
                    }
                    else {
                        target.parents(".sub-item").first().addClass("hover");
                    }
                }, function (event) {
                    var target = angular.element(event.target);
                    if (target.hasClass("sub-item") && target.hasClass("hover")) {
                        target.removeClass("hover");
                    }
                    else {
                        target.parents(".sub-item.hover").first().removeClass("hover");
                    }
                });
                //PRFT Custom code start
                this.GetAbandonedCartSetting();
                this.$timeout(function () {
                    _this.promptAbandonedCartPopup();
                }, 10000);
                //PRFT custom code end
            };
            EmployeeHeaderController.prototype.onCartLoaded = function (cart) {
                this.cart = cart;
            };
            EmployeeHeaderController.prototype.getCart = function () {
                var _this = this;
                this.cartService.getCart().then(function (cart) { _this.getCartCompleted(cart); }, function (error) { _this.getCartFailed(error); });
            };
            EmployeeHeaderController.prototype.getCartCompleted = function (cart) {
            };
            EmployeeHeaderController.prototype.getCartFailed = function (error) {
            };
            EmployeeHeaderController.prototype.getSession = function () {
                var _this = this;
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
            };
            EmployeeHeaderController.prototype.getSessionCompleted = function (session) {
                this.session = session;
            };
            EmployeeHeaderController.prototype.getSessionFailed = function (error) {
            };
            EmployeeHeaderController.prototype.getSettings = function () {
                var _this = this;
                this.settingsService.getSettings().then(function (settingsCollection) { _this.getSettingsCompleted(settingsCollection); }, function (error) { _this.getSettingsFailed(error); });
            };
            EmployeeHeaderController.prototype.openSearchInput = function () {
                this.isVisibleSearchInput = true;
                this.$timeout(function () {
                    angular.element(".sb-search input#isc-searchAutoComplete-b2c").focus();
                }, 500);
            };
            EmployeeHeaderController.prototype.signOut = function (returnUrl) {
                var _this = this;
                this.sessionService.signOut().then(function (signOutResult) { _this.signOutCompleted(signOutResult, returnUrl); }, function (error) { _this.signOutFailed(error); });
            };
            EmployeeHeaderController.prototype.signOutCompleted = function (signOutResult, returnUrl) {
                this.$window.location.href = returnUrl;
            };
            EmployeeHeaderController.prototype.signOutFailed = function (error) {
            };
            EmployeeHeaderController.prototype.hideB2CNav = function ($event) {
                var target = angular.element($event.target);
                if (target.hasClass("toggle-sub")) {
                    // For tablets
                    $event.preventDefault();
                    target.mouseover();
                }
                else {
                    target.mouseout();
                }
            };
            //PRFT costom code start.
            EmployeeHeaderController.prototype.GetAbandonedCartSetting = function () {
                var _this = this;
                this.settingsService.getSettings().then(function (settingsCollection) { _this.getSettingsCompleted(settingsCollection); }, function (error) { _this.getSettingsFailed(error); });
            };
            EmployeeHeaderController.prototype.getSettingsCompleted = function (settingsCollection) {
                this.abandonedCartIntervalTime = settingsCollection.abandonedCartSetting.abandonedCartIntervalTimeInSecond;
                this.abandonedCartNoOfTimesPopupPrompt = settingsCollection.abandonedCartSetting.abandonedCartNoOfTimesPopupPrompt;
                this.abandonedCartPopupPageURL = settingsCollection.abandonedCartSetting.abandonedCartPopupPageURL;
                this.disabledAbandonedCartPopup = settingsCollection.abandonedCartSetting.disabledAbandonedCartPopup;
                this.accountSettings = settingsCollection.accountSettings;
            };
            EmployeeHeaderController.prototype.getSettingsFailed = function (error) {
            };
            EmployeeHeaderController.prototype.promptAbandonedCartPopup = function () {
                var _this = this;
                if (this.disabledAbandonedCartPopup === 'True')
                    return;
                var intervalTime = 60;
                if (this.abandonedCartNoOfTimesPopupPrompt) {
                    intervalTime = +this.abandonedCartIntervalTime;
                }
                intervalTime = intervalTime * 1000;
                if (!this.isExcludePopupPage() && this.isAuthenticatedUser() && this.isValidPromptCount() && this.isValidAbandonedCart()) {
                    this.openAbandonedCartPopup();
                }
                setTimeout(function () {
                    _this.promptAbandonedCartPopup();
                }, intervalTime);
            };
            EmployeeHeaderController.prototype.isValidAbandonedCart = function () {
                var isValid = false;
                var isAbandonedCartExistCookie = this.ipCookie("IsAbandonedCartExistCookie");
                if (isAbandonedCartExistCookie && isAbandonedCartExistCookie == true)
                    return true;
                return isValid;
            };
            EmployeeHeaderController.prototype.isExcludePopupPage = function () {
                var isCurrentPageExcluded = false;
                if (this.abandonedCartPopupPageURL) {
                    var excludePageNameList = this.abandonedCartPopupPageURL.split(',');
                    var currentPage = this.getCurrentPageName();
                    if (excludePageNameList.length > 0) {
                        for (var _i = 0, excludePageNameList_1 = excludePageNameList; _i < excludePageNameList_1.length; _i++) {
                            var page = excludePageNameList_1[_i];
                            if (page === currentPage) {
                                return true;
                            }
                        }
                    }
                }
                return isCurrentPageExcluded;
            };
            EmployeeHeaderController.prototype.isAuthenticatedUser = function () {
                return this.session.isAuthenticated;
            };
            EmployeeHeaderController.prototype.getCurrentPageName = function () {
                return this.$window.location.pathname.split('?')[0];
            };
            EmployeeHeaderController.prototype.openAbandonedCartPopup = function () {
                var _this = this;
                this.popupPromptCount = this.popupPromptCount + 1;
                this.$localStorage.set("AbandonedCartPromptCount", this.popupPromptCount.toString());
                this.coreService.displayModal(angular.element("#AbandonedCartMessage"));
                this.$timeout(function () {
                    _this.closeAbandonedCartPopup();
                }, 10000);
            };
            EmployeeHeaderController.prototype.closeAbandonedCartPopup = function () {
                this.coreService.closeModal("#AbandonedCartMessage");
            };
            EmployeeHeaderController.prototype.isValidPromptCount = function () {
                var isValidCount = true;
                var currentCountSettingValue = +this.abandonedCartNoOfTimesPopupPrompt;
                var abandonedCartPromptCount = +this.$localStorage.get("AbandonedCartPromptCount");
                if (isNaN(abandonedCartPromptCount)) {
                    abandonedCartPromptCount = 0;
                }
                if (abandonedCartPromptCount >= currentCountSettingValue) {
                    return false;
                }
                return isValidCount;
            };
            //PRFT custom code end.
            EmployeeHeaderController.prototype.openDeliveryMethodPopup = function () {
                this.deliveryMethodPopupService.display({
                    session: this.session
                });
            };
            EmployeeHeaderController.$inject = [
                "$scope",
                "$timeout",
                "cartService",
                "sessionService",
                "$window",
                "settingsService",
                "coreService",
                "ipCookie",
                "$localStorage",
                "deliveryMethodPopupService"
            ];
            return EmployeeHeaderController;
        }());
        layout.EmployeeHeaderController = EmployeeHeaderController;
        angular
            .module("insite")
            .controller("EmployeeHeaderController", EmployeeHeaderController);
    })(layout = insite.layout || (insite.layout = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.header.controller.js.map