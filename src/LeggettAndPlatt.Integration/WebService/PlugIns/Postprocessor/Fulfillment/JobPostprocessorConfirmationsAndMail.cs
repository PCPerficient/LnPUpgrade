using Insite.Core.Interfaces.Dependency;
using Insite.Integration.WebService.Interfaces;
using System;
using Insite.Data.Entities;
using System.Data;
using System.Threading;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Interfaces.Data;
using Insite.Integration.WebService.SystemSettings;
using LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Helpers;
using LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment.Common;
using System.Linq;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Fulfillment
{
    [DependencyName("LNPJobPostprocessorConfirmationsAndMail")]
    public class JobPostprocessorConfirmationsAndMail : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {
        protected readonly IEmailService EmailService;
        protected readonly IUnitOfWorkFactory UnitOfWorkFactory;
        protected readonly IJobLoggerFactory JobLoggerFactory;
        protected readonly IntegrationGeneralSettings IntegrationGeneralSettings;
        ConcreateConfirmationAndMailing confirmationAndMailing;
        ConcreateShipmentAndMailing shipmentAndMailing;
        ConcreateCancellationAndMailing cancellationAndMailing;

        public JobPostprocessorConfirmationsAndMail(IUnitOfWorkFactory unitOfWorkFactory, IEmailService emailService, IJobLoggerFactory jobLoggerFactory, IntegrationGeneralSettings integrationGeneralSettings)
        {
            this.UnitOfWorkFactory = unitOfWorkFactory;
            this.EmailService = emailService;
            this.JobLoggerFactory = jobLoggerFactory;
            this.IntegrationGeneralSettings = integrationGeneralSettings;
            confirmationAndMailing = new ConcreateConfirmationAndMailing();
            shipmentAndMailing = new ConcreateShipmentAndMailing();
            cancellationAndMailing = new ConcreateCancellationAndMailing();
        }

        #region Public Jobs
        public IntegrationJob IntegrationJob
        {
            get; set;
        }

        public IJobLogger JobLogger
        {
            get; set;
        }

        #endregion

        #region Actions
        public void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            this.JobLogger = this.JobLoggerFactory.GetJobLogger(this.IntegrationJob.Id, this.UnitOfWorkFactory, this.IntegrationGeneralSettings);
            IUnitOfWork unitOfWork = this.UnitOfWorkFactory.GetUnitOfWork();

            this.JobLogger.Info("OMS Mails Jobs Started");

            foreach (DataTable dataTable in dataSet.Tables)
            {
                var distinctOrders = dataTable.AsEnumerable()
                    .Select(s => new
                    {
                        id = s.Field<string>("OrderNumber"),
                    })
                    .Distinct().ToList();

                if (dataTable.TableName.ToLower().Equals(ConstantsUtil.OrderConfirmationTableName.ToLower()))
                {
                    this.JobLogger.Info("OMS Mails Jobs Started For Order Confirmation, Time Started: " + DateTime.Now);
                    foreach (var order in distinctOrders)
                    {
                        DataTable orderDataTable = GetOrderTableById(dataTable, order.id);
                        if (orderDataTable != null && orderDataTable.Rows.Count > 0)
                        {
                            var emailObject = confirmationAndMailing.BuildExpandoObject(this.JobLogger, orderDataTable);
                            var emailListName = UtilHelper.GetEmailListNameFromJobSteps(emailObject, this.IntegrationJob, JobStepNames.OrderConfirmation.ToString());

                            if (!string.IsNullOrEmpty(emailListName))
                                confirmationAndMailing.SendMail(this.JobLogger, this.EmailService, unitOfWork, emailObject, emailListName);
                        }
                    }
                    this.JobLogger.Info("OMS Mails Jobs Completed For Order Confirmation, Time Ended: " + DateTime.Now);
                }
                else if (dataTable.TableName.ToLower().Equals(ConstantsUtil.ShipmentTableName.ToLower()))
                {
                    this.JobLogger.Info("OMS Mails Jobs Started For Shipment, Time Started: " + DateTime.Now);
                    foreach (var order in distinctOrders)
                    {
                        DataTable orderDataTable = GetOrderTableById(dataTable, order.id);
                        if (orderDataTable != null && orderDataTable.Rows.Count > 0)
                        {
                            var emailObject = shipmentAndMailing.BuildExpandoObject(this.JobLogger, orderDataTable);
                            var emailListName = UtilHelper.GetEmailListNameFromJobSteps(emailObject, this.IntegrationJob, JobStepNames.Shipment.ToString());

                            if (!string.IsNullOrEmpty(emailListName))
                                shipmentAndMailing.SendMail(this.JobLogger, this.EmailService, unitOfWork, emailObject, emailListName);
                        }
                    }
                    this.JobLogger.Info("OMS Mails Jobs Completed For Shipment , Time Ended: " + DateTime.Now);
                }
                else if (dataTable.TableName.ToLower().Equals(ConstantsUtil.OrderCancellationTableName.ToLower()))
                {
                    this.JobLogger.Info("OMS Mails Jobs Started For Order Cancellation , Time Started: " + DateTime.Now);
                    foreach (var order in distinctOrders)
                    {
                        DataTable orderDataTable = GetOrderTableById(dataTable, order.id);
                        if (orderDataTable != null && orderDataTable.Rows.Count > 0)
                        {
                            var emailObject = cancellationAndMailing.BuildExpandoObject(this.JobLogger, orderDataTable);
                            var emailListName = UtilHelper.GetEmailListNameFromJobSteps(emailObject, this.IntegrationJob, JobStepNames.OrderCancellation.ToString());

                            if (!string.IsNullOrEmpty(emailListName))
                                cancellationAndMailing.SendMail(this.JobLogger, this.EmailService, unitOfWork, emailObject, emailListName);
                        }

                    }
                    this.JobLogger.Info("OMS Mails Jobs Completed For Order Cancellation, Time Ended: " + DateTime.Now);
                }
            }
            this.JobLogger.Info("OMS Mails Jobs end");
        }
        private DataTable GetOrderTableById(DataTable dt, string orderId)
        {
            DataTable orderDataTable = new DataTable();
            DataRow[] dataRows = dt.Select($"OrderNumber='{ orderId}'");
            if (dataRows.Count() > 0)
            {
                orderDataTable = dataRows.CopyToDataTable();
            }
            return orderDataTable;
        }


        public void Cancel()
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}
