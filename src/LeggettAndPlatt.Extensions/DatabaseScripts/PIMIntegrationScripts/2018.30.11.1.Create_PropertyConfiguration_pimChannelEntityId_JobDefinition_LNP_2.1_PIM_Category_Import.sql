IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId'  AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website'))=0  )
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')
           ,'pimChannelEntityId'
           ,''
           ,'PIM Channel EntityId'
           ,'Insite.Admin.ControlTypes.TextFieldControl'
           ,0
           ,0
           ,'PIM Channel EntityId'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'PIM Channel EntityId'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

GO

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_CreativeServices','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_LP_Security','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_ReadOnly','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_Security','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),0,0)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='pimChannelEntityId' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='website')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END


GO




--Inserting value for property
IF((select count(1) from CustomProperty where name = 'pimChannelEntityId' and ParentId = (select Id from WebSite where Name = 'Employee'))=0)
BEGIN 

INSERT INTO [dbo].[CustomProperty]
           ([Id]
           ,[ParentId]
           ,[Name]
           ,[Value]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[ParentTable])
     VALUES
           (NEWID()
           ,(select Id from WebSite where Name = 'Employee')
           ,'pimChannelEntityId'
           ,''
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Website')

END

GO



IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')=0)
BEGIN
update [dbo].[JobDefinition] set name = 'LNP 2.00 PIM Files Import' WHERE Name='LNP PIM Files Import';
END

GO

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.10 PIM Category Import')=0)
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
           ,'LNP 2.10 PIM Category Import'
           ,'Import Category from PIM Temp table'
           ,'Refresh'
           ,0
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'None'
           ,'ExecuteStoredProcedureLNP'
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

GO


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId = (SELECT id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.10 PIM Category Import') and Name='IntegrationJobId')=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP 2.10 PIM Category Import')
           ,0
           ,'String'
           ,''
           ,''
           ,'IntegrationJobId'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
END

GO



IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId = (SELECT id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.10 PIM Category Import') and Name='StoredProcedureName')=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP 2.10 PIM Category Import')
           ,0
           ,'String'
           ,'PRFTImportCategoryDelta'
           ,''
           ,'StoredProcedureName'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
END



GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PIMChannelNode_Locale')
BEGIN
CREATE TABLE [dbo].[PIMChannelNode_Locale](
	[EntityId] [int] NOT NULL,
	[LanguageCode] [nvarchar](50) NULL,
	[ChannelNodeName] [nvarchar](max) NULL
)

END


GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PRFTCategoryExtension')
BEGIN
	CREATE TABLE dbo.PRFTCategoryExtension
		(
			ID UNIQUEIDENTIFIER
			,CategoryID UNIQUEIDENTIFIER
			,PIMEntityID INT
			,PIMChannelNodeIsActive BIT
			,PIMLinkInActive BIT
			CONSTRAINT [PK_PRFTCategoryExtension] PRIMARY KEY CLUSTERED 
			(
				[Id] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		)
	ALTER TABLE [dbo].[PRFTCategoryExtension]  WITH CHECK ADD  CONSTRAINT [FK_PRFTCategoryExtension_Category] FOREIGN KEY([CategoryID])
		REFERENCES [dbo].[Category] ([Id]) ON DELETE CASCADE
END

GO


