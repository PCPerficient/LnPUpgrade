using Insite.Core.Interfaces.Dependency;
using Insite.Integration.WebService.Interfaces;
using System;
using Insite.Data.Entities;
using LeggettAndPlatt.FTP.RequestModel;
using LeggettAndPlatt.FTP;
using LeggettAndPlatt.Integration.Common;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Preprocessor
{
    [DependencyName("GenericDownloadFileFromFTP")]
    public class JobPreprocessorDownloadFilesFromFtp : IJobPreprocessor, ITransientLifetime, IDependency, IExtension
    {
        private string FTPHost;
        private string FTPUsername;
        private string FTPPassword;
        private string FTPPort;
        private string FTPDownloadRemoteDirectoryLocaltion;
        private string JobImportFolderPath;

        public IJobLogger JobLogger { get; set; }
        public IntegrationJob IntegrationJob { get; set; }

        public IntegrationJob Execute()
        {

            if (this.IntegrationJob == null)
                throw new ArgumentNullException("integrationJob", "Integration Job required to execute DownloadFilesFromFtp");
            if (this.IntegrationJob.JobDefinition.JobDefinitionParameters == null)
                throw new ArgumentNullException("integrationJob", "Integration Job Defination Parameter required to execute DownloadFilesFromFtp");
            if(string.IsNullOrEmpty(this.IntegrationJob.JobDefinition.IntegrationConnection.Url))
                throw new ArgumentNullException("integrationJob", "Integration connection import folder required to execute DownloadFilesFromFtp");
            //Get Parameter

            JobLogger.Info("Job preprocess (GenericDownloadFileFromFTP): Running for job : " + this.IntegrationJob.JobDefinition.Name);
            JobLogger.Info("Job preprocess (GenericDownloadFileFromFTP): Get parameter for job defination :" + this.IntegrationJob.JobDefinition.Name);
            foreach (JobDefinitionParameter parameter in this.IntegrationJob.JobDefinition.JobDefinitionParameters)
            {
                if (parameter.Name == JobDefinitionParametersConstant.FTPHost) this.FTPHost = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPUsername) this.FTPUsername = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPPassword) this.FTPPassword = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPPort) this.FTPPort = parameter.DefaultValue;
                if (parameter.Name == JobDefinitionParametersConstant.FTPDownloadRemoteDirectoryLocaltion) this.FTPDownloadRemoteDirectoryLocaltion = parameter.DefaultValue;
            }
            JobLogger.Info("Job preprocess (GenericDownloadFileFromFTP): Get import folder path for job defination :" + this.IntegrationJob.JobDefinition.Name);
            //Get connection import folder path.
            JobImportFolderPath = this.IntegrationJob.JobDefinition.IntegrationConnection.Url;
            JobLogger.Info("Job preprocess (GenericDownloadFileFromFTP): Downloading files from FTP for job defination :" + this.IntegrationJob.JobDefinition.Name);
            //Download files from FTP.
            FTPRequestModel ftpRequest = new FTPRequestModel
            {
                FTPAddress = this.FTPHost,
                FTPUsername = this.FTPUsername,
                FTPPassword = this.FTPPassword,
                FTPPort = string.IsNullOrEmpty(this.FTPPort) ? 21 : Convert.ToInt32(this.FTPPort),
                FTPRemoteFolderPath = this.FTPDownloadRemoteDirectoryLocaltion,
                LocalFolderPath = JobImportFolderPath,
            };
            FtpManager ftpClient = new FtpManager(ftpRequest);
            ftpClient.DownloadFiles();
            JobLogger.Info("Job preprocess (GenericDownloadFileFromFTP): Job is completed for job defination :" + this.IntegrationJob.JobDefinition.Name);
            return this.IntegrationJob;
        }
    }
}
