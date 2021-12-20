

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Images Import')=0)
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
           ,(SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnectionPIM')
           ,'LNP PIM Images Import'
           ,'Import Files From Pim Server To Local Path'
           ,'Import'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'None'
           ,'None'
           ,NULL
           ,''
           ,''
           ,0
           ,NULL
           ,NULL
           ,1
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
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name='FTPSRemoteFolderPath' AND JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name ='LNP PIM Images Import'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Images Import')
           ,0
           ,'String'
           ,'/LPPMCOutbound/B2B/EmployeeResource/'
           ,''
           ,'FTPSRemoteFolderPath'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

END
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE Name='DownloadFilesWithSecureConnection' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Images Import'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Images Import')
           ,1
           ,'DownloadFilesWithSecureConnection'
           ,''
           ,(SELECT Id from IntegrationConnection WHERE Name ='PIMFtpsConnection')
           ,'DownloadFilesFromFtpsPIM'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'')

END
