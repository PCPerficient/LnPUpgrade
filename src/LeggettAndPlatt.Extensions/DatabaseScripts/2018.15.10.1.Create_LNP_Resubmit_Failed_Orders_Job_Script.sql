IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP Resubmit Failed Orders')=0)
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
           ,'LNP Resubmit Failed Orders'
           ,'Resubmit the failed orders'
           ,'Submit'
           ,1
           ,0
           ,''
           ,'Failure'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'None'
           ,'LNPResubmitFailedOrders'
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



IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [Name] ='LNP Submit Order' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit'))=0)
BEGIN

UPDATE [dbo].[JobDefinitionStep] SET [IntegrationConnectionOverrideId] =(SELECT Id FROM IntegrationConnection WHERE Name='DriftFtpConnection') WHERE  [Name] ='LNP Submit Order' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit') AND [IntegrationConnectionOverrideId] IS null;

END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [Name] ='DownloadFiles' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh'))=0)
BEGIN

UPDATE [dbo].[JobDefinitionStep] SET [IntegrationConnectionOverrideId] =(SELECT Id FROM IntegrationConnection WHERE Name='DriftFtpConnection') WHERE  [Name] ='DownloadFiles' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Refresh') AND [IntegrationConnectionOverrideId] IS null;

END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [Name] ='DownloadFiles' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product'))=0)
BEGIN

UPDATE [dbo].[JobDefinitionStep] SET [IntegrationConnectionOverrideId] = (SELECT Id FROM IntegrationConnection WHERE Name='DriftFtpConnection') WHERE  [Name] ='DownloadFiles' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product') AND [IntegrationConnectionOverrideId] IS null;

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [Name] ='DownloadFiles' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'))=0)
BEGIN

UPDATE [dbo].[JobDefinitionStep] SET [IntegrationConnectionOverrideId] = (SELECT Id FROM IntegrationConnection WHERE Name='DriftFtpConnection') WHERE  [Name] ='DownloadFiles' AND [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications') AND [IntegrationConnectionOverrideId] IS null;

END
