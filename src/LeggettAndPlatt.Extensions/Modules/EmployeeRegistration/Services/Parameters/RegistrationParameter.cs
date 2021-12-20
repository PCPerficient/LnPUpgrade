using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters
{
    public class RegistrationParameter : ParameterBase
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Unique { get; set; }
        public string Clock { get; set; }
    }
}
