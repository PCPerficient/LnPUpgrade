using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Core.WebApi;


namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels
{
    public class ElavonSessionTokenModel : BaseModel
    {
        public string ElavonToken { get; set; }

        public Dictionary<string, string> ElavonResponseCodes { get; set; }

        public string ElavonAcceptAVSResponseCode { get; set; }

        public string ElavonAcceptCVVResponseCode { get; set; }

        public string ElavonTransactionType { get; set; }     

    }
}
