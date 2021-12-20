var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var insite;
(function (insite) {
    var catalog;
    (function (catalog) {
        "use strict";
        var EmployeeProductSearchController = /** @class */ (function (_super) {
            __extends(EmployeeProductSearchController, _super);
            function EmployeeProductSearchController($element, sessionService, $filter, coreService, searchService, settingsService, $state, queryString, $scope, $window) {
                var _this = _super.call(this, $element, $filter, coreService, searchService, settingsService, $state, queryString, $scope, $window) || this;
                _this.$element = $element;
                _this.sessionService = sessionService;
                _this.$filter = $filter;
                _this.coreService = coreService;
                _this.searchService = searchService;
                _this.settingsService = settingsService;
                _this.$state = $state;
                _this.queryString = queryString;
                _this.$scope = $scope;
                _this.$window = $window;
                return _this;
            }
            EmployeeProductSearchController.prototype.getSettingsCompleted = function (settingsCollection) {
                var _this = this;
                this.autocompleteEnabled = settingsCollection.searchSettings.autocompleteEnabled;
                this.searchHistoryEnabled = settingsCollection.searchSettings.searchHistoryEnabled;
                this.sessionService.getSession().then(function (session) { _this.getSessionCompleted(session); }, function (error) { _this.getSessionFailed(error); });
            };
            EmployeeProductSearchController.prototype.getSessionCompleted = function (session) {
                this.session = session;
            };
            EmployeeProductSearchController.prototype.getSessionFailed = function (error) {
            };
            EmployeeProductSearchController.$inject = ["$element", "sessionService", "$filter", "coreService", "searchService", "settingsService", "$state", "queryString", "$scope", "$window"];
            return EmployeeProductSearchController;
        }(catalog.ProductSearchController));
        catalog.EmployeeProductSearchController = EmployeeProductSearchController;
        angular
            .module("insite")
            .controller("ProductSearchController", EmployeeProductSearchController);
    })(catalog = insite.catalog || (insite.catalog = {}));
})(insite || (insite = {}));
//# sourceMappingURL=employee.product-search.controller.js.map