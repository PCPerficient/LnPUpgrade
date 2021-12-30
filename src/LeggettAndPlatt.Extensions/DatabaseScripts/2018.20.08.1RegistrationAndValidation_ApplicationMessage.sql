if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_Account_ClockNumberOrUniqueIDInvalidMsg')=0)
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
           ,'LNP_Account_ClockNumberOrUniqueIDInvalidMsg'
           ,'Clock Number or Unique ID not in valid format.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End

------------------------------------------------------------------------------------------------------------

if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_Account_NotAnActivEmployee_Msg')=0)
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
           ,'LNP_Account_NotAnActivEmployee_Msg'
           ,'No employee record found for Clock Number or Unique ID {0}.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End

-------------------------------------------------------------------------------------------------------------
if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_Account_AlreadyRegiter_UsingUniqueClock_Msg')=0)
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
           ,'LNP_Account_AlreadyRegiter_UsingUniqueClock_Msg'
           ,'Registration for Clock Number or Unique ID is already done. Please try using different details.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
-------------------------------------------------------------------------------------------------------------

if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_Account_UnableToCreateAccount_Msg')=0)
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
           ,'LNP_Account_UnableToCreateAccount_Msg'
           ,'Unable to create an account.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
-------------------------------------------------------------------------------------------------------------
if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_ActivateAccountSuccess_Msg')=0)
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
           ,'LNP_ActivateAccountSuccess_Msg'
           ,'Activation link successfully sent, please check email to activate your account.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
-------------------------------------------------------------------------------------------------------------
if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_Account_UniqueNumberOrClockId_Tooltip_Msg')=0)
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
           ,'LNP_Account_UniqueNumberOrClockId_Tooltip_Msg'
           ,'About Unique Number And Clock ID.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
-------------------------------------------------------------------------------------------------------------
if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_Account_ExceptionError_Msg')=0)
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
           ,'LNP_Account_ExceptionError_Msg'
           ,'An error has occurred. We apologize for the inconvenience.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End

