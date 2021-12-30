
delete from applicationmessage where name='LNP_AddressConfirmationPopup_Msg'
--------------------------------------------------------------------------------------------------------------------
delete from applicationmessage where name='LNP_AddressValidation_ExceptionError_Msg'
--------------------------------------------------------------------------------------------------------------------
delete from applicationmessage where name='LNP_AddressValidationPopup_TopHeading_Msg'
---------------------------------------------------------------------------------------------------------------------
if((select count(1) from [dbo].[ApplicationMessage] where name='LNP_AddressValidationPopup_ConfirmationPopup_Msg')=0)
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
           ,'LNP_AddressValidationPopup_ConfirmationPopup_Msg'
           ,'Unable to verify address. Do you wish to continue?'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
Else
Begin
UPDATE dbo.ApplicationMessage
SET Message = 'Unable to verify address. Do you wish to continue?'
WHERE Name = 'LNP_AddressValidationPopup_ConfirmationPopup_Msg'
End
GO
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
           ,'USPS found the following address to use:'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
Else
Begin
UPDATE dbo.ApplicationMessage
SET Message = 'USPS found the following address to use:'
WHERE Name = 'LNP_AddressValidationPopup_CorrectedAddress_Msg'
End
GO
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
           ,'That wasn’t my address, please use this one:'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
Else
Begin
UPDATE dbo.ApplicationMessage
SET Message = 'That wasn’t my address, please use this one:'
WHERE Name = 'LNP_AddressValidationPopup_RequestedAddress_Msg'
End
GO
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
           ,'Please review your shipping address.'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End
Else
Begin
UPDATE dbo.ApplicationMessage
SET Message = 'Please review your shipping address.'
WHERE Name = 'LNP_AddressValidationPopup_Title_Msg'
End
GO