IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD') AND RoleName='ISC_StoreFrontApi')>0)
BEGIN 
	UPDATE [AppDict].[PropertyPermission] SET CanView=NULL,CanEdit=NULL
	WHERE PropertyConfigurationId=(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='isTaxTBD')
	AND RoleName='ISC_StoreFrontApi'
END

IF((SELECT COUNT(1) FROM dbo.ApplicationMessage where name = 'LNP_Vertex_Tax_TBD_Msg')=0)
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
           ,'LNP_Vertex_Tax_TBD_Msg'
           ,'There is some error in calculating tax. It will be reflected while processing the order.'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,NULL
           ,'')

END