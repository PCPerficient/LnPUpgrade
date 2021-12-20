IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP Order Submit')>0)
BEGIN
INSERT INTO [dbo].[JobDefinitionParameter]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[ValueType]
           ,[DefaultValue]
           ,[Prompt]
           ,[Name]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order Submit')
           ,0
           ,'String'
           ,'1'
           ,''
           ,'ArchiveRetentionDays'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
END
