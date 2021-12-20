
if((select count(1) from [dbo].[ApplicationMessage] where name='AbandonedCart_PopupMessage_Title')=0)
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
           ,'AbandonedCart_PopupMessage_Title'
           ,'Abandoned Cart'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End