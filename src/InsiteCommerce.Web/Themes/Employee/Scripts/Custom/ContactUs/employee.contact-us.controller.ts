module insite.contactus {
    "use strict";

    export class EmployeeContactUsController {
        submitted = false;
        $form: JQuery;

        static $inject = ["$element", "$scope"];

        constructor(
            protected $element: ng.IRootElementService,
            protected $scope: ng.IScope) {
        }

        $onInit(): void {
            this.$form = this.$element.find("form");
            this.$form.removeData("validator");
            this.$form.removeData("unobtrusiveValidation");
            $.validator.unobtrusive.parse(this.$form);
        }

        submit($event): boolean {
            $event.preventDefault();
            if (!this.$form.valid()) {
                return false;
            }

            //(this.$form as any).ajaxPost(() => {
            //    this.submitted = true;
            //    this.$scope.$apply();
            //});
            var that = this;

            var formData = {
                'firstName': $('[name="FirstName"]').val(),
                'lastName': $('[name="LastName"]').val(),
                'message': $('[name="Message"]').val(),
                'topic': $('[name="Topic"]').val(),
                'emailAddress': $('[name="EmailAddress"]').val()
            }

            $.ajax({
                url: window.location.protocol + "//" + window.location.host + this.$form.first().attr('action'),
                type: "POST",

                beforeSend: function (xhr) {
                    xhr.setRequestHeader("RequestVerificationToken", $('.cf-form').attr('antiforgerytokencontent'));
                },

                data: formData,
                success: function (data) {
                    this.submitted = true;
                    that.$scope.$apply();
                }
            });

            return false;
        }
    }

    angular
        .module("insite")
        .controller("EmployeeContactUsController", EmployeeContactUsController);
}