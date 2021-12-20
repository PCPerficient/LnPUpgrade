var insite;
(function (insite) {
    var catalog;
    (function (catalog) {
        "use strict";
        var EmployeeProductImageCarouselController = /** @class */ (function () {
            function EmployeeProductImageCarouselController($timeout, $scope) {
                this.$timeout = $timeout;
                this.$scope = $scope;
                this.$onInit();
            }
            EmployeeProductImageCarouselController.prototype.$onInit = function () {
                var _this = this;
                this.$scope.$watch(function () { return _this.productImages; }, function () {
                    if (_this.productImages.length > 0) {
                        _this.imagesLoaded = 0;
                        _this.waitForDom(_this.maxTries);
                    }
                });
            };
            EmployeeProductImageCarouselController.prototype.waitForDom = function (tries) {
                var _this = this;
                if (isNaN(+tries)) {
                    tries = this.maxTries || 1000; // Max 20000ms
                }
                // If DOM isn't ready after max number of tries then stop
                if (tries > 0) {
                    this.$timeout(function () {
                        if (_this.isCarouselDomReadyAndImagesLoaded()) {
                            _this.initializeCarousel();
                            _this.$scope.$apply();
                        }
                        else {
                            _this.waitForDom(tries - 1);
                        }
                    }, 20, false);
                }
            };
            EmployeeProductImageCarouselController.prototype.isCarouselDomReadyAndImagesLoaded = function () {
                return $("#" + this.prefix + "-img-carousel").length > 0 && this.productImages
                    && this.imagesLoaded >= this.productImages.length;
            };
            EmployeeProductImageCarouselController.prototype.initializeCarousel = function () {
                var _this = this;
                var $carousel = $("#" + this.prefix + "-img-carousel");
                if ($carousel.data("flexslider")) {
                    $carousel.removeData("flexslider");
                }
                $carousel.flexslider({
                    animation: "slide",
                    controlNav: false,
                    animationLoop: true,
                    slideshow: false,
                    animationSpeed: 200,
                    itemWidth: 46,
                    itemMargin: 4.8,
                    move: 1,
                    customDirectionNav: $("." + this.prefix + "-carousel-control-nav"),
                    start: function (slider) { _this.onSliderStart(slider); }
                });
                $(window).resize(function () {
                    _this.onWindowResize();
                });
            };
            EmployeeProductImageCarouselController.prototype.onSliderStart = function (slider) {
                this.carousel = slider;
                this.carouselWidth = this.getCarouselWidth();
                this.reloadCarousel();
            };
            EmployeeProductImageCarouselController.prototype.onWindowResize = function () {
                var currentCarouselWidth = this.getCarouselWidth();
            };
            EmployeeProductImageCarouselController.prototype.reloadCarousel = function () {
                var $carousel = $("#" + this.prefix + "-img-carousel");
                var totalCarouselWidth = Math.round((this.carousel.vars.itemWidth + this.carousel.vars.itemMargin) * this.carousel.count - this.carousel.vars.itemMargin);
                $("#" + this.prefix + "-img-carousel-wrapper").css({
                    visibility: "visible",
                    position: "relative"
                });
                $carousel.css({
                    width: "",
                    margin: ""
                });
                if (totalCarouselWidth < $carousel.width()) {
                    $carousel.css({
                        width: totalCarouselWidth,
                        margin: "0 auto"
                    });
                }
                // this line should be there because of a flexslider issue (https://github.com/woocommerce/FlexSlider/issues/1263)
                $carousel.resize();
                this.showImageCarouselArrows($carousel.width() < totalCarouselWidth);
            };
            EmployeeProductImageCarouselController.prototype.showImageCarouselArrows = function (shouldShowArrows) {
                if (shouldShowArrows) {
                    $("." + this.prefix + "-carousel-control-nav").show();
                }
                else {
                    $("." + this.prefix + "-carousel-control-nav").hide();
                }
            };
            EmployeeProductImageCarouselController.prototype.selectImage = function (image) {
                var _this = this;
                this.selectedImage = image;
                var fileExt = this.getFileExtension(this.selectedImage.largeImagePath);
                var spinDiv = angular.element('#spin-image');
                if (fileExt == "spin") {
                    Sirv.stop();
                    spinDiv.attr('data-src', '');
                    spinDiv.attr('data-src', this.selectedImage.largeImagePath);
                    spinDiv.show();
                    Sirv.start();
                    $("#mainProductImage").hide();
                }
                else {
                    spinDiv.hide();
                    $("#mainProductImage").show();
                }
                this.$timeout(function () {
                    _this.reloadCarousel();
                }, 20);
            };
            EmployeeProductImageCarouselController.prototype.getFileExtension = function (filename) {
                return (/[.]/.exec(filename)) ? /[^.]+$/.exec(filename)[0] : undefined;
            };
            EmployeeProductImageCarouselController.$inject = ["$timeout", "$scope"];
            return EmployeeProductImageCarouselController;
        }());
        catalog.EmployeeProductImageCarouselController = EmployeeProductImageCarouselController;
        angular
            .module("insite")
            .controller("EmployeeProductImageCarouselController", EmployeeProductImageCarouselController);
    })(catalog = insite.catalog || (insite.catalog = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.product-image-carousel.controller.js.map