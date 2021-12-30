using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results
{
    public class RegistrationResult : ResultBase
    {
        public bool IsRegistered { get; set; }
        public string ErrorMessage { get; set; }
    }
}
