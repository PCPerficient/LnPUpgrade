using Insite.Core.Interfaces.Data;
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
using System.Data.SqlClient;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.PIM
{
    [DependencyName("BulkInsertPIMTables")]
    public class JobPostProcessorBulkInsertPIMTables : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {
        protected readonly IUnitOfWork UnitOfWork;

        public JobPostProcessorBulkInsertPIMTables(IUnitOfWorkFactory unitOfWorkFactory)
        {
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
        }

        public IntegrationJob IntegrationJob { get; set; }

        public IJobLogger JobLogger { get; set; }

        public void Cancel()
        {
        }

        public void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            TruncatePIMTempTables();

            if (dataSet.Tables.Count > 0)
            {               

                foreach (JobDefinitionStep jobDefinitionStep in (IEnumerable<JobDefinitionStep>)this.IntegrationJob.JobDefinition.JobDefinitionSteps.OrderBy<JobDefinitionStep, int>((Func<JobDefinitionStep, int>)(s => s.Sequence)))
                {
                    JobDefinitionStep step = jobDefinitionStep;
                    string dataTableName = step.Sequence + step.ObjectName;
                    if (dataSet.Tables.Contains(dataTableName))
                    {
                        string columns = GetTableColumn(step.SelectClause);
                        CreatePIMTable(step.ObjectName, columns);
                        ImportDataTable(dataSet.Tables[dataTableName], step.ObjectName);
                    }
                }
            }

        }


        private void CreatePIMTable(string tableName, string columns)
        {
            string cmd = @"
                    IF EXISTS
                    (
                        SELECT *
                        FROM
                            sys.schemas s
                                INNER JOIN sys.tables t ON
                                    t.[schema_id] = s.[schema_id]
                        WHERE
                            s.name = 'dbo' AND
                            t.name = '" + tableName + @"'
                    )
                    BEGIN
                        DROP TABLE dbo." + tableName + @"
                    END;
                    IF NOT EXISTS
                    (
                        SELECT *
                        FROM
                            sys.schemas s
                                INNER JOIN sys.tables t ON
                                    t.[schema_id] = s.[schema_id]
                        WHERE
                            s.name = 'dbo' AND
                            t.name = '" + tableName + @"'
                    )
                    BEGIN
                        CREATE TABLE dbo." + tableName + @"
                        (
                            " + columns + @"
                        );
                    END";

            this.UnitOfWork.DataProvider.SqlExecuteNonQuery(cmd);

        }
        private void ImportDataTable(DataTable dt, string tableName)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["InSite.Commerce"].ConnectionString;
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlBulkCopy bulkCopy = new SqlBulkCopy(connection))
            {
                connection.Open();
                bulkCopy.DestinationTableName = "dbo." + tableName;

                bulkCopy.WriteToServer(dt);
            }
        }

        private string GetTableColumn(string columns)
        {
            string columnName = string.Empty;
            if (!string.IsNullOrEmpty(columns))
            {
                string[] columnArray = columns.Split(',');
                foreach (var item in columnArray)
                {
                    columnName = columnName + "[" +item + "] nvarchar(MAX) NULL,";
                }
                columnName = columnName.TrimEnd(',');
            }
            return columnName;
        }

        private void TruncatePIMTempTables()
        {
            this.JobLogger.Info("Stored Procedure PRFTTruncatePIMTempTables Start.");
            this.UnitOfWork.DataProvider.SqlExecuteStoredProcedure("PRFTTruncatePIMTempTables", null, 3600);
            this.JobLogger.Info("Stored Procedure PRFTTruncatePIMTempTables End.");
        }
    }
}
