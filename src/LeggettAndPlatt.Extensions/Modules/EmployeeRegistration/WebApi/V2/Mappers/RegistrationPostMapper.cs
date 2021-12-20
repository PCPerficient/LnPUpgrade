using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.Mappers.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.Mappers
{
    public class RegistrationPostMapper : IRegistrationPostMapper, IDependency, IExtension
    {
        private const int uniqueLength = 7;

        public RegistrationParameter MapParameter(RegistrationModel apiParameter, HttpRequestMessage request)
        {
            RegistrationParameter registrationParameter = new RegistrationParameter();
            registrationParameter.FirstName = apiParameter.FirstName;
            registrationParameter.LastName = apiParameter.LastName;
            registrationParameter.Email = apiParameter.Email;
            registrationParameter.Unique = string.Empty;
            registrationParameter.Clock = string.Empty;
            if (!string.IsNullOrEmpty(apiParameter.UniqueOrClock))
            {
                if(apiParameter.UniqueOrClock.Length == uniqueLength)
                {
                    registrationParameter.Unique = apiParameter.UniqueOrClock;
                }
                else
                {
                    registrationParameter.Clock = apiParameter.UniqueOrClock;
                }
            }
            return registrationParameter;
        }

        public RegistrationResultModel MapResult(RegistrationResult serviceResult, HttpRequestMessage request)
        {
            RegistrationResultModel model = new RegistrationResultModel();
            model.IsRegistered = serviceResult.IsRegistered;
            model.ErrorMessage = serviceResult.ErrorMessage;
            return model;
        }
    }
}
