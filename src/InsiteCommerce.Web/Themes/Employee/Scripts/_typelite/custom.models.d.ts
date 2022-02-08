declare module LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels {

    interface ElavonSessionTokenModel extends Insite.Core.WebApi.BaseModel {
        elavonSessionToken: LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels.ElavonSessionTokenModel[];
    }

    interface ElavonSessionTokenModel {
        elavonToken: string;
        errorMessage: string;
        companyName: string;
        customerNumber: string;
        elavonErrorMessage: string;
        elavonTransactionResponseMessage: string;
        elavonResponseCodes: string[];
        elavonAcceptAVSResponseCode: string;
        elavonAcceptCVVResponseCode: string;
        elavonTransactionType: string;
    }

    interface Elavon3DS2Model extends Insite.Core.WebApi.BaseModel {
        elavon3DS2: LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels.Elavon3DS2Model[];
    }

    interface Elavon3DS2Model {
        dsTransID: string;
        eci: string;
        authenticationValue: string;
        programProtocol: string;
    }

    interface ElavonErrorLogModel extends Insite.Core.WebApi.BaseModel {
        elavonErrorLogs: LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels.ElavonErrorLogModel[];
    }
    interface ElavonErrorLogModel {
        elavonResponse: string;
        customerNumber: string;     
        errorMessage: string;
        erroLogResponse: string;
        elavonResponseFor: string;
        saveElavonResponse: boolean;
    }
}

declare module LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels {
    interface RegistrationModel extends Insite.Core.WebApi.BaseModel {
        firstName: string;
        lastName: string;
        email: string;
        uniqueOrClock: string;
    }
    interface RegistrationResultModel extends Insite.Core.WebApi.BaseModel {
        isRegistered: boolean;
        errorMessage: string;
    }
}
declare module LeggettAndPlatt.Extensions.Modules.VertexAddressValidation.WebApi.V2.ApiModels {

    interface AddressValidationResponseModel extends Insite.Core.WebApi.BaseModel {
        addressSuggestions: AddressSuggestion[];
        requestAddress: AddressSuggestion;
        errorMessage: string;
        exceptionMsg: string;
        responseTime: string;
    }
    interface AddressValidationRequestModel extends Insite.Core.WebApi.BaseModel {
        streetAddress1: string;
        streetAddress2: string;
        city: string;
        stateId: string;
        county: string;
        countryId: string;
        postalCode: string;
    }
    interface AddressSuggestion extends Insite.Core.WebApi.BaseModel {
        streetAddress1: string;
        streetAddress2: string;
        city: string;
        state: Insite.Websites.WebApi.V1.ApiModels.StateModel;
        country: Insite.Websites.WebApi.V1.ApiModels.CountryModel;
        county: string;
        postalCode: string;
        isRequestedAddress: boolean;
    }
}
declare module LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels {
    interface CustomPropertyRequestModel extends Insite.Core.WebApi.BaseModel {
        objectName: string;
        propertyName: string;
        propertyValue: string;
    }
    interface CustomPropertyResponseModel extends Insite.Core.WebApi.BaseModel {
        result: boolean;
    }
}