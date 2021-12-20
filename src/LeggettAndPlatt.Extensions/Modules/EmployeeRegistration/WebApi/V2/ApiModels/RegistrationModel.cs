using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.WebApi.V2.ApiModels
{
    public class RegistrationModel : BaseModel
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string UniqueOrClock { get; set; }


    }
}
