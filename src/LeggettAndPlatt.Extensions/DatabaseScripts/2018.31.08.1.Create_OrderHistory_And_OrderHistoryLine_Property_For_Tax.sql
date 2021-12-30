IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')
           ,'isTaxTBD'
           ,''
           ,'Is Tax TBD'
           ,'Insite.Admin.ControlTypes.ToggleSwitchControl'
           ,0
           ,0
           ,'This flag is set when vertex tax api is down'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'This flag is set when vertex tax api is down'
           ,'System.Boolean, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END




IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine'))=0)
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')
           ,'taxAmount'
           ,''
           ,'Tax Amount'
           ,'Insite.Admin.ControlTypes.DecimalFieldControl'
           ,0
           ,0
           ,'Vertex Line item level tax'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Vertex Line item level tax'
           ,'System.Decimal, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='taxAmount' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistoryLine')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END

