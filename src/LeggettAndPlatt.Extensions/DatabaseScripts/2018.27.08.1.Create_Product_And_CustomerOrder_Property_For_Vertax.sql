IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId')=0)
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='product')
           ,'vertaxTaxAreaId'
           ,''
           ,'Vertax Tax Area Id'
           ,'Insite.Admin.ControlTypes.TextFieldControl'
           ,0
           ,0
           ,'Seller TaxAreaId for calculate Tax'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Seller TaxAreaId for calculate Tax'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),0,0)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxTaxAreaId'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END



IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity')=0)
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='product')
           ,'vertaxLegalEntity'
           ,''
           ,'Vertax Legal Entity'
           ,'Insite.Admin.ControlTypes.TextFieldControl'
           ,0
           ,0
           ,'Seller Legal Entity for calculate Tax'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Seller Legal Entity for calculate Tax'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),0,0)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxLegalEntity'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END


IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch')=0)
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='product')
           ,'vertaxBranch'
           ,''
           ,'Vertax Branch'
           ,'Insite.Admin.ControlTypes.TextFieldControl'
           ,0
           ,0
           ,'Seller Branch for calculate Tax'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Seller Branch for calculate Tax'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),0,0)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='vertaxBranch'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END


IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD')=0)
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
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),0,0)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END




