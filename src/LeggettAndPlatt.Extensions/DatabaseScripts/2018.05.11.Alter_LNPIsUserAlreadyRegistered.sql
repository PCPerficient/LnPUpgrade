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

					 IF(@Result = 1)
					 BEGIN
					  SET @ActivationStatus = (
						Select  up.ActivationStatus From UserProfile up Where Id = (
                           SELECT cp.ParentId      
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
					
						)

						SET @IsUserDeactivated = (
						Select  up.IsDeactivated From UserProfile up Where Id = (
                           SELECT cp.ParentId      
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
					
						)
					  END
       END