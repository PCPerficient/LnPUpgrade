
module insite.account {
    "use strict";
    import RegistrationModel = LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels.RegistrationModel;
    import RegistrationResultModel = LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels.RegistrationResultModel;

    export class CreateEmployeeAccountController {
        createError: string;
        email: string;
        isSubscribed: boolean;
        password: string;
        returnUrl: string;
        settings: AccountSettingsModel;
        userName: string;
        session: SessionModel;
        firstName: string;
        lastName: string;
        clockOrUnique: string;
        clockOrUniqueError: boolean = false;
        isUserRegistered: boolean = false;
        account = {
            firstName: "",
            lastName: "",
            email: "",
            uniqueOrClock: ""
        } as RegistrationModel;
        vaidationSetting: any;
        static $inject = [
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

        constructor(
            protected accountService: IAccountService,
            protected sessionService: ISessionService,
            protected coreService: core.ICoreService,
            protected settingsService: core.ISettingsService,
            protected queryString: common.IQueryStringService,
            protected accessToken: common.IAccessTokenService,
            protected spinnerService: core.SpinnerService,
            protected $q: ng.IQService,
            protected registrationService: IRegistrationService) {

        }

        $onInit(): void {
            this.returnUrl = this.queryString.get("returnUrl");

            this.sessionService.getSession().then(
                (session: SessionModel) => { this.getSessionCompleted(session); },
                (error: any) => { this.getSessionFailed(error); });

            this.settingsService.getSettings().then(
                (settingsCollection: core.SettingsCollection) => { this.getSettingsCompleted(settingsCollection); },
                (error: any) => { this.getSettingsFailed(error); });
        }

        protected getSessionCompleted(session: SessionModel): void {
            this.session = session;
        }

        protected getSessionFailed(error: any): void {
        }

        protected getSettingsCompleted(settingsCollection: any): void {
            this.settings = settingsCollection.accountSettings;
            this.vaidationSetting = settingsCollection.validationSetting;
        }

        protected getSettingsFailed(error: any): void {
        }

        createAccount(): void {
            this.createError = "";
            this.clockOrUniqueError = false;
            this.isUserRegistered = false;
            let valid = $("#createAccountForm").validate().form();
            this.account = {
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                uniqueOrClock: this.clockOrUnique
            } as RegistrationModel;
            if (this.notValidateCrossSiteScripting()) {
                valid = false;
                this.coreService.displayModal(angular.element("#invalidAddressErrorPopup"));
            }

            if (!valid) {
                return;
            }
            if (this.validateUniqueOrClock()) {
                this.spinnerService.show("mainLayout", true);

                this.registrationService.createAccount(this.account).then(
                    (registrationResultModel: RegistrationResultModel) => {
                        if (registrationResultModel.isRegistered) {
                            this.isUserRegistered = true;
                            this.clearField();
                            let redirectUrl = this.getEmployeeRedirectUrlPath(registrationResultModel);
                            if (redirectUrl != "") {
                                this.coreService.redirectToPath(redirectUrl);
                            }
                        }
                        else {
                            let redirectUrl = this.getEmployeeRedirectUrlPath(registrationResultModel);
                            if (redirectUrl != "") {
                                this.coreService.redirectToPath(redirectUrl);
                            }
                            else {
                                this.createError = registrationResultModel.errorMessage;
                            }
                        }
                        this.spinnerService.hide("mainLayout");
                    },
                    (error: any) => { this.createError = error.message; this.spinnerService.hide("mainLayout"); });
            }
            else
                this.spinnerService.hide("mainLayout");

        }

        getEmployeeRedirectUrlPath(registrationResultModel: RegistrationResultModel): string {
            if (registrationResultModel.properties['registrationRedirectUrl'] != null && registrationResultModel.properties['registrationRedirectUrl'] != '') {
                let redirectUrl = registrationResultModel.properties['registrationRedirectUrl'].toString();
                return redirectUrl;
            }
            return "";
        }

        clearField(): void {
            this.firstName = "";
            this.lastName = "";
            this.email = "";
            this.clockOrUnique = "";
        }

        validateUniqueOrClock(): boolean {
            var result = false;
            var uniqueOrClockId = this.clockOrUnique;
            if (uniqueOrClockId.length.toString() == "4")
                result = true
            if (uniqueOrClockId.length.toString() == "7")
                result = this.isNumber(uniqueOrClockId);

            if (!result)
                this.clockOrUniqueError = true;

            return result;
        }
        isNumber(n): boolean {
            return !isNaN(n - n);
        }
        notValidateCrossSiteScripting(): boolean {

            return (this.containsSpecialChars(this.account.firstName)
                || this.containsSpecialChars(this.account.lastName)
            );

        }
        containsSpecialChars(str) {
            const specialChars = new RegExp(`[${this.vaidationSetting.specialCharecters}]`);
            return specialChars.test(str);
        }
    }

    angular
        .module("insite")
        .controller("CreateEmployeeAccountController", CreateEmployeeAccountController);
}