

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP Console User Export')=0)
BEGIN
INSERT INTO [dbo].[JobDefinition]
           ([Id]
           ,[IntegrationConnectionId]
           ,[Name]
           ,[Description]
           ,[JobType]
           ,[DebuggingEnabled]
           ,[PassThroughJob]
           ,[NotifyEmail]
           ,[NotifyCondition]
           ,[LinkedJobId]
           ,[PassDataSetToLinkedJob]
           ,[UseDeltaDataSet]
           ,[PreProcessor]
           ,[IntegrationProcessor]
           ,[PostProcessor]
           ,[LastRunDateTime]
           ,[LastRunJobNumber]
           ,[LastRunStatus]
           ,[RecurringJob]
           ,[RecurringStartDateTime]
           ,[RecurringEndDateTime]
           ,[RecurringInterval]
           ,[RecurringType]
           ,[RecurringStartTime]
           ,[RecurringStartDay]
           ,[EmailTemplateId]
           ,[RunStepsInParallel]
           ,[LinkedJobCondition]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[MaxErrorsBeforeFail]
           ,[MaxWarningsBeforeFail]
           ,[MaxRetries]
           ,[MaxDeactivationPercent]
           ,[MaxTimeoutMinutes]
           ,[StandardJobName])
     VALUES
           (NEWID()
           ,(SELECT Id FROM IntegrationConnection WHERE Name='LocalSQLConnection')
           ,'LNP Console User Export'
           ,'Export the console users information with roles and upload it on remote ftp localtion'
           ,'Export'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'ConsoleUserExport'
           ,'ConsoleUserExport'
           ,'None'
           ,NULL
           ,''
           ,''
           ,1
           ,'2018-11-17 23:00:00.0000000 +05:30'
           ,NULL
           ,7
           ,'Days'
           ,NULL
           ,0
           ,NULL
           ,0
           ,'SuccessOnly'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,0
           ,0
           ,0
           ,0
           ,'')
END
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name='SystemColumnValueInExcel' AND JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Console User Export'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[ValueType]
           ,[DefaultValue]
           ,[Prompt]
           ,[Name]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Console User Export')
           ,0
           ,'String'
           ,'InSite'
           ,''
           ,'SystemColumnValueInExcel'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

END
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name='ConsoleUserExportFileName' AND JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Console User Export'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[ValueType]
           ,[DefaultValue]
           ,[Prompt]
           ,[Name]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Console User Export')
           ,0
           ,'String'
           ,'InSite_User.csv'
           ,''
           ,'ConsoleUserExportFileName'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

END
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name='FTPUploadDirectoryLocation' AND JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Console User Export'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[ValueType]
           ,[DefaultValue]
           ,[Prompt]
           ,[Name]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Console User Export')
           ,0
           ,'String'
           ,'/Home/DC_Reports/'
           ,''
           ,'FTPUploadDirectoryLocation'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name='LocalDirectoryPath' AND JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Console User Export'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[ValueType]
           ,[DefaultValue]
           ,[Prompt]
           ,[Name]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Console User Export')
           ,0
           ,'String'
           ,'C:\PerficientData\Developers\FlatFile\Dev_Archive\ConsoleUser\'
           ,''
           ,'LocalDirectoryPath'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

END 

IF((SELECT COUNT(1) FROM [dbo].[IntegrationConnection] WHERE Name='LNPConsoleUserExportConnection')=0)
BEGIN

INSERT INTO [dbo].[IntegrationConnection]
           ([Id]
           ,[Name]
           ,[TypeName]
           ,[DataSource]
           ,[RunsOn]
           ,[DebuggingEnabled]
           ,[Delimiter]
           ,[Url]
           ,[LogOn]
           ,[Password]
           ,[ConnectionString]
           ,[ArchiveFolder]
           ,[ArchiveRetentionDays]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[IntegratedSecurity]
           ,[SystemNumber]
           ,[Client]
           ,[Language]
           ,[ConnectionsLimit]
           ,[ConnectionTimeout]
           ,[AppServerHost]
           ,[AppServerService]
           ,[MessageServerHost]
           ,[MessageServerService]
           ,[GatewayHost]
           ,[GatewayService]
           ,[SystemId]
           ,[SystemIds]
           ,[LogonGroup]
           ,[SourceServerTimeZone])
     VALUES
           (NEWID()
           ,'LNPConsoleUserExportConnection'
           ,'ApiEndpoint'
           ,''
           ,''
           ,1
           ,','
           ,'12.51.139.190'
           ,'dcreports'
           ,'EL3POU7NvU3jO4J3oaqQ9w=='
           ,''
           ,''
           ,30
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,'Central Standard Time')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE Name='UploadConsoleUserExelFile' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Console User Export'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionStep]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[Name]
           ,[ObjectName]
           ,[IntegrationConnectionOverrideId]
           ,[IntegrationProcessorOverride]
           ,[SelectClause]
           ,[FromClause]
           ,[WhereClause]
           ,[ParameterizedWhereClause]
           ,[DeleteAction]
           ,[DeleteActionFieldToSet]
           ,[DeleteActionValueToSet]
           ,[SkipHeaderRow]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[FlatFileErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Console User Export')
           ,1
           ,'UploadConsoleUserExelFile'
           ,''
           ,(SELECT Id from IntegrationConnection WHERE Name ='LNPConsoleUserExportConnection')
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'')

END
