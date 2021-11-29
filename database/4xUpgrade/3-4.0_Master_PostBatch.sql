-- POST BATCH MASTER
BEGIN TRANSACTION 


-- Miscellaneous cleanup stuff after executing compare script and creating new fields
-- 3.7 to 4.0 data manipulations
insert into ApplicationLog (type, Source, message, LogDate) values ('Info', 'DBScript', 'Applying PostBatch script', getdate())

-- Remove Scheduled Tasks from Menu
delete from menu where name = 'Scheduled Tasks'
GO

-- Clean up app dictionary
DELETE from ApplicationDictionary where FieldName = 'MetaTags'
DELETE FROM ApplicationDictionary where FieldName = 'AltText'
GO

-- New assignment types for customers
UPDATE Customer SET IsBillTo = IIF (Customer.ParentId IS NULL,1,0)
IF @@ERROR <> 0 SET NOEXEC ON
GO



-- Handle Product.UrlSegment
UPDATE Product SET UrlSegment = Name
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Product_UrlSegment] ON [dbo].[Product]
(
	[UrlSegment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- Add in UrlSegment data into Product & Category
UPDATE Category SET UrlSegment = Name
IF @@ERROR <> 0 SET NOEXEC ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Category_UrlSegment] ON [dbo].[Category](
	[UrlSegment] ASC,
	[WebSiteId] ASC,
	[ParentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF @@ERROR <> 0 SET NOEXEC ON
GO

-----------------------------------------------------------------------------------------------------------------

-- CREATE MODIFY/CREATE DATE FIELDS
PRINT 'Adding Date fields to tables'
-- Load up the table
create table #filenames (tablename varchar(30),HasCreatedOn tinyint, HasCreatedBy tinyint, HasModifiedOn tinyint, HasModifiedBy tinyint)
insert into #filenames (tablename,hascreatedon,hascreatedby,hasmodifiedon,hasmodifiedby)
select so.name,0,0,0,0 from sysobjects so join syscolumns sc on so.id = sc.id where sc.name = 'id' and so.xtype = 'U' and
so.name not like 'asp_%'
order by so.name

-- Find tables where columns already exist
update #filenames set HasCreatedOn = ( SELECT count(*) From information_schema.columns where table_name = #filenames.tablename and
column_name = 'CreatedOn')
update #filenames set HasCreatedBy = ( SELECT count(*) From information_schema.columns where table_name = #filenames.tablename and
column_name = 'CreatedBy')
update #filenames set HasModifiedOn = ( SELECT count(*) From information_schema.columns where table_name = #filenames.tablename and
column_name = 'ModifiedOn')
update #filenames set HasModifiedBy = ( SELECT count(*) From information_schema.columns where table_name = #filenames.tablename and
column_name = 'ModifiedBy')

 -- select * from #filenames where hascreatedon > 0 or hascreatedby > 0 or hasmodifiedon > 0 or hasmodifiedby > 0

DECLARE @Dynsql nvarchar(max) 
SET @Dynsql = ''

SELECT @Dynsql = @Dynsql + '
alter table ' + QUOTENAME(#filenames.tablename) +
' add [CreatedOn] datetime2(7) not null constraint DF_' + #filenames.tablename + '_CreatedOn DEFAULT getdate()'
FROM #filenames where HasCreatedOn = 0

SELECT @Dynsql = @Dynsql + '
alter table ' + QUOTENAME(#filenames.tablename) +
' add [CreatedBy] nvarchar(100) not null constraint DF_' + #filenames.tablename + '_CreatedBy DEFAULT  ('''')' 
FROM #filenames where HasCreatedBy = 0

SELECT @Dynsql = @Dynsql + '
alter table ' + QUOTENAME(#filenames.tablename) +
' add [ModifiedOn] datetime2(7) not null constraint DF_' + #filenames.tablename + '_ModifiedOn DEFAULT  getdate()'
FROM #filenames where HasModifiedOn = 0

SELECT @Dynsql = @Dynsql + '
alter table ' + QUOTENAME(#filenames.tablename) +
' add [ModifiedBy] nvarchar(100) not null constraint DF_' + #filenames.tablename + '_ModifiedBy DEFAULT  ('''')'
FROM #filenames where HasModifiedBy = 0
drop table #filenames
--select  @dynsql
EXEC (@Dynsql)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

-----------------------------------------------------------------------------------------------------------------
-- RELATED PRODUCTS CLEANUP
-- Product/Category relationships replaces CrossSells and Accessories 
-- 3.7 to 4.0 data manipulations the must run AFTER table renames and BEFORE all the db automated script changes

PRINT 'Processing Related Products'
DECLARE @XSellMiscId as uniqueidentifier
DECLARE @AccyMiscId as uniqueidentifier
DECLARE @MiscGroupId as uniqueidentifier
SELECT @MiscGroupId = Id from MiscellaneousCode where Name = 'ProductRelationship' and ParentId is null

-- Create Misc Code group for related products
IF @MiscGroupId IS NULL 
	BEGIN
	  INSERT INTO MiscellaneousCode(ParentId,Name,AdditionalInfo,Description) values (NULL,'ProductRelationship','','Product Relationships such as Cross-sell or Accessory')
	  SELECT @MiscGroupId = Id from MiscellaneousCode where Name = 'ProductRelationship' and ParentId is null
	END
	
--Create Cross-Sell misc code
SELECT @XSellMiscId = ID from MiscellaneousCode mc where mc.parentid = @MiscGroupId and Name = 'Cross-Sell'
IF @XSellMiscId is NUll 
BEGIN
	INSERT INTO MiscellaneousCode(ParentId,Name,AdditionalInfo,Description) values (@MiscGroupId,'Cross-Sell','','')
	SELECT @XSellMiscId = ID from MiscellaneousCode mc where mc.parentid = @MiscGroupId and Name = 'Cross-Sell'
END

-- Create Accessory entry
SELECT @AccyMiscId = ID from MiscellaneousCode mc where mc.parentid = @MiscGroupId and Name = 'Accessory'
IF @AccyMiscId is NUll 
BEGIN
	INSERT INTO MiscellaneousCode(ParentId,Name,AdditionalInfo,Description) values (@MiscGroupId,'Accessory','','')
	SELECT @AccyMiscId = ID from MiscellaneousCode mc where mc.parentid = @MiscGroupId and Name = 'Accessory'
END

-- Update Category Related first
insert into CategoryRelatedProduct(CategoryId,ProductRelationshipMiscId,ProductId)
SELECT CategoryId,@XSellMiscId,ProductId FROM CategoryProductCrossSell
IF @@ERROR <> 0 SET NOEXEC ON

-- Work on Products Next
insert into ProductRelatedProduct(ProductId,ProductRelationshipMiscId,RelatedProductId)
SELECT ProductId,@XSellMiscId,CrossSellProductId FROM ProductProductCrossSell
IF @@ERROR <> 0 SET NOEXEC ON


insert into ProductRelatedProduct(ProductId,ProductRelationshipMiscId,RelatedProductId)
SELECT ProductId,@AccyMiscId,ProductAccessoryId FROM ProductProductAccessory
IF @@ERROR <> 0 SET NOEXEC ON
GO

DROP TABLE CategoryProductCrossSell
DROP TABLE ProductProductAccessory
DROP TABLE ProductProductCrossSell
IF @@ERROR <> 0 SET NOEXEC ON
GO
-----------------------------------------------------------------------------------------------------------------
-- LANGUAGE CODE CLEANUP

-- Resets languageCode to LanguageId in tables, removes column once updated
-- Presumes that LanguageId is added to these tables from the SQL Compare script so both LanguageCode and LanguageId
--   will be present
-- Added logic to handle blank language code

PRINT 'Language Code cleanup'
DECLARE @DefaultLanguage nvarchar(50)
SELECT @DefaultLanguage = LanguageCode from Language where isdefault = 1
IF @DefaultLanguage IS NULL SELECT TOP 1 @DefaultLanguage = LanguageCode from Language where languagecode like '%en%'
IF @DefaultLanguage IS NULL SELECT TOP 1 @DefaultLanguage from Language


-- Content
UPDATE Content SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from Content
where not exists (select 1 from Language l2 where l2.languagecode = Content.LanguageCode) 

UPDATE Content 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = Content.LanguageCode)
ALTER TABLE Content DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON

-- CustomerOrder
UPDATE CustomerOrder set LanguageCode = @DefaultLanguage where LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from CustomerOrder
where not exists (select 1 from Language l2 where l2.languagecode = CustomerOrder.LanguageCode)
UPDATE CustomerOrder 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = CustomerOrder.LanguageCode)
ALTER TABLE CustomerOrder DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON

-- Dictionary Label
UPDATE DictionaryLabel SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from DictionaryLabel
where not exists (select 1 from Language l2 where l2.languagecode = DictionaryLabel.LanguageCode) 
UPDATE DictionaryLabel 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = DictionaryLabel.LanguageCode)
ALTER TABLE [dbo].[DictionaryLabel] DROP CONSTRAINT [FK_DictionaryLabel_Language]
IF @@ERROR <> 0 SET NOEXEC ON

DROP INDEX IX_DictionaryLabel ON DictionaryLabel
IF @@ERROR <> 0 SET NOEXEC ON
CREATE UNIQUE NONCLUSTERED INDEX [IX_DictionaryLabel] ON [dbo].[DictionaryLabel]
(
	[ApplicationDictionaryId] ASC,
	[LanguageId] ASC,
	[SystemLabel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF @@ERROR <> 0 SET NOEXEC ON
ALTER TABLE [dbo].[DictionaryLabel]  WITH CHECK ADD  CONSTRAINT [FK_DictionaryLabel_Language] FOREIGN KEY([LanguageId])
REFERENCES [dbo].[Language] ([Id])
IF @@ERROR <> 0 SET NOEXEC ON
ALTER TABLE DictionaryLabel DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON



-- Document
UPDATE Document SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from Document
where not exists (select 1 from Language l2 where l2.languagecode = Document.LanguageCode) 
UPDATE Document 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = Document.LanguageCode)
ALTER TABLE Document DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON

-- GlobalSynonym
UPDATE GlobalSynonym SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from GlobalSynonym
where not exists (select 1 from Language l2 where l2.languagecode = GlobalSynonym.LanguageCode) 
UPDATE GlobalSynonym 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = GlobalSynonym.LanguageCode)
DROP INDEX IX_GlobalSynonym_NaturalKey ON GlobalSynonym
IF @@ERROR <> 0 SET NOEXEC ON
CREATE UNIQUE NONCLUSTERED INDEX [IX_GlobalSynonym_NaturalKey] ON [dbo].[GlobalSynonym]
(
	[SynonymType] ASC,
	[LanguageId] ASC,
	[LookupValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF @@ERROR <> 0 SET NOEXEC ON

ALTER TABLE GlobalSynonym DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON



-- Menu
UPDATE Menu SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from Menu
where not exists (select 1 from Language l2 where l2.languagecode = Menu.LanguageCode) 
UPDATE Menu 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = Menu.LanguageCode)
ALTER TABLE Menu DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON

-- Message
UPDATE Message SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from Message
where not exists (select 1 from Language l2 where l2.languagecode = Message.LanguageCode) 
UPDATE Message 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = Message.LanguageCode)
ALTER TABLE Message DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON


-- SearchSynonym
UPDATE SearchSynonym SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from SearchSynonym
where not exists (select 1 from Language l2 where l2.languagecode = SearchSynonym.LanguageCode) 
UPDATE SearchSynonym 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = SearchSynonym.LanguageCode)
ALTER TABLE SearchSynonym DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON

-- TranslationDictionary
UPDATE TranslationDictionary SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from TranslationDictionary
where not exists (select 1 from Language l2 where l2.languagecode = TranslationDictionary.LanguageCode) 
UPDATE TranslationDictionary 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = TranslationDictionary.LanguageCode)
DROP INDEX IX_TranslationDictionary ON TranslationDictionary
DROP INDEX IX_TranslationDictionary_SourceKeywordLanguageCode on TranslationDictionary -- SEEMS TO BE A PROBLEM

CREATE UNIQUE NONCLUSTERED INDEX [IX_TranslationDictionary] ON [dbo].[TranslationDictionary]
(
	[Source] ASC,
	[Keyword] ASC,
	[LanguageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_TranslationDictionary_SourceKeywordLanguage] ON [dbo].[TranslationDictionary]
(
	[LanguageId] ASC,
	[Source] ASC,
	[Keyword] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF @@ERROR <> 0 SET NOEXEC ON

ALTER TABLE TranslationDictionary DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON



-- TranslationProperty
UPDATE TranslationProperty SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from TranslationProperty
where not exists (select 1 from Language l2 where l2.languagecode = TranslationProperty.LanguageCode) 
UPDATE TranslationProperty 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = TranslationProperty.LanguageCode)
DROP INDEX TranslationProperty.IX_TranslationProperty_ParentNameLanguage
DROP INDEX TranslationProperty.IX_TranslationProperty_ParentTable
DROP INDEX IX_TranslationProperty_NaturalKey on TranslationProperty

CREATE UNIQUE NONCLUSTERED INDEX [IX_TranslationProperty_NaturalKey] ON [dbo].[TranslationProperty]
(
	[LanguageId] ASC,
	[ParentTable] ASC,
	[ParentId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TranslationProperty_ParentTable] ON [dbo].[TranslationProperty]
(
	[ParentTable] ASC
)
INCLUDE ( 	[LanguageId],
	[ParentId],
	[TranslatedValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


ALTER TABLE TranslationProperty DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON



-- UserProfile
UPDATE UserProfile SET LanguageCode = @DefaultLanguage WHERE LanguageCode = ''
insert into language (LanguageCode,Description) 
SELECT DISTINCT LanguageCode,'Created from 4.0 Conversion' from UserProfile
where not exists (select 1 from Language l2 where l2.languagecode = UserProfile.LanguageCode) 
UPDATE UserProfile 
SET LanguageId = (SELECT Id FROM Language (NOLOCK) WHERE LanguageCode = UserProfile.LanguageCode)
ALTER TABLE UserProfile DROP COLUMN LanguageCode
IF @@ERROR <> 0 SET NOEXEC ON
GO

-----------------------------------------------------------------------------------------------------------------
-- WAREHOUSE CLEANUP

-- Resets Warehouse to WarehouseId in tables, removes column once updated
-- Presumes that LanguageId is added to these tables from the SQL Compare script so both LanguageCode and LanguageId
--   will be present

PRINT 'Warehouse Code cleanup'

-- Customer
insert into warehouse (Name,Description,IsDefaultWarehouse) 
SELECT DISTINCT Warehouse,'Created from 4.0 Conversion',0 from Customer
where not exists (select 1 from warehouse w2 where w2.name = Customer.Warehouse) AND Customer.Warehouse <> ''

UPDATE Customer
SET DefaultWarehouseId = (SELECT Id FROM Warehouse (NOLOCK) WHERE Warehouse.Name = Customer.Warehouse)
ALTER TABLE Customer DROP CONSTRAINT DF_Customer_Warehouse
GO
ALTER TABLE Customer DROP COLUMN Warehouse
IF @@ERROR <> 0 SET NOEXEC ON
GO


-- CustomerOrder
insert into warehouse (Name,Description,IsDefaultWarehouse) 
SELECT DISTINCT DefaultWarehouse,'Created from 4.0 Conversion',0 from CustomerOrder
where not exists (select 1 from warehouse w2 where w2.name = CustomerOrder.DefaultWarehouse) AND customerOrder.DefaultWarehouse <> ''


UPDATE CustomerOrder
SET DefaultWarehouseId = (SELECT Id FROM Warehouse (NOLOCK) WHERE Warehouse.Name = CustomerOrder.DefaultWarehouse)
ALTER TABLE CustomerOrder DROP CONSTRAINT DF_CustomerOrder_Warehouse
GO
ALTER TABLE CustomerOrder DROP COLUMN DefaultWarehouse
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- OrderLine
insert into warehouse (Name,Description,IsDefaultWarehouse) 
SELECT DISTINCT Warehouse,'Created from 4.0 Conversion',0 from OrderLine
where not exists (select 1 from warehouse w2 where w2.name = OrderLine.Warehouse)  and OrderLine.Warehouse <> ''

UPDATE OrderLine
SET WarehouseId = (SELECT Id FROM Warehouse (NOLOCK) WHERE Warehouse.Name = OrderLine.Warehouse)
ALTER TABLE OrderLine DROP CONSTRAINT DF_OrderLine_Warehouse
ALTER TABLE OrderLine DROP COLUMN Warehouse
IF @@ERROR <> 0 SET NOEXEC ON
GO

-----------------------------------------------------------------------------------------------------------------
-- SalesManager CLEANUP

-- Resets Customer.SalesManager to SalesManagerId, removes column once updated

PRINT 'Sales Manager Code cleanup'

-- Salesperson (from either name or number)
UPDATE Salesperson
SET SalesManagerId = (SELECT Id FROM Salesperson s2 (NOLOCK) WHERE S2.SalespersonNumber = Salesperson.SalesManager)
UPDATE Salesperson
SET SalesManagerId = (SELECT Id FROM Salesperson s2 (NOLOCK) WHERE S2.Name = Salesperson.SalesManager) 
WHERE Salesperson.SalesManagerId is null

ALTER TABLE Salesperson DROP CONSTRAINT DF_Salesperson_SalesManager
GO
ALTER TABLE Salesperson DROP COLUMN SalesManager
IF @@ERROR <> 0 SET NOEXEC ON
GO

-----------------------------------------------------------------------------------------------------------------
-- Fix up State Table - using US as the primary country as a default
PRINT 'Fixing up State table'
DECLARE @CountryId as uniqueidentifier
SELECT TOP 1 @CountryId = Id from Country where (Abbreviation = 'US' or Name = 'United States' or ISOCode2 = 'USA')
UPDATE State SET CountryId = @CountryId WHERE CountryId IS NULL
GO

DROP INDEX [IX_State_NaturalKey] ON [dbo].[State]
GO

DELETE FROM State WHERE Id IN (
    SELECT Id FROM (
        SELECT 
            Id
            ,ROW_NUMBER() OVER (PARTITION BY CountryId,Abbreviation ORDER BY Id) AS [ItemNumber]
        FROM 
            State
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO


ALTER TABLE State ALTER COLUMN CountryId uniqueidentifier NOT NULL
CREATE UNIQUE NONCLUSTERED INDEX [IX_State_NaturalKey] ON [dbo].[State](
	[CountryId] ASC,
	[Abbreviation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE State ALTER COLUMN CountryId uniqueidentifier NOT NULL
IF @@ERROR <> 0 SET NOEXEC ON
GO
-----------------------------------------------------------------------------------------------------------------
-- Cleanup other stuff to get things up to snuff
update ApplicationSetting set value = 'Standard' where name = 'TaxCalculator' and value = 'Generic'
UPDATE	[dbo].[ShipRule]
SET		ShipRuleType = 'ShipRuleOrderShippingToPostalCode'
WHERE	ShipRuleType = 'ShipRuleOrderShippingToZipCode'

UPDATE ApplicationSetting set name = 'TaxCalculator_UserOrderWarehouseForOriginAddress' where
name = 'TaxCalculator_Avalara_UserOrderWarehouseForOriginAddress'
GO

-----------------------------------------------------------------------------------------------------------------

-- Create/Convert from ASP Membership to ASP Identity
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
PRINT 'Creating ASP Identity Objects'

-- TABLE: AspNetUsers
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[Hometown] [nvarchar](256) NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
SET ANSI_PADDING ON
GO

-- TABLE: AspNetUsers
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]') AND name = N'UserNameIndex')
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- TABLE: AspNetRoles
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetRoles]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

SET ANSI_PADDING ON
GO

-- INDEX on AspNetRoles
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AspNetRoles]') AND name = N'RoleNameIndex')
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- TABLE: AspNetUserRoles
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

SET ANSI_PADDING ON
GO
-- INDEX on AspNetUserRoles
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]') AND name = N'IX_RoleId')
CREATE NONCLUSTERED INDEX [IX_RoleId] ON [dbo].[AspNetUserRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
SET ANSI_PADDING ON
GO

-- SUPPORTING for AspNetUserRoles
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]') AND name = N'IX_UserId')
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserRoles]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]'))
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]'))
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]'))
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserRoles]'))
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- TABLE: AspNetUserClaims
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserClaims]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
SET ANSI_PADDING ON

GO

-- SUPPORTING for AspNetUserClaims
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserClaims]') AND name = N'IX_UserId')
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserClaims]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserClaims]'))
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserClaims]'))
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- TABLE: AspNetUserLogins
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserLogins]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

SET ANSI_PADDING ON
GO

-- SUPPORTING for AspNetUserLogins
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUserLogins]') AND name = N'IX_UserId')
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserLogins]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserLogins]'))
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[AspNetUserLogins]'))
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-----------------------------------------------------------------------------------------------------------------
-- CONVERT ASP Membership to ASP Identity
PRINT 'Converting ASP Membership to Identity'

INSERT INTO AspNetUsers(
Id,
UserName,
PasswordHash,
SecurityStamp,
Email,
EmailConfirmed,
PhoneNumberConfirmed,
LockoutEnabled,
TwoFactorEnabled,
AccessFailedCount)
SELECT
aspnet_Users.UserId,
aspnet_Users.UserName,
(aspnet_Membership.Password+'|'+CAST(aspnet_Membership.PasswordFormat as varchar)+'|'+aspnet_Membership.PasswordSalt),
NewID(),
aspnet_Membership.Email,
1,
1,
1,
0,
0
FROM aspnet_Users
INNER JOIN aspnet_Membership ON 
aspnet_Membership.ApplicationId = aspnet_Users.ApplicationId 
AND aspnet_Users.UserId = aspnet_Membership.UserId AND
aspnet_Users.ApplicationId = '0B9A7BDC-4700-47EC-835C-4A9191C3C053';
IF @@ERROR <> 0 SET NOEXEC ON
GO

INSERT INTO AspNetRoles(Id,Name)
SELECT RoleId,RoleName
FROM aspnet_Roles where ApplicationId = '0B9A7BDC-4700-47EC-835C-4A9191C3C053';
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- modified to join to membership as well so we don't error out on constraint where a user doesn't get created due to missing membership
INSERT INTO AspNetUserRoles(UserId,RoleId)
SELECT ur.UserId,ur.RoleId
FROM aspnet_UsersInRoles ur join aspnet_users u on u.userid = ur.userid join aspnet_membership um on um.userid = u.userid where u.applicationid = '0B9A7BDC-4700-47EC-835C-4A9191C3C053';
IF @@ERROR <> 0 SET NOEXEC ON
GO

-----------------------------------------------------------------------------------------------------------------
-- DONE/WRAP UP
COMMIT TRANSACTION

DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
PRINT 'Conversion to 4.0 Complete'



