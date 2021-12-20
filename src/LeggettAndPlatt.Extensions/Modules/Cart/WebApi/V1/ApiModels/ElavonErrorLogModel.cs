using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels
{
    public class ElavonErrorLogModel : BaseModel
    {
        public string ElavonResponse { get; set; }
        public string ElavonResponseFor { get; set; }
        public string CustomerNumber { get; set; }
        public string CompanyName { get; set; }
        public string ErrorMessage { get; set; }
        public Boolean ErroLogResponse { get; set; }
        public bool saveElavonResponse { get; set; }
    }
}
