
module insite.customproperty {
    "use strict";

    

    export interface ICustomPropertyService {
        addUpdateCustomerOrderCustomProperty(requestModel: CustomPropertyRequestModel): ng.IPromise<CustomPropertyResponseModel>;
    }
    export class CustomPropertyService {
        serviceUri = "/api/v2/CustomerOrder/CustomProperty";
        static $inject = ["$http", "httpWrapperService"];

        constructor(
            protected $http: ng.IHttpService,
            protected httpWrapperService: core.HttpWrapperService) {
        }

        addUpdateCustomerOrderCustomProperty(requestModel: CustomPropertyRequestModel): ng.IPromise<CustomPropertyResponseModel> {
            return this.httpWrapperService.executeHttpRequest(
                this,
                this.$http.post(this.serviceUri, requestModel),
                this.AddUpdateCustomPropertyCompleted,
                this.AddUpdateCustomPropertyFailed
            );
        }
        protected AddUpdateCustomPropertyCompleted(response: ng.IHttpPromiseCallbackArg<CustomPropertyResponseModel>): void {
        }
        protected AddUpdateCustomPropertyFailed(error: ng.IHttpPromiseCallbackArg<any>): void {
        }
    }
    angular
        .module("insite")
        .service("custompropertyservice", CustomPropertyService);

}