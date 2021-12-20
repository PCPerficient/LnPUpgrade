using Insite.Account.Emails;
using Insite.Account.SystemSettings;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using LeggettAndPlatt.Extensions.Common;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Extensions.Entities;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Handlers;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Parameters;
using LeggettAndPlatt.Extensions.Modules.EmployeeRegistration.Services.Results;
using LeggettAndPlatt.Test.TestBaseHelper;
using Moq;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Test.Modules.EmployeeRegistration
{
    [TestFixture]
    class RegistrationTest : TestBase
    {
        private Registration registration;
        private RegistrationResult registrationResult;
        Guid Id;
        string userName = string.Empty;
        public override void SetUp()
        {
            var handlerFactory = new Mock<IHandlerFactory>();
            var accountActivationEmail = new Mock<IAccountActivationEmail>();
            var websiteUtilities = new Mock<IWebsiteUtilities>();
            var storefrontSecuritySettings = new Mock<StorefrontSecuritySettings>();
            var commonSettings = new Mock<CommonSettings>();
            var orderSettings = new Mock<OrderSettings>();
            var unitOfWorkFactory = new Mock<IUnitOfWorkFactory>();
            var emailHelper = new EmailHelper(commonSettings.Object, unitOfWorkFactory.Object, orderSettings.Object);

            var emailService = new Mock<IEmailService>();
            registrationResult = new RegistrationResult();
            Id = new Guid();

            registration = new Registration(handlerFactory.Object, accountActivationEmail.Object, websiteUtilities.Object, storefrontSecuritySettings.Object, emailHelper, commonSettings.Object, emailService.Object);
        }

        [TestCase]
        public void IsUserAlreadyExist_ReturnsTrue()
        {
            userName = "test123@gmail.com";
            fakeUnitOfWork.SetupEntityList(GetUserProfile());

            var output = typeof(Registration)
               .GetMethod("IsUserAlreadyExist", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(registration, new object[3] { fakeUnitOfWork, userName, registrationResult });

            Assert.That(output, Is.EqualTo(true));
        }
        [TestCase]
        public void IsUserAlreadyExist_ReturnsFalse()
        {
            userName = "test1234@gmail.com";
            fakeUnitOfWork.SetupEntityList(GetUserProfile());

            var output = typeof(Registration)
               .GetMethod("IsUserAlreadyExist", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(registration, new object[3] { fakeUnitOfWork, userName, registrationResult });

            Assert.That(output, Is.EqualTo(false));
        }
        [TestCase]
        public void IsActiveEmployee_ReturnsTrue()
        {
            fakeUnitOfWork.SetupEntityList(GetEmployee());
            RegistrationParameter parameter = GetRegistrationParameter();

            var output = typeof(Registration)
               .GetMethod("IsActiveEmployee", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(registration, new object[3] { fakeUnitOfWork, parameter, registrationResult });

            Assert.That(output, Is.EqualTo(true));
        }
        [TestCase]
        public void IsActiveEmployee_ReturnsFalse()
        {
            fakeUnitOfWork.SetupEntityList(GetEmployee());
            RegistrationParameter parameter = GetRegistrationParameter();
            parameter.Unique = "1234";
            var output = typeof(Registration)
               .GetMethod("IsActiveEmployee", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(registration, new object[3] { fakeUnitOfWork, parameter, registrationResult });

            Assert.That(output, Is.EqualTo(false));
        }
        [TestCase]
        public void AddUpdateUserProfileCustomProperty_Add()
        {
            fakeUnitOfWork.SetupEntityList(GetEmployee());
            RegistrationParameter parameter = GetRegistrationParameter();
            parameter.Unique = "1234";
            var output = typeof(Registration)
               .GetMethod("IsActiveEmployee", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(registration, new object[3] { fakeUnitOfWork, parameter, registrationResult });

            Assert.That(output, Is.EqualTo(false));
        }



        [Ignore]
        private List<UserProfile> GetUserProfile()
        {
            List<UserProfile> userProfileList = new List<UserProfile>();
            UserProfile userProfile = new UserProfile()
            {
                Id = this.Id,
                UserName = "test123@gmail.com"
            };
            userProfileList.Add(userProfile);
            return userProfileList;
        }
        [Ignore]
        private RegistrationParameter GetRegistrationParameter()
        {
            return new RegistrationParameter()
            {
                FirstName = "TOM",
                LastName = "JONES",
                Email = "test123@gmail.com",
                Unique = "1234567",
                Clock = string.Empty
            };
        }
        [Ignore]
        private List<LPEmployee> GetEmployee()
        {
            List<LPEmployee> employeeList = new List<LPEmployee>();
            LPEmployee employee = new LPEmployee()
            {
                FirstName = "TOM",
                LastName = "JONES",
                UniqueIdNumber = "1234567",
                ClockNumber = string.Empty
            };
            employeeList.Add(employee);
            return employeeList;
        }

    }
}
