IF((SELECT COUNT(1) FROM dbo.ApplicationMessage where name = 'LNP_Elavon_Get_Token_Error_Message')>0)
BEGIN

UPDATE dbo.ApplicationMessage
SET Message = 'Something went wrong while placing the order, Please contact to Administrator.'
WHERE Name = 'LNP_Elavon_Get_Token_Error_Message'

END
ELSE
BEGIN

	INSERT INTO [dbo].[ApplicationMessage]
           ([Id]
           ,[Name]
           ,[Message]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[WebSiteId]
           ,[Description])
     VALUES
           (NEWID()
           ,'LNP_Elavon_Get_Token_Error_Message'
           ,'Something went wrong while placing the order, Please contact to Administrator.'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,NULL
           ,'')

END



IF((SELECT COUNT(1) FROM dbo.SystemList where name = 'ElavonErrorMessageList')>0)
BEGIN

UPDATE dbo.SystemList
SET Description = 'User Friendly Error Messages based on Elavon Responses'
WHERE Name = 'ElavonErrorMessageList'

END
ELSE
BEGIN

	INSERT INTO [dbo].SystemList
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
           ,'ElavonErrorMessageList'
           ,'User Friendly Error Messages based on Elavon Responses'
           ,''
           ,null
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM dbo.SystemListValue where SystemListId = (select Id from dbo.SystemList where Name='ElavonErrorMessageList') and Name = 'AMOUNT ERROR')>0)
BEGIN

UPDATE dbo.SystemListValue
SET Description = 'Something went wrong while placing the order, AMOUNT ERROR'
WHERE SystemListId = (select Id from dbo.SystemList where Name='ElavonErrorMessageList') and Name = 'AMOUNT ERROR'

END
ELSE
BEGIN

	INSERT INTO [dbo].SystemListValue
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
		   ,(select Id from dbo.SystemList where Name='ElavonErrorMessageList')
           ,'AMOUNT ERROR'
           ,'Something went wrong while placing the order, AMOUNT ERROR'
           ,''
           ,null
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin')

END