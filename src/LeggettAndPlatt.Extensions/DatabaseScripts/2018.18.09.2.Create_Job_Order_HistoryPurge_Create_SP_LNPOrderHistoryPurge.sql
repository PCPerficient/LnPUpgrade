IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Purge')=0)
BEGIN
INSERT INTO [dbo].[JobDefinition]
           ([Id]
           ,[IntegrationConnectionId]
           ,[Name]
           ,[Description]
           ,[JobType]
           ,[DebuggingEnabled]
           ,[PassThroughJob]
           ,[NotifyEmail]
           ,[NotifyCondition]
           ,[LinkedJobId]
           ,[PassDataSetToLinkedJob]
           ,[UseDeltaDataSet]
           ,[PreProcessor]
           ,[IntegrationProcessor]
           ,[PostProcessor]
           ,[LastRunDateTime]
           ,[LastRunJobNumber]
           ,[LastRunStatus]
           ,[RecurringJob]
           ,[RecurringStartDateTime]
           ,[RecurringEndDateTime]
           ,[RecurringInterval]
           ,[RecurringType]
           ,[RecurringStartTime]
           ,[RecurringStartDay]
           ,[EmailTemplateId]
           ,[RunStepsInParallel]
           ,[LinkedJobCondition]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[MaxErrorsBeforeFail]
           ,[MaxWarningsBeforeFail]
           ,[MaxRetries]
           ,[MaxDeactivationPercent]
           ,[MaxTimeoutMinutes]
           ,[StandardJobName])
     VALUES
           (NEWID()
           ,(SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnection')
           ,'LNP Order History Purge'
           ,'Delete old orders from Insite Order History table'
           ,'Refresh'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'None'
           ,'ExecuteStoredProcedureLNP'
           ,NULL
           ,''
           ,''
           ,0
           ,NULL
           ,NULL
           ,1
           ,'Days'
           ,NULL
           ,0
           ,NULL
           ,0
           ,'SuccessOnly'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,0
           ,0
           ,0
           ,0
           ,'')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Purge'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Purge')
           ,0
           ,'String'
           ,'LNPOrderHistoryPurge'
           ,''
           ,'StoredProcedureName'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP Order History Purge'))>0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP Order History Purge')
           ,0
           ,'String'
           ,730
           ,''
           ,'RetentionDays'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END



IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE Name = 'LNPOrderHistoryPurge')
BEGIN
	DROP PROCEDURE dbo.LNPOrderHistoryPurge	  
END
GO

create PROCEDURE [dbo].LNPOrderHistoryPurge
@RetentionWindow INT		
	AS
       BEGIN
	   DECLARE @RetentionDate DATETIME,
		@Continue INT 
	DECLARE @PurgeTable TABLE (Id UNIQUEIDENTIFIER)
	DECLARE @PurgeTableInt TABLE (Id Int) 

	SET @RetentionWindow = -1 * @RetentionWindow
	SET @RetentionDate = DATEADD(day, @RetentionWindow, GETDATE())
	SET @Continue = 1
	WHILE (@Continue > 0)
	BEGIN
		INSERT INTO @PurgeTable SELECT DISTINCT TOP 100 oh.Id AS Id FROM OrderHistory oh (NOLOCK) 
			WHERE oh.OrderDate < @RetentionDate
	
		DELETE oh FROM OrderHistory oh INNER JOIN @PurgeTable pt ON pt.Id = oh.Id
		SET @Continue = @@ROWCOUNT		
		DELETE FROM @PurgeTable
	END 
	END

