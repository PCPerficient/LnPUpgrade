module insite.account {
    "use strict";

    export class EmployeeSignInController extends SignInController {

        protected signInCompleted(session: SessionModel): void {

            this.sessionService.setContextFromSession(session);
            if (session.isRestrictedProductExistInCart) {
                this.$localStorage.set("hasRestrictedProducts", true.toString());
            }

            if (this.invitedToList) {
                const inviteParam = "invite=";
                const lowerCaseReturnUrl = this.returnUrl.toLowerCase();
                const invite = lowerCaseReturnUrl.substr(lowerCaseReturnUrl.indexOf(inviteParam) + inviteParam.length);
                this.wishListService.activateInvite(invite).then(
                    (wishList: WishListModel) => { this.selectCustomer(session); },
                    (error: any) => { this.selectCustomer(session); });
            } else {
                this.selectCustomer(session);
            }
        }

        selectCustomer(session: SessionModel): void {         
            this.returnUrl = (session.dashboardIsHomepage) ? '/MyAccount' : this.homePageUrl; 
            if (session.redirectToChangeCustomerPageOnSignIn) {       
                this.$window.location.href = this.returnUrl;
            } else {
                this.cartService.expand = "cartlines";
                this.cartService.getCart(this.cart.id).then(
                    (cart: CartModel) => { this.getCartCompleted(session, cart); },
                    (error: any) => { this.getCartFailed(error); });
            }
        }
    }

    angular
        .module("insite")
        .controller("SignInController", EmployeeSignInController);

}