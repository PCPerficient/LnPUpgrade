var insite;
(function (insite) {
    var catalog;
    (function (catalog) {
        "use strict";
        angular
            .module("insite")
            .directive("employeeProductImages", function () { return ({
            restrict: "E",
            replace: true,
            scope: {
                product: "="
            },
            templateUrl: "/PartialViews/Catalog-EmployeeProductImages",
            controller: "EmployeeProductImagesController",
            controllerAs: "vm",
            bindToController: true
        }); });
    })(catalog = insite.catalog || (insite.catalog = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.product-images.directive.js.map