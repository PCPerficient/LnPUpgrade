using Insite.Core.Enums;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Integration;
using Insite.Data.Entities;
using Insite.Data.Repositories.Interfaces;
using Insite.Integration.WebService.Interfaces;
using LeggettAndPlatt.Integration.Common;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Orders
{
    /// <summary>The job postprocessor resubmit all orders.</summary>
    [DependencyName("LNPResubmitFailedOrders")]
    public class JobPostprocessorLNPResubmitFailedOrders : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {
        /// <summary>The integration job scheduling service.</summary>
        protected readonly IIntegrationJobSchedulingService IntegrationJobSchedulingService;
        /// <summary>The unit of work.</summary>
        protected readonly IUnitOfWork UnitOfWork;

        /// <summary>Initializes a new instance of the <see cref="T:Insite.Integration.WebService.PlugIns.Postprocessor.JobPostprocessorResubmitAllOrders" /> class.</summary>
        /// <param name="unitOfWorkFactory">The unit Of Work Factory.</param>
        /// <param name="integrationJobSchedulingService">The integration job scheduling service.</param>
        public JobPostprocessorLNPResubmitFailedOrders(IUnitOfWorkFactory unitOfWorkFactory, IIntegrationJobSchedulingService integrationJobSchedulingService)
        {
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.IntegrationJobSchedulingService = integrationJobSchedulingService;
        }

        /// <summary>Gets or sets the job logger.</summary>
        public IJobLogger JobLogger { get; set; }

        /// <summary>Gets or sets the integration job.</summary>
        public IntegrationJob IntegrationJob { get; set; }

        /// <summary>The execute.</summary>
        /// <param name="dataSet">The data set.</param>
        /// <param name="cancellationToken">The cancellation Token.</param>
        public virtual void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            //System.Diagnostics.Debugger.Launch();
            List<string> list = this.GetReSubmitCustomerOrderList();
            JobDefinition byStandardName = this.UnitOfWork.GetTypedRepository<IJobDefinitionRepository>().GetByStandardName(JobDefinitionStandardJobName.OrderSubmit.ToString());
            if (byStandardName == null)
                throw new Exception(string.Format("Unable to find a JobDefinition for {0}.", (object)JobDefinitionStandardJobName.OrderSubmit));
            foreach (string orderNumber in list)
            {
                this.JobLogger.Debug("Resubmitting order " + orderNumber);
                this.IntegrationJobSchedulingService.ScheduleBatchIntegrationJob(byStandardName.Name, (DataSet)null, (Collection<JobDefinitionStepParameter>)null, orderNumber, new DateTime?(), false);
            }
            this.JobLogger.Info("Resubmitted " + (object)list.Count + " orders.");
        }

        /// <summary>The cancel.</summary>
        public void Cancel()
        {
        }

        /// <summary>The get re submit customer order list.</summary>
        /// <returns>The <see cref="T:System.Collections.Generic.IEnumerable`1" />.</returns>
        protected virtual List<string> GetReSubmitCustomerOrderList()
        {
            var customerOrderTable = UnitOfWork.GetRepository<CustomerOrder>().GetTable().Where(order => order.Status == CustomerOrder.StatusType.Submitted);
            var customPropertyTable = UnitOfWork.GetRepository<CustomProperty>().GetTable().Where(property => property.Name == OrderCustomPropertyConstant.isOrderSendToFtp);
            List<string> orders = (from co in customerOrderTable
                                   join cp in customPropertyTable on co.Id equals cp.ParentId
                                   into rd
                                   from rt in rd.DefaultIfEmpty()
                                   where (co.Status == CustomerOrder.StatusType.Submitted &&
                                   !(from subcp in customPropertyTable where subcp.Name == OrderCustomPropertyConstant.isOrderSendToFtp && subcp.Value == "true" select subcp.ParentId).Contains(rt.ParentId)) || (rt.Name == OrderCustomPropertyConstant.isOrderSendToFtp && rt.Value != "true")
                                   orderby co.OrderNumber
                                   select co.OrderNumber).Distinct().ToList();
            
            return orders;
        }
    }
}
