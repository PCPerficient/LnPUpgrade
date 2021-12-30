IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified')=0)
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
           ,'isAddressVerified'
           ,''
           ,'Is Address Verified'
           ,'Insite.Admin.ControlTypes.ToggleSwitchControl'
           ,0
           ,0
           ,'This flag is set when address is verified'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'This flag is set when address is verified'
           ,'System.Boolean, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),0,0)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isAddressVerified'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END


----------------------------------------------------------------------------------------------------


if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_AddressValidation_ExceptionError_Msg')=0)
BEGIN
INSERT INTO [dbo].[ApplicationMessage]
           ([Id]
           ,[Name]
           ,[Message]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[WebSiteId])
     VALUES
           (NEWID()
           ,'LNP_AddressValidation_ExceptionError_Msg'
           ,'An error has occurred. We apologize for the inconvenience.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
---------------------------------------------------------------------------------------------------

if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_AddressValidationPopup_Title_Msg')=0)
BEGIN
INSERT INTO [dbo].[ApplicationMessage]
           ([Id]
           ,[Name]
           ,[Message]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[WebSiteId])
     VALUES
           (NEWID()
           ,'LNP_AddressValidationPopup_Title_Msg'
           ,'Please Review Your Address Information For Shipping.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End

---------------------------------------------------------------------------------------------------

if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_AddressValidationPopup_TopHeading_Msg')=0)
BEGIN
INSERT INTO [dbo].[ApplicationMessage]
           ([Id]
           ,[Name]
           ,[Message]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[WebSiteId])
     VALUES
           (NEWID()
           ,'LNP_AddressValidationPopup_TopHeading_Msg'
           ,'We could not find an exact match for what you entered with Vertex Service. Please choose the most accurate address in order to expedite your order.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End

---------------------------------------------------------------------------------------------------

if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_AddressValidationPopup_RequestedAddress_Msg')=0)
BEGIN
INSERT INTO [dbo].[ApplicationMessage]
           ([Id]
           ,[Name]
           ,[Message]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[WebSiteId])
     VALUES
           (NEWID()
           ,'LNP_AddressValidationPopup_RequestedAddress_Msg'
           ,'Keep my address information as I entered it.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
---------------------------------------------------------------------------------------------------
if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_AddressValidationPopup_CorrectedAddress_Msg')=0)
BEGIN
INSERT INTO [dbo].[ApplicationMessage]
           ([Id]
           ,[Name]
           ,[Message]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[WebSiteId])
     VALUES
           (NEWID()
           ,'LNP_AddressValidationPopup_CorrectedAddress_Msg'
           ,'Use a Vertex suggestion below.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
---------------------------------------------------------------------------------------------------

