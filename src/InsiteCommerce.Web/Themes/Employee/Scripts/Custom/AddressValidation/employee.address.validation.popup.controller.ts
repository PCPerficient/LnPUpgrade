
module insite.addressvalidation {
    "use strict";
    import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
    import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
    import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;

    export class EmployeeAddressValidationPopupController {

        selectedModel: AddressSuggestion;

        setAddress(model: AddressSuggestion): void {
            this.selectedModel = model;
        }
    }
    angular
        .module("insite")
        .controller("EmployeeAddressValidationPopupController", EmployeeAddressValidationPopupController);
}