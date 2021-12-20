IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='btFirstName'  AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0  )
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
           ,'btFirstName'
           ,''
           ,'BT First Name'
           ,''
           ,0
           ,0
           ,'Bill To First Name'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Bill To First Name'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END









IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'btLastName'
           ,''
           ,'BT Last Name'
           ,''
           ,0
           ,0
           ,'Bill To Last Name'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Bill To Last Name'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END









IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'stLastName'
           ,''
           ,'ST Last Name'
           ,''
           ,0
           ,0
           ,'Ship To Last Name'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Ship To Last Name'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stLastName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END











IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'stFirstName'
           ,''
           ,'ST First Name'
           ,''
           ,0
           ,0
           ,'Ship To First Name'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Ship To First Name'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stFirstName' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END







IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'stEmail'
           ,''
           ,'ST Email'
           ,''
           ,0
           ,0
           ,'Ship To Email'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Ship To Email'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END






IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'btEmail'
           ,''
           ,'BT Email'
           ,''
           ,0
           ,0
           ,'Bill To Email'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Bill To Email'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btEmail' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END









IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'stPhone'
           ,''
           ,'ST Phone'
           ,''
           ,0
           ,0
           ,'Ship To Phone'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Ship To Phone'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='stPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END







IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory'))=0)
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
           ,'btPhone'
           ,''
           ,'BT Phone'
           ,''
           ,0
           ,0
           ,'Bill To Phone'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Bill To Phone'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END
--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='btPhone' AND EntityConfigurationId =(SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='orderHistory')),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END

