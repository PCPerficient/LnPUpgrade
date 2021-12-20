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
        var EmployeeSignInController = /** @class */ (function (_super) {
            __extends(EmployeeSignInController, _super);
            function EmployeeSignInController() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            EmployeeSignInController.prototype.signInCompleted = function (session) {
                var _this = this;
                this.sessionService.setContextFromSession(session);
                if (session.isRestrictedProductExistInCart) {
                    this.$localStorage.set("hasRestrictedProducts", true.toString());
                }
                if (this.invitedToList) {
                    var inviteParam = "invite=";
                    var lowerCaseReturnUrl = this.returnUrl.toLowerCase();
                    var invite = lowerCaseReturnUrl.substr(lowerCaseReturnUrl.indexOf(inviteParam) + inviteParam.length);
                    this.wishListService.activateInvite(invite).then(function (wishList) { _this.selectCustomer(session); }, function (error) { _this.selectCustomer(session); });
                }
                else {
                    this.selectCustomer(session);
                }
            };
            EmployeeSignInController.prototype.selectCustomer = function (session) {
                var _this = this;
                this.returnUrl = (session.dashboardIsHomepage) ? '/MyAccount' : this.homePageUrl;
                if (session.redirectToChangeCustomerPageOnSignIn) {
                    this.$window.location.href = this.returnUrl;
                }
                else {
                    this.cartService.expand = "cartlines";
                    this.cartService.getCart(this.cart.id).then(function (cart) { _this.getCartCompleted(session, cart); }, function (error) { _this.getCartFailed(error); });
                }
            };
            return EmployeeSignInController;
        }(account.SignInController));
        account.EmployeeSignInController = EmployeeSignInController;
        angular
            .module("insite")
            .controller("SignInController", EmployeeSignInController);
    })(account = insite.account || (insite.account = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.sign-in.controller.js.map