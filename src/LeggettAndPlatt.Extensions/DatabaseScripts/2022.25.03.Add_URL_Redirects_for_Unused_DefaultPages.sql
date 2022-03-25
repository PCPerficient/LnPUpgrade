IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/ChangeCustomer' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/ChangeCustomer'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END
IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/UserAdministration' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/UserAdministration'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END
IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/Budget' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/Budget'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END
IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/JobQuote/MyJobQuotes' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/JobQuote/MyJobQuotes'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/Requisitions' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/Requisitions'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/Rfq/MyQuotes' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/Rfq/MyQuotes'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/MyAccount/SavedPayments' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/MyAccount/SavedPayments'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/Requisition/Confirmation' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/Requisition/Confirmation'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/Rfq/Confirmation' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/Rfq/Confirmation'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/Rfq' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/Rfq'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/Catalog/ProductComparison' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/Catalog/ProductComparison'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END


IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/OrderStatus' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/OrderStatus'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END


IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/StaticList' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/StaticList'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

IF((SELECT COUNT(1) FROM [dbo].[HtmlRedirect] WHERE [OldUrl] = '/ContactCustomerService' and [NewUrl]= '/error?errorCode=404')=0)
BEGIN
INSERT INTO [dbo].[HtmlRedirect]
           ([Id]
           ,[OldUrl]
           ,[NewUrl]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,'/ContactCustomerService'
           ,'/error?errorCode=404'
            ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')

END

