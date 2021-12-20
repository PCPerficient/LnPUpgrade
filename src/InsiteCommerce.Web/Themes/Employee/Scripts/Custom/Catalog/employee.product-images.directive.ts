module insite.catalog {
    "use strict";

    angular
        .module("insite")
        .directive("employeeProductImages", () => ({
            restrict: "E",
            replace: true,
            scope: {
                product: "="
            },
            templateUrl: "/PartialViews/Catalog-EmployeeProductImages",
            controller: "EmployeeProductImagesController",
            controllerAs: "vm",
            bindToController: true
        }));
}