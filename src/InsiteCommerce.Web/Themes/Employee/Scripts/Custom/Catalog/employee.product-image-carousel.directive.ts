module insite.catalog {
    "use strict";

    angular
        .module("insite")
        .directive("employeeProductImageCarousel", () => ({
            restrict: "E",
            replace: true,
            scope: {
                productImages: "=",
                selectedImage: "=",
                prefix: "@",
                maxTries: "@",
                getCarouselWidth: "&"
            },
            templateUrl: "/PartialViews/Catalog-EmployeeProductImageCarousel",
            controller: "EmployeeProductImageCarouselController",
            controllerAs: "vm",
            bindToController: true
        }));
}