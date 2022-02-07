module insite {
    "use strict";

    angular.module('insite').directive('antiForgeryToken', ['$http', function ($http: ng.IHttpService) {

        return function (scope, element, attrs) {
            $http.defaults.headers.common['RequestVerificationToken'] = attrs.antiForgeryToken || "no request verification token";
        };
    }])


}