using Insite.Common.Dependencies;
using Insite.Common.Helpers;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos;
using Insite.Integration.Enums;
using Insite.Integration.WebService;
using Insite.Integration.WebService.Interfaces;
using Insite.Integration.WebService.PlugIns.Postprocessor.FieldMap;
using Insite.Integration.WebService.PlugIns.Postprocessor.FieldMap.Interfaces;
using Insite.Integration.WebService.SystemSettings;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Threading;
using LeggettAndPlatt.Integration.Common;
using LeggettAndPlatt.FTP.RequestModel;
using LeggettAndPlatt.FTP;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.FieldMap
{
    [DependencyName("LNPFieldMap")]
    public class LNPFieldMap : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {
        private const int MinimumRowCountForThreading = 1000;
        private readonly IDeleteProcessor deleteProcessor;
        private readonly IUnitOfWork unitOfWork;
        private readonly IntegrationGeneralSettings integrationGeneralSettings;

        private string FTPHost;
        private string FTPUsername;
        private string FTPPassword;
        private string FTPPort;
        private string FTPDownloadRemoteDirectoryLocaltion;

        public LNPFieldMap(IUnitOfWorkFactory unitOfWorkFactory, IDeleteProcessor deleteProcessor, IntegrationGeneralSettings integrationGeneralSettings)
        {
            this.deleteProcessor = deleteProcessor;
            this.unitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.integrationGeneralSettings = integrationGeneralSettings;
        }

        public IJobLogger JobLogger { get; set; }

        public IntegrationJob IntegrationJob { get; set; }

        public void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            foreach (JobDefinitionStep jobDefinitionStep in (IEnumerable<JobDefinitionStep>)this.IntegrationJob.JobDefinition.JobDefinitionSteps.OrderBy<JobDefinitionStep, int>((Func<JobDefinitionStep, int>)(s => s.Sequence)))
            {
                try
                {
                    this.ProcessJobDefinitionStep(jobDefinitionStep, dataSet, cancellationToken);
                    this.ArchiveRemoteFiles();
                }
                catch (LoggingThresholdReachedException ex)
                {
                    throw;
                }
                catch (Exception ex)
                {
                    this.JobLogger.Error(string.Format("Aborting post processing due to exception: {0}", (object)ex.Message), jobDefinitionStep);
                    break;
                }
            }
        }

        public void ProcessJobDefinitionStep(JobDefinitionStep jobDefinitionStep, DataSet dataSet, CancellationToken cancellationToken)
        {
            JobDefinitionStep jobDefinitionStep1 = jobDefinitionStep;
            string objectName = jobDefinitionStep1.ObjectName;
            string index = string.Format((IFormatProvider)CultureInfo.InvariantCulture, "{0}{1}", new object[2]
            {
        (object) jobDefinitionStep1.Sequence,
        (object) jobDefinitionStep1.ObjectName
            });
            if (objectName.EqualsIgnoreCase("dataset"))
            {
                this.MapInToDataSet(jobDefinitionStep1, dataSet, index);
                this.unitOfWork.Save();
            }
            else if (!dataSet.Tables.Contains(index))
            {
                this.JobLogger.Info(string.Format("Unable to find the {0} table in the dataset returned from the Integration Processor.  Skipping this step.", (object)index), jobDefinitionStep);
            }
            else
            {
                DataTable table = dataSet.Tables[index];
                Type modelType = this.GetModelType(objectName);
                if (modelType == (Type)null)
                    throw new ArgumentException(string.Format("Invalid Target Object ({0}) found.", (object)objectName));
                Collection<string> naturalKeys = LNPFieldMap.GetNaturalKeys(jobDefinitionStep1.JobDefinitionStepFieldMaps, modelType);
                if (naturalKeys == null || naturalKeys.Count == 0)
                    throw new ArgumentException(string.Format("Target Object ({0}) has no natural keys.", (object)objectName));
                using (IProcessedRecordService processedRecordService = this.CreateProcessedRecordService(jobDefinitionStep1))
                {
                    this.JobLogger.Info(string.Format("Starting transcription for {0} rows.", (object)table.Rows.Count), jobDefinitionStep1);
                    processedRecordService.CreateRecordTrackingTable();
                    try
                    {
                        this.TranscribeData(cancellationToken, table, jobDefinitionStep1, naturalKeys, modelType);
                        if (cancellationToken.IsCancellationRequested)
                            return;
                        if (this.JobLogger.ThresholdReached())
                            throw new LoggingThresholdReachedException();
                        try
                        {
                            this.deleteProcessor.Execute(this.IntegrationJob, jobDefinitionStep1, processedRecordService, modelType, table, this.JobLogger);
                        }
                        catch (LoggingThresholdReachedException ex)
                        {
                            throw;
                        }
                        catch (Exception ex)
                        {
                            this.JobLogger.Error(string.Format("Unhandled exception occured: {0}.", (object)ExceptionMessageHelper.GetFullErrorMessage(ex)), jobDefinitionStep1);
                        }
                    }
                    finally
                    {
                        processedRecordService.DropRecordTrackingTable();
                    }
                }
                this.JobLogger.Info("Finished transcribing data.", jobDefinitionStep1);
                this.unitOfWork.Save();
            }
        }

        private void TranscribeData(CancellationToken cancellationToken, DataTable table, JobDefinitionStep integrationJobStep, Collection<string> naturalKeys, Type modelType)
        {
            int numberOfThreads = this.GetNumberOfThreads(table, integrationJobStep);
            int count1 = 0;
            int count2 = table.Rows.Count / numberOfThreads;
            List<Thread> threadList = new List<Thread>();
            int num = 0;
            while (count1 < table.Rows.Count)
            {
                ++num;
                if (count1 + count2 > table.Rows.Count)
                    count2 = table.Rows.Count - count1;
                int insideThreadCount = num;
                int insideStartRow = count1;
                int insidePageSize = count2;
                DataTable tableSplit = count2 == table.Rows.Count ? table : table.AsEnumerable().Skip<DataRow>(count1).Take<DataRow>(count2).CopyToDataTable<DataRow>();
                tableSplit.TableName = table.TableName;
                UserProfileDto userProfileDto = SiteContext.Current?.UserProfileDto;
                Thread thread = new Thread((ThreadStart)(() =>
                {
                    try
                    {
                        SiteContext.SetSiteContext((ISiteContext)new SiteContextDto(SiteContext.Current)
                        {
                            UserProfileDto = userProfileDto
                        });
                        using (IProcessedRecordService processedRecordService = this.CreateProcessedRecordService(integrationJobStep))
                            DependencyLocator.Current.GetInstance<IDataTableService>().ProcessDataTable(insideThreadCount, integrationJobStep, naturalKeys, modelType, tableSplit, insideStartRow, insidePageSize, processedRecordService, this.IntegrationJob.Id, cancellationToken);
                    }
                    catch
                    {
                    }
                }));
                thread.Start();
                threadList.Add(thread);
                count1 += count2;
            }
            foreach (Thread thread in threadList)
                thread.Join();
        }

        private int GetNumberOfThreads(DataTable table, JobDefinitionStep integrationJobStep)
        {
            int num = this.integrationGeneralSettings.RefreshNumberOfThreads;
            if (table.Rows.Count < 1000)
            {
                this.JobLogger.Info(string.Format("Setting thread count to 1 because row count doesn't meet threshold ({0}) for multi-threading.", (object)1000), integrationJobStep);
                num = 1;
            }
            else if (this.IntegrationJob.JobDefinition.UseDeltaDataSet)
            {
                this.JobLogger.Info("Setting thread count to 1 because this job uses delta datasets.", integrationJobStep);
                num = 1;
            }
            else
                this.JobLogger.Debug(string.Format("Using {0} threads to transcribe data.", (object)num), integrationJobStep);
            return num;
        }

        public void Cancel()
        {
        }

        private IProcessedRecordService CreateProcessedRecordService(JobDefinitionStep integrationJobStep)
        {
            if (integrationJobStep.DeleteAction == DeleteAction.Ignore.ToString())
                return (IProcessedRecordService)new NullProcessedRecordService();
            return (IProcessedRecordService)new ProcessedRecordService(this.IntegrationJob.JobNumber, integrationJobStep.Sequence, this.IntegrationJob.JobDefinition.Name);
        }

        private void MapInToDataSet(JobDefinitionStep jobStep, DataSet dataSet, string dataTableName)
        {
            DataSet dataSet1 = new DataSet();
            ICollection<JobDefinitionStepFieldMap> definitionStepFieldMaps = jobStep.JobDefinitionStepFieldMaps;
            List<string> stringList1;
            if (!definitionStepFieldMaps.Select<JobDefinitionStepFieldMap, string>((Func<JobDefinitionStepFieldMap, string>)(m => m.FromProperty)).Distinct<string>().ToList<string>().Any<string>((Func<string, bool>)(f => f.Contains("."))))
                stringList1 = new List<string>() { dataTableName };
            else
                stringList1 = definitionStepFieldMaps.Select<JobDefinitionStepFieldMap, string>((Func<JobDefinitionStepFieldMap, string>)(m => m.FromProperty.Split('.')[0].Replace("{", string.Empty).Replace("}", string.Empty))).Distinct<string>().ToList<string>();
            List<string> stringList2 = stringList1;
            List<string> list1 = definitionStepFieldMaps.Select<JobDefinitionStepFieldMap, string>((Func<JobDefinitionStepFieldMap, string>)(m => m.ToProperty.Split('.')[0])).Distinct<string>().ToList<string>();
            foreach (string str in list1)
            {
                string toTableName = str;
                List<string> list2 = definitionStepFieldMaps.Where<JobDefinitionStepFieldMap>((Func<JobDefinitionStepFieldMap, bool>)(m => m.ToProperty.Split('.')[0].EqualsIgnoreCase(toTableName))).Select<JobDefinitionStepFieldMap, string>((Func<JobDefinitionStepFieldMap, string>)(m => m.ToProperty.Split('.')[1])).ToList<string>();
                DataTable toTable = new DataTable(toTableName);
                Action<string> action = (Action<string>)(c => toTable.Columns.Add(c));
                list2.ForEach(action);
                dataSet1.Tables.Add(toTable);
            }
            this.JobLogger.Debug(string.Format("Mapping from Tables: {0} to Tables: {1}.", (object)string.Join(",", (IEnumerable<string>)stringList2), (object)string.Join(",", (IEnumerable<string>)list1)), jobStep);
            foreach (string index1 in stringList2)
            {
                this.JobLogger.Debug(string.Format("Processing FromTableName {0} Rows {1}.", (object)index1, (object)dataSet.Tables[index1].Rows.Count), jobStep);
                foreach (DataRow row in (InternalDataCollectionBase)dataSet.Tables[index1].Rows)
                {
                    Dictionary<string, DataRow> dictionary = new Dictionary<string, DataRow>();
                    foreach (DataColumn column in (InternalDataCollectionBase)row.Table.Columns)
                    {
                        string fromPropertyName = index1.Equals(dataTableName) ? column.ColumnName : index1 + "." + column.ColumnName;
                        ICollection<JobDefinitionStepFieldMap> source = definitionStepFieldMaps;
                        foreach (JobDefinitionStepFieldMap definitionStepFieldMap in source.Where<JobDefinitionStepFieldMap>((Func<JobDefinitionStepFieldMap, bool>)(m => m.FromProperty.Replace("{", string.Empty).Replace("}", string.Empty).EqualsIgnoreCase(fromPropertyName))))
                        {
                            string key = definitionStepFieldMap.ToProperty.Split('.')[0];
                            string index2 = definitionStepFieldMap.ToProperty.Split('.')[1];
                            DataRow dataRow;
                            if (dictionary.ContainsKey(key))
                            {
                                dataRow = dictionary[key];
                            }
                            else
                            {
                                dataRow = dataSet1.Tables[key].NewRow();
                                dictionary.Add(key, dataRow);
                            }
                            dataRow[index2] = row[column.ColumnName];
                        }
                    }
                    foreach (KeyValuePair<string, DataRow> keyValuePair in dictionary)
                        dataSet1.Tables[keyValuePair.Key].Rows.Add(keyValuePair.Value);
                }
            }
            DataSet dataset = XmlDatasetManager.ConvertXmlToDataset(this.IntegrationJob.ResultData);
            dataset.Merge(dataSet1);
            this.IntegrationJob.ResultData = XmlDatasetManager.ConvertDatasetToXml(dataset);
        }

        private Type GetModelType(string objectName)
        {
            return this.unitOfWork.DataProvider.GetTypeForClassName(objectName);
        }

        private static Collection<string> GetNaturalKeys(ICollection<JobDefinitionStepFieldMap> stepMappings, Type modelType)
        {
            Collection<string> collection = new Collection<string>();
            if (modelType == typeof(Category))
            {
                JobDefinitionStepFieldMap definitionStepFieldMap = stepMappings.FirstOrDefault<JobDefinitionStepFieldMap>((Func<JobDefinitionStepFieldMap, bool>)(m => m.ToProperty.Equals("WebSiteCategoryName", StringComparison.OrdinalIgnoreCase)));
                if (definitionStepFieldMap == null)
                    throw new ArgumentException("Integration to Target Object (Category) requires a mapping to 'WebSiteCategoryName'.");
                collection.Add(definitionStepFieldMap.ToProperty);
                return collection;
            }
            foreach (PropertyInfo propertyInfo in ((IEnumerable<PropertyInfo>)modelType.GetProperties()).Where<PropertyInfo>((Func<PropertyInfo, bool>)(pi => ((IEnumerable<object>)pi.GetCustomAttributes(typeof(NaturalKeyFieldAttribute), false)).Any<object>())).OrderBy<PropertyInfo, int>((Func<PropertyInfo, int>)(pi => ((NaturalKeyFieldAttribute)pi.GetCustomAttributes(typeof(NaturalKeyFieldAttribute), false)[0]).Order)).ToList<PropertyInfo>())
            {
                string fieldName = propertyInfo.Name.EndsWith("Id") ? propertyInfo.Name.Substring(0, propertyInfo.Name.Length - 2) : propertyInfo.Name;
                JobDefinitionStepFieldMap definitionStepFieldMap = stepMappings.FirstOrDefault<JobDefinitionStepFieldMap>((Func<JobDefinitionStepFieldMap, bool>)(m => m.ToProperty.Equals(fieldName, StringComparison.OrdinalIgnoreCase)));
                if (definitionStepFieldMap == null)
                    throw new ArgumentException(string.Format("Integration to {0} requires the lookup field {1}.", (object)modelType.Name, (object)propertyInfo.Name));
                collection.Add(definitionStepFieldMap.ToProperty);
            }
            return collection;
        }

        private void ArchiveRemoteFiles()
        {
            if (this.IntegrationJob == null)
                throw new ArgumentNullException("integrationJob", "Integration Job required to execute LNPFieldMap");
            if (this.IntegrationJob.JobDefinition.JobDefinitionParameters == null)
                throw new ArgumentNullException("integrationJob", "Integration Job Defination Parameter required to execute LNPFieldMap");
            if (string.IsNullOrEmpty(this.IntegrationJob.JobDefinition.IntegrationConnection.Url))
                throw new ArgumentNullException("integrationJob", "Integration connection import folder required to execute LNPFieldMap");
            //Get Parameter

            JobLogger.Info("Job LNPFieldMap >> MoveFiles >> start.");

            foreach (JobDefinitionParameter parameter in this.IntegrationJob.JobDefinition.JobDefinitionParameters)
            {
                if (parameter.Name == JobDefinitionParametersConstant.FTPHost) this.FTPHost = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPUsername) this.FTPUsername = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPPassword) this.FTPPassword = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPPort) this.FTPPort = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPDownloadRemoteDirectoryLocaltion) this.FTPDownloadRemoteDirectoryLocaltion = parameter.DefaultValue;
            }
            //Download files from FTP.
            FTPRequestModel ftpRequest = new FTPRequestModel
            {
                FTPAddress = this.FTPHost,
                FTPUsername = this.FTPUsername,
                FTPPassword = this.FTPPassword,
                FTPPort = string.IsNullOrEmpty(this.FTPPort) ? 21 : Convert.ToInt32(this.FTPPort),
                FTPRemoteFolderPath = this.FTPDownloadRemoteDirectoryLocaltion
            };

            if (!string.IsNullOrEmpty(this.FTPDownloadRemoteDirectoryLocaltion))
            {
                FtpManager ftpClient = new FtpManager(ftpRequest);
                ftpClient.MoveFiles();
                JobLogger.Info("Job LNPFieldMap >> MoveFiles >> end.");
            }
            else
            {
                JobLogger.Info("Job LNPFieldMap >> MoveFiles >> Unable to archive files.");
            }
        }
    }
}
