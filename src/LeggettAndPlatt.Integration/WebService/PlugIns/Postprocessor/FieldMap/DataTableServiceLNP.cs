using Insite.Integration.WebService.PlugIns.Postprocessor.FieldMap;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Insite.Integration.WebService.Interfaces;
using Insite.Data.Entities;
using System.Collections.ObjectModel;
using System.Data;
using Insite.Integration.WebService.PlugIns.Postprocessor.FieldMap.Interfaces;
using System.Threading;
using Insite.Core.Interfaces.Data;
using Insite.Data;
using Insite.Integration.WebService;
using Insite.Integration.Enums;
using Insite.Core.ApplicationDictionary;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.FieldMap
{
    public class DataTableServiceLNP : DataTableService
    {
        private static readonly object StatisticsLock = new object();
        public DataTableServiceLNP(Insite.Core.Interfaces.Data.IUnitOfWorkFactory unitOfWorkFactory, Insite.Integration.WebService.PlugIns.Postprocessor.FieldMap.Interfaces.IContentFieldTypeMapper contentFieldTypeMapper, IJobLoggerFactory jobLoggerFactory, Insite.Core.Interfaces.Plugins.Security.IAuthenticationService authenticationService, Insite.Core.ApplicationDictionary.IEntityDefinitionProvider entityDefinitionProvider, Insite.Integration.WebService.SystemSettings.IntegrationGeneralSettings integrationGeneralSettings) : base(unitOfWorkFactory, contentFieldTypeMapper, jobLoggerFactory, authenticationService, entityDefinitionProvider, integrationGeneralSettings)
        {
        }

        public override void ProcessDataTable(int threadNumber, JobDefinitionStep jobDefinitionStep, Collection<string> naturalKeys, Type entityType, DataTable table, int startRow, int pageSize, IProcessedRecordService processedRecordService, Guid integrationJobId, CancellationToken cancellationToken)
        {
            try
            {
                this.IntegrationJobId = integrationJobId;
                this.JobLogger = this.JobLoggerFactory.GetJobLogger(this.IntegrationJobId, this.UnitOfWorkFactory, this.IntegrationGeneralSettings);
                if (!entityType.Name.Equals("LPEmployee"))
                {
                    this.EntityDefinitionDto = this.EntityDefinitionProvider.GetByName(entityType.Name, (string)null);
                }
                this.ProcessingPageSize = this.IntegrationGeneralSettings.ProcessingBatchSize;
                IRepository untypedRepository = this.GetUntypedRepository(entityType);
                int index = 0;
                this.SetupPropertyCaches(jobDefinitionStep, table, entityType);
                this.SetTimeZone(jobDefinitionStep);
                this.JobLogger.Info(string.Format("Thread {0} starting for rows {1} to {2}", (object)threadNumber, (object)(startRow + 1), (object)(startRow + pageSize)), jobDefinitionStep);
                int count = table.Rows.Count;
                this.UnitOfWork.DataProvider.SetConfiguration((IDataProviderConfiguration)new DataProviderConfiguration(this.UnitOfWork.DataProvider.GetConfiguration())
                {
                    ChangeTrackingEnabled = false
                });
                if (count > 0)
                    this.ReadAndCachePageOfEntities((IList<JobDefinitionStepFieldMap>)jobDefinitionStep.JobDefinitionStepFieldMaps.ToList<JobDefinitionStepFieldMap>(), naturalKeys, entityType, table, index, count, untypedRepository);
                try
                {
                    int errorCount = 0;
                    this.SaveEachRow = false;
                    while (index < count)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            DataRow row = table.Rows[index];
                            bool flag = row.RowState == DataRowState.Deleted;
                            Guid? nullable;
                            try
                            {
                                nullable = this.ProcessDataRow(untypedRepository, naturalKeys, jobDefinitionStep, entityType, row, threadNumber, index);
                            }
                            catch (LoggingThresholdReachedException ex)
                            {
                                break;
                            }
                            if (nullable.HasValue)
                                processedRecordService.InsertIntoRecordTrackingTable(nullable.Value, flag ? new Guid?() : nullable);
                            else
                                ++errorCount;
                            ++index;
                            if (index % this.ProcessingPageSize == 0 || index == count)
                            {
                                index = this.ProcessPageBreak(jobDefinitionStep, threadNumber, count, index, errorCount);
                                if (index < count)
                                    this.ReadAndCachePageOfEntities((IList<JobDefinitionStepFieldMap>)jobDefinitionStep.JobDefinitionStepFieldMaps.ToList<JobDefinitionStepFieldMap>(), naturalKeys, entityType, table, index, count, untypedRepository);
                            }
                        }
                        else
                            break;
                    }
                }
                finally
                {
                    lock (DataTableServiceLNP.StatisticsLock)
                        this.UpdateRecordStatistics();
                }
                if (cancellationToken.IsCancellationRequested)
                {
                    this.JobLogger.Info(string.Format("Thread {0} canceled at row {1}", (object)threadNumber, (object)index), jobDefinitionStep);
                    this.UnitOfWork.Close();
                    cancellationToken.ThrowIfCancellationRequested();
                }
                this.UnitOfWork.Close();
                GC.Collect();
            }
            catch (Exception ex)
            {
                this.JobLogger.Error(ExceptionMessageHelper.GetFullErrorMessage(ex), jobDefinitionStep);
            }
        }

        protected override void SetupPropertyCaches(JobDefinitionStep jobDefinitionStep, DataTable table, Type entityType)
        {
            foreach (JobDefinitionStepFieldMap definitionStepFieldMap in (IEnumerable<JobDefinitionStepFieldMap>)jobDefinitionStep.JobDefinitionStepFieldMaps)
            {
                JobDefinitionStepFieldMap map = definitionStepFieldMap;
                if (map.FieldType == IntegrationFieldType.Field.ToString() && !table.Columns.Contains(map.FromProperty))
                    throw new ArgumentException(string.Format("The source DataTable did not contain a column named: {0}.", (object)map.FromProperty));
                if (!entityType.Name.Equals("LPEmployee"))
                {
                    PropertyDefinitionDto propertyDefinitionDto = this.EntityDefinitionDto.Properties.FirstOrDefault<PropertyDefinitionDto>((Func<PropertyDefinitionDto, bool>)(o => o.Name.EqualsIgnoreCase(map.ToProperty)));
                    string key = entityType.Name + map.ToProperty;
                    if (!this.IsCustomPropertyCache.ContainsKey(key))
                        this.IsCustomPropertyCache[key] = propertyDefinitionDto != null && propertyDefinitionDto.IsCustomProperty;
                    if (!this.PropertyTypeCache.ContainsKey(key))
                        this.PropertyTypeCache[key] = propertyDefinitionDto?.PropertyType;
                }

                if (entityType.Name.Equals("LPEmployee"))
                {
                    string key = entityType.Name + map.ToProperty;
                    if (!this.IsCustomPropertyCache.ContainsKey(key))
                        this.IsCustomPropertyCache[key] = false;
                  
                   if (!this.PropertyTypeCache.ContainsKey(key))
                    {
                        switch (map.ToProperty)
                        {
                            case "FirstName":
                                this.PropertyTypeCache[key] =typeof(string);
                                break;
                            case "LastName":
                                this.PropertyTypeCache[key] = typeof(string);
                                break;
                            case "UniqueIdNumber":
                                this.PropertyTypeCache[key] = typeof(int);
                                break;
                            case "ClockNumber":
                                this.PropertyTypeCache[key] = typeof(string);
                                break;
                            default:
                                break;
                        }
                    }
                        
                }
            }
        }


    }
}
