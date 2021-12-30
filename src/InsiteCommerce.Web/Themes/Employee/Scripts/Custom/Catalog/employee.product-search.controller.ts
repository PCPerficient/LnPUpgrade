module insite.catalog {
    "use strict";

    export class EmployeeProductSearchController extends ProductSearchController {

        session: SessionModel;

        static $inject = ["$element", "sessionService", "$filter", "coreService", "searchService", "settingsService", "$state", "queryString", "$scope" , "$window"];

        constructor(
            protected $element: ng.IRootElementService,
            protected sessionService: account.ISessionService,
            protected $filter: ng.IFilterService,
            protected coreService: core.ICoreService,
            protected searchService: ISearchService,
            protected settingsService: core.ISettingsService,
            protected $state: angular.ui.IStateService,
            protected queryString: common.IQueryStringService,
            protected $scope: ng.IScope,
            protected $window: ng.IWindowService) {
            super($element, $filter, coreService, searchService, settingsService, $state, queryString, $scope, $window)
        }

        protected getSettingsCompleted(settingsCollection: core.SettingsCollection): void {
            this.autocompleteEnabled = settingsCollection.searchSettings.autocompleteEnabled;
            this.searchHistoryEnabled = settingsCollection.searchSettings.searchHistoryEnabled;

            this.sessionService.getSession().then(
                (session: SessionModel) => { this.getSessionCompleted(session); },
                (error: any) => { this.getSessionFailed(error); });
        }

        protected getSessionCompleted(session: SessionModel): void {
            this.session = session;
        }

        protected getSessionFailed(error: any): void {
        }
    }

    angular
        .module("insite")
        .controller("ProductSearchController", EmployeeProductSearchController);
}