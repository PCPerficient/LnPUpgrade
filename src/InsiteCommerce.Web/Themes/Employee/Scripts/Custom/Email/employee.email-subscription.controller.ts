﻿module insite.email {
    "use strict";

    export class EmployeeEmailSubscriptionController {
        session: SessionModel;
        submitted = false;
        $form: JQuery;

        static $inject = ["$element", "$scope", "sessionService"];

        constructor(
            protected $element: ng.IRootElementService,
            protected $scope: ng.IScope,
            protected sessionService: account.ISessionService
        ) {
           
        }

        $onInit(): void {
            this.$form = this.$element.find("form");
            this.$form.removeData("validator");
            this.$form.removeData("unobtrusiveValidation");
            $.validator.unobtrusive.parse(this.$form);

            this.sessionService.getSession().then(
                (session: SessionModel) => { this.getSessionCompleted(session); },
                (error: any) => { this.getSessionFailed(error); });
        }

        protected getSessionCompleted(session: SessionModel): void {
            this.session = session;
        }

        protected getSessionFailed(error: any): void {
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
                    that.submitted = true;
                    that.$scope.$apply();
                }
            });
            return false;
        }
    }

    angular
        .module("insite")
        .controller("EmployeeEmailSubscriptionController", EmployeeEmailSubscriptionController);
}