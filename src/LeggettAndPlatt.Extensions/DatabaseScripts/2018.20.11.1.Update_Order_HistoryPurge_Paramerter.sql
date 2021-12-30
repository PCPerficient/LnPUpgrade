IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE [Name] = 'RetentionDays' AND JobDefinitionId = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Purge'))>0)
BEGIN
UPDATE [dbo].[JobDefinitionParameter] SET [Name] = 'RetentionWindow' WHERE [Id] = (SELECT Id FROM [dbo].[JobDefinitionParameter] WHERE [Name] = 'RetentionDays' AND  JobDefinitionId = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Purge'))
END

