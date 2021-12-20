import ElavonSessionTokenModel = LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels.ElavonSessionTokenModel;
import ElavonErrorLogModel = LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels.ElavonErrorLogModel;
module insite.elavon {
    "use strict";

    export interface IElavonParameters {
        elavonToken: string;
    }

    export interface IElavonService {
        getElavonSessionToken(): any;
        elavonErrorLog(ElavonErrorLogModel): ng.IPromise<ElavonErrorLogModel>;

    }

    export class ElavonService implements IElavonService {

        elavonSessionTokenUrl = "/api/v2/getelavonsessiontoken";
        elavonErrorLogUrl = "/api/v1/elavonerrorlog";
        static $inject = ["$http", "$rootScope", "$q", "coreService", "httpWrapperService"];

        constructor(
            protected $http: ng.IHttpService,
            protected $rootScope: ng.IRootScopeService,
            protected $q: ng.IQService,
            protected coreService: core.ICoreService,
            protected httpWrapperService: core.HttpWrapperService) {
            this.init();
        }

        init(): void {

        }

        elavonErrorLog(errorLogModel: ElavonErrorLogModel): ng.IPromise<ElavonErrorLogModel> {
            return this.httpWrapperService.executeHttpRequest(
                this,
                this.$http({ method: "Put", url: this.elavonErrorLogUrl, data: errorLogModel, bypassErrorInterceptor: true }),
                (response: ng.IHttpPromiseCallbackArg<ElavonErrorLogModel>) => { this.elavonErrorLogCompleted(response); },
                this.elavonErrorLogFailed);
        }
        protected elavonErrorLogCompleted(response: any): void {
        }

        protected elavonErrorLogFailed(error: any): void {
        }

        getElavonSessionToken(): any {
            var num = new Date();
            var number = num.getSeconds();
            var url = this.elavonSessionTokenUrl + "/" + number;
            return this.httpWrapperService.executeHttpRequest(
                this,
                this.$http({ method: "GET", url: url }),
                this.getElavonSessionTokenCompleted,
                this.getElavonSessionTokenFailed);
        }

        protected getElavonSessionTokenCompleted(response: any): void {
        }

        protected getElavonSessionTokenFailed(error: any): void {
        }

    }
    angular
        .module("insite")
        .service("elavonService", ElavonService);
}