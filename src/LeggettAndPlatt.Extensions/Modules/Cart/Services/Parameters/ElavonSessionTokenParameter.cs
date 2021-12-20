using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Parameters
{
    public class ElavonSessionTokenParameter : ParameterBase
    {
        public string ElavonToken { get; set; }

        public Dictionary<string, string> ElavonResponseCodes { get; set; }

    }
}
