var insite;
(function (insite) {
    var catalog;
    (function (catalog) {
        "use strict";
        angular
            .module("insite")
            .directive("employeeProductImageCarousel", function () { return ({
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
        }); });
    })(catalog = insite.catalog || (insite.catalog = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.product-image-carousel.directive.js.map