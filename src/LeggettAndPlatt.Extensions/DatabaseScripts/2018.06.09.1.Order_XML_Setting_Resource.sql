IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP Order Submit')=0)
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
           ,'LNP Order Submit'
           ,'To execute the job on order submit for generate the order xml file on local server and upload it on remote server'
           ,'Submit'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'GenericSubmit'
           ,'OrderSubmit'
           ,'ProcessOrderSubmitResponse'
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
           ,'OrderSubmit')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order Submit'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'C:\Program Files\Insite Software\Commerce Integration Service V4.4\OrderXML\'
           ,''
           ,'OrderXmlLocalDirectoryPath'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'insite2btdev'
           ,''
           ,'FTPUsername'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'10.21.9.82'
           ,''
           ,'FTPHost'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'Insite/InsiteToBizTalk'
           ,''
           ,'FTPUploadDirectoryLocation'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'Showmust5tart'
           ,''
           ,'FTPPassword'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'21'
           ,''
           ,'FTPPort'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');

END
IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE [JobDefinitionId]=(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,1
           ,'LNP Submit Order'
           ,'customerOrder'
           ,NULL
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

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStepParameter] WHERE [JobDefinitionStepId]=(SELECT Id FROM JobDefinitionStep WHERE JobDefinitionId=(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionStepParameter]
           ([Id]
           ,[JobDefinitionStepId]
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
           ,(SELECT Id FROM JobDefinitionStep WHERE JobDefinitionId=(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit'))
           ,1
           ,'String'
           ,''
           ,''
           ,'OrderNumber'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'OrderSubmit_ErpSubmitOrders')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'true'
WHERE Name = 'OrderSubmit_ErpSubmitOrders'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'OrderSubmit_ErpSubmitOrders',NULL,'true',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'OrderSubmit_SubmitAllPaymentInfo')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'true'
WHERE Name = 'OrderSubmit_SubmitAllPaymentInfo'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'OrderSubmit_SubmitAllPaymentInfo',NULL,'true',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END


IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp')=0)
BEGIN

INSERT INTO [AppDict].[PropertyConfiguration]
           ([Id]
           ,[EntityConfigurationId]
           ,[Name]
           ,[ParentProperty]
           ,[Label]
           ,[ControlType]
           ,[IsRequired]
           ,[IsTranslatable]
           ,[HintText]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[ToolTip]
           ,[PropertyType]
           ,[IsCustomProperty]
           ,[CanView]
           ,[CanEdit]
           ,[HintTextPropertyName])
     VALUES
           (NEWID(),
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='customerOrder')
           ,'isOrderSendToFtp'
           ,''
           ,'Is Order Send To Ftp'
           ,'Insite.Admin.ControlTypes.ToggleSwitchControl'
           ,0
           ,0
           ,'This flag is set true if order xml is uploded on remote server '
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Flag to indicate that order xml is sent to remote server or not'
           ,'System.Boolean, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isOrderSendToFtp'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END
