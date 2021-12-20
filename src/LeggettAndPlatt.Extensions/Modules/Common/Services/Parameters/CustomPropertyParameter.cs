using Insite.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Modules.Common.Services.Parameters
{
    public class CustomPropertyParameter : ParameterBase
    {
        public string ObjectName { get; set; }
        public string PropertyName { get; set; }
        public string PropertyValue { get; set; }
    }
}
