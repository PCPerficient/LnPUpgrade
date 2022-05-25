using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Core.Services;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Results
{
    public class ElavonSessionTokenResult : ResultBase
    {
        public string ElavonToken { get; set; }

        public Dictionary<string, string> ElavonResponseCodes { get; set; }

        public string ElavonAcceptAVSResponseCode { get; set; }

        public string ElavonAcceptCVVResponseCode { get; set; }

        public string ElavonTransactionType { get; set; }

        public Dictionary<string, string> Elavon3DS2ErrorCodes { get; set; }
        public Dictionary<string, string> ElavonAVSResponseCodes { get; set; }
    }
}
