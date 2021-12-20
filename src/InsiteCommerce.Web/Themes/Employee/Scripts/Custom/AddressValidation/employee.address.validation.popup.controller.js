var insite;
(function (insite) {
    var addressvalidation;
    (function (addressvalidation) {
        "use strict";
        var EmployeeAddressValidationPopupController = /** @class */ (function () {
            function EmployeeAddressValidationPopupController() {
            }
            EmployeeAddressValidationPopupController.prototype.setAddress = function (model) {
                this.selectedModel = model;
            };
            return EmployeeAddressValidationPopupController;
        }());
        addressvalidation.EmployeeAddressValidationPopupController = EmployeeAddressValidationPopupController;
        angular
            .module("insite")
            .controller("EmployeeAddressValidationPopupController", EmployeeAddressValidationPopupController);
    })(addressvalidation = insite.addressvalidation || (insite.addressvalidation = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.address.validation.popup.controller.js.map