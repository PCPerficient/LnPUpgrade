
using Insite.Common.Helpers;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Security;
using Insite.Core.Security;
using Insite.Data.Entities;
using Insite.Integration.WebService.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Preprocessor.ConsoleUser
{
  
    [DependencyName("ConsoleUserExport")]
    
    public class JobPreprocessorConsoleUserExport : IJobPreprocessor, ITransientLifetime, IDependency, IExtension
    {
        protected readonly IUnitOfWork UnitOfWork;
        public IJobLogger JobLogger { get; set; }
        protected IRepository<AdminUserProfile> adminUserProfileRepository;
        protected readonly IAuthenticationService AuthenticationService;

        DataSet adminUserProfileDataset;
        DataTable adminUserProfileDataTable;

        protected DataSet consoleUsersDataSet;
        IEnumerable<AdminUserProfile> adminUserProfiles;
        public JobPreprocessorConsoleUserExport(IUnitOfWorkFactory unitOfWorkFactory, IAuthenticationService authenticationService)
        {
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.AuthenticationService = authenticationService;
            this.adminUserProfileRepository = UnitOfWork.GetRepository<AdminUserProfile>();
        }

        public IntegrationJob IntegrationJob { get; set; }
     
        public IntegrationJob Execute()
        {
                   
            try
            {
                this.JobLogger.Info("Console user export create dataset start.");
                CreateDataset();
                this.JobLogger.Info("Console user export create dataset end.");
            }
            catch (Exception ex)
            {
                this.JobLogger.Error(string.Format("Exception : Admin profile export Error: {0} \n Exception Message : {1}", ex, ex.Message));
                throw;
            }
            this.IntegrationJob.InitialData = XmlDatasetManager.ConvertDatasetToXml(this.adminUserProfileDataset);
            return this.IntegrationJob;
        }
        private void CreateDataset()
        {
            this.adminUserProfileDataset = new DataSet();
            this.CreateTable();
            this.JobLogger.Info("Add data row start.");
            this.adminUserProfiles = this.adminUserProfileRepository.GetTable().OrderBy(o => o.UserName).ToList();
            string systemColumnValue = this.GetSystemColumnValue();
            foreach (var adminProfile in adminUserProfiles)
            {

                var roles =  this.AuthenticationService.GetRolesForUser(AdminUserNameHelper.AddPrefix(adminProfile.UserName)).Select<RoleDto, string>((Func<RoleDto, string>)(x => x.RoleName)).AsQueryable<string>();
                foreach (string role in roles)
                {
                    this.adminUserProfileDataTable.Rows.Add(
                    systemColumnValue,
                    adminProfile.UserName,
                    adminProfile.FirstName,
                    adminProfile.LastName,
                    adminProfile.Email,
                    (adminProfile.IsDeactivated)? 0 : 1 ,
                    role,
                    this.GetRequiredDateFormat(adminProfile.LastLoginOn.ToString(), "MM/dd/yyyy hh:mm tt"),
                    this.GetRequiredDateFormat(DateTime.Now.ToString(), "MM/dd/yyyy")
                    );
                }
                
            }
            this.JobLogger.Info("Add data row end.");
            this.adminUserProfileDataset.Tables.Add(this.adminUserProfileDataTable);
        }
        private string GetSystemColumnValue()
        {
            IntegrationJobParameter[] integrationJobParameters = this.IntegrationJob.IntegrationJobParameters.Where(
              x => x.JobDefinitionParameter != null
              ).ToArray();
            IntegrationJobParameter integrationJobParameter = integrationJobParameters.FirstOrDefault<IntegrationJobParameter>((Func<IntegrationJobParameter, bool>)(p => p.JobDefinitionParameter.Name.EqualsIgnoreCase("SystemColumnValueInExcel")));
            if (integrationJobParameter != null)
                return integrationJobParameter.Value.ToString();
           
            return (string)null;
            
        }
        private void CreateTable()
        {
            this.JobLogger.Info("Create data table start.");
            this.adminUserProfileDataTable = new DataTable("adminUserProfile");
            this.adminUserProfileDataTable.Columns.Add("System");
            this.adminUserProfileDataTable.Columns.Add("User id");
            this.adminUserProfileDataTable.Columns.Add("Firstname");
            this.adminUserProfileDataTable.Columns.Add("Lastname");
            this.adminUserProfileDataTable.Columns.Add("Email");
            this.adminUserProfileDataTable.Columns.Add("Enabled");
            this.adminUserProfileDataTable.Columns.Add("Rolename");
            this.adminUserProfileDataTable.Columns.Add("lastlogon");
            this.adminUserProfileDataTable.Columns.Add("ExtractedDate");
            this.JobLogger.Info("Create data table end.");
        }
        private string GetRequiredDateFormat(string originalDate,string format)
        {
            if (originalDate.Length > 0)
            {
                DateTime _date;
                string formatedDate = "";
                _date = DateTime.Parse(originalDate);
                formatedDate = _date.ToString(format);
                return formatedDate;
            }
            return originalDate;       
        }
    }
}
