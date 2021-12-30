using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Cart.WebApi.V1.ApiModels
{
    public class ElavonTokenModel : BaseModel
    {
        public string Token { get; set; }

        public Dictionary<string, string> ElavonResponseCodes { get; set; }

    }
}
