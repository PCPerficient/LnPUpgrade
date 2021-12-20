using Insite.Core.WebApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Common.WebApi.V2.ApiModels
{
    public class CustomPropertyRequestModel : BaseModel
    {
        public string ObjectName { get; set; }
        public string PropertyName { get; set; }
        public string PropertyValue { get; set; }
    }
}
