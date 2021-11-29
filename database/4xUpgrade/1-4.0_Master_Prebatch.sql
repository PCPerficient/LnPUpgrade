-- 3.7 to 4.0 Prebatch Master

-- Start with a fresh db to upgrade and make sure you have a backup

PRINT 'Renaming DB Tables to new names'
insert into ApplicationLog (type, Source, message, LogDate) values ('Info', 'DBScript', 'Applying Prebatch script', getdate())

-- Table rename
exec sp_rename 'CarrierZoneZipCodeRange','CarrierZonePostalCodeRange'
exec sp_rename 'CategoryFilterSection','CategoryAttributeType'
exec sp_rename 'CategoryFilterValue','CategoryAttributeValue'
exec sp_rename 'CustomerSalesman','CustomerSalesperson'
exec sp_rename 'FilterSection','AttributeType'
exec sp_rename 'FilterValue','AttributeValue'
exec sp_rename 'IntegrationJobDefinition','JobDefinition'
exec sp_rename 'IntegrationJobDefinitionPostprocessorParameter','JobDefinitionParameter'
exec sp_rename 'IntegrationJobDefinitionStep','JobDefinitionStep'
exec sp_rename 'IntegrationJobDefinitionStepFieldMap','JobDefinitionStepFieldMap'
exec sp_rename 'IntegrationJobDefinitionStepParameter','JobDefinitionStepParameter'
exec sp_rename 'OrderLineAttribute','OrderLineProperty'
exec sp_rename 'PackageLine','ShipmentPackageLine'
exec sp_rename 'PaymentTerm','PaymentMethod'
exec sp_rename 'PromotionCode','OrderPromotionCode'
exec sp_rename 'ProductFilterValue','ProductAttributeValue'
exec sp_rename 'PunchOutOrderRequestValidationMessage','PunchOutOrderRequestMessage'
exec sp_rename 'Restriction','ShippingRestriction'
exec sp_rename 'Salesman','Salesperson'
IF @@ERROR <> 0 SET NOEXEC ON
GO

---------------------------------------------------------------------------------------------
-- Populate ERPCustomerNumber/Sequence and change index for NaturalKey to it
PRINT 'Updating ERPNumber/Sequence in Customer Table '
UPDATE Customer SET ERPNumber = CustomerNumber where ERPNumber = ''
UPDATE Customer SET ERPSequence = CustomerSequence where ERPSequence = ''
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- REMOVING DUPLICATES FOR NEW NATURAL KEYS WITH UNIQUE INDEXES

-- Application Message
DELETE FROM ApplicationMessage WHERE applicationmessageId IN (
    SELECT applicationmessageId FROM (
        SELECT 
            applicationmessageId
            ,ROW_NUMBER() OVER (PARTITION BY Name ORDER BY applicationmessageId) AS [ItemNumber]
        FROM 
            ApplicationMessage
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
GO

-- CustomerCostCode
PRINT 'Removing duplicates from CustomerCostCode'
DELETE FROM CustomerCostCode WHERE CustomerCostCodeId IN (
    SELECT CustomerCostCodeId FROM (
        SELECT 
            CustomerCostCodeId
            ,ROW_NUMBER() OVER (PARTITION BY CustomerId,CostCode ORDER BY CustomerCostCodeId) AS [ItemNumber]
        FROM 
            CustomerCostCode
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
GO

-- CustomerBudget
PRINT 'Removing duplicates from CustomerBudget'
DELETE FROM CustomerBudget WHERE CustomerBudgetId IN (
    SELECT CustomerBudgetId FROM (
        SELECT 
            CustomerBudgetId
            ,ROW_NUMBER() OVER (PARTITION BY CustomerId,UserProfileId,FiscalYear ORDER BY CustomerBudgetId) AS [ItemNumber]
        FROM 
            CustomerBudget
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
GO

-- OrderPromotionCode
PRINT 'Removing duplicates from OrderPromotionCode'
DELETE FROM OrderPromotionCode WHERE PromotionCodeId IN (
    SELECT PromotionCodeId FROM (
        SELECT 
            PromotionCodeId
            ,ROW_NUMBER() OVER (PARTITION BY CustomerOrderId,Code ORDER BY PromotionCodeId) AS [ItemNumber]
        FROM 
            OrderPromotionCode
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
GO
-- DictionaryLabel
PRINT 'Removing duplicates from DictionaryLabel'
DELETE FROM DictionaryLabel WHERE DictionaryLabelId IN (
    SELECT DictionaryLabelId FROM (
        SELECT 
            DictionaryLabelId
            ,ROW_NUMBER() OVER (PARTITION BY ApplicationDictionaryId,LanguageCode,SystemLabel ORDER BY DictionaryLabelId) AS [ItemNumber]
        FROM 
            DictionaryLabel
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
GO

PRINT 'Removing duplicates from WebsiteConfiguration'
DELETE FROM WebsiteConfiguration WHERE WebsiteConfigurationId IN (
    SELECT WebsiteConfigurationId FROM (
        SELECT 
            WebsiteConfigurationId
            ,ROW_NUMBER() OVER (PARTITION BY WebsiteId,Name ORDER BY WebsiteConfigurationId) AS [ItemNumber]
        FROM 
            WebsiteConfiguration
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from ApplicationSetting'
DELETE FROM ApplicationSetting WHERE ApplicationSettingId IN (
    SELECT ApplicationSettingId FROM (
        SELECT 
            ApplicationSettingId
            ,ROW_NUMBER() OVER (PARTITION BY Name ORDER BY ApplicationSettingId) AS [ItemNumber]
        FROM 
            ApplicationSetting
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from WebsiteConfiguration'
DELETE FROM WebsiteConfiguration WHERE WebsiteConfigurationId IN (
    SELECT WebsiteConfigurationId FROM (
        SELECT 
            WebsiteConfigurationId
            ,ROW_NUMBER() OVER (PARTITION BY WebsiteId,Name ORDER BY WebsiteConfigurationId) AS [ItemNumber]
        FROM 
            WebsiteConfiguration
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from WishList'
DELETE FROM WishList WHERE WishListId IN (
    SELECT WishListId FROM (
        SELECT 
            WishListId
            ,ROW_NUMBER() OVER (PARTITION BY Name,UserProfileId,CustomerId ORDER BY WishListId) AS [ItemNumber]
        FROM 
            WishList
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from ProductWarehouse'
DELETE FROM ProductWarehouse WHERE ProductWarehouseId IN (
    SELECT ProductWarehouseId FROM (
        SELECT 
            ProductWarehouseId
            ,ROW_NUMBER() OVER (PARTITION BY ProductId,WarehouseId ORDER BY ProductWarehouseId) AS [ItemNumber]
        FROM 
            ProductWarehouse
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from Menu'
DELETE FROM Menu WHERE MenuId IN (
    SELECT MenuId FROM (
        SELECT 
            MenuId
            ,ROW_NUMBER() OVER (PARTITION BY ParentId,Name ORDER BY MenuId) AS [ItemNumber]
        FROM 
            Menu
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT 'Removing duplicates from CarrierZoneRate'
DELETE FROM CarrierZoneRate WHERE CarrierZoneRateId IN (
    SELECT CarrierZoneRateId FROM (
        SELECT 
            CarrierZoneRateId
            ,ROW_NUMBER() OVER (PARTITION BY CarrierZoneId,Weight ORDER BY CarrierZoneRateId) AS [ItemNumber]
        FROM 
            CarrierZoneRate
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from OrderHistoryLine'
DELETE FROM OrderHistoryLine WHERE OrderHistoryLineId IN (
    SELECT OrderHistoryLineId FROM (
        SELECT 
            OrderHistoryLineId
            ,ROW_NUMBER() OVER (PARTITION BY OrderHistoryId,LineNumber,ReleaseNumber ORDER BY OrderHistoryLineId) AS [ItemNumber]
        FROM 
            OrderHistoryLine
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

PRINT 'Removing duplicates from UserProfilePassword'
DELETE FROM UserProfilePassword WHERE UserProfilePasswordId IN (
    SELECT UserProfilePasswordId FROM (
        SELECT 
            UserProfilePasswordId
            ,ROW_NUMBER() OVER (PARTITION BY UserProfileId,Password,PasswordSalt ORDER BY UserProfilePasswordId) AS [ItemNumber]
        FROM 
            UserProfilePassword
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
)
IF @@ERROR <> 0 SET NOEXEC ON
GO

-- Identify duplicates in attributevalue
PRINT 'Identifying duplicates from AttributeValue - PLEASE FIX BEFORE RUNNING UPGRADE'
    SELECT FilterValueId,FilterSectionId,Value FROM (
        SELECT 
            FilterValueId,FilterSectionId,Value
            ,ROW_NUMBER() OVER (PARTITION BY FilterSectionId,Value ORDER BY FilterValueId) AS [ItemNumber]
        FROM 
            AttributeValue
    ) a WHERE ItemNumber > 1 -- Keep only the first unique item
	/* NOTE - no really good way to fix these - I do it by hand
		select * from attributevalue where value = 'Yellow' to find the different values that are duped;
		copy the list and paste it into the query below - typically the duplicates have not been assigned

		select * from productattributevalue where filtervalueid in (
		'EABE2408-3BC4-4EE5-A40C-A38500BFF2A4',
		'509DB234-0F75-43E3-A3DD-A38500C100AF'
		)
		If there are not multiple values, simple identify the one with nothing associated and delete it; otherwise
		rekey the existing records to the one you want to anchor to and then delete the extra ones

		delete from attributevalue where filtervalueid = 'EABE2408-3BC4-4EE5-A40C-A38500BFF2A4'
		*/

IF @@ERROR <> 0 SET NOEXEC ON
GO

--------------------------------------------------------------------------------------
-- Whack auto-generated defaults


PRINT 'Deleting auto-generated defaults'
-- Load up the table
create table #filenames (tablename varchar(40), constraintname varchar(80))
insert into #filenames (tablename,constraintname)
select so2.name, so.name from sysobjects so 
join sysobjects so2 on so2.id = so.parent_obj
where so.name like 'DF[_][_]%' and so.name not like '%aspnet%' and so.xtype = 'D'
order by so.name

DECLARE @Dynsql nvarchar(max) 
SET @Dynsql = ''


SELECT @Dynsql = @Dynsql + '
alter table [' + #filenames.tablename + '] drop constraint [' + #filenames.constraintname + ']'
FROM #filenames 

drop table #filenames
--select  @dynsql
EXEC (@Dynsql)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO

--------------------------------------------------------------------------------------
-- Whack auto-generated statistics

PRINT 'Deleting auto-generated statistics'
-- Load up the table
create table #filenames (tablename varchar(40), statname varchar(80))
insert into #filenames (statname,tablename)
select stat.name, so.name from sysobjects so 
join sys.stats stat on stat.object_id = so.id
where stat.name like '[_]dta[_]stat_%' and so.name not like '%aspnet%' 
order by stat.name

DECLARE @Dynsql nvarchar(max) 
SET @Dynsql = ''

SELECT @Dynsql = @Dynsql + '
drop statistics  [' + #filenames.tablename + '].[' + #filenames.statname + ']'
FROM #filenames 

drop table #filenames
--select  @dynsql
EXEC (@Dynsql)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
---------------------------------------------------------------

if @@ERROR = 0 PRINT 'Succesful completion of prebatch phase - continue with back sync'
if @@ERROR <> 0 PRINT 'Completed with errors - please review, revise and rerun'




