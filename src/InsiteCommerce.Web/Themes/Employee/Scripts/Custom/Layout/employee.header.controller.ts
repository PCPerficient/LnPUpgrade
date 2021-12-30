module insite.layout {
    "use strict";

    export class EmployeeHeaderController  {
              
        cart: CartModel;
        session: any;
        isVisibleSearchInput = false;
        abandonedCartIntervalTime: string;
        abandonedCartNoOfTimesPopupPrompt: string = "0";
        popupPromptCount: number = 0;
        abandonedCartPopupPageURL: string;
        disabledAbandonedCartPopup: string;
        accountSettings: AccountSettingsModel;

        static $inject = [
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

        constructor(
            protected $scope: ng.IScope,
            protected $timeout: ng.ITimeoutService,
            protected cartService: cart.ICartService,
            protected sessionService: account.ISessionService,
            protected $window: ng.IWindowService,
            protected settingsService: core.ISettingsService,
            protected coreService: core.ICoreService,
            protected ipCookie: any,
            protected $localStorage: common.IWindowStorage,
            protected deliveryMethodPopupService: account.IDeliveryMethodPopupService) {
           
        }

        $onInit(): void {
            this.$scope.$on("cartLoaded", (event, cart) => {
                this.onCartLoaded(cart);
            });

            // use a short timeout to wait for anything else on the page to call to load the cart
            this.$timeout(() => {
                if (!this.cartService.cartLoadCalled) {
                    this.getCart();
                }
            }, 20);

            this.getSession();
            this.getSettings();
            // set min-width of the Search label
            angular.element(".header-b2c .header-zone.rt .sb-search").css("min-width", angular.element(".search-label").outerWidth());
            angular.element(".header-b2c .mega-nav .top-level-item").hover((event) => {
                const target = angular.element(event.target);
                if (target.hasClass("top-level-item")) {
                    target.addClass("hover");
                } else {
                    target.parents(".top-level-item").first().addClass("hover");
                }
            }, (event) => {
                const target = angular.element(event.target);
                if (target.hasClass("top-level-item")) {
                    target.removeClass("hover");
                } else {
                    target.parents(".top-level-item").first().removeClass("hover");
                }
            });
            angular.element(".header-b2c .mega-nav .sub-item").hover((event) => {
                const target = angular.element(event.target);
                if (target.hasClass("sub-item")) {
                    target.addClass("hover");
                } else {
                    target.parents(".sub-item").first().addClass("hover");
                }
            }, (event) => {
                const target = angular.element(event.target);
                if (target.hasClass("sub-item") && target.hasClass("hover")) {
                    target.removeClass("hover");
                } else {
                    target.parents(".sub-item.hover").first().removeClass("hover");
                }
            });
            //PRFT Custom code start
            this.GetAbandonedCartSetting();
            this.$timeout(() => {
                this.promptAbandonedCartPopup();
            }, 10000);
            //PRFT custom code end
        }

        protected onCartLoaded(cart: CartModel): void {
            this.cart = cart;
        }

        protected getCart(): void {
            this.cartService.getCart().then(
                (cart: CartModel) => { this.getCartCompleted(cart); },
                (error: any) => { this.getCartFailed(error); });
        }

        protected getCartCompleted(cart: CartModel): void {
        }

        protected getCartFailed(error: any): void {
        }

        protected getSession(): void {
            this.sessionService.getSession().then(
                (session: SessionModel) => { this.getSessionCompleted(session); },
                (error: any) => { this.getSessionFailed(error); });
        }

        protected getSessionCompleted(session: SessionModel): void {
            this.session = session;
        }

        protected getSessionFailed(error: any): void {
        }
        protected getSettings(): void {
            this.settingsService.getSettings().then(
                (settingsCollection: core.SettingsCollection) => { this.getSettingsCompleted(settingsCollection); },
                (error: any) => { this.getSettingsFailed(error); });
        }

        
        protected openSearchInput(): void {
            this.isVisibleSearchInput = true;
            this.$timeout(() => {
                angular.element(".sb-search input#isc-searchAutoComplete-b2c").focus();
            }, 500);
        }

        signOut(returnUrl: string): void {

            this.sessionService.signOut().then(
                (signOutResult: string) => { this.signOutCompleted(signOutResult, returnUrl); },
                (error: any) => { this.signOutFailed(error); });
        }

        protected signOutCompleted(signOutResult: string, returnUrl: string): void {
            this.$window.location.href = returnUrl;
        }

        protected signOutFailed(error: any): void {
        }

        hideB2CNav($event: any): void {
            const target = angular.element($event.target);
            if (target.hasClass("toggle-sub")) {

                // For tablets
                $event.preventDefault();
                target.mouseover();
            } else {
                target.mouseout();
            }
        }
       //PRFT costom code start.
        protected GetAbandonedCartSetting(): void {
            this.settingsService.getSettings().then(
                (settingsCollection: core.SettingsCollection) => { this.getSettingsCompleted(settingsCollection); },
                (error: any) => { this.getSettingsFailed(error); });
        }

        protected getSettingsCompleted(settingsCollection: any): void {

            this.abandonedCartIntervalTime = settingsCollection.abandonedCartSetting.abandonedCartIntervalTimeInSecond;
            this.abandonedCartNoOfTimesPopupPrompt = settingsCollection.abandonedCartSetting.abandonedCartNoOfTimesPopupPrompt;
            this.abandonedCartPopupPageURL = settingsCollection.abandonedCartSetting.abandonedCartPopupPageURL;
            this.disabledAbandonedCartPopup = settingsCollection.abandonedCartSetting.disabledAbandonedCartPopup;
            this.accountSettings = settingsCollection.accountSettings;
        }

        protected getSettingsFailed(error: any): void {

        }

        protected promptAbandonedCartPopup(): void {
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

            setTimeout(() => {
                this.promptAbandonedCartPopup();
            }, intervalTime);
        }
        protected isValidAbandonedCart(): boolean {
            var isValid = false;
            var isAbandonedCartExistCookie = this.ipCookie("IsAbandonedCartExistCookie");

            if (isAbandonedCartExistCookie && isAbandonedCartExistCookie == true)
                return true;

            return isValid;
        }
        protected isExcludePopupPage(): boolean {
            var isCurrentPageExcluded = false;
            if (this.abandonedCartPopupPageURL) {
                var excludePageNameList = this.abandonedCartPopupPageURL.split(',');
                var currentPage = this.getCurrentPageName();

                if (excludePageNameList.length > 0) {
                    for (let page of excludePageNameList) {
                        if (page === currentPage) {
                            return true;
                        }
                    }
                }
            }
            return isCurrentPageExcluded;
        }
        protected isAuthenticatedUser(): boolean {
            return this.session.isAuthenticated
        }

        protected getCurrentPageName(): string {
            return this.$window.location.pathname.split('?')[0];
        }
        protected openAbandonedCartPopup(): void {
            this.popupPromptCount = this.popupPromptCount + 1;
            this.$localStorage.set("AbandonedCartPromptCount", this.popupPromptCount.toString());
            this.coreService.displayModal(angular.element("#AbandonedCartMessage"));

            this.$timeout(() => {
                this.closeAbandonedCartPopup();
            }, 10000);
        }
        protected closeAbandonedCartPopup(): void {
            this.coreService.closeModal("#AbandonedCartMessage");
        }
        protected isValidPromptCount(): boolean {
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
        }
        //PRFT custom code end.

        protected openDeliveryMethodPopup() {
            this.deliveryMethodPopupService.display({
                session: this.session
            });
        }
        
    }

    angular
        .module("insite")
        .controller("EmployeeHeaderController", EmployeeHeaderController);
}