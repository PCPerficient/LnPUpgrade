module insite.cart {
    "use strict";
    declare var ConvergeEmbeddedPayment: any;
    declare var Elavon3DSWebSDK: any;
    declare var window: any;
    import StateModel = Insite.Websites.WebApi.V1.ApiModels.StateModel;
    export class EmployeeReviewAndPayController extends ReviewAndPayController {

        promotionCodeFormDisplay: boolean = false;
        shippingDisplay: boolean = false;
        elavonToken: string;
        elavonResponseCodes: string[];
        SentEmailEvalonPaymentFailuer: boolean;
        LogEvalonPaymentResponse: boolean;

        elavonSettings: any;
        ccTransactionSucceeded: boolean;
        ccElavonErrorMessage: string;
        ccTransactionFailedMessage: string;
        placeOrderAttempt: number;
        submitErrorMessage: string;
        elavonAcceptAVSResponseCode: string;
        elavonAcceptCVVResponseCode: string;
        efsToken: any;
        efsUrl: any;

        static $inject = [
            "elavonService",
            "$scope",
            "$window",
            "cartService",
            "promotionService",
            "sessionService",
            "coreService",
            "spinnerService",
            "$attrs",
            "settingsService",
            "queryString",
            "$localStorage",
            "websiteService",
            "deliveryMethodPopupService",
            "selectPickUpLocationPopupService"
        ];

        constructor(
            protected elavonService: elavon.ElavonService,
            protected $scope: ng.IScope,
            protected $window: ng.IWindowService,
            protected cartService: ICartService,
            protected promotionService: promotions.IPromotionService,
            protected sessionService: account.ISessionService,
            protected coreService: core.ICoreService,
            protected spinnerService: core.ISpinnerService,
            protected $attrs: IReviewAndPayControllerAttributes,
            protected settingsService: core.ISettingsService,
            protected queryString: common.IQueryStringService,
            protected $localStorage: common.IWindowStorage,
            protected websiteService: websites.IWebsiteService,
            protected deliveryMethodPopupService: account.IDeliveryMethodPopupService,
            protected selectPickUpLocationPopupService: account.ISelectPickUpLocationPopupService) {
            super($scope, $window, cartService, promotionService, sessionService, coreService, spinnerService, $attrs, settingsService, queryString, $localStorage, websiteService, deliveryMethodPopupService, selectPickUpLocationPopupService)
        }


        protected getIsAuthenticatedForSubmitCompleted(isAuthenticated: boolean, submitSuccessUri: string, signInUri: string): void {
            if (!isAuthenticated) {
                this.coreService.redirectToPathAndRefreshPage(`${signInUri}?returnUrl=${this.coreService.getCurrentPath()}`);
                return;
            }

            if (this.cart.requiresApproval) {
                this.cart.status = "AwaitingApproval";
            } else {
                this.cart.status = "Submitted";
            }

            this.cart.requestedDeliveryDate = this.formatWithTimezoneEmployee(this.cart.requestedDeliveryDate);

            this.spinnerService.show("mainLayout", true);
            if (this.cart.paymentMethod.isCreditCard) {
                if (this.$localStorage.get("placeOrderAttempt")) {
                    this.placeOrderAttempt = Number(this.$localStorage.get("placeOrderAttempt"));
                    this.placeOrderAttempt++;
                }
                else {
                    this.$localStorage.set("placeOrderAttempt", "1");
                }

                const elavonSessionTokenModel = {} as ElavonSessionTokenModel;

                this.elavonService.getElavonSessionToken().then(
                    (elavonTokenDetails: ElavonSessionTokenModel) => {
                        this.getElavonSessionTokenCompleted(elavonTokenDetails, submitSuccessUri);
                    },
                    (error: any) => { this.getElavonSessionTokenFailed(error); }
                );
            }
            else {
                this.tokenizeCardInfoIfNeeded(submitSuccessUri);
            }
        }

        private formatWithTimezoneEmployee(date: string): string {
            return date ? moment(date).format() : date;
        }

        protected getSettingsCompleted(settingsCollection: any): void {
            this.cartSettings = settingsCollection.cartSettings;
            this.SentEmailEvalonPaymentFailuer = settingsCollection.elavonSetting.elavonSettingPaymentFailuerMail;
            this.LogEvalonPaymentResponse = settingsCollection.elavonSetting.logEvalonPaymentResponse;
            this.efsUrl = settingsCollection.elavonSetting.elavonTestMode ? settingsCollection.elavonSetting.elavonDemo3DS2Gateway : settingsCollection.elavonSetting.elavonProd3DS2Gateway;
            var res = settingsCollection.shippingDisplay.shippingDisplay;
            if (res.toLowerCase() == 'true') {
                this.shippingDisplay = true;
            }
            var promo = settingsCollection.shippingDisplay.promotionCodeFormDisplay;
            if (promo.toLowerCase() == 'true') {
                this.promotionCodeFormDisplay = true;
            }
            this.customerSettings = settingsCollection.customerSettings;
            this.useTokenExGateway = settingsCollection.websiteSettings.useTokenExGateway;
            this.enableWarehousePickup = settingsCollection.accountSettings.enableWarehousePickup;

            this.sessionService.getSession().then(
                (session: SessionModel) => { this.getSessionCompleted(session); },
                (error: any) => { this.getSessionFailed(error); });
        }

        protected getElavonSessionTokenCompleted(elavonDetails: ElavonSessionTokenModel, submitSuccessUri: string): void {
            this.elavonToken = elavonDetails.elavonToken;
            this.elavonResponseCodes = elavonDetails.elavonResponseCodes;
            this.elavonAcceptAVSResponseCode = elavonDetails.elavonAcceptAVSResponseCode;
            this.elavonAcceptCVVResponseCode = elavonDetails.elavonAcceptCVVResponseCode;

            if (typeof (this.elavonToken) !== "undefined" && this.elavonToken != "") {
              this.getEFSToken(elavonDetails, submitSuccessUri);
            }
            else {
                const errorLog = {} as ElavonErrorLogModel;
                errorLog.customerNumber = this.cart.billTo.customerNumber;
                errorLog.elavonResponse = JSON.stringify("Elavon Token Generation Error");
                errorLog.elavonResponseFor = "Declined";
                if ((this.LogEvalonPaymentResponse) || (this.SentEmailEvalonPaymentFailuer)) {
                    this.elavonService.elavonErrorLog(errorLog)
                }
                this.spinnerService.hide();
                this.submitting = false;
                this.submitErrorMessage = angular.element("#elavonTokenErrorMessage").val();

                this.placeOrderAttempt = Number(this.$localStorage.get("placeOrderAttempt"));
                if (this.placeOrderAttempt == 3 || this.placeOrderAttempt > 3) {
                    this.$localStorage.remove("placeOrderAttempt");
                    this.coreService.redirectToPath("/cart");
                    return;
                }
                this.placeOrderAttempt++;
                this.$localStorage.set("placeOrderAttempt", this.placeOrderAttempt.toString());
                return;
            }
        }

        protected getElavonSessionTokenFailed(error: any): void {
            this.submitting = false;
            this.ccElavonErrorMessage = "Payment Processing Error.";
            this.coreService.displayModal(angular.element("#elavonTokenErrorMessage"));
            const errorLog = {} as ElavonErrorLogModel;
            errorLog.customerNumber = this.cart.billTo.customerNumber;
            errorLog.elavonResponse = JSON.stringify("Elavon Token Generation Error");
            errorLog.elavonResponseFor = "Declined";
            if ((this.LogEvalonPaymentResponse) || (this.SentEmailEvalonPaymentFailuer)) {
                this.elavonService.elavonErrorLog(errorLog)
            }
            this.placeOrderAttempt = Number(this.$localStorage.get("placeOrderAttempt"));
            this.placeOrderAttempt++;
            if (this.placeOrderAttempt == 3 || this.placeOrderAttempt > 3) {
                this.$localStorage.remove("placeOrderAttempt");
                this.coreService.redirectToPath("/cart");
                return;
            }
            return;
        }
               
        private payTransaction(elavonDetails: ElavonSessionTokenModel, submitSuccessUri: string,elavon3DS2Model: Elavon3DS2Model): any {
            var that = this;
            const errorLog = {} as ElavonErrorLogModel;
            errorLog.customerNumber = this.cart.billTo.customerNumber;

            var billingCountry;
            if (this.cart.properties["billingAddressCountryCode"]) {
                billingCountry = this.cart.properties["billingAddressCountryCode"];
            }
            else {
                billingCountry = this.cart.billTo.country.abbreviation;
            }

            var paymentData = {
                ssl_txn_auth_token: elavonDetails.elavonToken,
                ssl_card_number: this.cart.paymentOptions.creditCard.cardNumber,
                ssl_exp_date: this.getCCExpirationDate(),
                ssl_cvv2cvc2: this.cart.paymentOptions.creditCard.securityCode,
                ssl_amount: this.cart.orderGrandTotal.toFixed(2),
                ssl_get_token: 'y',
                ssl_add_token: 'y',
                ssl_cvv2cvc2_indicator: 1,
                ssl_avs_address: this.cart.billTo.address1.substring(0, 30),
                ssl_city: this.cart.billTo.city.substring(0, 30),
                ssl_state: this.cart.billTo.state.abbreviation,
                ssl_avs_zip: this.cart.billTo.postalCode.replace("-", "").substring(0, 9),
                ssl_country: billingCountry,
                ssl_first_name: this.cart.billTo.firstName.substring(0, 20),
                ssl_last_name: this.cart.billTo.lastName.substring(0, 30),
                ssl_verify: 'y',
                ssl_transaction_type: 'CCGETTOKEN',
                ssl_program_protocol: elavon3DS2Model.programProtocol,
                ssl_dir_server_tran_id: elavon3DS2Model.dsTransID,
                ssl_eci_ind: elavon3DS2Model.eci,
                ssl_3dsecure_value: elavon3DS2Model.authenticationValue
            };
            
            var callback = {
                onError: function (error) {
                    that.ccElavonErrorMessage = elavonDetails.elavonErrorMessage;
                    that.spinnerService.hide();
                    errorLog.elavonResponse = "";
                    errorLog.elavonResponseFor = "Error";
                    errorLog.errorMessage = error;
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer) {
                        that.elavonService.elavonErrorLog(errorLog)
                    }
                    that.submitting = false;
                    that.submitErrorMessage = angular.element("#elavonPaymentErrorMessage").val();

                    that.placeOrderAttempt = Number(that.$localStorage.get("placeOrderAttempt"));

                    if (that.placeOrderAttempt == 3 || that.placeOrderAttempt > 3) {
                        that.$localStorage.remove("placeOrderAttempt");
                        that.coreService.redirectToPath("/cart");
                        return;
                    }
                    that.placeOrderAttempt++;
                    that.$localStorage.set("placeOrderAttempt", that.placeOrderAttempt.toString());

                    return true;
                },
                onDeclined: function (response) {
                    that.ccElavonErrorMessage = response['ssl_result_message'];
                    var replaced = that.ccElavonErrorMessage.split(' ').join('_');
                    that.ccElavonErrorMessage = replaced.toLowerCase();
                    that.spinnerService.hide();
                    errorLog.elavonResponse = JSON.stringify(response);
                    errorLog.elavonResponseFor = "Declined";
                    errorLog.saveElavonResponse = false;
                    that.submitErrorMessage = that.elavonResponseCodes[that.ccElavonErrorMessage];
                    if (that.submitErrorMessage == null || typeof that.submitErrorMessage === 'undefined') {
                        that.submitErrorMessage = response['ssl_result_message'];
                        errorLog.saveElavonResponse = true;
                    }
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer || errorLog.saveElavonResponse) {
                        that.elavonService.elavonErrorLog(errorLog);
                    }
                    that.submitting = false;

                    that.placeOrderAttempt = Number(that.$localStorage.get("placeOrderAttempt"));
                    if (that.placeOrderAttempt == 3 || that.placeOrderAttempt > 3) {
                        that.$localStorage.remove("placeOrderAttempt");
                        that.coreService.redirectToPath("/cart");
                        return;
                    }
                    that.placeOrderAttempt++;
                    that.$localStorage.set("placeOrderAttempt", that.placeOrderAttempt.toString());
                    return true;
                },
                onApproval: function (response) {
                    var isValidAvsResponse = that.isValidElavonAVSResponse(response);
                    if (!isValidAvsResponse) {
                        that.submitErrorMessage = angular.element("#elavonAvsErrorMessage").val();
                        that.submitting = false;
                    }

                    if (isValidAvsResponse) {
                        var isValidCvvResponse = that.isValidElavonCVVResponse(response);
                        if (!isValidCvvResponse) {
                            that.submitErrorMessage = angular.element("#elavonCvvErrorMessage").val();
                            that.submitting = false;
                        }
                    }
                    if (isValidAvsResponse && isValidCvvResponse) {
                        var isValidResponse = that.isValidElavonResponse(response);
                        if (!isValidResponse) {
                            that.submitErrorMessage = angular.element("#elavonResponseTokenNotPresentMessage").val();
                            that.submitting = false;
                        }
                    }

                    //code for log and mail elavon error response START
                    errorLog.elavonResponse = JSON.stringify(response);
                    if (!isValidAvsResponse || !isValidResponse || !isValidCvvResponse) {
                        errorLog.elavonResponseFor = "Declined";
                    }
                    else {
                        errorLog.elavonResponseFor = "Approval";
                    }
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer || errorLog.saveElavonResponse) {
                        that.elavonService.elavonErrorLog(errorLog);
                    }
                    //code for log and mail elavon error response END

                    if (isValidAvsResponse && isValidResponse && isValidCvvResponse) {
                        that.cart.properties["ElavonRespMessage"] = errorLog.elavonResponse;
                        that.cartService.updateCart(that.cart, true).then(
                            (cart: CartModel) => { that.submitCompleted(cart, submitSuccessUri); },
                            (error: any) => { that.submitFailed(error); });
                    }
                    if (!isValidAvsResponse || !isValidResponse || !isValidCvvResponse) {
                        that.spinnerService.hide();
                    }
                    return true;
                }
            };
            ConvergeEmbeddedPayment.pay(paymentData, callback);
        }

        private getEFSToken(elavonDetails: ElavonSessionTokenModel, submitSuccessUri: string): any {
            var that = this;
            const errorLog = {} as ElavonErrorLogModel;
            errorLog.customerNumber = this.cart.billTo.customerNumber;

            var paymentData = {
                ssl_txn_auth_token: elavonDetails.elavonToken
            };
            var callback = {
                onError: function (error) {
                    that.ccElavonErrorMessage = elavonDetails.elavonErrorMessage;
                    that.spinnerService.hide();
                    errorLog.elavonResponse = "";
                    errorLog.elavonResponseFor = "Error";
                    errorLog.errorMessage = error;
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer) {
                        that.elavonService.elavonErrorLog(errorLog)
                    }
                    that.submitting = false;
                    that.submitErrorMessage = angular.element("#elavonPaymentErrorMessage").val();

                    that.placeOrderAttempt = Number(that.$localStorage.get("placeOrderAttempt"));

                    if (that.placeOrderAttempt == 3 || that.placeOrderAttempt > 3) {
                        that.$localStorage.remove("placeOrderAttempt");
                        that.coreService.redirectToPath("/cart");
                        return;
                    }
                    that.placeOrderAttempt++;
                    that.$localStorage.set("placeOrderAttempt", that.placeOrderAttempt.toString());

                    return true;
                },
                onDeclined: function (response) {
                    that.ccElavonErrorMessage = response['ssl_result_message'];
                    var replaced = that.ccElavonErrorMessage.split(' ').join('_');
                    that.ccElavonErrorMessage = replaced.toLowerCase();
                    that.spinnerService.hide();
                    errorLog.elavonResponse = JSON.stringify(response);
                    errorLog.elavonResponseFor = "Declined";
                    errorLog.saveElavonResponse = false;
                    that.submitErrorMessage = that.elavonResponseCodes[that.ccElavonErrorMessage];
                    if (that.submitErrorMessage == null || typeof that.submitErrorMessage === 'undefined') {
                        that.submitErrorMessage = response['ssl_result_message'];
                        errorLog.saveElavonResponse = true;
                    }
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer || errorLog.saveElavonResponse) {
                        that.elavonService.elavonErrorLog(errorLog);
                    }
                    that.submitting = false;

                    that.placeOrderAttempt = Number(that.$localStorage.get("placeOrderAttempt"));
                    if (that.placeOrderAttempt == 3 || that.placeOrderAttempt > 3) {
                        that.$localStorage.remove("placeOrderAttempt");
                        that.coreService.redirectToPath("/cart");
                        return;
                    }
                    that.placeOrderAttempt++;
                    that.$localStorage.set("placeOrderAttempt", that.placeOrderAttempt.toString());
                    return true;
                },
                onApproval: function (response) {
                    var isValidAvsResponse = that.isValidElavonAVSResponse(response);
                    if (!isValidAvsResponse) {
                        that.submitErrorMessage = angular.element("#elavonAvsErrorMessage").val();
                        that.submitting = false;
                    }

                    if (isValidAvsResponse) {
                        var isValidCvvResponse = that.isValidElavonCVVResponse(response);
                        if (!isValidCvvResponse) {
                            that.submitErrorMessage = angular.element("#elavonCvvErrorMessage").val();
                            that.submitting = false;
                        }
                    }
                    if (isValidAvsResponse && isValidCvvResponse) {
                        var isValidResponse = that.isValidElavonResponse(response);
                        if (!isValidResponse) {
                            that.submitErrorMessage = angular.element("#elavonResponseTokenNotPresentMessage").val();
                            that.submitting = false;
                        }
                    }

                    //code for log and mail elavon error response START
                    errorLog.elavonResponse = JSON.stringify(response);
                    if (!isValidAvsResponse || !isValidResponse || !isValidCvvResponse) {
                        errorLog.elavonResponseFor = "Declined";
                    }
                    else {
                        errorLog.elavonResponseFor = "Approval";
                    }
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer || errorLog.saveElavonResponse) {
                        that.elavonService.elavonErrorLog(errorLog);
                    }
                    //code for log and mail elavon error response END

                    if (isValidAvsResponse && isValidResponse && isValidCvvResponse) {
                        that.cart.properties["ElavonRespMessage"] = errorLog.elavonResponse;
                        that.cartService.updateCart(that.cart, true).then(
                            (cart: CartModel) => { that.submitCompleted(cart, submitSuccessUri); },
                            (error: any) => { that.submitFailed(error); });
                    }
                    if (!isValidAvsResponse || !isValidResponse || !isValidCvvResponse) {
                        that.spinnerService.hide();
                    }
                    return true;
                },
                onCancelled: function () {
                   
                },
                onThreeDSecure2: function (response) {
                    console.log("3ds2 token response:");
                    console.log(response);
                    if (response.ssl_3ds2_token) {
                        that.efsToken = response.ssl_3ds2_token;
                        console.log("efsToken " + that.efsToken);
                        if (that.efsToken != undefined) {
                           
                            that.call3DS2Gateway(that.efsToken, elavonDetails, submitSuccessUri);
                           
                        }
                      
                    } else {
                        that.efsToken = "";
                    }
                }
            };
            ConvergeEmbeddedPayment.getEFSToken(paymentData, callback);
            
        }

        private call3DS2Gateway(efsToken: any, elavonDetails: ElavonSessionTokenModel, submitSuccessUri: string): void {
            var that = this;
            var sdk = new window.Elavon3DSWebSDK({ baseUrl: this.efsUrl, token: efsToken, el: 'holder' });
            let elavon3DS2Model = {} as Elavon3DS2Model;

            const errorLog = {} as ElavonErrorLogModel;
            errorLog.customerNumber = this.cart.billTo.customerNumber;

            var request = {
                purchaseAmount: parseFloat(this.cart.orderGrandTotal.toFixed(2)),
                purchaseCurrency: "840",
                purchaseExponent: "2",
                acctNumber: this.cart.paymentOptions.creditCard.cardNumber,
                cardExpiryDate: this.getEFSExpiry(),//this.getCCExpirationDate(),//getEFSExpiry(),
                messageCategory: "01",
                transType: "01",
                threeDSRequestorAuthenticationInd: "01",
                challengeWindowSize: "03",
                displayMode: "lightbox"
            };
            console.log(request);

            sdk.web3dsFlow(request).then(function success(response) {
                console.log(response);
                elavon3DS2Model.dsTransID = response.dsTransID;
                elavon3DS2Model.eci = that.getEFSEci(response.eci);
                elavon3DS2Model.authenticationValue = response.authenticationValue;
                elavon3DS2Model.programProtocol = "2";
                that.payTransaction(elavonDetails, submitSuccessUri, elavon3DS2Model);
            }, function error(response) {
                console.log("Error " + response);
                    elavon3DS2Model.eci = "7";
                    that.ccElavonErrorMessage = JSON.stringify(response);
                    that.spinnerService.hide();
                    errorLog.elavonResponse = JSON.stringify(response);
                    errorLog.elavonResponseFor = "Error";
                    errorLog.errorMessage = JSON.stringify(response);
                    if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer) {
                        that.elavonService.elavonErrorLog(errorLog)
                    }
                    that.submitting = false;
                    that.submitErrorMessage = angular.element("#elavonTokenErrorMessage").val();

                    that.placeOrderAttempt = Number(that.$localStorage.get("placeOrderAttempt"));

                    if (that.placeOrderAttempt == 3 || that.placeOrderAttempt > 3) {
                        that.$localStorage.remove("placeOrderAttempt");
                        that.coreService.redirectToPath("/cart");
                        return;
                    }
                    that.placeOrderAttempt++;
                    that.$localStorage.set("placeOrderAttempt", that.placeOrderAttempt.toString());

                    return true;
               
            });
         

        }

        private getEFSEci(eci:any): string {
            if (eci === '02' || eci === '05') {
                return '5';
            } else if (eci === '01' || eci === '06') {
                return '6';
            } else {
                return '7';
            }
        }

        private getCCExpirationDate(): number {
            return this.pad(this.cart.paymentOptions.creditCard.expirationMonth, 2, "0") + (this.cart.paymentOptions.creditCard.expirationYear % 100);
        }

        private getEFSExpiry():string {
            var expMM = this.pad(this.cart.paymentOptions.creditCard.expirationMonth, 2, "0");
            var expYY = this.cart.paymentOptions.creditCard.expirationYear.toString().substring(2, 4);
          return expYY.concat(expMM);
    };


        private pad(n, width, z) {
            z = z || '0';
            n = n + '';
            return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
        }

        private isValidElavonResponse(response: any): boolean {
            var result = false;
            if (response && response["ssl_token"] != undefined && response["ssl_token"] != "") {
                result = true;
            }
            return result;
        }

        private isValidElavonAVSResponse(response: any): boolean {
            var result = false;
            if (response && response["ssl_transaction_type"] != undefined && response["ssl_transaction_type"] != "" && response["ssl_transaction_type"] == "GETTOKEN" && response["ssl_avs_response"] == undefined) {
                result = true;
                return result;
            }
            if (response && response["ssl_avs_response"] != undefined && response["ssl_avs_response"] != "") {
                var ssl_avs_response = response["ssl_avs_response"];
                if (this.elavonAcceptAVSResponseCode) {
                    var responseCodes = this.elavonAcceptAVSResponseCode.split(',');
                    var data = responseCodes.filter(x => x.includes(ssl_avs_response));
                    if (data && data.length > 0) {
                        result = true;
                        return result;
                    }
                }
            }
            return result;
        }

        private isValidElavonCVVResponse(response: any): boolean {
            var result = false;
            if (response && response["ssl_transaction_type"] != undefined && response["ssl_transaction_type"] != "" && response["ssl_transaction_type"] == "GETTOKEN" && response["ssl_cvv2_response"] == undefined) {
                result = true;
                return result;
            }
            if (response && response["ssl_cvv2_response"] != undefined && response["ssl_cvv2_response"] != "") {
                var ssl_cvv2_response = response["ssl_cvv2_response"];
                if (this.elavonAcceptCVVResponseCode) {
                    var responseCodes = this.elavonAcceptCVVResponseCode.split(',');
                    var data = responseCodes.filter(x => x.includes(ssl_cvv2_response));
                    if (data && data.length > 0) {
                        result = true;
                    }
                }
            }
            return result;
        }

    }

    angular
        .module("insite")
        .controller("ReviewAndPayController", EmployeeReviewAndPayController);
}