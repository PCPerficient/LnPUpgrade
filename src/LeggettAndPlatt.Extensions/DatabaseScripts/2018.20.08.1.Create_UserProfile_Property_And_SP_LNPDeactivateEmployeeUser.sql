IF((SELECT COUNT(1) FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock')=0)
BEGIN

INSERT INTO [AppDict].[PropertyConfiguration]
           ([Id]
           ,[EntityConfigurationId]
           ,[Name]
           ,[ParentProperty]
           ,[Label]
           ,[ControlType]
           ,[IsRequired]
           ,[IsTranslatable]
           ,[HintText]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[ToolTip]
           ,[PropertyType]
           ,[IsCustomProperty]
           ,[CanView]
           ,[CanEdit]
           ,[HintTextPropertyName])
     VALUES
           (NEWID(),
            (SELECT Id FROM [AppDict].[EntityConfiguration] WHERE Name='userprofile')
           ,'employeeUniqueIdOrClock'
           ,''
           ,'Employee UniqueId Or Clock'
           ,'Insite.Admin.ControlTypes.TextFieldControl'
           ,0
           ,0
           ,'Employee UniqueId Or Clock'
           ,GETDATE()
           ,'admin_admin'
           ,GETDATE()
           ,'admin_admin'
           ,'Employee UniqueId Or Clock'
           ,'System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
           ,1
           ,1
           ,1
           ,'')

END

--Permissions for above configurations in [PropertyPermission]
IF((SELECT COUNT(1) FROM [AppDict].[PropertyPermission] WHERE PropertyConfigurationId in(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'))=0)
BEGIN 
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_StoreFrontApi','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_Integration','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_FrontEndDev','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_ContentApprover','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_ContentAdmin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_System','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_ContentEditor','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_User','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_Admin','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
INSERT INTO [AppDict].[PropertyPermission] VALUES (NEWID(),(SELECT Id FROM AppDict.PropertyConfiguration WHERE Name='employeeUniqueIdOrClock'),'ISC_Implementer','admin_admin',GETDATE(),'admin_admin',GETDATE(),NULL,NULL)
END


IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE Name = 'LNPDeactivateEmployeeUser')
BEGIN
	DROP PROCEDURE dbo.LNPDeactivateEmployeeUser	  
END
GO
	
	
CREATE PROCEDURE [dbo].[LNPDeactivateEmployeeUser]
AS
BEGIN
	
	/* Select UserProfileId into Temp Table */
	SELECT DISTINCT ParentId
	INTO #DeactivateUsers
	FROM CustomProperty 
	WHERE ParentTable='UserProfile' 
	AND [Name]='employeeUniqueIdOrClock'
	AND [Value] NOT IN
		(
			SELECT [Unique] 
			FROM LNPEmployee
		)
	AND [Value] NOT IN
		(
			SELECT Clock FROM LNPEmployee
		)

	/* Deactivate UserProfile */
	UPDATE up 
			SET up.IsDeactivated=1 
			FROM dbo.UserProfile up
			INNER JOIN #DeactivateUsers
			cp ON up.Id = cp.ParentId

	/* Deactivate BillTo Customer */
	UPDATE c 
			SET c.IsActive=0
			FROM dbo.Customer c
			INNER JOIN CustomerUserProfile cup 
			ON c.Id = cup.CustomerId
			INNER JOIN #DeactivateUsers cp 
			ON cup.UserProfileId = cp.ParentId
			WHERE c.IsBillTo=1

	--DROP TABLE IF EXISTS #DeactivateUsers
	IF OBJECT_ID('tempdb..#DeactivateUsers') IS NOT NULL
	  DROP TABLE #DeactivateUsers


	/* Select UserProfileId into Temp Table For Updating Last Name */
	SELECT DISTINCT cp.ParentId,le.LastName
	INTO #UpdateUsers
	FROM CustomProperty cp
	INNER JOIN
		(
			SELECT DISTINCT LastName,[Unique] AS [Value] FROM LNPEmployee
			UNION 
			SELECT DISTINCT LastName,Clock AS [Value] FROM LNPEmployee
		) le ON cp.[Value] = le.[Value]
	WHERE cp.ParentTable='UserProfile' 
	AND cp.[Name]='employeeUniqueIdOrClock'

	/* Update UserProfile */
	UPDATE up 
			SET up.LastName=cp.LastName 
			FROM dbo.UserProfile up
			INNER JOIN #UpdateUsers cp
			ON up.Id = cp.ParentId

	UPDATE c 
			SET c.LastName=cp.LastName 
			FROM dbo.Customer c
			INNER JOIN CustomerUserProfile cup 
			ON c.Id = cup.CustomerId
			INNER JOIN #UpdateUsers cp 
			ON cup.UserProfileId = cp.ParentId
			WHERE  c.IsBillTo=1

	--DROP TABLE IF EXISTS #UpdateUsers
		IF OBJECT_ID('tempdb..#UpdateUsers') IS NOT NULL
	  DROP TABLE UpdateUsers

END
GO

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 1.1 Employee Deactivate')=0)
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
           ,'LNP 1.1 Employee Deactivate'
           ,'Deactivate InSite Users that registered using employee data but no longer exist in employee file'
           ,'Execution'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'None'
           ,'ExecuteStoredProcedure'
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

IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP 1.1 Employee Deactivate'))=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP 1.1 Employee Deactivate')
           ,0
           ,'String'
           ,'LNPDeactivateEmployeeUser'
           ,''
           ,'StoredProcedureName'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin')
END

IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP 1 Employee Import')=0)
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
           ,'LNP 1 Employee Import'
           ,'Import employee data from flat file to InSite custom table LNPEmployee'
           ,'Import'
           ,1
           ,0
           ,''
           ,'Completion'
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP 1.1 Employee Deactivate')
           ,0
           ,0
           ,'None'
           ,'FlatFile'
           ,'FieldMap'
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP 1 Employee Import')
           ,1
           ,'Employee'
           ,'LNPEmployee'
           ,NULL
           ,''
           ,'FirstName,LastName,Unique,Clock'
           ,'employee_sample.csv'
           ,''
           ,''
           ,'DeleteRecord'
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Error')

INSERT INTO [dbo].[JobDefinitionStepFieldMap]
           ([Id]
           ,[JobDefinitionStepId]
           ,[FieldType]
           ,[FromProperty]
           ,[ToProperty]
           ,[Overwrite]
           ,[IsErpKey]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[LookupErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinitionStep WHERE Name='Employee')
           ,'Field'
           ,'Unique'
           ,'Unique'
           ,0
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Warning')

INSERT INTO [dbo].[JobDefinitionStepFieldMap]
           ([Id]
           ,[JobDefinitionStepId]
           ,[FieldType]
           ,[FromProperty]
           ,[ToProperty]
           ,[Overwrite]
           ,[IsErpKey]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[LookupErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinitionStep WHERE Name='Employee')
           ,'Field'
           ,'LastName'
           ,'LastName'
           ,1
           ,0
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Warning')

INSERT INTO [dbo].[JobDefinitionStepFieldMap]
           ([Id]
           ,[JobDefinitionStepId]
           ,[FieldType]
           ,[FromProperty]
           ,[ToProperty]
           ,[Overwrite]
           ,[IsErpKey]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[LookupErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinitionStep WHERE Name='Employee')
           ,'Field'
           ,'FirstName'
           ,'FirstName'
           ,1
           ,0
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Warning')

INSERT INTO [dbo].[JobDefinitionStepFieldMap]
           ([Id]
           ,[JobDefinitionStepId]
           ,[FieldType]
           ,[FromProperty]
           ,[ToProperty]
           ,[Overwrite]
           ,[IsErpKey]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[LookupErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinitionStep WHERE Name='Employee')
           ,'Field'
           ,'Clock'
           ,'Clock'
           ,1
           ,0
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Warning')

END

IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE Name = 'LNPIsUserAlreadyRegistered')
BEGIN
	DROP PROCEDURE dbo.LNPIsUserAlreadyRegistered	  
END
GO

Create PROCEDURE [dbo].[LNPIsUserAlreadyRegistered] 
       @LastName NVARCHAR(100),
       @UniqueIdOrClock NVARCHAR(7),
       @Result BIT OUTPUT
       AS
       BEGIN
              SET @Result = 0
              IF EXISTS
                     (
                           SELECT 1      
                                  FROM dbo.CustomProperty     cp
                                  INNER JOIN LNPEmployee le 
                                          ON
                                                (
                                                       le.LastName=@LastName 
                                                       AND (le.[Unique] = @UniqueIdOrClock OR le.Clock=@UniqueIdOrClock)
                                                       AND (cp.[Value] = le.[Unique] OR cp.[Value] = le.Clock)
                                                )
                                  WHERE  cp.ParentTable='UserProfile' 
                                         AND cp.[Name]='employeeUniqueIdOrClock'
                     )
                     SET @Result = 1
       END 


