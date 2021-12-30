IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')=0)
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
           ,'LNP OMS Pricing For Product'
           ,'Update drift product pricing using flat file provided by OMS'
           ,'Import'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'GenericDownloadFileFromFTP'
           ,'FlatFile'
           ,'FieldMap'
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
           ,'SuccessWarningErrorOrFailure'
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



IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product'))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product'),0,'String','10.21.9.82','','FTPHost',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product'),1,'String','insite2btdev','','FTPUsername',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product'),2,'String','Showmust5tart','','FTPPassword',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product'),3,'String','21','','FTPPort',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product'),4,'String','/Insite/OMS/DriftProductPrice/','','FTPDownloadRemoteDirectoryLocaltion',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Pricing For Product')
           ,1
           ,'ImportPrice'
           ,'product'
           ,NULL
           ,''
           ,'Product Number,Unit Of Measure,Basic List Price,Basic Sale Price,Basie Sale Start Date,Basic Sale End Date'
           ,'OMS_PricingUpdate_*.csv'
           ,''
           ,''
           ,'Ignore'
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Warning')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStepFieldMap] WHERE JobDefinitionStepId in(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')),'Field','Basie Sale Start Date','BasicSaleStartDate',1,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')),'Field','Unit Of Measure','UnitOfMeasure',1,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')),'Field','Basic Sale End Date','BasicSaleEndDate',1,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')),'Field','Basic Sale Price','BasicSalePrice',1,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')),'Field','Product Number','ErpNumber',0,1,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Pricing For Product')),'Field','Basic List Price','BasicListPrice',1,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
END