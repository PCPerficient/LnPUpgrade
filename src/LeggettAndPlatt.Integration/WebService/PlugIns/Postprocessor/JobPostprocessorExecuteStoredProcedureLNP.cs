using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Data.Entities;
using Insite.Integration.WebService.Extensions;
using Insite.Integration.WebService.Interfaces;
using Insite.Integration.WebService.Resources;
using System;
using System.Collections.ObjectModel;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor
{
    /// <summary>Executes the stored procedure that is specified in the JobDefinitionParameters named StoredProcedureName.</summary>
    [DependencyName("ExecuteStoredProcedureLNP")]
    class JobPostprocessorExecuteStoredProcedureLNP : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {
        /// <summary>Injected in <see cref="T:Insite.Core.Interfaces.Data.IUnitOfWork" />.</summary>
        protected readonly IUnitOfWork UnitOfWork;

        /// <summary>Initializes a new instance of the <see cref="T:Insite.Integration.WebService.PlugIns.Postprocessor.JobPostprocessorExecuteStoredProcedure" /> class. Public constructor with all dependencies injected in.</summary>
        /// <param name="unitOfWorkFactory">The unit Of Work Factory.</param>
        public JobPostprocessorExecuteStoredProcedureLNP(IUnitOfWorkFactory unitOfWorkFactory)
        {
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
        }

        /// <summary>Gets or sets the job logger.</summary>
        public IJobLogger JobLogger { get; set; }

        /// <summary>Gets or sets the integration job.</summary>
        public IntegrationJob IntegrationJob { get; set; }

        /// <summary>Executes the stored procedure that is specified in the JobDefinitionParameters named StoredProcedureName.</summary>
        /// <param name="dataSet">The dataset.</param>
        /// <param name="cancellationToken">The cancellation Token.</param>
        public virtual void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            string storedProcedureName = this.GetParameter(this.IntegrationJob, "StoredProcedureName");
            if (string.IsNullOrEmpty(storedProcedureName))
                throw new ArgumentException("InvalidParameterName: StoredProcedureName");

        
            Collection<IDbDataParameter> iDbDataParameter = new Collection<IDbDataParameter>();
            var jobParameters = this.GetJobParameterList();
            foreach (var jobParameter in jobParameters)
            {
                IDbDataParameter dbDataParameter = new SqlParameter
                {
                    DbType = DbType.String,
                    ParameterName = "@"+ jobParameter.JobDefinitionParameter.Name,
                    Value = GetJobParameterValue(jobParameter)
                };
                iDbDataParameter.Add(dbDataParameter);
            }
                  
            this.JobLogger.Info("StartingStoredProcedure:" + storedProcedureName);
            this.UnitOfWork.DataProvider.SqlExecuteStoredProcedure(storedProcedureName, iDbDataParameter, 3600);
            this.JobLogger.Info("StartingStoredProcedure:" + storedProcedureName);
        }
        private IntegrationJobParameter[] GetJobParameterList()
        {
     
            IntegrationJobParameter[] integrationJobParameters = this.IntegrationJob.IntegrationJobParameters.Where(
                x => x.JobDefinitionParameter != null && x.JobDefinitionParameter.Name != "StoredProcedureName"
                ).ToArray();

            return integrationJobParameters;

        }

        private string GetJobParameterValue(IntegrationJobParameter jobParameter)
        {
            string parameterValue = null;
            switch (jobParameter.JobDefinitionParameter.Name)
            {
                case "IntegrationJobId":
                    parameterValue = this.IntegrationJob.Id.ToString();
                    break;               
                default:
                    parameterValue = jobParameter.Value.ToString();
                    break;
            }

            return parameterValue;
        }
        /// <summary>The cancel.</summary>
        public void Cancel()
        {
        }
    }
}
