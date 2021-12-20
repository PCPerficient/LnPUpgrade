ALTER PROCEDURE [dbo].[LNPDeactivateEmployeeUser]
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
			SELECT [UniqueIdNumber] 
			FROM LPEmployee
		)
	AND [Value] NOT IN
		(
			SELECT ClockNumber FROM LPEmployee
		)
	AND [Value] <> 'DO NOT REMOVE'

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

	DROP TABLE IF EXISTS #DeactivateUsers


	/* Select UserProfileId into Temp Table For Updating Last Name */
	SELECT DISTINCT cp.ParentId,le.LastName
	INTO #UpdateUsers
	FROM CustomProperty cp
	INNER JOIN
		(
			SELECT DISTINCT LastName,[UniqueIdNumber] AS [Value] FROM LPEmployee
			UNION 
			SELECT DISTINCT LastName,ClockNumber AS [Value] FROM LPEmployee
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

	DROP TABLE IF EXISTS #UpdateUsers

END

GO

UPDATE  AppDict.PropertyConfiguration
SET ToolTip ='Employee UniqueId Or Clock; Enter "DO NOT REMOVE" for member without ID such as Board Member'
WHERE Name='employeeUniqueIdOrClock' and EntityConfigurationId=(SELECT Id FROM AppDict.EntityConfiguration WHERE Name='userProfile')