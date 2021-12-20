
module insite.addressvalidation {
    "use strict";
    import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
    import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
    import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;

    export interface IAddressValidationService {
        validateAddress(addressValidationModel: AddressValidationRequestModel): ng.IPromise<AddressValidationResponseModel>;
    }

    export class AddressValidationService implements IAddressValidationService {
        serviceUri = "/api/v2/address/validation";
        static $inject = ["$http", "$window", "httpWrapperService"];

        constructor(
            protected $http: ng.IHttpService,
            protected $window: ng.IWindowService,
            protected httpWrapperService: core.HttpWrapperService) {
        }

        validateAddress(addressValidationModel: AddressValidationRequestModel): ng.IPromise<AddressValidationResponseModel> {
            return this.httpWrapperService.executeHttpRequest(
                this,
                this.$http({ method: "GET", url: this.serviceUri, params: addressValidationModel }),
                this.validateAddressCompleted,
                this.validateAddressFailed);
        }
        protected validateAddressCompleted(response: ng.IHttpPromiseCallbackArg<AddressValidationResponseModel>): void {
        }

        protected validateAddressFailed(error: ng.IHttpPromiseCallbackArg<any>): void {
        }
    }

    angular
        .module("insite")
        .service("addressValidationService", AddressValidationService);
}