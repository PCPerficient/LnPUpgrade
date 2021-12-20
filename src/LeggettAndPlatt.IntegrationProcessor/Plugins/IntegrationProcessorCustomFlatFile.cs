using Insite.Common.Extensions;
using Insite.Integration.Enums;
using Insite.WIS.Broker;
using Insite.WIS.Broker.Interfaces;
using Insite.WIS.Broker.Plugins;
using Insite.WIS.Broker.WebIntegrationService;
using Microsoft.VisualBasic.FileIO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;

namespace LeggettAndPlatt.IntegrationProcessor.Plugins
{
    public class IntegrationProcessorCustomFlatFile : IIntegrationProcessor
    {
        /// <summary>The FileFinder object.</summary>
        private readonly CustomFileFinder customFileFinder;
        /// <summary>The job logger.</summary>
        protected IIntegrationJobLogger JobLogger;

        /// <summary>Initializes a new instance of the <see cref="T:Insite.WIS.Broker.Plugins.IntegrationProcessorFlatFile" /> class.</summary>
        /// <param name="fileFinder">The <see cref="T:Insite.WIS.Broker.Plugins.FileFinder" /> object.</param>
        public IntegrationProcessorCustomFlatFile(CustomFileFinder customFileFinder)
        {
            this.customFileFinder = customFileFinder;
        }

        /// <summary>Executes the job associated with the passed in <see cref="T:Insite.WIS.Broker.WebIntegrationService.IntegrationJob" /> and <see cref="T:Insite.WIS.Broker.WebIntegrationService.JobDefinitionStep" />.</summary>
        /// <param name="siteConnection"><see cref="T:Insite.WIS.Broker.SiteConnection" /> which encapsulates connection to the site which we are integrating to.</param>
        /// <param name="integrationJob">The <see cref="T:Insite.WIS.Broker.WebIntegrationService.IntegrationJob" /> that is to be executed.</param>
        /// <param name="jobStep">The <see cref="T:Insite.WIS.Broker.WebIntegrationService.JobDefinitionStep" /> of the <see cref="T:Insite.WIS.Broker.WebIntegrationService.IntegrationJob" /> being executed.</param>
        /// <returns>The results of the passed in <see cref="T:Insite.WIS.Broker.WebIntegrationService.IntegrationJob" /> and <see cref="T:Insite.WIS.Broker.WebIntegrationService.JobDefinitionStep" /></returns>
        public virtual DataSet Execute(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
            this.JobLogger = (IIntegrationJobLogger)new IntegrationJobLogger(siteConnection, integrationJob);
            IntegrationConnection integrationConnection = integrationJob.JobDefinition.IntegrationConnection;
            DataSet dataSet = new DataSet();
            DataTable dataTableSchema = new DataTable(string.Format((IFormatProvider)CultureInfo.InvariantCulture, "{0}{1}", new object[2]
            {
        (object) jobStep.Sequence,
        (object) jobStep.ObjectName
            }));
            string selectClause = jobStep.SelectClause;
            char[] chArray = new char[1] { ',' };
            foreach (string str in selectClause.Split(chArray))
                dataTableSchema.Columns.Add(str.Trim());
            List<string> files = this.GetFiles(integrationJob, jobStep, integrationConnection);
            this.LogFilesFoundMessage(jobStep, files.Count);
            this.ProcessFiles(siteConnection, integrationJob, jobStep, files, dataTableSchema, integrationConnection, dataSet);
            return dataSet;
        }

        protected virtual void LogFilesFoundMessage(JobDefinitionStep jobStep, int fileCount)
        {
            string message = fileCount == 0 ? string.Format("No files found matching '{0}'", (object)jobStep.FromClause) : string.Format("Found {0} files matching '{1}'", (object)fileCount, (object)jobStep.FromClause);
            if (fileCount == 0)
            {
                switch (jobStep.FlatFileErrorHandling.EnumParse<LookupErrorHandlingType>())
                {
                    case LookupErrorHandlingType.Warning:
                        this.JobLogger.Warn(message, true);
                        break;
                    case LookupErrorHandlingType.Error:
                        this.JobLogger.Error(message, true);
                        break;
                    case LookupErrorHandlingType.Ignore:
                        this.JobLogger.Info(message, true);
                        break;
                    default:
                        this.JobLogger.Warn(message, true);
                        break;
                }
            }
            else
                this.JobLogger.Info(message, true);
        }

        /// <summary>Get the files to process.</summary>
        /// <param name="integrationJob">The integration job.</param>
        /// <param name="jobStep">The job step.</param>
        /// <param name="integrationConnection">The integration connection.</param>
        /// <returns>The List of strings.</returns>
        protected virtual List<string> GetFiles(IntegrationJob integrationJob, JobDefinitionStep jobStep, IntegrationConnection integrationConnection)
        {
            List<string> list1 = ((IEnumerable<string>)jobStep.FromClause.Split(',')).Select<string, string>((Func<string, string>)(o => o.Trim())).ToList<string>();
            List<string> list2 = this.customFileFinder.GetFiles(integrationConnection.Url, (IList<string>)list1).ToList<string>();
            List<string> list3 = list1.Select<string, string>((Func<string, string>)(o => o + "." + (object)integrationJob.JobNumber + ".processed")).ToList<string>();
            list2.AddRange((IEnumerable<string>)this.customFileFinder.GetFiles(integrationConnection.Url, (IList<string>)list3));
            return list2;
        }

        protected virtual void ProcessFiles(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep, List<string> files, DataTable dataTableSchema, IntegrationConnection integrationConnection, DataSet dataSet)
        {
            foreach (string str1 in files.Distinct<string>())
            {
                DataTable dataTable = dataTableSchema.Clone();
                DataSet dataSet1 = new DataSet();
                string empty = string.Empty;
                string str2;
                try
                {
                    str2 = this.RenameFile(integrationJob, str1);
                }
                catch (IOException ex)
                {
                    this.JobLogger.Warn(string.Format("Exception {0} occurred trying to access file {1}, skipping this file", (object)ex.Message, (object)empty), true);
                    continue;
                }
                this.JobLogger.Debug(string.Format("Starting Reading File {0}", (object)str2), true);
                int file;
                try
                {
                    file = this.ParseFile(integrationJob, jobStep, str2, integrationConnection, dataTable);
                }
                catch (Exception ex)
                {
                    this.JobLogger.Error(string.Format("Exception Reading File {0} Moving to Bad Folder.  Message: {1}", (object)str2, (object)ex.Message), true);
                    string directoryName = Path.GetDirectoryName(str2);
                    int idx = directoryName.LastIndexOf('\\');

                    if (idx != -1 && directoryName != null)
                    {
                        string str3 = Path.Combine(directoryName.Substring(0, idx), "BadFiles");
                        string str4 = Path.Combine(str3, directoryName.Substring(idx + 1));

                        //string str4 = Path.Combine(directoryName, "BadFiles");
                        if (!Directory.Exists(str4))
                            Directory.CreateDirectory(str4);
                        File.Move(str2, Path.Combine(str4, Path.GetFileName(str2)));
                        continue;
                    }
                    continue;
                }
                if (integrationJob.IsPreview)
                {
                    dataSet1.Tables.Add(dataTable);
                    dataSet.Merge(dataSet1);
                    File.Move(str2, str1);
                    break;
                }
                if (!str1.EndsWith(integrationJob.JobNumber.ToString() + ".processed"))
                {
                    string destFileName = str1 + "." + (object)integrationJob.JobNumber + ".processed";
                    File.Move(str2, destFileName);
                }
                this.JobLogger.Debug(string.Format("Finished Reading File {0}, Total Rows {1}{2}", (object)str2, (object)file, !string.IsNullOrEmpty(jobStep.WhereClause) ? (object)" Applying Where Clause" : (object)string.Empty), true);
                if (string.IsNullOrEmpty(jobStep.WhereClause))
                {
                    dataSet1.Tables.Add(dataTable);
                }
                else
                {
                    DataTable table = dataTableSchema.Clone();
                    foreach (DataRow row in dataTable.Select(jobStep.WhereClause))
                        table.ImportRow(row);
                    dataSet1.Tables.Add(table);
                    this.JobLogger.Debug(string.Format("Finished Applying Where Clause, Total Rows {0}", (object)table.Rows.Count), true);
                }
                dataSet.Merge(dataSet1);
            }
        }

        /// <summary>Rename the file if necessary.</summary>
        /// <param name="integrationJob">The integration job.</param>
        /// <param name="flatFileName">The file name.</param>
        /// <returns>The new file name.</returns>
        protected virtual string RenameFile(IntegrationJob integrationJob, string flatFileName)
        {
            string destFileName;
            if (flatFileName.EndsWith(integrationJob.JobNumber.ToString() + ".processed"))
            {
                destFileName = flatFileName;
            }
            else
            {
                destFileName = flatFileName + "." + (object)integrationJob.JobNumber + ".processing";
                File.Move(flatFileName, destFileName);
            }
            return destFileName;
        }

        /// <summary>Parse file</summary>
        /// <param name="integrationJob">The integration job.</param>
        /// <param name="jobStep">The job step.</param>
        /// <param name="processingFileName">The processing file name.</param>
        /// <param name="integrationConnection">The integration connection.</param>
        /// <param name="dataTable">The data table.</param>
        /// <returns>The row count.</returns>
        protected virtual int ParseFile(IntegrationJob integrationJob, JobDefinitionStep jobStep, string processingFileName, IntegrationConnection integrationConnection, DataTable dataTable)
        {
            int num = 0;
            using (TextFieldParser textFieldParser = new TextFieldParser(processingFileName))
            {
                textFieldParser.SetDelimiters(this.GetDelimiter(integrationConnection));
                if (jobStep.SkipHeaderRow)
                    textFieldParser.ReadLine();
                while (!textFieldParser.EndOfData)
                {
                    string[] strArray = textFieldParser.ReadFields();
                    if (strArray == null)
                        throw new FileLoadException(string.Format("Unable to read the file {0}", (object)processingFileName));
                    if (strArray.Length != dataTable.Columns.Count)
                        throw new DataMisalignedException(string.Format("Number of columns in File {0} does not match number of columns defined in Job {1}", (object)strArray.Length, (object)dataTable.Columns.Count));
                    dataTable.LoadDataRow((object[])strArray, true);
                    ++num;
                    if (integrationJob.IsPreview)
                    {
                        if (num >= 10)
                            break;
                    }
                }
            }
            return num;
        }

        /// <summary>Get the integration connection delimiter.</summary>
        /// <param name="integrationConnection">The integration connection.</param>
        /// <returns>The delimiter.</returns>
        protected virtual string GetDelimiter(IntegrationConnection integrationConnection)
        {
            string str = integrationConnection.Delimiter;
            if (str.Equals("<tab>", StringComparison.InvariantCultureIgnoreCase))
                str = "\t";
            else if (str.StartsWith("<") && str.EndsWith(">"))
                str = Convert.ToChar(str.Replace("<", string.Empty).Replace(">", string.Empty)).ToString();
            return str;
        }
    }
}
