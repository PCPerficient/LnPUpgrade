ALTER PROCEDURE [dbo].[PRFTImportCategoryDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS

BEGIN
	--SET XACT_ABORT ON
	--SET NOCOUNT ON
	CREATE TABLE #ImportCategoryLog	--PRFTImportCategoryLog
		(
			LogKey				INT IDENTITY(1,1)
			,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
			,LogMessage			NVARCHAR(MAX)
			,LogDateTime		DATETIMEOFFSET
		)
	INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Category Import from PIM ----',GETUTCDATE()
	DECLARE @EntityID			INT
	DECLARE @SourceEntityID		INT
	DECLARE @ChannelEntityId	INT
	DECLARE @ErrorNumber		INT
	DECLARE @ErrorLine			INT
	DECLARE @Index				INT
	DECLARE @CategoryID			UNIQUEIDENTIFIER
	DECLARE @WebSiteID			UNIQUEIDENTIFIER
	DECLARE @ContentManagerID	UNIQUEIDENTIFIER
	DECLARE @vNuContentManagerID	UNIQUEIDENTIFIER
	DECLARE @vNuCategoryID		UNIQUEIDENTIFIER
	DECLARE @vNuParentCategoryID	UNIQUEIDENTIFIER
	DECLARE @vNuCategoryExtensionID	UNIQUEIDENTIFIER
	DECLARE @PersonaID			UNIQUEIDENTIFIER
	DECLARE @LanguageID			UNIQUEIDENTIFIER
	DECLARE @SourceTable		NVARCHAR(100)
	DECLARE @ErrorProcedure		NVARCHAR(200)
	DECLARE @ChannelNodeName	NVARCHAR(255)
	DECLARE @ShortDescription	NVARCHAR(255)
	DECLARE @PageTitle			NVARCHAR(1024)
	DECLARE @MetaKeywords		NVARCHAR(MAX)
	DECLARE @MetaDescription	NVARCHAR(MAX)
	DECLARE @ErrorMessage		NVARCHAR(MAX)
	DECLARE @Action				NVARCHAR(MAX)
	DECLARE @FieldsUpdated		NVARCHAR(MAX)
	DECLARE @DateCreated		DATETIMEOFFSET
	DECLARE @LastModified		DATETIMEOFFSET
	DECLARE @IsInActive			BIT
	DECLARE @ChannelNodeIsActive BIT
	DECLARE @OldChannelNodeIsActive BIT 
	DECLARE @OldLinkInActive	BIT

	UPDATE dbo.PIMChannelNode
		SET LastModified = CAST(DATEADD(dd,-2,GETDATE()) AS DATETIMEOFFSET)
		WHERE LastModified LIKE '1/1/0001%'
	UPDATE dbo.PIMCVLData
		SET LastModified = CAST(DATEADD(dd,-2,GETDATE()) AS DATETIMEOFFSET)
		WHERE LastModified LIKE '1/1/0001%'
	UPDATE dbo.PIMItem
		SET LastModified = CAST(DATEADD(dd,-2,GETDATE()) AS DATETIMEOFFSET)
		WHERE LastModified LIKE '1/1/0001%'
	UPDATE dbo.PIMLink
		SET LastModified = CAST(DATEADD(dd,-2,GETDATE()) AS DATETIMEOFFSET)
		WHERE LastModified LIKE '1/1/0001%'
	UPDATE dbo.PIMProduct
		SET LastModified = CAST(DATEADD(dd,-2,GETDATE()) AS DATETIMEOFFSET)
		WHERE LastModified LIKE '1/1/0001%'
	UPDATE dbo.PIMResource
		SET LastModified = CAST(DATEADD(dd,-2,GETDATE()) AS DATETIMEOFFSET)
		WHERE LastModified LIKE '1/1/0001%'

	-- for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
	CREATE TABLE #TempParents
		(
			ContentManagerID UNIQUEIDENTIFIER
			,CategoryID UNIQUEIDENTIFIER
			,ParentCategoryID UNIQUEIDENTIFIER
			,CategoryExtensionID UNIQUEIDENTIFIER
		)
	-- get ChannelNode Hirarchy for newly created ChannelNodes
	--DROP TABLE #NewCatHirarchy
	CREATE TABLE #NewCatHirarchy
		(
			RowID INT IDENTITY(1,1)
			,SourceEntityID INT
			,TargetEntityID INT
			,[Index] INT
			,InActive BIT
			,[Action] VARCHAR(10)
			,LastModified DATETIMEOFFSET
			,ChannelEntityID INT
			,SourceTable VARCHAR(20)
		)
	-- New Root level ChannelNodes 
	INSERT INTO #NewCatHirarchy
		(
			SourceEntityID
			,TargetEntityID
			,[Index]
			,InActive
			,[Action]
			,LastModified
			,ChannelEntityID
			,SourceTable
		)
		SELECT DISTINCT 
				CAST(NULL AS INT) SourceEntityID
				,CAST(TargetEntityId AS INT) TargetEntityID
				,CAST([Index] AS INT) [Index]
				,CASE
					WHEN ISNULL(InActive,'True') = 'True' THEN 1
					ELSE 0
					END InActive
				,[Action]
				,CAST(LastModified AS DATETIMEOFFSET) 
				,CAST(ChannelEntityId AS INT) ChannelEntityId
				,'Link' SourceTable
			FROM dbo.[PIMLink] 
			WHERE LinkTypeID = 'ChannelChannelNodes'
				AND [Action] = 'A'
			ORDER BY CAST(LastModified AS DATETIMEOFFSET)

	;WITH NewCategoriesWithHirarchy
		(
			SourceEntityID
			,TargetEntityID
			,[Index]
			,InActive
			,[Action]
			,LastModified
			,ChannelEntityID
			,HirarchyLevel
		) 
		AS   
		(  
			-- ChannelNodes not used as Parent in the 'ChannelNodeChannelNodes' Link
			SELECT DISTINCT 
					CAST(l.SourceEntityId AS INT) SourceEntityID
					,CAST(l.TargetEntityId AS INT) TargetEntityID
					,CAST(l.[Index] AS INT)	[Index]
					,CASE
						WHEN ISNULL(l.InActive,'True') = 'True' THEN 1
						ELSE 0
					 END InActive
					,l.[Action]
					,CAST(l.LastModified AS DATETIMEOFFSET) LastModified
					,CAST(l.ChannelEntityId AS INT) ChannelEntityId
					,CAST(1 AS INT) HirarchyLevel
				FROM dbo.[PIMLink] l 
				WHERE l.LinkTypeID = 'ChannelNodeChannelNodes'
					AND l.[Action] = 'A'
					AND NOT EXISTS 
						(
							SELECT 1 
								FROM dbo.[PIMLink] l1 
								WHERE l1.LinkTypeID = 'ChannelNodeChannelNodes' 
									AND l1.[Action] = 'A' 
									AND l1.SourceEntityID = l.TargetEntityID
						)
			UNION ALL  
			-- Other levels of ChannelNodes 
			SELECT 
					CAST(e.SourceEntityId AS INT) SourceEntityID
					,CAST(e.TargetEntityId AS INT) TargetEntityID
					,CAST(e.[Index] AS INT)	[Index]
					,CASE
						WHEN ISNULL(e.InActive,'True') = 'True' THEN 1
						ELSE 0
					 END InActive
					,e.[Action]
					,CAST(e.LastModified AS DATETIMEOFFSET) LastModified
					,CAST(e.ChannelEntityId AS INT) ChannelEntityId
					,d.HirarchyLevel + 1 HirarchyLevel
				FROM dbo.[PIMLink] e   
				INNER JOIN NewCategoriesWithHirarchy d ON e.TargetEntityID = d.SourceEntityID
				WHERE e.LinkTypeID = 'ChannelNodeChannelNodes'
					AND e.[Action] = 'A'
		)
	-- New Other than Root Level Categories
	INSERT INTO #NewCatHirarchy
		(
			SourceEntityID
			,TargetEntityID
			,[Index]
			,InActive
			,[Action]
			,LastModified
			,ChannelEntityID
			,SourceTable
		)
		SELECT 
				SourceEntityID
				,TargetEntityID
				,[Index]
				,InActive
				,[Action]
				,LastModified
				,ChannelEntityID
				,'Link' SourceTable
			FROM  NewCategoriesWithHirarchy 
			ORDER BY HirarchyLevel DESC, CAST(LastModified AS DATETIMEOFFSET)
			OPTION ( MaxRecursion 0 )
	-- Existing Categories used for 'U' and 'D' in Link
	INSERT INTO #NewCatHirarchy
		(
			SourceEntityID
			,TargetEntityID
			,[Index]
			,InActive
			,[Action]
			,LastModified
			,ChannelEntityID
			,SourceTable
		)
		SELECT 
				CASE
					WHEN l.LinkTypeId = 'ChannelChannelNodes' THEN CAST(NULL AS INT)
					ELSE CAST(l.SourceEntityId AS INT)
				END SourceEntityId
				,CAST(l.TargetEntityId AS INT) TargetEntityId
				,CAST(l.[Index] AS INT)	[Index]
				,CASE
					WHEN ISNULL(l.InActive,'True') = 'True' THEN 1
					ELSE 0
				 END InActive
				,l.[Action]
				,CAST(l.LastModified AS DATETIMEOFFSET) LastModified
				,CAST(l.ChannelEntityId AS INT) ChannelEntityId
				,'Link' SourceTable
			FROM dbo.PIMLink l
			WHERE l.LinkTypeId IN ('ChannelChannelNodes','ChannelNodeChannelNodes')
				AND l.[Action] <> 'A'
		UNION ALL
		SELECT 
				CAST(NULL AS INT) SourceEntityId
				,CAST(c.EntityId AS INT)
				,CAST(NULL AS INT)				--SortOrder
				,CASE
					WHEN ISNULL(c.ChannelNodeIsActive,'False') = 'False' THEN 1
					ELSE 0
				 END 							--ActivateOn,DeactivateOn
				,c.[Action]
				,CAST(c.LastModified AS DATETIMEOFFSET) LastModified	--ModifiedOn
				,CAST(NULL AS INT)
				,'Entity' SourceTable
			FROM dbo.PIMChannelNode c
			WHERE c.[Action] NOT IN ('A','D')
		ORDER BY LastModified
	-- get ChannelNode (Category) data from PIM
	DECLARE Cur_Categories CURSOR LOCAL FAST_FORWARD FOR
		SELECT 
				l.SourceEntityId
				,l.TargetEntityId
				,l.[Index]				--SortOrder
				,l.InActive				--ActivateOn,DeactivateOn
				,l.[Action]
				,w.Id					--Insite WebsiteId
				,l.LastModified			--ModifiedOn
				,l.ChannelEntityId
				,l.SourceTable
			FROM #NewCatHirarchy l
			LEFT JOIN
				(
					SELECT ws.Id,CAST(cp.Value AS INT) PimChannelEntityId
						FROM dbo.CustomProperty cp
						INNER JOIN dbo.Website ws ON cp.ParentId = ws.Id
						WHERE cp.ParentTable = 'Website'
							AND cp.Name = 'pimChannelEntityId'
				) w ON ISNULL(l.ChannelEntityId,0) = ISNULL(CAST(w.PimChannelEntityId AS INT),0)
			ORDER BY l.RowID
	OPEN Cur_Categories
	INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Import Entity_ChannelNode data from PIM',GETUTCDATE()
	FETCH NEXT FROM Cur_Categories INTO 
		@SourceEntityID	
		,@EntityID
		,@Index			--SortOrder
		,@IsInActive		--ActivateOn,DeactivateOn
		,@Action
		,@WebSiteID		--Insite WebsiteId
		,@LastModified	--ModifiedOn
		,@ChannelEntityId
		,@SourceTable
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SELECT @PersonaID = Id FROM dbo.Persona WHERE Name = 'Default'
		SELECT @LanguageID = Id FROM dbo.Language WHERE LanguageCode = 'en-US'
		-- for 'A' - Category data will exist in PIMLink as well as PIMChannelNode
		IF @Action = 'A'
		BEGIN
			-- for 'A' Insite Website should be present for each Category i.e. row with valid ChannelEntityId should be present in PIMLink
			IF @WebsiteId IS NULL
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Cannot Add Category as it has Invalid WebsiteID or Website not in Insite', -- Message text.  
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
					-- Log Error for Add Category
					INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Add Category - PIM Target Entity ID = '+ISNULL(CAST(@EntityID AS NVARCHAR(50)),'**NULL**')
									+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
									+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @WebsiteId IS NULL
			ELSE
			BEGIN	-- @WebsiteId IS NOT NULL
				SELECT 
						@ChannelNodeName = 
							CASE
								WHEN LEN(ISNULL(cn.ChannelNodename,'')) <= 255 THEN cn.ChannelNodename
								ELSE LEFT(cn.ChannelNodename,255)
							END			--Name, ShortDescription, UrlSegment
						,@ShortDescription = cn.ChannelNodeDescription		-- Insite Content
						,@MetaKeywords = cn.ChannelNodeMetaKeywords			--MetaKeywords
						,@MetaDescription = cn.ChannelNodeMetaDescription	--MetaDescription
						,@PageTitle = 				
							CASE
								WHEN LEN(ISNULL(cn.ChannelNodeMetaTitle,'')) <= 1024 THEN cn.ChannelNodeMetaTitle
								ELSE LEFT(cn.ChannelNodeMetaTitle,1024)
							END			--PageTitle
						,@DateCreated = CAST(cn.DateCreated AS DATETIMEOFFSET)	--CreatedOn
						,@ChannelNodeIsActive = 
							CASE
								WHEN ISNULL(cn.ChannelNodeIsActive,'False') = 'False' THEN 0
								ELSE 1
							END 											--ActivateOn,DeactivateOn
					FROM dbo.PIMChannelNode cn
					WHERE cn.EntityId = @EntityID
				-- for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
				TRUNCATE TABLE #TempParents
				IF @SourceEntityID IS NULL	-- New Root level Category
				BEGIN
					-- logic for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
					INSERT INTO #TempParents
						SELECT NEWID() ContentManagerID, NEWID() CategoryID, NULL ParentCategoryID, NEWID() CategoryExtensionID
				END
				ELSE 
				BEGIN
					-- logic for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
					INSERT INTO #TempParents
						SELECT NEWID() ContentManagerID, NEWID() CategoryID, c.ID ParentCategoryID, NEWID() CategoryExtensionID 
							FROM dbo.Category c WITH(NOLOCK)
							INNER JOIN dbo.PRFTCategoryExtension ce WITH(NOLOCK) 
								ON (ce.PIMEntityID = @SourceEntityID AND c.ID = ce.CategoryID)
							WHERE c.WebSiteID = @WebSiteID
				END
				DECLARE curNuCat CURSOR LOCAL FAST_FORWARD FOR
					SELECT ContentManagerID,CategoryID, ParentCategoryID, CategoryExtensionID
						FROM #TempParents
				OPEN curNuCat
				FETCH NEXT FROM curNuCat INTO @vNuContentManagerID,@vNuCategoryID,@vNuParentCategoryID,@vNuCategoryExtensionID
				WHILE @@FETCH_STATUS = 0 
				BEGIN
					BEGIN TRY
						IF NOT EXISTS
							(
								SELECT 1 FROM dbo.Category 
									WHERE Name = @ChannelNodeName 
										AND WebSiteID = @WebSiteID 
										AND ISNULL(CAST(ParentId AS NVARCHAR(100)),'') = ISNULL(CAST(@vNuParentCategoryID AS NVARCHAR(100)),'')
							)
						BEGIN
							INSERT INTO dbo.ContentManager
								(
									Id
									,Name
									,CreatedOn
									--,CreatedBy
									,ModifiedOn
									--,ModifiedBy
								)
								-- for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
								SELECT 
										@vNuContentManagerID
										,'Category'
										,@DateCreated
										--,CreatedBy
										,@LastModified
										--,ModifiedBy
							-- Category short description used instead of title on Category pages and widgets
							IF ISNULL(@ShortDescription,'') <> ''
							BEGIN
								INSERT INTO dbo.Content 
									(
										Id
										,ContentManagerId
										,Html
										,SubmittedForApprovalOn
										,ApprovedOn
										,PublishToProductionOn
										,CreatedOn
										,Revision
										,DeviceType
										,PersonaId
										,LanguageId
										,ModifiedOn
									)
									SELECT
										NEWID()
										,@vNuContentManagerID
										,@ShortDescription
										,@DateCreated
										,@DateCreated
										,@DateCreated
										,@DateCreated
										,1
										,'Desktop'
										,@PersonaID
										,@LanguageID
										,@LastModified
							END	-- ISNULL(@ShortDescription,'') <> ''
							INSERT INTO dbo.Category
								(
									ID
									,WebSiteID
									,ParentId
									,Name
									,ShortDescription
									,MetaKeywords
									,MetaDescription
									,PageTitle
									,ActivateOn
									,DeActivateOn
									,UrlSegment
									,ContentManagerId
									,CreatedOn
									,ModifiedOn
								)
								SELECT
										@vNuCategoryID
										,@WebSiteID
										,@vNuParentCategoryID
										,@ChannelNodeName
										,@ChannelNodeName
										,@MetaKeywords
										,@MetaDescription
										,@PageTitle
										,todatetimeoffset(cast(dateadd(day,-1,cast(@DateCreated as datetime)) as datetime2),datepart(tz,CAST(@DateCreated AS DATETIMEOFFSET)))
										,CASE 
											-- Entity ChannelNode is Active and Link ChannelChannelNodes/ChannelNodeChannelNodes is Active
											WHEN @IsInActive = 0 AND @ChannelNodeIsActive = 1 
												THEN NULL
											-- Entity ChannelNode is Active or Link ChannelChannelNodes/ChannelNodeChannelNodes is Active
											ELSE
												CASE
													-- Entity ChannelNode is InActive
													WHEN @ChannelNodeIsActive = 0
														THEN todatetimeoffset(cast(dateadd(day,-1,cast(@DateCreated as datetime)) as datetime2),datepart(tz,CAST(@DateCreated AS DATETIMEOFFSET)))
													-- Link ChannelChannelNodes/ChannelNodeChannelNodes is InActive
													ELSE todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET))) 
												END
										 END
										,@ChannelNodeName
										,@vNuContentManagerID
										,@DateCreated
										,@LastModified
							INSERT INTO dbo.PRFTCategoryExtension
								(
									ID
									,CategoryID
									,PIMEntityID
									,PIMChannelNodeIsActive
									,PIMLinkInActive
								)
								SELECT
										@vNuCategoryExtensionID
										,@vNuCategoryID
										,@EntityID
										,@ChannelNodeIsActive
										,@IsInActive
						END	 -- Category does not exist
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
						-- Log Error for New Category
						INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error for New Category - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
										+'; Category Name = '+ISNULL(@ChannelNodeName,'**NULL**')
										+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
					FETCH NEXT FROM curNuCat INTO @vNuContentManagerID,@vNuCategoryID,@vNuParentCategoryID,@vNuCategoryExtensionID
				END		-- end cursor curNuCat
				CLOSE curNuCat
				DEALLOCATE curNuCat
			END	-- @WebsiteId IS NOT NULL
		END	-- @Action = 'A'
		ELSE IF @Action = 'U'
		BEGIN
			-- for data from PIMLink a valid Website should always exist in Insite
			IF (@SourceTable = 'Link' AND @WebsiteId IS NULL)
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Cannot Update Category Link as Website does not exist in Insite', -- Message text.  
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
					--ROLLBACK TRANSACTION
					SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
											+' Error Procedure: '+@ErrorProcedure
											+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
											+' Error Message: '+@ErrorMessage
					-- Log Error for Update Category
					INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Update Category Link - PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
									+'; PIM Target Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END		-- @SourceTable = 'Link' AND @WebsiteId IS NULL
			ELSE
			BEGIN	-- @SourceTable <> 'Link' OR @WebsiteId IS NOT NULL
				-- for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
				IF EXISTS (
							SELECT 1 FROM dbo.Category c WITH(NOLOCK) 
								INNER JOIN dbo.PRFTCategoryExtension ce WITH(NOLOCK)
									ON (ce.PIMEntityID = @EntityID AND c.ID = ce.CategoryID)
								WHERE
									(
										-- in case of Link - Website will be available
										(@WebSiteID IS NOT NULL AND c.WebSiteID = @WebSiteID)
										OR
										-- in case of Entity - Website will not be available (changes will be across all websites)
										(@WebSiteID IS NULL)
									)
						  )
				BEGIN
					-- for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
					DECLARE curUpCat CURSOR LOCAL FAST_FORWARD FOR
						SELECT c.ID, c.ContentManagerId, ce.PIMChannelNodeIsActive, ce.PIMLinkInActive
							FROM dbo.Category c WITH(NOLOCK)
							INNER JOIN dbo.PRFTCategoryExtension ce WITH(NOLOCK)
								ON (ce.PIMEntityID = @EntityID AND c.ID = ce.CategoryID)
							WHERE
								(
									-- in case of Link - Website will be available
									(@WebSiteID IS NOT NULL AND c.WebSiteID = @WebSiteID)
									OR
									-- in case of Entity - Website will not be available (changes will be across all websites)
									(@WebSiteID IS NULL)
								)
					OPEN curUpCat
					FETCH NEXT FROM curUpCat INTO @CategoryID, @ContentManagerID, @OldChannelNodeIsActive, @OldLinkInActive
					WHILE @@FETCH_STATUS = 0 
					BEGIN
						BEGIN TRY
							IF @SourceTable = 'Link'
							BEGIN
								UPDATE dbo.Category
									SET
										SortOrder = @Index
										,DeactivateOn = 
											CASE 
												-- Link = InActive or Category = InActive => InActive
												WHEN (@IsInActive = 1 OR @OldChannelNodeIsActive = 0) THEN ActivateOn
												-- Link = Active and Category = Active => Active
												WHEN (@IsInActive = 0 AND @OldChannelNodeIsActive = 1) THEN NULL
												ELSE DeactivateOn 
											END
									WHERE Id = @CategoryID
								UPDATE dbo.PRFTCategoryExtension 
									SET PIMLinkInActive = @IsInActive
									WHERE CategoryID = @CategoryID
							END
							ELSE
							BEGIN	-- @SourceTable = 'Entity'
								SELECT 
										@ChannelNodeName = 
											CASE
												WHEN LEN(ISNULL(cn.ChannelNodename,'')) <= 255 THEN cn.ChannelNodename
												ELSE LEFT(cn.ChannelNodename,255)
											END												--Name, ShortDescription, UrlSegment
										,@ShortDescription = cn.ChannelNodeDescription		-- Insite Content
										,@MetaKeywords = cn.ChannelNodeMetaKeywords			--MetaKeywords
										,@MetaDescription = cn.ChannelNodeMetaDescription	--MetaDescription
										,@PageTitle = 
											CASE
												WHEN LEN(ISNULL(cn.ChannelNodeMetaTitle,'')) <= 1024 THEN cn.ChannelNodeMetaTitle
												ELSE LEFT(cn.ChannelNodeMetaTitle,1024)
											END												--PageTitle
										,@FieldsUpdated = cn.FieldsUpdated
										,@DateCreated = CAST(cn.DateCreated AS DATETIMEOFFSET)
									FROM dbo.PIMChannelNode cn
									WHERE cn.EntityId = @EntityID
								UPDATE dbo.Category
									SET
										Name = @ChannelNodeName
										-- Category short description used instead of title on Category pages and widgets
										,ShortDescription = @ChannelNodeName	
										,MetaKeywords = @MetaKeywords
										,MetaDescription = @MetaDescription
										,PageTitle = @PageTitle
										,UrlSegment = @ChannelNodeName
										,ModifiedOn = @LastModified
										,DeactivateOn = 
											CASE 
												-- Link = InActive or Category = InActive => InActive
												WHEN (@OldLinkInActive = 1 OR @IsInActive = 1) THEN ActivateOn
												-- Link = Active and Category = Active => Active
												WHEN (@OldLinkInActive = 0 AND @IsInActive = 0) THEN NULL
												ELSE DeactivateOn 
											END
									WHERE ID = @CategoryID
								UPDATE dbo.PRFTCategoryExtension 
									SET PIMChannelNodeIsActive = 
										CASE WHEN @IsInActive = 0 THEN 1 ELSE 0 END
									WHERE CategoryID = @CategoryID
								IF PATINDEX('%ChannelNodeDescription%',@FieldsUpdated) > 0
								BEGIN
									-- for the category, delete content of 'en-us' from Insite
									DELETE FROM dbo.Content 
										WHERE ContentManagerId = @ContentManagerID AND LanguageId = @LanguageID
									-- for the category, re-insert content of 'en-us', if exists in PIM
									IF ISNULL(@ShortDescription,'') <> ''
									BEGIN
										INSERT INTO dbo.Content 
											(
												Id
												,ContentManagerId
												,Html
												,SubmittedForApprovalOn
												,ApprovedOn
												,PublishToProductionOn
												,CreatedOn
												,Revision
												,DeviceType
												,PersonaId
												,LanguageId
												,ModifiedOn
											)
											SELECT
												NEWID()
												,@ContentManagerID
												,@ShortDescription
												-- 2018/12/26 - begin - JIRA - LPCF-454 - Cannot insert the value NULL into column 'CreatedOn'
												,@LastModified
												,@LastModified
												,@LastModified
												,@LastModified
												-- 2018/12/26 - end - JIRA - LPCF-454 - Cannot insert the value NULL into column 'CreatedOn'
												,1
												,'Desktop'
												,@PersonaID
												,@LanguageID
												,@LastModified
									END	-- ISNULL(@ShortDescription,'') <> ''
								END	-- PATINDEX('%ChannelNodeDescription%',@FieldsUpdated) > 0
							END	-- @SourceTable = 'Entity'
						END TRY
						BEGIN CATCH
							SELECT
								@ErrorNumber = ERROR_NUMBER()
								,@ErrorProcedure = ERROR_PROCEDURE()
								,@ErrorLine = ERROR_LINE()
								,@ErrorMessage = ERROR_MESSAGE()
							--ROLLBACK TRANSACTION
							SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
													+' Error Procedure: '+@ErrorProcedure
													+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
													+' Error Message: '+@ErrorMessage
							-- Log Error for Update Category
							INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
								SELECT	'Warn'
										,'Error for Update Category '
											+ CASE 
												WHEN @SourceTable = 'Link' 
													THEN 'Link - PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
														+'; PIM Target Entity ID = '+CAST(@EntityID AS NVARCHAR(50)) 
												ELSE ' - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50)) 
											  END
											+'; CategoryID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
											+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
											+ '; Error Message = '+@ErrorMessage
										,GETUTCDATE()
						END CATCH
						FETCH NEXT FROM curUpCat INTO @CategoryID, @ContentManagerID, @OldChannelNodeIsActive, @OldLinkInActive
					END
					CLOSE curUpCat
					DEALLOCATE curUpCat
				END	-- Category exists in Insite
				ELSE	
				BEGIN	-- Category does not exist in Insite
					BEGIN TRY
						RAISERROR ('Custom Error - Cannot Update Category as it does not exist in Insite', -- Message text.  
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
						--ROLLBACK TRANSACTION
						SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
												+' Error Procedure: '+@ErrorProcedure
												+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
												+' Error Message: '+@ErrorMessage
						-- Log Error for Update Category
						INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error for Update Category '
										+ CASE 
											WHEN @SourceTable = 'Link' 
												THEN 'Link - PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
													+'; PIM Target Entity ID = '+CAST(@EntityID AS NVARCHAR(50)) 
											ELSE ' - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50)) 
											END
										+'; CategoryID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
										+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
				END	-- Category does not exist in Insite
			END		-- @SourceTable <> 'Link' OR @WebsiteId IS NOT NULL
		END	-- @Action = 'U'
		ELSE IF @Action = 'D'
		BEGIN
			-- for 'D' Insite Website should be present for each Category i.e. row with valid ChannelEntityId should be present in PIMLink
			IF @WebsiteId IS NULL
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Cannot Delete Category as it has Invalid WebsiteID or Website not in Insite', -- Message text.  
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
					--ROLLBACK TRANSACTION
					SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
											+' Error Procedure: '+@ErrorProcedure
											+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
											+' Error Message: '+@ErrorMessage
					-- Log Error for Update Category
					INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Delete Category '
									+ CASE 
										WHEN @SourceTable = 'Link' 
											THEN 'Link - PIM Source Entity ID = '+CAST(@SourceEntityID AS NVARCHAR(50))
												+'; PIM Target Entity ID = '+CAST(@EntityID AS NVARCHAR(50)) 
										ELSE ' - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50)) 
										END
									+'; CategoryID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
									+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @WebsiteId IS NULL
			ELSE
			BEGIN	-- @WebsiteId IS NOT NULL
				IF EXISTS (
							SELECT 1 FROM dbo.Category c WITH(NOLOCK) 
								INNER JOIN dbo.PRFTCategoryExtension ce WITH(NOLOCK)
									ON (ce.PIMEntityID = @EntityID AND c.ID = ce.CategoryID)
								WHERE c.WebSiteID = @WebSiteID
						  )
				-- for Sub-Categories having Parent Category associated to multiple Grand-Parent Categories
				BEGIN
					TRUNCATE TABLE #TempParents
					IF @SourceEntityID IS NULL	-- New Root level Category
					BEGIN
						INSERT INTO #TempParents
							SELECT c.ContentManagerID, c.Id CategoryID, NULL ParentCategoryID, ce.Id CategoryExtensionID
								FROM dbo.Category c WITH(NOLOCK)
								INNER JOIN dbo.PRFTCategoryExtension ce WITH(NOLOCK)
									ON (ce.PIMEntityID = @EntityID AND c.ID = ce.CategoryID)
								WHERE (c.WebSiteID = @WebSiteID AND c.ParentId IS NULL)
					END
					ELSE 
					BEGIN
						INSERT INTO #TempParents
							SELECT c.ContentManagerID, c.Id CategoryID, c.ParentId ParentCategoryID, ce.Id CategoryExtensionID
								FROM dbo.Category c WITH(NOLOCK)
								INNER JOIN dbo.PRFTCategoryExtension ce WITH(NOLOCK)
									ON (ce.PIMEntityID = @EntityID AND c.ID = ce.CategoryID)
								INNER JOIN dbo.Category pc WITH(NOLOCK) ON c.ParentId = pc.Id
								INNER JOIN dbo.PRFTCategoryExtension pce WITH(NOLOCK)
									ON (pce.PIMEntityID = @SourceEntityID AND pc.ID = pce.CategoryID)
								WHERE (c.WebSiteID = @WebSiteID AND pc.WebSiteID = @WebSiteID AND c.ParentId IS NOT NULL)
					END
					DECLARE curDelCat CURSOR LOCAL FAST_FORWARD FOR
						SELECT ContentManagerID,CategoryID, ParentCategoryID, CategoryExtensionID
							FROM #TempParents
					OPEN curDelCat
					FETCH NEXT FROM curDelCat INTO @vNuContentManagerID,@vNuCategoryID,@vNuParentCategoryID,@vNuCategoryExtensionID
					WHILE @@FETCH_STATUS = 0 
					BEGIN
						BEGIN TRY
							DELETE FROM dbo.TranslationProperty
								WHERE ParentTable = 'Category'
									AND ParentID = @vNuCategoryID
							DELETE cn
								FROM dbo.Content cn
								WHERE cn.ContentManagerId = @vNuContentManagerID
							DELETE cnm
								FROM dbo.ContentManager cnm 
								WHERE cnm.Id = @vNuContentManagerID
							DELETE FROM dbo.PRFTCategoryExtension
								WHERE Id = @vNuCategoryExtensionID
							DELETE FROM dbo.Category
								WHERE ID = @vNuCategoryID
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
							-- Log Error for Delete Category
							INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
								SELECT	'Warn'
										,'Error for Delete Category - PIM Target Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
											+'; PIM Source Entity ID = '+ISNULL(CAST(@EntityID AS NVARCHAR(50)),'**NULL**')
											+'; CategoryID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
											+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
											+ '; Error Message = '+@ErrorMessage
										,GETUTCDATE()
						END CATCH
						FETCH NEXT FROM curDelCat INTO @vNuContentManagerID,@vNuCategoryID,@vNuParentCategoryID,@vNuCategoryExtensionID
					END
					CLOSE curDelCat
					DEALLOCATE curDelCat
				END	-- Category exists in Insite
				ELSE	
				BEGIN	-- Category does not exist in Insite
					BEGIN TRY
						RAISERROR ('Custom Error - Cannot Delete Category as it does not exist in Insite', -- Message text.  
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
						-- Log Error for Delete Category
						INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error for Delete Category - PIM Target Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
										+'; PIM Source Entity ID = '+ISNULL(CAST(@EntityID AS NVARCHAR(50)),'**NULL**')
										+'; CategoryID = '+ISNULL(CAST(@CategoryID AS NVARCHAR(100)),'**NULL**')
										+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
				END	-- Category does not exist in Insite
			END	-- @WebsiteId IS NOT NULL
		END	-- @Action = 'D'
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
				--ROLLBACK TRANSACTION
				SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
										+' Error Procedure: '+@ErrorProcedure
										+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
										+' Error Message: '+@ErrorMessage
				-- Log Error for Invalid Action Type in Category
				INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Category - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
								+'; WebSiteID = '+ISNULL(CAST(@WebSiteID AS NVARCHAR(100)),'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @Action <> 'A'/'U'/'D'
		FETCH NEXT FROM Cur_Categories INTO 
			@SourceEntityID	
			,@EntityID
			,@Index			--SortOrder
			,@IsInActive		--ActivateOn,DeactivateOn
			,@Action
			,@WebSiteID		--Insite WebsiteId
			,@LastModified	--ModifiedOn
			,@ChannelEntityId
			,@SourceTable
	END
	CLOSE Cur_Categories
	DEALLOCATE Cur_Categories
	INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Import Entity_ChannelNode data from PIM',GETUTCDATE()
	DROP TABLE #TempParents
	INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Import Link data for ChannelNodes from PIM',GETUTCDATE()
	INSERT INTO #ImportCategoryLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Category Import from PIM ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportCategoryLog				
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
					,'Category Imort Module'
				FROM #ImportCategoryLog
	END
	IF EXISTS(SELECT 1 FROM #ImportCategoryLog WHERE LogTypeName = 'Error')
	BEGIN
		--RAISERROR ('Completed with Errors...',16, 1)
		DROP TABLE #ImportCategoryLog
		RETURN -1	--ERROR_STATE()
		
	END
	ELSE
	BEGIN
		DROP TABLE #ImportCategoryLog
		RETURN 0	--ERROR_STATE()
	END
END
GO
