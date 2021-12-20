var insite;
(function (insite) {
    var catalog;
    (function (catalog) {
        "use strict";
        var EmployeeProductImagesController = /** @class */ (function () {
            function EmployeeProductImagesController($scope, coreService) {
                this.$scope = $scope;
                this.coreService = coreService;
                this.mainPrefix = "main";
                this.zoomPrefix = "zoom";
                this.init();
            }
            EmployeeProductImagesController.prototype.init = function () {
                var _this = this;
                this.$scope.$watch(function () { return _this.product.productImages; }, function () {
                    if (_this.product.productImages.length > 0) {
                        _this.selectedImage = _this.product.productImages[0];
                        var fileExt = _this.getFileExtension(_this.selectedImage.largeImagePath);
                        if (fileExt == "spin") {
                            var spinDiv = angular.element('#spin-image');
                            Sirv.stop();
                            spinDiv.attr('data-src', '');
                            spinDiv.attr('data-src', _this.selectedImage.largeImagePath);
                            spinDiv.show();
                            Sirv.start();
                            _this.hideMainImage = true;
                        }
                    }
                    else {
                        _this.selectedImage = {
                            imageType: "Static",
                            smallImagePath: _this.product.smallImagePath,
                            mediumImagePath: _this.product.mediumImagePath,
                            largeImagePath: _this.product.largeImagePath,
                            altText: _this.product.altText
                        };
                    }
                }, true);
                this.coreService.refreshUiBindings();
                angular.element(document).on("close.fndtn.reveal", "#imgZoom[data-reveal]:visible", function () { _this.onImgZoomClose(); });
                angular.element(document).on("opened.fndtn", "#imgZoom[data-reveal]", function () { _this.onImgZoomOpened(); });
                this.collectImagesForPopup();
                this.$scope.$on("$destroy", function () {
                    angular.element(document).off("close.fndtn.reveal", "#imgZoom[data-reveal]:visible");
                    angular.element(document).off("opened.fndtn", "#imgZoom[data-reveal]");
                });
            };
            EmployeeProductImagesController.prototype.collectImagesForPopup = function () {
                this.zoomProductImages = [];
                var self = this;
                this.product.productImages.forEach(function (value, key) {
                    if (value.largeImagePath !== undefined) {
                        var fileExt = self.getFileExtension(value.largeImagePath);
                        if (fileExt !== "spin") {
                            self.zoomProductImages.push(value);
                        }
                    }
                });
            };
            EmployeeProductImagesController.prototype.getFileExtension = function (filename) {
                return (/[.]/.exec(filename)) ? /[^.]+$/.exec(filename)[0] : undefined;
            };
            EmployeeProductImagesController.prototype.onImgZoomClose = function () {
                var _this = this;
                this.$scope.$apply(function () {
                    _this.showCarouselOnZoomModal = false;
                });
            };
            EmployeeProductImagesController.prototype.onImgZoomOpened = function () {
                var _this = this;
                this.$scope.$apply(function () {
                    _this.showCarouselOnZoomModal = true;
                });
            };
            EmployeeProductImagesController.prototype.getMainImageWidth = function () {
                return angular.element("#" + this.mainPrefix + "ProductImage").outerWidth();
            };
            EmployeeProductImagesController.prototype.getZoomImageWidth = function () {
                return angular.element("#" + this.zoomPrefix + "ProductImage").outerWidth();
            };
            EmployeeProductImagesController.$inject = ["$scope", "coreService"];
            return EmployeeProductImagesController;
        }());
        catalog.EmployeeProductImagesController = EmployeeProductImagesController;
        angular
            .module("insite")
            .controller("EmployeeProductImagesController", EmployeeProductImagesController);
    })(catalog = insite.catalog || (insite.catalog = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.product-images.controller.js.map