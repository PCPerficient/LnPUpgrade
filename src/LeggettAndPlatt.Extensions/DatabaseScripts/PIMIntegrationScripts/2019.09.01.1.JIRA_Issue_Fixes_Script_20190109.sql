ALTER PROCEDURE [dbo].[PRFTImportCategoryProductLinkDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS

BEGIN
	CREATE TABLE #ImportCategoryProductLog	--PRFTImportCategoryLog
		(
			LogKey				INT IDENTITY(1,1)
			,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
			,LogMessage			NVARCHAR(MAX)
			,LogDateTime		DATETIMEOFFSET
		)
	INSERT INTO #ImportCategoryProductLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Import Link data for ChannelNode-Product from PIM Product ----',GETUTCDATE()
	DECLARE @TargetEntityID INT
	DECLARE @SourceEntityID INT
	DECLARE @ChannelEntityId INT
	DECLARE @ErrorNumber INT
	DECLARE @ErrorLine INT
	DECLARE @Index INT
	DECLARE @ProductID UNIQUEIDENTIFIER
	DECLARE @CategoryID UNIQUEIDENTIFIER
	DECLARE @WebSiteID UNIQUEIDENTIFIER
	DECLARE @ErrorProcedure NVARCHAR(200)
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @Action NVARCHAR(MAX)
	DECLARE @LinkTypeId NVARCHAR(MAX)
	DECLARE @LastModified DATETIMEOFFSET
	DECLARE @IsInactive BIT

	-- for 'A' in Link there should always be 'A' in the respective Entity CSV, if not then don't consider those rows
	DELETE l
		FROM dbo.PIMLink l
		WHERE l.LinkTypeId = 'ChannelNodeProducts'
			AND l.[Action] = 'A'
			AND NOT EXISTS 
				(
					SELECT 1 FROM dbo.PIMProduct WHERE EntityId = l.TargetEntityID
				)

	SELECT ws.Id WebsiteId,CAST(cp.Value AS INT) PimChannelEntityId
		INTO #TempWebsite
		FROM dbo.CustomProperty cp WITH (NOLOCK)
		INNER JOIN dbo.Website ws WITH (NOLOCK) ON cp.ParentId = ws.Id
		WHERE cp.ParentTable = 'Website'
			AND cp.Name = 'pimChannelEntityId'
			AND LEN(LTRIM(RTRIM(cp.Value))) > 0

	DECLARE Cur_CategoryProductLink CURSOR LOCAL FAST_FORWARD FOR
		SELECT 
				l.LinkTypeId
				,l.SourceEntityId
				,c.CategoryId
				,l.TargetEntityId
				,p.ProductId
				,l.[Index]
				,l.Inactive
				,l.[Action]
				,l.LastModified
				,l.ChannelEntityId
				,w.WebsiteId
			FROM dbo.[PIMLink] l WITH (NOLOCK)
			LEFT JOIN #TempWebsite w ON l.ChannelEntityId = w.PimChannelEntityId
			LEFT JOIN
				(
					SELECT cext.CategoryId,cat.WebSiteId,cext.PIMEntityID
						FROM dbo.Category cat WITH (NOLOCK)
						INNER JOIN dbo.PRFTCategoryExtension cext WITH (NOLOCK) ON cat.Id = cext.CategoryID
						INNER JOIN #TempWebsite web ON cat.WebSiteId = web.WebsiteId
				) c ON l.SourceEntityId = c.PIMEntityID
			LEFT JOIN
				(
					SELECT pext.ProductId,pext.PIMProductEntityID
						FROM dbo.Product prd WITH (NOLOCK)
						INNER JOIN dbo.PRFTProductExtension pext WITH (NOLOCK) ON prd.Id = pext.ProductID
				) p ON l.TargetEntityId = p.PIMProductEntityID
			 
			WHERE l.LinkTypeID = 'ChannelNodeProducts'	
			ORDER BY l.LastModified
	OPEN Cur_CategoryProductLink
	FETCH NEXT FROM Cur_CategoryProductLink INTO 
		@LinkTypeId
		,@SourceEntityID
		,@CategoryId
		,@TargetEntityID
		,@ProductId
		,@Index
		,@IsInactive
		,@Action
		,@LastModified
		,@ChannelEntityId
		,@WebSiteID
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @WebSiteID IS NULL
		BEGIN
			BEGIN TRY
				RAISERROR ('Custom Error - Website does not exist in Insite', -- Message text.  
							16, -- Severity.  
							1 -- State.  
							)
			END TRY
			BEGIN CATCH
				SELECT
					@ErrorNumber = ERROR_NUMBER()
					,@ErrorProcedure = ERROR_PROCEDURE()
					,@ErrorLine = ERROR_LINE()
					,@ErrorMessage = ERROR_MESSAGE()
				SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
										+' Error Procedure: '+@ErrorProcedure
										+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
										+' Error Message: '+@ErrorMessage
				-- Log Error for Action Type for Category-Product Link
				INSERT INTO #ImportCategoryProductLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Add/Update/Delete Category - Product Linking - PIM Target Entity ID = '+CAST(@TargetEntityID AS NVARCHAR(50))
								--+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
								+'; PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
								--+'; Category ID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
								+'; Channel Entity ID = '+CAST(@ChannelEntityId AS NVARCHAR(50))				
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @WebSiteID IS NULL
		ELSE IF @Action IN ('A','U','D')
		BEGIN
			IF ((@ProductID IS NULL OR @CategoryID IS NULL) AND @Action = 'A')
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Product and/or Parent Category does not exist in Insite', -- Message text.  
								16, -- Severity.  
								1 -- State.  
								)
				END TRY
				BEGIN CATCH
					SELECT
						@ErrorNumber = ERROR_NUMBER()
						,@ErrorProcedure = ERROR_PROCEDURE()
						,@ErrorLine = ERROR_LINE()
						,@ErrorMessage = ERROR_MESSAGE()
					SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
											+' Error Procedure: '+@ErrorProcedure
											+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
											+' Error Message: '+@ErrorMessage
					-- Log Error for Action Type for Category-Product Link
					INSERT INTO #ImportCategoryProductLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Add Category - Product Linking - PIM Target Entity ID = '+CAST(@TargetEntityID AS NVARCHAR(50))
									+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
									+'; PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
									+'; Category ID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
									+'; Website ID = '+CAST(@WebSiteID AS NVARCHAR(100))				
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @ProductID IS NULL OR @CategoryID IS NULL
			ELSE
			BEGIN	-- @ProductID IS NOT NULL AND @CategoryID IS NOT NULL
				BEGIN TRY
					-- ignore Action = 'U'
					-- Action 'U' will be only when there's change in Index i.e.SortOrder which is available required in CategoryProduct table
					-- for Link Active => Action = 'A' and for Link InActive => Action = 'D'
					IF @Action = 'A'
					BEGIN
						INSERT INTO dbo.CategoryProduct
							(
								Id
								,CategoryId
								,ProductId
								,CreatedOn
								,ModifiedOn
							)
							SELECT
								NEWID()
								,@CategoryID
								,@ProductID
								,@LastModified
								,@LastModified
						-- if attribute values of the product are not associated to the category, then associate them
						INSERT INTO dbo.CategoryAttributeValue
							(
								CategoryID
								,AttributeValueID
							)
							SELECT 
									@CategoryID
									,pav.AttributeValueID
								FROM dbo.ProductAttributeValue pav
								LEFT JOIN dbo.CategoryAttributeValue cav
									ON (cav.CategoryID = @CategoryID AND pav.AttributeValueID = cav.AttributeValueID)
								WHERE pav.ProductID = @ProductID
									AND cav.AttributeValueID IS NULL
						-- if attribute types for attribute values of the product are not associated to the category, then associate them
						INSERT INTO dbo.CategoryAttributeType
							(
								Id
								,CategoryID
								,AttributeTypeID
								,CreatedOn
								,ModifiedOn
							)
							SELECT 
									NEWID()
									,@CategoryID
									,pat.AttributeTypeID
									,@LastModified
									,@LastModified
								FROM 
									(
										SELECT DISTINCT
												@ProductID ProductID
												,av.AttributeTypeID
											FROM dbo.ProductAttributeValue pav
											INNER JOIN dbo.AttributeValue av ON pav.AttributeValueID = av.ID
											WHERE pav.ProductID = @ProductID
									) pat
								LEFT JOIN dbo.CategoryAttributeType cat
									ON (cat.CategoryID = @CategoryID AND pat.AttributeTypeID = cat.AttributeTypeID)
								WHERE cat.AttributeTypeID IS NULL
					END	-- @Action = 'A'
					ELSE IF @Action = 'D'
					BEGIN
						DELETE FROM dbo.CategoryProduct
								WHERE CategoryId = @CategoryID AND ProductId = @ProductID
						-- if no other product of the category is associated to the attribute values, then delete
						DELETE FROM cav
							FROM dbo.CategoryAttributeValue cav
							LEFT JOIN
								(
									SELECT a2.CategoryId,a1.AttributeValueID
										FROM dbo.ProductAttributeValue a1
										INNER JOIN dbo.CategoryProduct a2 
											ON (a2.CategoryId = @CategoryID AND a1.ProductID = a2.ProductID)
								) oldcav 
									ON (cav.CategoryId = oldcav.CategoryID AND cav.AttributeValueID = oldcav.AttributeValueID)
							WHERE cav.CategoryID = @CategoryID
								AND oldcav.AttributeValueId IS NULL
						-- if no attribute values of the attribute type is associated to the category, then delete
						DELETE FROM cat
							FROM dbo.CategoryAttributeType cat
							LEFT JOIN
								(
									SELECT a1.CategoryId,a2.AttributeTypeID 
										FROM dbo.CategoryAttributeValue a1
										INNER JOIN dbo.AttributeValue a2 
											ON (a1.CategoryId = @CategoryID AND a1.AttributeValueID = a2.Id)
								) oldcat
									ON (cat.CategoryId = oldcat.CategoryId AND cat.AttributeTypeId = oldcat.AttributeTypeId)
							WHERE cat.CategoryID = @CategoryID
								AND oldcat.AttributeTypeId IS NULL
					END	-- @Action = 'D'
				END TRY
				BEGIN CATCH
					SELECT
						@ErrorNumber = ERROR_NUMBER()
						,@ErrorProcedure = ERROR_PROCEDURE()
						,@ErrorLine = ERROR_LINE()
						,@ErrorMessage = ERROR_MESSAGE()
					SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
											+' Error Procedure: '+@ErrorProcedure
											+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
											+' Error Message: '+@ErrorMessage
					-- Log Error for Linking Category-Product
					INSERT INTO #ImportCategoryProductLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for '
									+ CASE
										WHEN @Action = 'A' THEN 'Add'
										ELSE 'Delete'
									  END
									+ ' Category - Product Linking - PIM Target Entity ID = '+CAST(@TargetEntityID AS NVARCHAR(50))
									+'; Product ID = '+CAST(@ProductID AS NVARCHAR(100))				
									+'; PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
									+'; Category ID = '+CAST(@CategoryID AS NVARCHAR(100))
									+'; Website ID = '+CAST(@WebSiteID AS NVARCHAR(100))				
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @ProductID IS NOT NULL AND @CategoryID IS NOT NULL
		END	-- @Action IN ('A','U','D')
		ELSE
		BEGIN	-- @Action <> 'A'/'U'/'D'
			BEGIN TRY
				RAISERROR ('Custom Error - Invalid Action (other than A/U/D)', -- Message text.  
							16, -- Severity.  
							1 -- State.  
							)
			END TRY
			BEGIN CATCH
				SELECT
					@ErrorNumber = ERROR_NUMBER()
					,@ErrorProcedure = ERROR_PROCEDURE()
					,@ErrorLine = ERROR_LINE()
					,@ErrorMessage = ERROR_MESSAGE()
				SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
										+' Error Procedure: '+@ErrorProcedure
										+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
										+' Error Message: '+@ErrorMessage
				-- Log Error for Invalid Action Type in Category Linking
				INSERT INTO #ImportCategoryProductLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Invalid Action "'+@Action+'" for Category - Product Linking - PIM Target Entity ID = '+CAST(@TargetEntityID AS NVARCHAR(50))
								+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
								+'; PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
								+'; Category ID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
								+'; Website ID = '+CAST(@WebSiteID AS NVARCHAR(100))				
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @Action <> 'A'/'U'/'D'
		FETCH NEXT FROM Cur_CategoryProductLink INTO 
			@LinkTypeId
			,@SourceEntityID
			,@CategoryId
			,@TargetEntityID
			,@ProductId
			,@Index
			,@IsInactive
			,@Action
			,@LastModified
			,@ChannelEntityId
			,@WebSiteID
	END
	CLOSE Cur_CategoryProductLink
	DEALLOCATE Cur_CategoryProductLink
	INSERT INTO #ImportCategoryProductLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Import Link data for ChannelNode-Product from PIM ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportCategoryProductLog				
	ELSE
	BEGIN
		INSERT INTO dbo.IntegrationJobLog
			(
				Id
				,IntegrationJobId
				,TypeName
				,LogDateTime
				,[Message]
				,CreatedOn
				,ModifiedOn
				,ModuleName
			)
			SELECT
					NEWID()
					,@IntegrationJobId
					,LogTypeName
					,LogDateTime
					,LogMessage
					,LogDateTime
					,LogDateTime
					,'Category-Product Link Import Module'
				FROM #ImportCategoryProductLog
	END
	DROP TABLE #TempWebsite
	IF EXISTS(SELECT 1 FROM #ImportCategoryProductLog WHERE LogTypeName = 'Error')
	BEGIN
		DROP TABLE #ImportCategoryProductLog
		RETURN -1	
		
	END
	ELSE
	BEGIN
		DROP TABLE #ImportCategoryProductLog
		RETURN 0	
	END
END
GO
