IF((SELECT COUNT(1) FROM dbo.ApplicationMessage where name = 'LNP_Order_Total_TBD_Msg')=0)
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
           ,'LNP_Order_Total_TBD_Msg'
           ,'Order total will be reflected while processing the order.'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,NULL
           ,'')

END