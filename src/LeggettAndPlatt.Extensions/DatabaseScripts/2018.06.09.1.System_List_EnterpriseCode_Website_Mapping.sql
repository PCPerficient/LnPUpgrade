IF((select count(1) from [SystemList] where [name]='WebsiteEnterpriseCodeMapping')=0)
BEGIN
INSERT INTO [dbo].[SystemList]
           ([Id]
           ,[Name]
           ,[Description]
           ,[AdditionalInfo]
           ,[DeactivateOn]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'WebsiteEnterpriseCodeMapping'
           ,'Website Enterprise Code Mapping'
           ,'This List is used to identify the website mapping while sending OMS emails.'
           ,null
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin')
END


if((select count(1) from [SystemListValue] where [name]='LP_DRIFT_STORE')=0)
BEGIN
INSERT INTO [dbo].[SystemListValue]
           ([Id]
           ,[SystemListId]
           ,[Name]
           ,[Description]
           ,[AdditionalInfo]
           ,[DeactivateOn]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(Select id from [SystemList] where name='WebsiteEnterpriseCodeMapping')
           ,'LP_DRIFT_STORE'
           ,'Driftotr'
           ,''
           ,null
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin')

End

if((select count(1) from [SystemListValue] where [name]='LP_EMP_STORE')=0)
BEGIN
INSERT INTO [dbo].[SystemListValue]
           ([Id]
           ,[SystemListId]
           ,[Name]
           ,[Description]
           ,[AdditionalInfo]
           ,[DeactivateOn]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(Select id from [SystemList] where name='WebsiteEnterpriseCodeMapping')
           ,'LP_EMP_STORE'
           ,'Employee'
           ,''
           ,null
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin')

End