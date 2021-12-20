using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters
{
    public class ElavonErrorLogParameter : ParameterBase
    {
        public string ResponseMessage { get; set; }
        public string ElavonResponse { get; set; }
        public string ElavonResponseFor { get; set; }
        public string CustomerNumber { get; set; }       
        public string ErrorMessage { get; set; }
        public bool saveElavonResponse { get; set; }

    }
}