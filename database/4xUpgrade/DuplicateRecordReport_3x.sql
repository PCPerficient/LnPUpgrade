/*----------------------------------------------------
 Script: DuplicateRecordReport_3x
 Purpose:	This procedure is intended to highlight duplicate records that may exist and must
			be dealth with or else an upgrade script may fail.  There are a number of these for the
			3x to 4x upgrade and assumes the db is at version 3.3 or higher
 History:	5/9/16 TJF Initial version
 ----------------------------------------------------*/
 SET NOCOUNT ON

 IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'DuplicateRecordFinder')
 BEGIN
	DROP PROCEDURE [dbo].[DuplicateRecordFinder]	
 END
 GO

 /* Create stored procedure that will be called by this routine */
 CREATE PROCEDURE [dbo].[DuplicateRecordFinder]
 @TableName varchar(255),
 @IndexName varchar(255),
 @Fields varchar(255),
 @AutoClean varchar(10)
AS
BEGIN
    SET NOCOUNT ON

	CREATE TABLE #Dupes
	(RecordCount int,
	FieldName1 nvarchar(255),
	FieldName2 nvarchar(255),
	FieldName3 nvarchar(255),
	FieldName4 nvarchar(255))	

	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName) RETURN

	PRINT 'Working on table ' + @TableName
	
	DECLARE @SQLCommand nvarchar(3000);
	DECLARE @NumFields tinyint
	SET @NumFields = LEN(@Fields) - LEN(REPLACE(@Fields,',','')) + 1

	SELECT @SQLCommand = 'INSERT INTO #Dupes (RecordCount, FieldName1' + 
	CASE @NumFields
	  WHEN 2 THEN ',FieldName2'
	  WHEN 3 THEN ',FieldName2,FieldName3'
	  WHEN 4 THEN ',FieldName2,FieldName3,FieldName4'
	  ELSE ''
	END +
	') ' +
	'(SELECT COUNT(*) AS Count, ' + @Fields + ' FROM ' + @TableName + ' GROUP BY ' + @Fields +
	' HAVING COUNT(*) > 1)'
	
	EXEC sp_executeSQL @SQLCommand
	
	-- Now take results and get them into main table
	INSERT INTO #DuplicateRecords
	SELECT @TableName,@IndexName + ':' + @Fields,RecordCount,FieldName1 +
	(CASE @NumFields
	   WHEN 2 THEN ',' + FieldName2
	   WHEN 3 THEN ',' + FieldName2 + ',' + FieldName3
	   WHEN 4 THEN ',' + FieldName2 + ',' + FieldName3 + ',' + FieldName4
	   ELSE ''
	 END),@AutoClean
	FROM #Dupes
	
	DROP TABLE #Dupes
END 
GO

--------------------------------------------------------------------------------------------
-- MAIN PROCESS FOR REPORT

CREATE TABLE #DuplicateRecords (
	TableName nvarchar(255),
	IndexName nvarchar(255),
	Count int,
	RecordKeys nvarchar(255),
	AutoClean varchar(10) )


EXEC DuplicateRecordFinder 'Affiliate','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'ApplicationDictionary','NaturalKey','ObjectName,FieldName','';
EXEC DuplicateRecordFinder 'ApplicationMessage','NaturalKey','Name','Yes';
EXEC DuplicateRecordFinder 'FilterSection','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'FilterValue','NaturalKey','FilterSectionId,Value','';
EXEC DuplicateRecordFinder 'BudgetCalendar','NaturalKey','CustomerId,FiscalYear','';
EXEC DuplicateRecordFinder 'Carrier','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'CarrierPackage','NaturalKey','CarrierId,Name','';
EXEC DuplicateRecordFinder 'CarrierZone','NaturalKey','CarrierId,Zone','';
EXEC DuplicateRecordFinder 'CarrierZoneRate','NaturalKey','CarrierZoneId,Weight','Yes';
EXEC DuplicateRecordFinder 'CarrierZoneZipCodeRange','NaturalKey','CarrierZoneId,ZipStartRange','';
EXEC DuplicateRecordFinder 'Category','NaturalKey','WebsiteId,ParentId,Name','';
EXEC DuplicateRecordFinder 'CategoryFilterSection','NaturalKey','CategoryId,FilterSectionId','';
EXEC DuplicateRecordFinder 'CategoryProduct','NaturalKey','CategoryId,ProductId','';
EXEC DuplicateRecordFinder 'CategoryProperty','NaturalKey','CategoryId,Name','';
EXEC DuplicateRecordFinder 'Company','NaturalKey','Name','';
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Configuration' and COLUMN_NAME = 'Name')
BEGIN
	EXEC DuplicateRecordFinder 'Configuration','NaturalKey','Name,Revision','';
END
EXEC DuplicateRecordFinder 'ConfigurationOption','ConfiguratonPageId_Name','ConfigurationPageId,Name','';
EXEC DuplicateRecordFinder 'ConfigurationOptionCondition','ConfigurationOptionId_Sequence','ConfigurationOptionId,Sequence','';
EXEC DuplicateRecordFinder 'Currency','NaturalKey','CurrencyCode','';
EXEC DuplicateRecordFinder 'CustomerBudget','NaturalKey','CustomerId,ShipToCustomerId,UserProfileId,FiscalYear','Yes';
EXEC DuplicateRecordFinder 'CustomerCostCode','NaturalKey','CustomerId,CostCode','Yes';
EXEC DuplicateRecordFinder 'CustomerOrder','NaturalKey','OrderNumber','';
EXEC DuplicateRecordFinder 'CustomerProduct','NaturalKey','CustomerId,ProductId','';
EXEC DuplicateRecordFinder 'CustomerProductSet','NaturalKey','CustomerId,Name','';
EXEC DuplicateRecordFinder 'CustomerProperty','NaturalKey','CustomerId,Name','';
EXEC DuplicateRecordFinder 'CustomProperty','NaturalKey','ParentId,Name','';
EXEC DuplicateRecordFinder 'Dealer','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'DealerProperty','NaturalKey','DealerId,Name','';
EXEC DuplicateRecordFinder 'DictionaryLabel','','ApplicationDictionaryId,LanguageCode,SystemLabel','Yes';
EXEC DuplicateRecordFinder 'EmailList','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'EmailSubscriber','NaturalKey','Email','';
EXEC DuplicateRecordFinder 'GiftCard','NaturalKey','GiftCardNumber','';
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'GlobalSynonym' and COLUMN_NAME = 'LanguageCode')
BEGIN
	EXEC DuplicateRecordFinder 'GlobalSynonym','NaturalKey','SynonymType,LanguageCode,LookupValue','';
END
EXEC DuplicateRecordFinder 'HTMLRedirect','NaturalKey','OldURL','';
EXEC DuplicateRecordFinder 'IntegrationConnection','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'IntegrationJobParameter','StepParameter','IntegrationJobId,IntegrationJobDefinitionStepParameterId','';
EXEC DuplicateRecordFinder 'InvoiceHistory','NaturalKey','InvoiceNumber','';
EXEC DuplicateRecordFinder 'InvoiceHistoryLine','NaturalKey','InvoiceHistoryId,LineNumber,ReleaseNumber','';
EXEC DuplicateRecordFinder 'IntegrationJobDefinition','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'IntegrationJobDefinitionStep','Sequence','IntegrationJobDefinitionId,Sequence','';
EXEC DuplicateRecordFinder 'IntegrationJobDefinitionStepParameter','Name','IntegrationJobDefinitionStepId,Name','';
EXEC DuplicateRecordFinder 'Language','NaturalKey','LanguageCode','';
EXEC DuplicateRecordFinder 'LocalTaxRate','NaturalKey','Zip','';
EXEC DuplicateRecordFinder 'Menu','NaturalKey','ParentId,Name','';
EXEC DuplicateRecordFinder 'Message','NaturalKey','Subject,DateToDisplay','';
EXEC DuplicateRecordFinder 'MessageStatus','NaturalKey','MessageId,UserProfileId','';
EXEC DuplicateRecordFinder 'MessageTarget','NaturalKey','MessageId,TargetType,TargetKey','';
EXEC DuplicateRecordFinder 'MiscellaneousCode','NaturalKey','ParentId,Name','';
EXEC DuplicateRecordFinder 'OrderHistoryLine','NaturalKey','OrderHistoryId,LineNumber,ReleaseNumber','Yes';
EXEC DuplicateRecordFinder 'OrderLine','NaturalKey','CustomerOrderId,Line,Release','';
EXEC DuplicateRecordFinder 'OrderLineAttribute','NaturalKey','OrderLineId,Name','';
EXEC DuplicateRecordFinder 'OrderLineRequisition','NaturalKey','OrderLineId,OriginalOrderLineId','';
EXEC DuplicateRecordFinder 'PaymentTerm','NaturalKey','TermsCode','';
EXEC DuplicateRecordFinder 'Persona','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'Plugin','NaturalKey','Name,ConnectionName','';
EXEC DuplicateRecordFinder 'Product','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'ProductProperty','NaturalKey','ProductId,Name','';
EXEC DuplicateRecordFinder 'ProductUnitOfMeasure','NaturalKey','ProductId,UnitOfMeasure','';
EXEC DuplicateRecordFinder 'ProductWarehouse','NaturalKey','ProductId,WarehouseId','';
EXEC DuplicateRecordFinder 'Promotion','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'PromotionCode','NaturalKey','CustomerOrderId,Code','Yes';
EXEC DuplicateRecordFinder 'RuleType','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'RuleTypeOption','NaturalKey','RuleTypeId,CriteriaType,CriteriaObject','';
EXEC DuplicateRecordFinder 'Salesman','NaturalKey','SalesmanNumber','';
EXEC DuplicateRecordFinder 'ShipCharge','NaturalKey','CarrierId,ShipViaId,Name','';
EXEC DuplicateRecordFinder 'Shipment','NaturalKey','ShipmentNumber','';
EXEC DuplicateRecordFinder 'ShipmentPackage','NaturalKey','ShipmentId,PackageNumber','';
EXEC DuplicateRecordFinder 'Restriction','NaturalKey','StateId,CategoryId,ProductId','';
EXEC DuplicateRecordFinder 'ShipRate','NaturalKey','ShipViaId,OrderAmount','';
EXEC DuplicateRecordFinder 'ShipVia','NaturalKey','CarrierId,ShipCode','';
EXEC DuplicateRecordFinder 'State','NaturalKey','CountryId,Abbreviation','';
EXEC DuplicateRecordFinder 'StyleClass','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'StyleTrait','NaturalKey','StyleClassId,Name','';
EXEC DuplicateRecordFinder 'StyleTraitValue','NaturalKey','StyleTraitId,Value','';
EXEC DuplicateRecordFinder 'Subscription','NaturalKey','CustomerOrderId,ProductId','';
EXEC DuplicateRecordFinder 'SubscriptionLine','NaturalKey','SubscriptionId,ProductId','';
EXEC DuplicateRecordFinder 'SubscriptionProduct','NaturalKey','ProductId,ParentProductId','';
EXEC DuplicateRecordFinder 'TaxExemption','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'TranslationDictionary','SourceKeywordLanguageCode','Source,Keyword,LanguageCode','';
EXEC DuplicateRecordFinder 'TranslationProperty','NaturalKey','LanguageCode,ParentTable,ParentId,Name','';
EXEC DuplicateRecordFinder 'UserProfile','NaturalKey','UserName,ApplicationName','';
EXEC DuplicateRecordFinder 'UserProfilePassword','NaturalKey','UserProfileId,Password,PasswordSalt','Yes';
EXEC DuplicateRecordFinder 'UserProfileProperty','NaturalKey','UserProfileId,Name','';
EXEC DuplicateRecordFinder 'Vendor','NaturalKey','VendorNumber','';
EXEC DuplicateRecordFinder 'Website','NaturalKey','Name','';
EXEC DuplicateRecordFinder 'WebsiteConfiguration','NaturalKey','WebsiteId,Name','Yes';
EXEC DuplicateRecordFinder 'WebsiteCurrency','NaturalKey','WebsiteId,CurrencyId','';
EXEC DuplicateRecordFinder 'WishList','NaturalKey','UserProfileId,CustomerId,Name','Yes';
PRINT 'Completed Check - displaying results...'

SELECT TableName as 'Table Name',
	   IndexName as 'Index Info',
	   [Count] as 'Record Count',
	   RecordKeys as 'Duplicate Key Info',
	   AutoClean as 'Dupes Automatically Removed'
FROM #DuplicateRecords

DROP TABLE #DuplicateRecords
