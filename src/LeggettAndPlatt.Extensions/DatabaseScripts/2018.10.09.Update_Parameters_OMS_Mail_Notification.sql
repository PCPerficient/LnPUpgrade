IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP OMS Order Notifications') and Name='ArchiveRetentionDays')=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter] VALUES (NEWID(),(SELECT Id FROM JobDefinition WHERE Name='LNP OMS Order Notifications'),10,'String','30','','ArchiveRetentionDays',GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin')
END