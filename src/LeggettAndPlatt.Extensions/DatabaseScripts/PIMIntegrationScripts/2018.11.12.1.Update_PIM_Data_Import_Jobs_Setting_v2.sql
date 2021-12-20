
IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.70 PIM Resource Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.80 PIM Images Import'), [LinkedJobCondition] = 'SuccessOrWarning' WHERE Name='LNP 2.70 PIM Resource Import';
END
GO