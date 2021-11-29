/*----------------------------------------------------
 Script: DuplicateRecordReport_420
 Purpose:	This procedure is intended to highlight duplicate records that may exist and must
			be dealt with or else an upgrade script may fail.  There are a number of these for the
			4.0 to 4.2 upgrade and assumes the db is up to 4.0 standard.
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

-- DuplicateRecordFinder <tablename>,<indexname>,<fields>
EXEC DuplicateRecordFinder 'Product','NaturalKey','ERPNumber','';
EXEC DuplicateRecordFinder 'ASPNetUsers','UserNameIndex','UserName','';
EXEC DuplicateRecordFinder 'UserProfile','NaturalKey','UserName',''; -- removing application name
EXEC DuplicateRecordFinder 'Category','URLSegment','URLSegment,WebsiteId,ParentId','';
EXEC DuplicateRecordFinder 'Product','URLSegment','UrlSegment','';
EXEC DuplicateRecordFinder 'EmailTemplate','Name','Name','';

PRINT 'Completed Check - displaying results...'

SELECT TableName as 'Table Name',
	   IndexName as 'Index Info',
	   [Count] as 'Record Count',
	   RecordKeys as 'Duplicate Key Info',
	   AutoClean as 'Dupes Automatically Removed'
FROM #DuplicateRecords

DROP TABLE #DuplicateRecords
