using Insite.Core.WebApi;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels
{
    public class RegistrationResultModel : BaseModel
    {
        public bool IsRegistered { get; set; }
        public string ErrorMessage { get; set; }
    }
}
