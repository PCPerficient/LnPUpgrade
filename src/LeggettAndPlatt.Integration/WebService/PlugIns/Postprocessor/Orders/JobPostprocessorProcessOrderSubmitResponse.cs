using Insite.Core.Interfaces.Dependency;
using Insite.Integration.WebService.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Data.Entities;
using System.Data;
using System.Threading;
using Insite.Core.Interfaces.Data;
using LeggettAndPlatt.Integration.Common;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Orders
{
    [DependencyName("ProcessOrderSubmitResponse")]
    public class JobPostprocessorProcessOrderSubmitResponse : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {
        protected readonly IUnitOfWork UnitOfWork;

        public JobPostprocessorProcessOrderSubmitResponse(IUnitOfWorkFactory unitOfWorkFactory)
        {
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
        }

        public IJobLogger JobLogger { get; set; }

        public IntegrationJob IntegrationJob { get; set; }


        public void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            this.ProcessOrderSubmit(dataSet);
            this.UnitOfWork.Save();
        }

        public void Cancel()
        {

        }

        protected virtual void ProcessOrderSubmit(DataSet dataSet)
        {
            if (!dataSet.Tables.Contains("OrderSubmit"))
                return;
            string orderId = dataSet.Tables["OrderSubmit"].Rows[0]["Id"].ToString();
            CustomerOrder customerOrder = this.UnitOfWork.GetRepository<CustomerOrder>().Get(orderId);
            if (customerOrder == null)
            {
                this.JobLogger.Info("No order found with order id " + orderId);
            }
            else
            {
                var customProperty = customerOrder.CustomProperties.FirstOrDefault(x => x.Name.Equals(OrderCustomPropertyConstant.isOrderSendToFtp, StringComparison.InvariantCultureIgnoreCase));
                if (customProperty != null)
                {
                    customProperty.Value = "true";
                }
                else {
                    customerOrder.SetProperty("isOrderSendToFtp", "true");
                }
                this.JobLogger.Info($"Order property {OrderCustomPropertyConstant.isOrderSendToFtp} set sucessfully");
            }
        }
    }
}
