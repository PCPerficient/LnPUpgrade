using Insite.Cart.Services.Pipelines;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Plugins.Caching;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Plugins.Utilities;
using Insite.Core.SystemSetting.Groups.OrderManagement;
using Insite.Data.Entities;
using LeggettAndPlatt.Extensions.Plugins.Cart;
using LeggettAndPlatt.Test.TestBaseHelper;
using Moq;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Test.Plugins.Cart
{
    [TestFixture]
    public class CartOrderProviderByUserDriftTest : TestBase
    {      
        private CartOrderProviderByUserDrift cartOrderProviderByUserDrift;
        Guid Id;

        public override void SetUp()
        {
            var cookieManager = new Mock<ICookieManager>();
            var perRequestCacheManager = new Mock<IPerRequestCacheManager>();
            var unitOfWorkFactory = new Mock<IUnitOfWorkFactory>();
            var customerOrderUtilities = new Mock<ICustomerOrderUtilities>();
            var cartPipeline = new Mock<ICartPipeline>();
            var cartSettings = new Mock<CartSettings>();
          
            Id = new Guid();
            cartOrderProviderByUserDrift = new CartOrderProviderByUserDrift(cookieManager.Object, perRequestCacheManager.Object, unitOfWorkFactory.Object, customerOrderUtilities.Object, cartPipeline.Object, cartSettings.Object);
        }

        [TestCase]
        public void RemoveCookieForNotLoggedUserTest()
        {
            var output = typeof(CartOrderProviderByUserDrift)
               .GetMethod("RemoveCookieForNotLoggedUser", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(cartOrderProviderByUserDrift, null);

            Assert.That(output, Is.EqualTo(true));
        }
        [TestCase]
        public void AddCookieForNotLoggedUsertTest()
        {
            var output = typeof(CartOrderProviderByUserDrift)
               .GetMethod("AddCookieForNotLoggedUser", BindingFlags.NonPublic | BindingFlags.Instance)
               .Invoke(cartOrderProviderByUserDrift, null);

            Assert.That(output, Is.EqualTo(true));
        }
        [TestCase]
        public void SetAbandonedCartExistCookieTest()
        {
            fakeUnitOfWork.SetupEntityList(GetCustomerOrder());
            IQueryable<CustomerOrder> customerOrderQuery = fakeUnitOfWork.GetRepository<CustomerOrder>().GetTable();

            var output = typeof(CartOrderProviderByUserDrift)
              .GetMethod("SetAbandonedCartExistCookie", BindingFlags.NonPublic | BindingFlags.Instance)
              .Invoke(cartOrderProviderByUserDrift, new object[1] { customerOrderQuery });
            Assert.AreEqual(true, true);
        }

        private List<CustomerOrder> GetCustomerOrder()
        {
            List<CustomerOrder> customerOrderList = new List<CustomerOrder>();
            CustomerOrder customerOrder = new CustomerOrder()
            {
                Id = Id,
                OrderLines = new List<OrderLine>() { new OrderLine() { Id = new Guid() } }
            };
            customerOrderList.Add(customerOrder);
            return customerOrderList;
        }
    }
}
