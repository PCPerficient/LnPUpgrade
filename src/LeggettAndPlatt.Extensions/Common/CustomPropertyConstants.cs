using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Common
{
    public class CustomPropertyConstants
    {
        #region ProductCustomProperty
        public const string customPropertyNameVertaxBranch = "vertaxBranch";
        public const string customPropertyNameVertaxTaxAreaId = "vertaxTaxAreaId";
        public const string customPropertyNameVertaxLegalEntity = "vertaxLegalEntity";
        #endregion

        #region CustomerOrderCustomProperty
        public const string customPropertyNameIsTaxTBD = "isTaxTBD";
        public const string customPropertyNameIsAddressVerified = "isAddressVerified";
        public const string customPropertyNameBtFirstName = "btFirstName";
        public const string customPropertyNameBtLastName = "btLastName";
        public const string customPropertyNameStFirstName = "stFirstName";
        public const string customPropertyNameStLastName = "stLastName";

        #endregion

        #region OrderHisotryLineCustomProperty
        public const string customPropertyNameTaxAmount = "taxAmount";
        #endregion

        #region Customer/Shipping address custom properties
        public const string customPropertyNameVertexChecked = "vertexChecked";
        #endregion
        #region Custom propertie Object Name
        public const string customPropertyCustomerOrderObjectName = "CustomerOrder";
        public const string customPropertyCustomerObjectName = "Customer";
        #endregion
    }
}
