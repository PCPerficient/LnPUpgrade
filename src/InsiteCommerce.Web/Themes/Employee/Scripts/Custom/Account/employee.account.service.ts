
module insite.account {
    "use strict";

    import RegistrationModel = LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels.RegistrationModel;
    import RegistrationResultModel = LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels.RegistrationResultModel;
    export interface IRegistrationService {
      
        createAccount(registrationModel: RegistrationModel): ng.IPromise<RegistrationResultModel>;
       
    }

    export class RegistrationService {
        serviceUri = "/api/v2/registration";

        static $inject = ["$http", "$window", "httpWrapperService"];

        constructor(
            protected $http: ng.IHttpService,
            protected $window: ng.IWindowService,
            protected httpWrapperService: core.HttpWrapperService) {
        }

        createAccount(registrationModel: RegistrationModel): ng.IPromise<RegistrationResultModel> {
            return this.httpWrapperService.executeHttpRequest(
                this,
                this.$http({ method: "GET", url: this.serviceUri, params: registrationModel }),
                this.createAccountCompleted,
                this.createAccountFailed);
        }

        protected createAccountCompleted(response: ng.IHttpPromiseCallbackArg<RegistrationResultModel>): void {
        }

        protected createAccountFailed(error: ng.IHttpPromiseCallbackArg<any>): void {
        }
    }
    angular
        .module("insite")
        .service("registrationService", RegistrationService);
}