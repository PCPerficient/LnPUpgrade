
IF((SELECT COUNT(1) FROM [dbo].[IntegrationConnection] WHERE Name='FlatFileConnectionPIMImages')=0)
BEGIN
INSERT INTO [dbo].[IntegrationConnection]
		   ([Id]
		   ,[Name]
		   ,[TypeName]
		   ,[DataSource]
		   ,[RunsOn]
		   ,[DebuggingEnabled]
		   ,[Delimiter]
		   ,[Url]
		   ,[LogOn]
		   ,[Password]
		   ,[ConnectionString]
		   ,[ArchiveFolder]
		   ,[ArchiveRetentionDays]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy]
		   ,[IntegratedSecurity]
		   ,[SystemNumber]
		   ,[Client]
		   ,[Language]
		   ,[ConnectionsLimit]
		   ,[ConnectionTimeout]
		   ,[AppServerHost]
		   ,[AppServerService]
		   ,[MessageServerHost]
		   ,[MessageServerService]
		   ,[GatewayHost]
		   ,[GatewayService]
		   ,[SystemId]
		   ,[SystemIds]
		   ,[LogonGroup]
		   ,[SourceServerTimeZone])
	 VALUES
		   (NEWID()
		   ,'FlatFileConnectionPIMImages'
		   ,'FlatFile'
		   ,''
		   ,''
		   ,1
		   ,','
		   ,'E:\Project2018\LAndPCommerceFoundation\Dev\LeggettAndPlatt.Web\UserFiles\Images\PIMImages'
		   ,''
		   ,''
		   ,''
		   ,''
		   ,30
		   ,GETUTCDATE()
		   ,'admin_admin'
			,GETUTCDATE()
		   ,'admin_admin'
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,'Central Standard Time')
END

IF((SELECT COUNT(1) FROM [dbo].[IntegrationConnection] WHERE Name='FlatFileConnectionPIMImages') > 0 AND (SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Images Import') >0 )
BEGIN
UPDATE [dbo].[JobDefinition] SET [IntegrationConnectionId] = (SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnectionPIMImages') WHERE Name='LNP PIM Images Import';
END