IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Order Notifications')=0)
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
           ,(SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnection')
           ,'LNP OMS Order Notifications'
           ,'Send Email Notifications for OMS Orders.'
           ,'Refresh'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'None'
           ,'LNPJobPostprocessorConfirmationsAndMail'
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

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Order Notifications'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),0,'String','10.21.9.82','','FTPHostName',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),1,'String','21','','FTPPort',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),2,'String','insite2btdev','','FTPLogOnName',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),3,'String','Showmust5tart','','FTPPassword',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),4,'String','/Insite/OMS/OrderConfirmation','','FTPOrderConfirmationDirectoryPath',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),5,'String','/Insite/OMS/Shipment','','FTPShipmmentPath',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),6,'String','/Insite/OMS/Cancellation','','FTPCancellationPath',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),7,'String',',','','FTPFileColumnDelimeter',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),8,'String','\n','','FTPFileNewLineSeperator',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),9,'String','','','LocalDownloadPath',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
END