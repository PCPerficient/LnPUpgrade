using Insite.Data.Entities;
using System;
using System.Linq;

namespace LeggettAndPlatt.Extensions.Common
{
    public class CustomPropertyHelper
    {
        public string GetCustomerOrderCustomProperty(string propertyName, CustomerOrder customerorder)
        {
            string customPropertyValue = string.Empty;
            CustomProperty customProperty = customerorder.CustomProperties.FirstOrDefault(c => c.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null && !string.IsNullOrEmpty(customProperty.Value))
            {
                customPropertyValue = customProperty.Value;
            }
            return customPropertyValue;
        }
    }
}
