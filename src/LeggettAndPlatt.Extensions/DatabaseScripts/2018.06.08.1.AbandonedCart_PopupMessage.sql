
if((select count(1) from [dbo].[ApplicationMessage] where name='AbandonedCart_PopupMessage')=0)
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
           ,'AbandonedCart_PopupMessage'
           ,'You have left item(s) in your cart, please complete the checkout process to get this item(s).'
           , GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,null)
End