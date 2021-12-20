IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Refresh')=0)
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
           ,(SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnectionOrderStatus')
           ,'LNP Order History Refresh'
           ,'Refresh Order History from XML'
           ,'Refresh'
           ,1
           ,0
           ,''
           ,'Failure'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'OrderHistoryXml'
           ,'OrderHistoryRefresh'
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

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name ='FTPPort' AND JobDefinitionId IN (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Refresh'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,0
           ,'String'
           ,'21'
           ,''
           ,'FTPPort'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name ='FTPUsername' AND JobDefinitionId IN (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Refresh'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,0
           ,'String'
           ,'insite2btdev'
           ,''
           ,'FTPUsername'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name ='FTPDownloadRemoteDirectoryLocaltion' AND JobDefinitionId IN (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Refresh'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,0
           ,'String'
           ,'/Insite/BizTalkToInsite/OrderStatus/'
           ,''
           ,'FTPDownloadRemoteDirectoryLocaltion'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name ='FTPHost' AND JobDefinitionId IN (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Refresh'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,0
           ,'String'
           ,'10.21.9.82'
           ,''
           ,'FTPHost'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name ='FTPPassword' AND JobDefinitionId IN (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Refresh'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,0
           ,'String'
           ,'Showmust5tart'
           ,''
           ,'FTPPassword'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh'))=0 
AND (SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE Name = 'DownloadOrderStatusFiles')=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,1
           ,'DownloadOrderStatusFiles'
           ,''
           ,NULL
           ,'DownloadFilesFromFtp'
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
           ,'');
END
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh'))>0 
AND (SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE Name = 'OrderHistory')=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh')
           ,2
           ,'OrderHistory'
           ,''
           ,NULL
           ,''
           ,''
           ,'OMS_StatusUpdate_*.xml'
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
           ,'Ignore')

END
