IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = N'LNPEmployee')
BEGIN

DROP TABLE [dbo].[LNPEmployee]

CREATE TABLE [dbo].[LPEmployee](
	[Id] [uniqueidentifier] NOT NULL DEFAULT (newsequentialid()),
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[UniqueIdNumber] [nvarchar](7) NOT NULL,
	[ClockNumber] [nvarchar](4) NOT NULL,
	[CreatedOn] [datetimeoffset](7) NOT NULL,
	[CreatedBy] [nvarchar](100) NOT NULL,
	[ModifiedOn] [datetimeoffset](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_LPEmployee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[LPEmployee] ADD  CONSTRAINT [DF_LPEmployee_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]

ALTER TABLE [dbo].[LPEmployee] ADD  CONSTRAINT [DF_LPEmployee_ModifiedOn]  DEFAULT (getutcdate()) FOR [ModifiedOn]

END

GO

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

ALTER PROCEDURE [dbo].[LNPIsUserAlreadyRegistered] 
       @LastName NVARCHAR(100),
       @UniqueIdOrClock NVARCHAR(7),
       @Result BIT OUTPUT,
	   @ActivationStatus NVARCHAR(100) OUTPUT,
	   @IsUserDeactivated BIT OUTPUT
       AS
       BEGIN
              SET @Result = 0
              IF EXISTS
                     (
                           SELECT 1      
                                  FROM dbo.CustomProperty     cp
                                  INNER JOIN LPEmployee le 
                                          ON
                                                (
                                                       le.LastName=@LastName 
                                                       AND (le.[UniqueIdNumber] = @UniqueIdOrClock OR le.ClockNumber=@UniqueIdOrClock)
                                                       AND (cp.[Value] = le.[UniqueIdNumber] OR cp.[Value] = le.ClockNumber)
                                                )
                                  WHERE  cp.ParentTable='UserProfile' 
                                         AND cp.[Name]='employeeUniqueIdOrClock'
                     )
                     SET @Result = 1

					 IF(@Result = 1)
					 BEGIN
					  SET @ActivationStatus = (
						Select  up.ActivationStatus From UserProfile up Where Id = (
                           SELECT cp.ParentId      
                                  FROM dbo.CustomProperty     cp
                                  INNER JOIN LPEmployee le 
                                          ON
                                                (
                                                       le.LastName=@LastName 
                                                       AND (le.[UniqueIdNumber] = @UniqueIdOrClock OR le.ClockNumber=@UniqueIdOrClock)
                                                       AND (cp.[Value] = le.[UniqueIdNumber] OR cp.[Value] = le.ClockNumber)
                                                )
                                  WHERE  cp.ParentTable='UserProfile' 
                                         AND cp.[Name]='employeeUniqueIdOrClock'
										 )
					
						)

						SET @IsUserDeactivated = (
						Select  up.IsDeactivated From UserProfile up Where Id = (
                           SELECT cp.ParentId      
                                  FROM dbo.CustomProperty     cp
                                  INNER JOIN LPEmployee le 
                                          ON
                                                (
                                                       le.LastName=@LastName 
                                                       AND (le.[UniqueIdNumber] = @UniqueIdOrClock OR le.ClockNumber=@UniqueIdOrClock)
                                                       AND (cp.[Value] = le.[UniqueIdNumber] OR cp.[Value] = le.ClockNumber)
                                                )
                                  WHERE  cp.ParentTable='UserProfile' 
                                         AND cp.[Name]='employeeUniqueIdOrClock'
										 )
					
						)
					  END
       END

GO


UPDATE JobDefinitionStepFieldMap
SET ToProperty='UniqueIdNumber'
WHERE JobDefinitionStepId = (select Id from JobDefinitionStep where JobDefinitionId = (select ID from JobDefinition where name='LNP 1 Employee Import'))
AND FromProperty='UniqueID'

UPDATE JobDefinitionStepFieldMap
SET ToProperty='ClockNumber'
WHERE JobDefinitionStepId = (select Id from JobDefinitionStep where JobDefinitionId = (select ID from JobDefinition where name='LNP 1 Employee Import'))
AND FromProperty='Clock'

UPDATE JobDefinitionStep
SET ObjectName='LPEmployee'
WHERE JobDefinitionId = (select ID from JobDefinition where name='LNP 1 Employee Import')
AND ObjectName='LNPEmployee'