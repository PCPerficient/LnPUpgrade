
using System;
using System.IO;
using System.Data;
using System.Linq;
using Insite.Integration.Enums;
using System.Collections.Generic;
using Insite.WIS.Broker;
using Insite.Common.Helpers;
using Insite.WIS.Broker.Plugins;
using Insite.WIS.Broker.Interfaces;
using Insite.WIS.Broker.Plugins.Constants;
using Insite.WIS.Broker.WebIntegrationService;
using LeggettAndPlatt.FTP;
using LeggettAndPlatt.FTP.RequestModel;

namespace LeggettAndPlatt.IntegrationProcessor
{
    public class IntegrationProcessorConsoleUserExport : IIntegrationProcessor
    {
        DataSet initialDataset = null;
      
        IntegrationJobLogger JobLogger;
        IntegrationJob IntegrationJob;
        
        string ftpUploadDirectoryLocation = null;
        string consoleUserExportFileName = null;
        string localDirectoryPath = null;
        string LocalFileLocation = null;
        string ftpUsername = null;
        string ftpPassword = null;
        string ftpHost = null;
        string ftpPort = null;
         

        public DataSet Execute(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
         
            this.JobLogger = new IntegrationJobLogger(siteConnection, integrationJob);
            this.IntegrationJob = integrationJob;
            this.JobLogger.Info("Console user export process start.");
            this.initialDataset = XmlDatasetManager.ConvertXmlToDataset(integrationJob.InitialData);

            if (this.initialDataset == null)
            {           
                this.JobLogger.Fatal("The initial dataset is empty.");
                throw new ArgumentException(Messages.InvalidInitialDataSetExceptionMessage);
            }
            
            this.InitJobParameters(integrationJob);
            this.CreatePathIfMissing(this.localDirectoryPath);
            ExcelHelper excelHelper = new ExcelHelper();
            this.LocalFileLocation = this.localDirectoryPath+this.consoleUserExportFileName;
            this.JobLogger.Info("Convert dataset to excel file start.");
            string fileExt = Path.GetExtension(this.consoleUserExportFileName).ToLower();
            if (fileExt  == ".csv")
            {
                excelHelper.ConvertDataSetToToCSV(this.initialDataset, this.LocalFileLocation);

            }else if(fileExt == ".xlsx")
            {
                excelHelper.ConvertDataSetToSpreadsheet(this.initialDataset, this.LocalFileLocation);

            }
            else
            {
               
                throw new Exception("File Name is invalid.");
                return this.initialDataset;

            }
            
           
            this.JobLogger.Info("Convert dataset to excel file end.");
            try
            {
                this.UploadExcelFile();
            }
            catch (Exception ex)
            {
                this.JobLogger.Error(ex.Message.ToString());
                throw ex;
            }

            this.JobLogger.Info("Console user export process end.");
            return this.initialDataset;
        }
        
        
        private void InitJobParameters(IntegrationJob integrationJob)
        {
            string portNumber = string.Empty;
            string address = string.Empty;

            IntegrationJobParameter[] integrationJobParameters = this.IntegrationJob.IntegrationJobParameters.Where(
                x => x.JobDefinitionParameter != null
                ).ToArray();

            JobDefinitionStep jobDefinitionStep = (from step in integrationJob.JobDefinition.JobDefinitionSteps
                                                  orderby step.Sequence ascending
                                                  select step).FirstOrDefault();

            if (jobDefinitionStep == null)
            {
                this.JobLogger.Info("JobDefinitionStep is not define");
                throw new ArgumentException("Step 1 is not define.");
            }


            if (jobDefinitionStep != null && jobDefinitionStep.IntegrationConnectionOverride != null)
            {
                IntegrationConnection connection = jobDefinitionStep.IntegrationConnectionOverride;

                    if (string.IsNullOrEmpty(connection.LogOn))
                        throw new ArgumentException("User name for ftp connection is required.");
                    if (string.IsNullOrEmpty(connection.Password))
                        throw new ArgumentException("Password for ftp connection is required.");
                    if (string.IsNullOrEmpty(connection.Url))
                        throw new ArgumentException("Host name for ftp connection is required.");

                string[] addressPort = connection.Url.Split(':');

                for (int i = 0; i < addressPort.Length; i++)
                {
                    if (i == 0)
                        address = addressPort[0];
                    else if (i == 1)
                        portNumber = string.IsNullOrEmpty(addressPort[1]) ? "21" : addressPort[1];
                }

                    this.ftpHost = address;
                    this.ftpPort = portNumber;
                    this.ftpUsername = connection.LogOn;
                    this.ftpPassword = EncryptionHelper.DecryptAes(connection.Password);
                    this.JobLogger.Info("Finished reading FTP connection credentials");
            }
            else
            {
                this.JobLogger.Info("Integration connection override for FTP credentials is not defined.");
                throw new ArgumentException("Integration connection override for FTP credentials is not defined.");
            }

            this.ftpUploadDirectoryLocation = this.GetParameterValue(
                (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
                "FTPUploadDirectoryLocation",
                "Unable to find job definition parameter 'FTPUploadDirectoryLocation'. This is an required parameter used to console user exel file on remote server.",
                IntegrationJobLogType.Fatal
                );
            
            this.localDirectoryPath = this.GetParameterValue(
                (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
                "LocalDirectoryPath",
                "Unable to find job definition parameter 'LocalDirectoryPath'. This is an required parameter used to console user exel file on local server.",
                IntegrationJobLogType.Fatal
                );
            this.consoleUserExportFileName = this.GetParameterValue(
               (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
               "ConsoleUserExportFileName",
               "Unable to find job definition parameter 'ConsoleUserExportFileName'. This is an required parameter to set the file name dynamicaly.",
               IntegrationJobLogType.Fatal
               );

        }

        private bool UploadExcelFile ()
        {
            this.JobLogger.Info("Console user excel upload start.");
            bool result = false;
            try
            {
                if (this.IntegrationJob.IntegrationJobParameters == null)
                {
                    this.JobLogger.Info(
                        "No job parameters defined. 'ConsoleUserExcelLocalFilePath'and 'FTPUploadDirectoryLocation' are all required parameters",
                        true
                        );
                }
                else
                {
                    int port = 0;
                    int.TryParse(this.ftpPort, out port);
                    FTPRequestModel ftpRequest = new FTPRequestModel
                    {
                        FTPAddress = this.ftpHost,
                        FTPUsername = this.ftpUsername,
                        FTPPassword = this.ftpPassword,
                        FTPPort = port,
                        FTPRemoteFolderPath = this.ftpUploadDirectoryLocation,
                        LocalFolderPath = this.localDirectoryPath,
                    };
                    FtpManager ftpClient = new FtpManager(ftpRequest);
                    ftpClient.FTPSUpload(this.consoleUserExportFileName);

                    result = true;
                }
            }
            catch (Exception ex)
            { 
                throw ex;
            }

            this.JobLogger.Info("Console user excel upload end.");
            return result;

        }
        private string GetParameterValue(
            IEnumerable<IntegrationJobParameter> integrationJobParameters,
            string parameterName, string notFoundMessage,
            IntegrationJobLogType logType = IntegrationJobLogType.Fatal
            )
        {
            this.JobLogger.Info("Get Parameter Value for " + parameterName + " Parameters count " + integrationJobParameters.Count());

            IntegrationJobParameter integrationJobParameter = integrationJobParameters.FirstOrDefault<IntegrationJobParameter>((Func<IntegrationJobParameter, bool>)(p => p.JobDefinitionParameter.Name.EqualsIgnoreCase(parameterName)));
            if (integrationJobParameter != null)
                return integrationJobParameter.Value;
            this.JobLogger.AddLogMessage(notFoundMessage, true, logType);
            return (string)null;
        }

        private void CreatePathIfMissing(string path)
        {
            try
            {
                if (!Directory.Exists(path))
                {
                    DirectoryInfo di = Directory.CreateDirectory(path);
                }
            }
            catch (IOException ioex)
            {
                this.JobLogger.Error(ioex.Message.ToString());
                throw ioex;
            }

        }

    }
}
