module insite.contactus {
    "use strict";

    export class EmployeeContactUsController {
        submitted = false;
        $form: JQuery;
        vaidationSetting: any;
        formData:{
            firstName: "",
            lastName: "",
            message: "",
            topic: "",
            emailAddress:""};
        static $inject = ["$element", "$scope", "coreService","settingsService"];

        constructor(
            protected $element: ng.IRootElementService,
            protected $scope: ng.IScope,
            protected coreService: core.ICoreService,
            protected settingsService: core.ISettingsService) {
        }

        $onInit(): void {
            this.$form = this.$element.find("form");
            this.$form.removeData("validator");
            this.$form.removeData("unobtrusiveValidation");
            this.settingsService.getSettings().then(
                (settingsCollection: core.SettingsCollection) => {
                    
                    this.getSettingsCompleted(settingsCollection);
                },
                (error: any) => { this.getSettingsFailed(error); });
            $.validator.unobtrusive.parse(this.$form);
        }
        protected getSettingsCompleted(settingsCollection: any): void {          
            this.vaidationSetting = settingsCollection.validationSetting;
        }
        protected getSettingsFailed(error: any): void {
        }

        submit($event): boolean {
            $event.preventDefault();
            if (!this.$form.valid()) {
                return false;
            }
            
            var that = this;

            this.formData = {
                firstName: $('[name="FirstName"]').val(),
                lastName: $('[name="LastName"]').val(),
                message: $('[name="Message"]').val(),
                topic: $('[name="Topic"]').val(),
                emailAddress: $('[name="EmailAddress"]').val()
            }
            if (this.notValidateCrossSiteScripting()) {
                this.coreService.displayModal(angular.element("#invalidAddressErrorPopup"));
                return false;
            }

            $.ajax({
                url: window.location.protocol + "//" + window.location.host + this.$form.first().attr('action'),
                type: "POST",

                beforeSend: function (xhr) {
                    xhr.setRequestHeader("RequestVerificationToken", $('.cf-form').attr('antiforgerytokencontent'));
                },

                data: this.formData,
                success: function (data) {
                    that.submitted = true;
                    that.coreService.displayModal(angular.element("#requestSucessPopupPopup"));
                    that.$scope.$apply();
                   
                    
                }
            });

            return false;
        }
        notValidateCrossSiteScripting(): boolean {

            return (this.containsSpecialChars(this.formData.firstName)
                || this.containsSpecialChars(this.formData.lastName)            
                || this.containsSpecialChars(this.formData.message)
                || this.containsSpecialChars(this.formData.topic)    
            );

        }
        containsSpecialChars(str) {
            const specialChars = new RegExp(`[${this.vaidationSetting.specialCharecters}]`);
            return specialChars.test(str);
        }
    }

    angular
        .module("insite")
        .controller("EmployeeContactUsController", EmployeeContactUsController);
}