IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage'))=0)
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
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')
           ,'trackingUrl'
           ,''
           ,'Tracking Url'
           ,''
           ,0
           ,0
           ,'Shipment Tracking Url'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Shipment Tracking Url'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='trackingUrl' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='shipmentPackage')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END
