using Insite.Common.Helpers;
using Insite.Integration.Enums;
using Insite.WIS.Broker;
using Insite.WIS.Broker.Interfaces;
using Insite.WIS.Broker.Plugins;
using Insite.WIS.Broker.WebIntegrationService;
using LeggettAndPlatt.FTP;
using LeggettAndPlatt.FTP.RequestModel;
using LeggettAndPlatt.IntegrationProcessor.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace LeggettAndPlatt.IntegrationProcessor.Plugins
{
    public class IntegrationProcessorDownloadFilesFromFtp : IIntegrationProcessor
    {
        IntegrationJobLogger JobLogger;
        IntegrationJob IntegrationJob;

        public DataSet Execute(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
            DataSet downloadFilesSet = DownloadFiles(siteConnection, integrationJob, jobStep);
            return downloadFilesSet;
        }

        private DataSet DownloadFiles(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
            DataSet downloadFilesSet = new DataSet();
            this.JobLogger = new IntegrationJobLogger(siteConnection, integrationJob);
            this.IntegrationJob = integrationJob;
            FTPRequestModel ftpRequest = new FTPRequestModel();

            this.JobLogger.Info("Download files form FTP job start");

            if (this.IntegrationJob == null)
            {
                this.JobLogger.Fatal("IntegrationJob is Null : Required to execute DownloadFilesFromFtp");
                throw new ArgumentNullException("integrationJob", "Integration Job required to execute DownloadFilesFromFtp");
            }
            if (this.IntegrationJob.JobDefinition.JobDefinitionParameters == null)
            {
                this.JobLogger.Fatal("JobDefinitionParameters is Null : Parameter required to execute DownloadFilesFromFtp");
                throw new ArgumentNullException("integrationJob", "Integration Job Defination Parameter required to execute DownloadFilesFromFtp");
            }
            this.JobLogger.Info("Starting reading integration connection URl");
            if (string.IsNullOrEmpty(this.IntegrationJob.JobDefinition.IntegrationConnection.Url))
            {
                this.JobLogger.Fatal("IntegrationConnection is Null : Required to execute DownloadFilesFromFtp");
                throw new ArgumentNullException("integrationJob", "Integration connection import folder required to execute DownloadFilesFromFtp");
            }
            this.JobLogger.Info("Finished reading integration connection URl");

            ftpRequest.LocalFolderPath = integrationJob.JobDefinition.IntegrationConnection.Url;
            this.ReadFPTConnectionParameter(integrationJob, ftpRequest);
     
            this.JobLogger.Info("Starting reading job defination Parameter");
            IntegrationJobParameter[] integrationJobParameters = this.IntegrationJob.IntegrationJobParameters.Where(
              x => x.JobDefinitionParameter != null
              ).ToArray();

            ftpRequest.FTPRemoteFolderPath = this.GetParameterValue(
             (IEnumerable<IntegrationJobParameter>)integrationJobParameters,
             JobDefinitionParametersConstant.FTPDownloadRemoteDirectoryLocaltion,
             "Unable to find job definition parameter 'FTPDownloadRemoteDirectoryLocaltion'. This is an required parameter used to download files.",
             IntegrationJobLogType.Fatal
             );
            this.JobLogger.Info("Finished reading job defination Parameter");
            this.MoveFiles(ftpRequest);
            this.JobLogger.Info("Download files from FTP job end");
            return downloadFilesSet;
        }
        private void ReadFPTConnectionParameter(IntegrationJob integrationJob,FTPRequestModel ftpRequest)
        {
            int portNumber=21;
            string address = string.Empty;

            this.JobLogger.Info("Starting reading FTP connection credentials");
            JobDefinitionStep downLoadFileStep = (from step in integrationJob.JobDefinition.JobDefinitionSteps
                                                  orderby step.Sequence ascending
                                                  select step).FirstOrDefault();
            if (downLoadFileStep == null)
            {
                this.JobLogger.Info("Step 1 DownloadFiles not define");
                throw new ArgumentException("Step 1 DownloadFiles not define.");
            }

            if (downLoadFileStep != null && downLoadFileStep.IntegrationConnectionOverride != null)
            {
                IntegrationConnection connection = downLoadFileStep.IntegrationConnectionOverride;

                if (string.IsNullOrEmpty(connection.LogOn))
                    throw new ArgumentException("User name for ftp connection is required.");
                if (string.IsNullOrEmpty(connection.Password))
                    throw new ArgumentException("Password for ftp connection is required.");
                if (string.IsNullOrEmpty(connection.Url))
                    throw new ArgumentException("Host name for ftp connection is required.");
                
                string[] addressPort = connection.Url.Split(':');

                for(int i=0;i< addressPort.Length;i++)
                {
                    if(i == 0)
                        address = addressPort[0];
                    else if(i == 1)
                        portNumber = string.IsNullOrEmpty(addressPort[1]) ? 21 : Convert.ToInt32(addressPort[1]);
                }

                ftpRequest.FTPAddress = address;
                ftpRequest.FTPPort = portNumber;
                ftpRequest.FTPUsername = connection.LogOn;
                ftpRequest.FTPPassword = EncryptionHelper.DecryptAes(connection.Password);
                this.JobLogger.Info("Finished reading FTP connection credentials");
            }
            else
            {
                this.JobLogger.Info("Integration connection override for FTP credentials is not defined.");
                throw new ArgumentException("Integration connection override for FTP credentials is not defined.");
            }

        }
        private void MoveFiles(FTPRequestModel ftpRequest)
        {
            FtpManager ftpClient = new FtpManager(ftpRequest);
            this.JobLogger.Info("Starting reading files from FTP");
            ftpClient.MoveFilesFromRemoteToLocal();
            this.JobLogger.Info("Finished reading files from FTP");
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
    }
}
