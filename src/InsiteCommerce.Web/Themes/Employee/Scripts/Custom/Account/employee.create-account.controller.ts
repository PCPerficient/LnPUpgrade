
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
            this.init();
        }

        init(): void {
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

        protected getSettingsCompleted(settingsCollection: core.SettingsCollection): void {
            this.settings = settingsCollection.accountSettings;
        }

        protected getSettingsFailed(error: any): void {
        }

        createAccount(): void {
            this.createError = "";
            this.clockOrUniqueError = false;
            this.isUserRegistered = false;

            const valid = $("#createAccountForm").validate().form();
            if (!valid) {
                return;
            }
            if (this.validateUniqueOrClock()) {
                this.spinnerService.show("mainLayout", true);
                const account = {
                    firstName: this.firstName,
                    lastName: this.lastName,
                    email: this.email,
                    uniqueOrClock: this.clockOrUnique
                } as RegistrationModel;
                this.registrationService.createAccount(account).then(
                    (registrationResultModel: RegistrationResultModel ) => {
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
    }

    angular
        .module("insite")
        .controller("CreateEmployeeAccountController", CreateEmployeeAccountController);
}