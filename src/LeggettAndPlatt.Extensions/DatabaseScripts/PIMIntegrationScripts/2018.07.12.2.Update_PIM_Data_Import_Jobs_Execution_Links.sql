IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.10 PIM Category Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.20 PIM Product Import') WHERE Name='LNP 2.10 PIM Category Import';
END

GO

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.20 PIM Product Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.30 PIM Item Import') WHERE Name='LNP 2.20 PIM Product Import';
END

GO

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.30 PIM Item Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.40 PIM Category Product Link Import') WHERE Name='LNP 2.30 PIM Item Import';
END

GO


IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.40 PIM Category Product Link Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.50 PIM Style Trait Import') WHERE Name='LNP 2.40 PIM Category Product Link Import';
END

GO

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.50 PIM Style Trait Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.60 PIM Attribute Import') WHERE Name='LNP 2.50 PIM Style Trait Import';
END

GO

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 2.60 PIM Attribute Import')>0)
BEGIN
update [dbo].[JobDefinition] set [LinkedJobId] = (SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 2.70 PIM Resource Import') WHERE Name='LNP 2.60 PIM Attribute Import';
END

GO