using Insite.Cart.Services.Pipelines;
using Insite.Common.Extensions;
using Insite.Common.Providers;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Caching;
using Insite.Core.Plugins.Cart;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Plugins.Utilities;
using Insite.Core.SystemSetting.Groups.OrderManagement;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos;
using Insite.Plugins.Cart;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Extensions.Plugins.Cart
{
    [DependencyName("ByUser")]
    public class CartOrderProviderByUserDrift : CartOrderProviderByUser
    {
        public CartOrderProviderByUserDrift(ICookieManager cookieManager, IPerRequestCacheManager perRequestCacheManager, IUnitOfWorkFactory unitOfWorkFactory, ICustomerOrderUtilities customerOrderUtilities, ICartPipeline cartPipeline, CartSettings cartSettings)
            : base(cookieManager, perRequestCacheManager, unitOfWorkFactory, customerOrderUtilities, cartPipeline, cartSettings)
        {
        }

        /// <summary>The get customer order for not logged user.</summary>
        /// <returns>The <see cref="T:Insite.Data.Entities.CustomerOrder" />.</returns>
        protected override CustomerOrder GetCustomerOrderForNotLoggedUser()
        {
            //PRFT custom start.
            RemoveCookieForNotLoggedUser();
            //PRFT custom end.

            string id = this.CookieManager.Get(this.CartCookieName);
            if (!id.IsBlank())
            {
                // PRFT custom start.
                AddCookieForNotLoggedUser();
                //PRFT custom end.
                return this.UnitOfWork.GetRepository<CustomerOrder>().Get(id);
            }
            return (CustomerOrder)null;
        }
        protected override IQueryable<CustomerOrder> ApplyCustomerOrderBaseFilter(IQueryable<CustomerOrder> query)
        {
            DateTimeOffset minValidOrderDate = this.CartRetentionDays > 0 ? DateTimeProvider.Current.Now.AddDays((double)-this.CartRetentionDays) : DateTimeOffset.MinValue;
            UserProfileDto currentUserProfile = SiteContext.Current.UserProfileDto ?? SiteContext.Current.RememberedUserProfileDto;
            string id = this.CookieManager.Get("PunchOutSessionId");
            Guid? punchOutSessionCustomerOrderId = id.IsBlank() ? new Guid?() : this.UnitOfWork.GetRepository<PunchOutSession>().Get(id)?.CustomerOrderId;
            //PRFT custom code start.
            var customerOrderQuery = query.Where<CustomerOrder>((Expression<Func<CustomerOrder, bool>>)(co => co.WebsiteId == SiteContext.Current.WebsiteDto.Id && co.Customer.IsActive && co.ShipTo.IsActive && co.InitiatedByUserProfileId == (Guid?)currentUserProfile.Id && co.Type != "Job" && (co.Status == "Cart" && punchOutSessionCustomerOrderId == new Guid?() || co.Status == "PunchOut" && co.Id == punchOutSessionCustomerOrderId.Value) && co.OrderDate > minValidOrderDate));
           // var customerOrderQuery = query.Where<CustomerOrder>((Expression<Func<CustomerOrder, bool>>)(co => co.WebsiteId == SiteContext.Current.WebsiteDto.Id && co.Customer.IsActive && co.ShipTo.IsActive && co.InitiatedByUserProfileId == (Guid?)currentUserProfile.Id && co.Type != "Job" && (co.Status == "Cart" && !isPunchOutSession || co.Status == "PunchOut" && isPunchOutSession) && co.OrderDate > minValidOrderDate));
            SetAbandonedCartExistCookie(customerOrderQuery);
            //PRFT custom code end.
            return customerOrderQuery;
        }

        #region helper Method start.
        private bool RemoveCookieForNotLoggedUser()
        {
            bool result = true;
            this.CookieManager.Remove("IsAbandonedCartExistCookie");
            this.CookieManager.Remove("IsAbandonedCartLoggedOutOrderCookie");
            return result;
        }
        private bool AddCookieForNotLoggedUser()
        {
            bool result = true;
            this.CookieManager.Add("IsAbandonedCartLoggedOutOrderCookie", "true");
            return result;
        }
        private bool SetAbandonedCartExistCookie(IQueryable<CustomerOrder> customerOrderQuery)
        {
            bool result = false;

            int count = customerOrderQuery.Count();
            if (count > 0)
            {
                int orderLinesCount = customerOrderQuery.FirstOrDefault().OrderLines.Count();
                if (orderLinesCount > 0)
                {
                    string isAbandonedCartExistCookie = this.CookieManager.Get("IsAbandonedCartExistCookie");
                    string isAbandonedCartLoggedOutOrderCookie = this.CookieManager.Get("IsAbandonedCartLoggedOutOrderCookie");

                    if (string.IsNullOrEmpty(isAbandonedCartLoggedOutOrderCookie))
                    {
                        if (string.IsNullOrEmpty(isAbandonedCartExistCookie))
                        {
                            this.CookieManager.Add("IsAbandonedCartExistCookie", "true");
                            return true;
                        }
                    }
                    else
                        this.CookieManager.Add("IsAbandonedCartExistCookie", "false");
                }
            }
            else
                this.CookieManager.Add("IsAbandonedCartExistCookie", "false");

            return result;
        }
        

        #endregion helper method end.
    }
}
