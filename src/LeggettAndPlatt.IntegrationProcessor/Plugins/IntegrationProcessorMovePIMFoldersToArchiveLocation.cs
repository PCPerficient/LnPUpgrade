using Insite.WIS.Broker;
using Insite.WIS.Broker.Interfaces;
using Insite.WIS.Broker.WebIntegrationService;
using Ionic.Zip;
using System;
using System.Data;
using System.IO;


namespace LeggettAndPlatt.IntegrationProcessor.Plugins
{
    public class IntegrationProcessorMovePIMFoldersToArchiveLocation : IIntegrationProcessor
    {
        public virtual DataSet Execute(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
            int jobNumber = integrationJob.JobDefinition.IntegrationJobs[0].JobNumber;

            string importFolder = integrationJob.JobDefinition.IntegrationConnection.Url;

            string archiveFolder = integrationJob.JobDefinition.IntegrationConnection.ArchiveFolder;

            var directories = Directory.GetDirectories(importFolder);

            using (ZipFile zipFile = new ZipFile())
            {
                string str4 = Path.Combine(importFolder, "IntegrationJob_" + jobNumber);
                Directory.CreateDirectory(str4);

                foreach (string directory in directories)
                {
                    int idx = directory.LastIndexOf('\\');
                    string dirName = directory.Substring(idx + 1);
                    if (dirName != "BadFiles" && dirName != "Errors")
                    {
                        string str5 = Path.Combine(str4, dirName);
                        if (Directory.Exists(str5))
                        {
                            Directory.Move(directory, str5 + DateTime.Now.ToString("_MMMdd_yyyy_HHmmss"));
                        }
                        else
                        {
                            Directory.Move(directory, str5);
                        }
                    }
                }

                zipFile.AddDirectory(str4);
                string fileName = Path.Combine(archiveFolder, string.Format("LNP_IntegrationJob_{0}.zip", (object)jobNumber));
                zipFile.Save(fileName);
                Directory.Delete(str4, true);
            }

            DataSet dataSet = new DataSet();
            return dataSet;
        }
    }
}