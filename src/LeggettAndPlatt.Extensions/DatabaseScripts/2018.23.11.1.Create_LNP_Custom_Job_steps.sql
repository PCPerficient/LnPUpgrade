IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Link' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Link.csv' WHERE name='Link' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Channel' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Entity_Channel.csv' WHERE name='Channel' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='ChannelNode' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Entity_ChannelNode.csv' WHERE name='ChannelNode' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Item' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Entity_Item.csv' WHERE name='Item' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Product' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Entity_Product.csv' WHERE name='Product' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Product' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Entity_Product.csv' WHERE name='Product' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Resource' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set FromClause = 'Entity_Resource.csv' WHERE name='Resource' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='MovePIMFoldersToArchiveLocation' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=1)
BEGIN

update JobDefinitionStep set Sequence=11 WHERE name='MovePIMFoldersToArchiveLocation' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')

END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Attribute' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

INSERT INTO [dbo].[JobDefinitionStep]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[Name]
           ,[ObjectName]
           ,[IntegrationConnectionOverrideId]
           ,[IntegrationProcessorOverride]
           ,[SelectClause]
           ,[FromClause]
           ,[WhereClause]
           ,[ParameterizedWhereClause]
           ,[DeleteAction]
           ,[DeleteActionFieldToSet]
           ,[DeleteActionValueToSet]
           ,[SkipHeaderRow]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[FlatFileErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,8
           ,'Attribute'
           ,'PIMAttribute'
           ,NULL
           ,''
           ,'Entity_Type,Entity_Id,AttributeName,AttributeValue'
           ,'Attribute.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='AttributeModel' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

INSERT INTO [dbo].[JobDefinitionStep]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[Name]
           ,[ObjectName]
           ,[IntegrationConnectionOverrideId]
           ,[IntegrationProcessorOverride]
           ,[SelectClause]
           ,[FromClause]
           ,[WhereClause]
           ,[ParameterizedWhereClause]
           ,[DeleteAction]
           ,[DeleteActionFieldToSet]
           ,[DeleteActionValueToSet]
           ,[SkipHeaderRow]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[FlatFileErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,9
           ,'AttributeModel'
           ,'PIMAttributeModel'
           ,NULL
           ,''
           ,'Entity_Type,AttributeName,AttributeLabel,AttributeDataType,AttributeMultiSelect'
           ,'AttributeModel.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='CVLData' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

INSERT INTO [dbo].[JobDefinitionStep]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[Name]
           ,[ObjectName]
           ,[IntegrationConnectionOverrideId]
           ,[IntegrationProcessorOverride]
           ,[SelectClause]
           ,[FromClause]
           ,[WhereClause]
           ,[ParameterizedWhereClause]
           ,[DeleteAction]
           ,[DeleteActionFieldToSet]
           ,[DeleteActionValueToSet]
           ,[SkipHeaderRow]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[FlatFileErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,10
           ,'CVLData'
           ,'PIMCVLData'
           ,NULL
           ,''
           ,'CvlId,DataType,CvlKeyId,Key,Value,Index,ParentKey,LastModified,DateCreated'
           ,'CVLData.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END