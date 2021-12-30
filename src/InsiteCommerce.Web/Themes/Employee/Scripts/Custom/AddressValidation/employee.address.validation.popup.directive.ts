module insite.addressvalidation {
    "use strict";

    //import AddressValidationResponseModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationResponseModel;
    //import AddressValidationRequestModel = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressValidationRequestModel;
    //import AddressSuggestion = LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels.AddressSuggestion;

    angular
        .module("insite")
        .directive("iscAddressValidationPopupTemplate", () => ({
            replace: true,
            restrict: "E",
            controller: "EmployeeAddressValidationPopupController",
            controllerAs: "vm",
            scope: {
                containerId: "@",
                title: "@",
                suggestedModel: "=",
                selectedAddress: "&",
                selectedModel: "="
            },
            transclude: true,
            templateUrl: "/PartialViews/AddressValidationPopup-AddressSuggestionPopup",
        }));
}