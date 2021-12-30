using Insite.Core.Interfaces.Data;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Entities;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;

namespace LeggettAndPlatt.Extensions.Common
{
    public class EmpRegistrationHelper
    {
        /// <summary>
        /// Validates Employee After LookUp In LNP_Employee Entity
        /// </summary>
        /// <param name="unitOfWork"></param>
        /// <param name="parameter"></param>
        /// <param name="registrationResult"></param>
        /// <returns></returns>
        public static bool IsUserValidEmployee(IUnitOfWork unitOfWork, RegistrationParameter parameter, out RegistrationResult registrationResult, bool isResetPasswordPage = false)
        {
            EmployeeSettings settings = new EmployeeSettings();
            registrationResult = new RegistrationResult();
            string uniqueOrClockId = !string.IsNullOrEmpty(parameter.Clock) ? parameter.Clock : parameter.Unique;
            if (isResetPasswordPage && uniqueOrClockId.Equals("DO NOT REMOVE", StringComparison.InvariantCultureIgnoreCase))
            {
                return true;
            }

            IEnumerable<LPEmployee> lnpEmployeeList = unitOfWork.GetRepository<LPEmployee>().GetTable().ToList().Where(x => (x.ClockNumber.Equals(uniqueOrClockId, StringComparison.InvariantCultureIgnoreCase) || x.UniqueIdNumber.Equals(uniqueOrClockId, StringComparison.InvariantCultureIgnoreCase)) && x.LastName.Equals(parameter.LastName, StringComparison.InvariantCultureIgnoreCase));

            if (lnpEmployeeList.Any())
                return true;
            else
            {
                registrationResult.IsRegistered = false;
                SetEmpRedirectUrlProperty(registrationResult, EmpRegistrationConstantsHelper.RegistrationRedirectUrl, settings.ContactCustomerServiceUrl);
                return false;
            }
        }

        /// <summary>
        /// Set Employee Redirect Property
        /// </summary>
        /// <param name="registrationResult"></param>
        /// <param name="propertyName"></param>
        /// <param name="propertyValue"></param>
        public static void SetEmpRedirectUrlProperty(RegistrationResult registrationResult, string propertyName, string propertyValue)
        {
            if (registrationResult.Properties.ContainsKey(propertyName)) return;

            registrationResult.Properties.Add(propertyName, propertyValue);
        }
    }

    public class EmpRegistrationConstantsHelper
    {
        public const string RegistrationRedirectUrl = "registrationRedirectUrl";
    }
}
