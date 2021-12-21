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
    var cart;
    (function (cart_1) {
        "use strict";
        var EmployeeReviewAndPayController = /** @class */ (function (_super) {
            __extends(EmployeeReviewAndPayController, _super);
            function EmployeeReviewAndPayController(elavonService, $scope, $window, cartService, promotionService, sessionService, coreService, spinnerService, $attrs, settingsService, queryString, $localStorage, websiteService, deliveryMethodPopupService, selectPickUpLocationPopupService) {
                var _this = _super.call(this, $scope, $window, cartService, promotionService, sessionService, coreService, spinnerService, $attrs, settingsService, queryString, $localStorage, websiteService, deliveryMethodPopupService, selectPickUpLocationPopupService) || this;
                _this.elavonService = elavonService;
                _this.$scope = $scope;
                _this.$window = $window;
                _this.cartService = cartService;
                _this.promotionService = promotionService;
                _this.sessionService = sessionService;
                _this.coreService = coreService;
                _this.spinnerService = spinnerService;
                _this.$attrs = $attrs;
                _this.settingsService = settingsService;
                _this.queryString = queryString;
                _this.$localStorage = $localStorage;
                _this.websiteService = websiteService;
                _this.deliveryMethodPopupService = deliveryMethodPopupService;
                _this.selectPickUpLocationPopupService = selectPickUpLocationPopupService;
                _this.promotionCodeFormDisplay = false;
                _this.shippingDisplay = false;
                return _this;
            }
            EmployeeReviewAndPayController.prototype.getIsAuthenticatedForSubmitCompleted = function (isAuthenticated, submitSuccessUri, signInUri) {
                var _this = this;
                if (!isAuthenticated) {
                    this.coreService.redirectToPathAndRefreshPage(signInUri + "?returnUrl=" + this.coreService.getCurrentPath());
                    return;
                }
                if (this.cart.requiresApproval) {
                    this.cart.status = "AwaitingApproval";
                }
                else {
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
                    var elavonSessionTokenModel = {};
                    this.elavonService.getElavonSessionToken().then(function (elavonTokenDetails) {
                        _this.getElavonSessionTokenCompleted(elavonTokenDetails, submitSuccessUri);
                    }, function (error) { _this.getElavonSessionTokenFailed(error); });
                }
                else {
                    this.tokenizeCardInfoIfNeeded(submitSuccessUri);
                }
            };
            EmployeeReviewAndPayController.prototype.formatWithTimezoneEmployee = function (date) {
                return date ? moment(date).format() : date;
            };
            EmployeeReviewAndPayController.prototype.getSettingsCompleted = function (settingsCollection) {
                var _this = this;
                this.cartSettings = settingsCollection.cartSettings;
                this.SentEmailEvalonPaymentFailuer = settingsCollection.elavonSetting.elavonSettingPaymentFailuerMail;
                this.LogEvalonPaymentResponse = settingsCollection.elavonSetting.logEvalonPaymentResponse;
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
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
            };
            EmployeeReviewAndPayController.prototype.getElavonSessionTokenCompleted = function (elavonDetails, submitSuccessUri) {
                this.elavonToken = elavonDetails.elavonToken;
                this.elavonResponseCodes = elavonDetails.elavonResponseCodes;
                this.elavonAcceptAVSResponseCode = elavonDetails.elavonAcceptAVSResponseCode;
                this.elavonAcceptCVVResponseCode = elavonDetails.elavonAcceptCVVResponseCode;
                if (typeof (this.elavonToken) !== "undefined" && this.elavonToken != "") {
                    this.payTransaction(elavonDetails, submitSuccessUri);
                }
                else {
                    var errorLog = {};
                    errorLog.customerNumber = this.cart.billTo.customerNumber;
                    errorLog.elavonResponse = JSON.stringify("Elavon Token Generation Error");
                    errorLog.elavonResponseFor = "Declined";
                    if ((this.LogEvalonPaymentResponse) || (this.SentEmailEvalonPaymentFailuer)) {
                        this.elavonService.elavonErrorLog(errorLog);
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
            };
            EmployeeReviewAndPayController.prototype.getElavonSessionTokenFailed = function (error) {
                this.submitting = false;
                this.ccElavonErrorMessage = "Payment Processing Error.";
                this.coreService.displayModal(angular.element("#elavonTokenErrorMessage"));
                var errorLog = {};
                errorLog.customerNumber = this.cart.billTo.customerNumber;
                errorLog.elavonResponse = JSON.stringify("Elavon Token Generation Error");
                errorLog.elavonResponseFor = "Declined";
                if ((this.LogEvalonPaymentResponse) || (this.SentEmailEvalonPaymentFailuer)) {
                    this.elavonService.elavonErrorLog(errorLog);
                }
                this.placeOrderAttempt = Number(this.$localStorage.get("placeOrderAttempt"));
                this.placeOrderAttempt++;
                if (this.placeOrderAttempt == 3 || this.placeOrderAttempt > 3) {
                    this.$localStorage.remove("placeOrderAttempt");
                    this.coreService.redirectToPath("/cart");
                    return;
                }
                return;
            };
            EmployeeReviewAndPayController.prototype.payTransaction = function (elavonDetails, submitSuccessUri) {
                var that = this;
                var errorLog = {};
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
                    ssl_transaction_type: 'CCGETTOKEN'
                };
                var callback = {
                    onError: function (error) {
                        that.ccElavonErrorMessage = elavonDetails.elavonErrorMessage;
                        that.spinnerService.hide();
                        errorLog.elavonResponse = "";
                        errorLog.elavonResponseFor = "Error";
                        errorLog.errorMessage = error;
                        if (that.LogEvalonPaymentResponse || that.SentEmailEvalonPaymentFailuer) {
                            that.elavonService.elavonErrorLog(errorLog);
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
                            that.cartService.updateCart(that.cart, true).then(function (cart) { that.submitCompleted(cart, submitSuccessUri); }, function (error) { that.submitFailed(error); });
                        }
                        if (!isValidAvsResponse || !isValidResponse || !isValidCvvResponse) {
                            that.spinnerService.hide();
                        }
                        return true;
                    }
                };
                ConvergeEmbeddedPayment.pay(paymentData, callback);
            };
            EmployeeReviewAndPayController.prototype.getCCExpirationDate = function () {
                return this.pad(this.cart.paymentOptions.creditCard.expirationMonth, 2, "0") + (this.cart.paymentOptions.creditCard.expirationYear % 100);
            };
            EmployeeReviewAndPayController.prototype.pad = function (n, width, z) {
                z = z || '0';
                n = n + '';
                return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
            };
            EmployeeReviewAndPayController.prototype.isValidElavonResponse = function (response) {
                var result = false;
                if (response && response["ssl_token"] != undefined && response["ssl_token"] != "") {
                    result = true;
                }
                return result;
            };
            EmployeeReviewAndPayController.prototype.isValidElavonAVSResponse = function (response) {
                var result = false;
                if (response && response["ssl_transaction_type"] != undefined && response["ssl_transaction_type"] != "" && response["ssl_transaction_type"] == "GETTOKEN" && response["ssl_avs_response"] == undefined) {
                    result = true;
                    return result;
                }
                if (response && response["ssl_avs_response"] != undefined && response["ssl_avs_response"] != "") {
                    var ssl_avs_response = response["ssl_avs_response"];
                    if (this.elavonAcceptAVSResponseCode) {
                        var responseCodes = this.elavonAcceptAVSResponseCode.split(',');
                        var data = responseCodes.filter(function (x) { return x.includes(ssl_avs_response); });
                        if (data && data.length > 0) {
                            result = true;
                            return result;
                        }
                    }
                }
                return result;
            };
            EmployeeReviewAndPayController.prototype.isValidElavonCVVResponse = function (response) {
                var result = false;
                if (response && response["ssl_transaction_type"] != undefined && response["ssl_transaction_type"] != "" && response["ssl_transaction_type"] == "GETTOKEN" && response["ssl_cvv2_response"] == undefined) {
                    result = true;
                    return result;
                }
                if (response && response["ssl_cvv2_response"] != undefined && response["ssl_cvv2_response"] != "") {
                    var ssl_cvv2_response = response["ssl_cvv2_response"];
                    if (this.elavonAcceptCVVResponseCode) {
                        var responseCodes = this.elavonAcceptCVVResponseCode.split(',');
                        var data = responseCodes.filter(function (x) { return x.includes(ssl_cvv2_response); });
                        if (data && data.length > 0) {
                            result = true;
                        }
                    }
                }
                return result;
            };
            EmployeeReviewAndPayController.$inject = [
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
            return EmployeeReviewAndPayController;
        }(cart_1.ReviewAndPayController));
        cart_1.EmployeeReviewAndPayController = EmployeeReviewAndPayController;
        angular
            .module("insite")
            .controller("ReviewAndPayController", EmployeeReviewAndPayController);
    })(cart = insite.cart || (insite.cart = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.review-and-pay.controller.js.map