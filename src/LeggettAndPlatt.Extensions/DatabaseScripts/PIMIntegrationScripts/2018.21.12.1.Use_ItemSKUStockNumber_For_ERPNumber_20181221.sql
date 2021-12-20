ALTER PROCEDURE [dbo].[PRFTImportItemDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	--SET XACT_ABORT ON
	--SET NOCOUNT ON
	-- table to hold error/log info. while processing data
	CREATE TABLE #ImportItemLog	--PRFTImportCategoryLog
		(
			LogKey				INT IDENTITY(1,1)
			,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
			,LogMessage			NVARCHAR(MAX)
			,LogDateTime		DATETIMEOFFSET
		)
	INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Item Import from PIM Item ----',GETUTCDATE()
	CREATE TABLE #TempItems
		(
			ProductID UNIQUEIDENTIFIER
			,ContentManagerID UNIQUEIDENTIFIER
			,ProductExtensionID UNIQUEIDENTIFIER
		)
	DECLARE @EntityID INT
	DECLARE @SourceEntityID INT
	DECLARE @ErrorNumber INT
	DECLARE @ErrorLine INT
	DECLARE @Index INT
	DECLARE @QtyPerShippingPackage INT
	DECLARE @ShippingWeight DECIMAL(18,3)
	DECLARE @ShippingLength DECIMAL(18,3)
	DECLARE @ShippingWidth DECIMAL(18,3)
	DECLARE @ShippingHeight DECIMAL(18,3)
	DECLARE @ProductID UNIQUEIDENTIFIER
	DECLARE @ProductExtensionID UNIQUEIDENTIFIER
	DECLARE @ParentProductID UNIQUEIDENTIFIER
	DECLARE @StyleParentID UNIQUEIDENTIFIER
	DECLARE @ContentManagerID UNIQUEIDENTIFIER
	DECLARE @ContentID UNIQUEIDENTIFIER
	DECLARE @PersonaID UNIQUEIDENTIFIER
	DECLARE @LanguageID UNIQUEIDENTIFIER
	DECLARE @VendorID UNIQUEIDENTIFIER
	DECLARE @SectionID UNIQUEIDENTIFIER
	DECLARE @ProductCode NVARCHAR(50)
	DECLARE @UPCCode NVARCHAR(50)
	DECLARE @ModelNumber NVARCHAR(50)
	DECLARE @SourceTable NVARCHAR(50)
	DECLARE @ItemNumber NVARCHAR(50)
	DECLARE @ItemSKUStockNumber NVARCHAR(100)
	DECLARE @ProductType NVARCHAR(100)
	DECLARE @ErrorProcedure NVARCHAR(200)
	DECLARE @ItemName NVARCHAR(255)
	DECLARE @PackDescription NVARCHAR(255)
	DECLARE @ParentProductName NVARCHAR(255)
	DECLARE @UrlSegment NVARCHAR(255)
	DECLARE @FilePath1 NVARCHAR(1024)
	DECLARE @FilePath2 NVARCHAR(1024)
	DECLARE @FilePath3 NVARCHAR(1024)
	DECLARE @FilePath4 NVARCHAR(1024)
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @Action NVARCHAR(MAX)
	DECLARE @FieldsUpdated NVARCHAR(MAX)
	DECLARE @CountryofOrigin NVARCHAR(MAX)
	DECLARE @ItemShortProductDescription NVARCHAR(MAX)
	DECLARE @ItemLongProductDescription NVARCHAR(MAX) 
	DECLARE @ItemBulletFeature1 NVARCHAR(MAX) 
	DECLARE @ItemBulletFeature2 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature3 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature4 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature5 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature6 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature7 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature8 NVARCHAR(MAX)
	DECLARE @ItemBulletFeature9 NVARCHAR(MAX)
	DECLARE @ContentDescription NVARCHAR(MAX)
	DECLARE @vertaxBranch NVARCHAR(MAX)
	DECLARE @vertaxTaxAreaId NVARCHAR(MAX)
	DECLARE @vertaxLegalEntity NVARCHAR(MAX)
	DECLARE @LastModified DATETIME
	DECLARE @IsInactive BIT
	DECLARE @IsSelected BIT
	-- get Item data from PIM
	DECLARE Cur_Items CURSOR LOCAL FAST_FORWARD FOR
		SELECT	DISTINCT	-- as Product/Items are global & csv files are channel specific, hence multiple rows (for each channel) may be there in dump tables
				CAST(l.SourceEntityId AS INT)
				,CAST(l.TargetEntityId AS INT) TargetEntityId
				,CAST(l.[Index] AS INT)	[Index]						--SortOrder
				,CASE
					WHEN ISNULL(l.InActive,'True') = 'True' THEN 1
					ELSE 0
				 END InActive										--ActivateOn,DeactivateOn
				,CASE
					WHEN pe.ID IS NULL THEN 'A'		-- does not exist in Insite
					WHEN pe.ID IS NOT NULL AND l.[Action] = 'A' THEN 'U'	-- already exists in Insite but Action = 'A'
					ELSE l.[Action]
				 END [Action]
				,CAST(l.LastModified AS DATETIMEOFFSET) LastModified	--ModifiedOn
				,'Link' SourceTable
			FROM dbo.PIMLink l
			-- for already existing Items for Products
			LEFT JOIN dbo.PRFTProductExtension pe 
				ON 
					(
						--l.[Action] = 'A'
						--AND 
						CAST(l.SourceEntityId AS INT) = pe.PIMProductEntityID 
						AND CAST(l.TargetEntityId AS INT) = ISNULL(PIMItemEntityID,0)
					)
			WHERE l.LinkTypeId = 'Product2Items'
		UNION ALL
		SELECT	DISTINCT	-- as Product/Items are global & csv files are channel specific, hence multiple rows (for each channel) may be there in dump tables
				CAST(NULL AS INT) SourceEntityId
				,CAST(p.EntityId AS INT)
				,CAST(NULL AS INT)				--SortOrder
				,CAST(NULL AS BIT)				--ActivateOn,DeactivateOn
				,p.[Action]
				,CAST(p.LastModified AS DATETIMEOFFSET) LastModified	--ModifiedOn
				,'Entity' SourceTable
			FROM dbo.PIMItem p
			-- for 'A' or 'D' - data will always exist with Action 'A' or 'D' in PIMLink 
			WHERE p.[Action] NOT IN ('A','D')
		ORDER BY LastModified
	OPEN Cur_Items
	FETCH NEXT FROM Cur_Items INTO 
		@SourceEntityID	
		,@EntityID
		,@Index			--SortOrder
		,@IsInActive		--ActivateOn,DeactivateOn
		,@Action
		,@LastModified	--ModifiedOn
		,@SourceTable
	INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Row by Row Import of Item data from PIM ----',GETUTCDATE()
	SELECT @PersonaID = Id FROM dbo.Persona WHERE Name = 'Default'
	SELECT @LanguageID = Id FROM dbo.Language WHERE LanguageCode = 'en-US'
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @ProductID = NULL
		SET @ParentProductID = NULL
		IF @Action = 'A'
		BEGIN
			SELECT
					@ItemName = 
						CASE 
							WHEN LEN(ISNULL(ItemName,'')) > 255 THEN LEFT(ItemName,255) 
							ELSE ItemName
						END						-- Name,ShortDescription
					,@ItemSKUStockNumber = 
						CASE 
							WHEN LEN(ISNULL(ItemSKUStockNumber,'')) > 100 THEN LEFT(ItemName,100) 
							ELSE ItemSKUStockNumber 
						END						-- Sku,UrlSegment
					-- 2018/12/21 - ItemSKUStockNumber is unique in PIM hence as per new mapping ItemSKUStockNumber => ERPNumber
					--,@ItemNumber = 
					--	CASE 
					--		WHEN LEN(ISNULL(ItemNumber,'')) > 50 THEN LEFT(ItemNumber,50) 
					--		ELSE ItemNumber  
					--	END						-- ERPNumber
					,@ItemNumber = 
						CASE 
							WHEN LEN(ISNULL(ItemSKUStockNumber,'')) > 50 THEN LEFT(ItemSKUStockNumber,50) 
							ELSE ItemSKUStockNumber  
						END						-- ERPNumber
					,@ShippingWeight = 
						CASE 
							WHEN LTRIM(RTRIM(ItemBoxPackageWeight)) = '' THEN 0
							ELSE CAST(ISNULL(ItemBoxPackageWeight,'0') AS DECIMAL(18,3)) 
						END
					,@ShippingLength = 
						CASE 
							WHEN LTRIM(RTRIM(ItemBoxPackageLength)) = '' THEN 0
							ELSE CAST(ISNULL(ItemBoxPackageLength,'0') AS DECIMAL(18,3)) 
						END
					,@ShippingWidth = 
						CASE 
							WHEN LTRIM(RTRIM(ItemBoxPackageWidth)) = '' THEN 0
							ELSE CAST(ISNULL(ItemBoxPackageWidth,'0') AS DECIMAL(18,3)) 
						END
					,@ShippingHeight = 
						CASE 
							WHEN LTRIM(RTRIM(ItemBoxPackageHeight)) = '' THEN 0
							ELSE CAST(ISNULL(ItemBoxPackageHeight,'0') AS DECIMAL(18,3)) 
						END
					,@QtyPerShippingPackage = 
						CASE 
							WHEN LTRIM(RTRIM(ItemNoOfItemsPerUnit)) = '' THEN 0
							ELSE ISNULL(ItemNoOfItemsPerUnit,'0') 
						END
					,@PackDescription = 
						CASE 
							WHEN LEN(ISNULL(ItemBoxComponentDescription,'')) > 255 THEN LEFT(ItemBoxComponentDescription,255) 
							ELSE ISNULL(ItemBoxComponentDescription,'') 
						END
					,@UPCCode = 
						CASE 
							WHEN LEN(ISNULL(ItemUPCGTINorEAN,'')) > 50 THEN LEFT(ItemUPCGTINorEAN,50) 
							ELSE ISNULL(ItemUPCGTINorEAN,'') 
						END
					,@ModelNumber = 
						CASE 
							WHEN LEN(ISNULL(ItemModel,'')) > 50 THEN LEFT(ItemModel,50) 
							ELSE ISNULL(ItemModel,'') 
						END
					,@vertaxBranch = ItemBranch 
					,@vertaxTaxAreaId = ItemTaxAreaID 
					,@vertaxLegalEntity = ItemLegalEntity 
					-- for Document
					,@FilePath1 = 
						CASE 
							WHEN LEN(ISNULL(ItemVideoFile1URL,'')) > 1024 THEN LEFT(ItemVideoFile1URL,1024) 
							ELSE ISNULL(ItemVideoFile1URL,'') 
						END
					,@FilePath2 = 
						CASE 
							WHEN LEN(ISNULL(ItemVideoFile2URL,'')) > 1024 THEN LEFT(ItemVideoFile2URL,1024) 
							ELSE ISNULL(ItemVideoFile2URL,'') 
						END
					,@FilePath3 = 
						CASE 
							WHEN LEN(ISNULL(ItemVideoFile3URL,'')) > 1024 THEN LEFT(ItemVideoFile3URL,1024) 
							ELSE ISNULL(ItemVideoFile3URL,'') 
						END
					,@FilePath4 = 
						CASE 
							WHEN LEN(ISNULL(ItemVideoFile4URL,'')) > 1024 THEN LEFT(ItemVideoFile4URL,1024) 
							ELSE ISNULL(ItemVideoFile4URL,'') 
						END
					-- for content
					,@ItemShortProductDescription = ItemShortProductDescription
					,@ItemLongProductDescription = ItemLongProductDescription 
					,@ItemBulletFeature1 = ItemBulletFeature1 
					,@ItemBulletFeature2 = ItemBulletFeature2
					,@ItemBulletFeature3 = ItemBulletFeature3
					,@ItemBulletFeature4 = ItemBulletFeature4
					,@ItemBulletFeature5 = ItemBulletFeature5
					,@ItemBulletFeature6 = ItemBulletFeature6
					,@ItemBulletFeature7 = ItemBulletFeature7
					,@ItemBulletFeature8 = ItemBulletFeature8
					,@ItemBulletFeature9 = ItemBulletFeature9
				FROM dbo.PIMItem
				WHERE EntityID = @EntityID AND [Action] = 'A'
			SET @ContentDescription = 
					ISNULL(@ItemShortProductDescription,'') 
					+ CASE 
						WHEN ISNULL(@ItemShortProductDescription,'') <> '' AND ISNULL(@ItemLongProductDescription,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemLongProductDescription,'')
			SET @ContentDescription = @ContentDescription 
					+ CASE 
						WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature1,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature1,'') 
					+ CASE 
						WHEN ISNULL(@ItemBulletFeature1,'') <> '' AND ISNULL(@ItemBulletFeature2,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature2,'')
			SET @ContentDescription = @ContentDescription 
					+ CASE 
						WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature3,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature3,'') 
					+ CASE 
						WHEN ISNULL(@ItemBulletFeature3,'') <> '' AND ISNULL(@ItemBulletFeature4,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature4,'')
			SET @ContentDescription = @ContentDescription 
					+ CASE 
						WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature5,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature5,'') 
					+ CASE 
						WHEN ISNULL(@ItemBulletFeature5,'') <> '' AND ISNULL(@ItemBulletFeature6,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature6,'')
			SET @ContentDescription = @ContentDescription 
					+ CASE 
						WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature7,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature7,'') 
					+ CASE 
						WHEN ISNULL(@ItemBulletFeature7,'') <> '' AND ISNULL(@ItemBulletFeature8,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature8,'')
			SET @ContentDescription = @ContentDescription 
					+ CASE 
						WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature9,'') <> '' 
							THEN CHAR(10) + CHAR(13) 
						ELSE '' 
					  END
					+ ISNULL(@ItemBulletFeature9,'') 
			SET @ProductType = 
				(
					SELECT DISTINCT pe.PIMProductType
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe 
							ON (pe.PIMProductEntityID = @SourceEntityID AND p.ID = pe.ProductID) 
				)
			IF ISNULL(@ProductType,'') = ''
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Cannot Add Item as its Product does not exist in Insite', -- Message text.  
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
					-- Log Error for Add Item
					INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Add Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Item Name = '+ISNULL(@ItemName,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END
			ELSE IF @ProductType = 'simple'
						AND EXISTS		-- only base product data row exists for 'simple' product, so update this with item data
							(
								SELECT 1
									FROM dbo.Product p
									INNER JOIN dbo.PRFTProductExtension pe ON p.Id = pe.ProductID
									WHERE pe.PIMProductEntityID = @SourceEntityID AND pe.PIMItemEntityID IS NULL
										AND pe.PIMProductType = 'simple'
							)
			BEGIN
				BEGIN TRY
					SET @ProductID = NULL
					SET @ContentManagerID = NULL
					SELECT @ProductID = pe.ProductID
							,@ContentManagerID = p.ContentManagerID 
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe ON p.Id = pe.ProductID
						WHERE pe.PIMProductEntityID = @SourceEntityID AND pe.PIMItemEntityID IS NULL
							AND pe.PIMProductType = 'simple'
					UPDATE dbo.Product
						SET
							Name = @ItemName
							,ShortDescription = @ItemName
							,Sku = @ItemSKUStockNumber
							,ActivateOn = @LastModified
							,DeactivateOn = 
								CASE
									WHEN @IsInActive = 1
										THEN todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET)))
									ELSE NULL
								END 
							,SortOrder = @Index
							,ShippingWeight = @ShippingWeight
							,ShippingLength = @ShippingLength
							,ShippingWidth = @ShippingWidth
							,ShippingHeight = @ShippingHeight
							,QtyPerShippingPackage = @QtyPerShippingPackage
							,PackDescription = @PackDescription
							,UrlSegment = @ItemSKUStockNumber
							,ERPNumber = @ItemNumber
							,UPCCode = @UPCCode
							,ModelNumber = @ModelNumber
							,ModifiedOn = @LastModified
						WHERE Id = @ProductID
					UPDATE dbo.PRFTProductExtension
						SET
							PIMItemEntityID = @EntityId
						WHERE ProductID = @ProductID
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
					-- Log Error for Update Product
					INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Add Item when base product exists for Simple Product - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Source Enttity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Item Name = '+ISNULL(@ItemName,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @ProductType = 'simple' and only base product data row exists, so update this with item data
			ELSE
			BEGIN	-- insert new row for with item data
				SET @ParentProductID = NULL
				SET @ParentProductName = NULL
				SET @ProductCode = NULL
				SET @VendorID = NULL
				SET @CountryofOrigin = NULL
				SET @StyleParentId = NULL
				IF @ProductType <> 'simple'		-- for style/config/bundle => base prod exists
				BEGIN
					SELECT 
							@ParentProductID = p.Id
							,@ParentProductName = p.Name
							,@ProductCode = p.ProductCode
							,@VendorID = p.VendorID
							,@CountryofOrigin = pe.ProductCountryofOrigin_Value
							,@StyleParentId = 
								CASE
									WHEN @ProductType = 'style' THEN p.Id
									ELSE NULL
								END
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe 
							ON (pe.PIMProductEntityID = @SourceEntityID AND pe.PIMItemEntityID IS NULL AND p.Id = pe.ProductID)
				END
				ELSE		-- for simple and base prod not exists => multiple rows for same PIMProductEntityID may exist
				BEGIN
					SELECT 
							@ProductCode = MAX(ISNULL(p.ProductCode,''))
							,@VendorID = MAX(p.VendorID)
							,@CountryofOrigin = MAX(ISNULL(pe.ProductCountryofOrigin_Value,''))
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe 
							ON (pe.PIMProductEntityID = @SourceEntityID AND p.Id = pe.ProductID)
				END
				IF 
					(
						@SourceEntityID IS NULL 
						OR 
						(
							@SourceEntityID IS NOT NULL 
							AND @ParentProductID IS NULL
							AND @ProductType <> 'simple'
						)
					)
				BEGIN
					BEGIN TRY
						RAISERROR ('Custom Error - Cannot Add Item as its Parent Product does not exist in Insite', -- Message text.  
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
						-- Log Error for New Item
						INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error when Adding Item  - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
										+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
										+'; Item Name = '+ISNULL(@ItemName,@ItemSKUStockNumber)
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
				END	-- @SourceEntityID IS NULL 
				ELSE
				BEGIN	--@SourceEntityID IS NOT NULL 
					SELECT @ContentManagerID = NEWID()
					SELECT @ProductID = NEWID()
					SELECT @ProductExtensionID = NEWID()
					BEGIN TRY
						INSERT INTO dbo.ContentManager
							(
								Id
								,Name
								,CreatedOn
								--,CreatedBy
								,ModifiedOn
								--,ModifiedBy
							)
							SELECT 
								@ContentManagerID
								,'Product'
								,@LastModified
								,@LastModified
						INSERT INTO dbo.Product
							(
								ID
								,[Name]
								,ShortDescription
								,ProductCode
								,SKU
								,ActivateOn
								,DeactivateOn
								,SortOrder
								,UrlSegment
								,ContentManagerID
								,ERPNumber
								,VendorID
								,ShippingWeight
								,ShippingLength
								,ShippingWidth
								,ShippingHeight
								,QtyPerShippingPackage
								,PackDescription
								,UPCCode
								,ModelNumber
								,StyleParentId
								,IsConfigured
								,IsFixedConfiguration
								,CreatedOn
								,ModifiedOn
							)
							SELECT
									@ProductID ProductID
									,ISNULL(@ItemName,@ItemSKUStockNumber)
									,ISNULL(@ItemName,@ItemSKUStockNumber)
									,@ProductCode
									,@ItemSKUStockNumber
									,@LastModified
									,CASE
										WHEN @IsInActive = 1
											THEN todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET)))
										ELSE NULL
									 END 
									,@Index
									,@ItemSKUStockNumber
									,@ContentManagerID
									,ISNULL(@ItemNumber,@ItemSKUStockNumber)
									,@VendorID
									,@ShippingWeight
									,@ShippingLength
									,@ShippingWidth
									,@ShippingHeight
									,@QtyPerShippingPackage
									,@PackDescription
									,@UPCCode
									,@ModelNumber
									,@StyleParentId
									,CASE 
										WHEN @ProductType in ('simple','style') THEN 0
										WHEN @ProductType in ('configurable','bundle') THEN 1
										ELSE  0
									 END
									,CASE 
										WHEN @ProductType in ('simple','style','configurable') THEN 0
										WHEN @ProductType = 'bundle' THEN 1
										ELSE  0
									 END
									,@LastModified
									,@LastModified
						INSERT INTO dbo.PRFTProductExtension
							(
								ID
								,ProductID
								,PIMProductEntityID
								,PIMItemEntityID
								,PIMProductType
								,ProductCountryofOrigin_Value
							)
							SELECT
									@ProductExtensionID
									,@ProductID
									,@SourceEntityID
									,@EntityID
									,@ProductType
									,@CountryofOrigin
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
						-- Log Error for New Item
						INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error when Adding Item for Parent Product - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
										+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
										+'; Item Name = '+ISNULL(@ItemName,@ItemSKUStockNumber)
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
				END	-- @SourceEntityID IS NOT NULL 
				IF @ProductID IS NOT NULL	-- insert Content/Custom Property/Document/Kit related data
				BEGIN
					BEGIN TRY
						IF @ContentDescription <> ''
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
									,@ContentDescription
									,@LastModified
									,@LastModified
									,@LastModified
									,@LastModified
									,1
									,'Desktop'
									,@PersonaID
									,@LanguageID
									,@LastModified
						END	-- @ContentDescription <> ''
						-- for custom property
						INSERT INTO dbo.CustomProperty
							(
								Id
								,ParentId
								,Name
								,Value
								,CreatedOn
								,ModifiedOn
								,ParentTable
							)
							SELECT
								NEWID()
								,@ProductID
								,'vertaxBranch'
								,ISNULL(@vertaxBranch,'')
								,@LastModified
								,@LastModified
								,'Product'
						INSERT INTO dbo.CustomProperty
							(
								Id
								,ParentId
								,Name
								,Value
								,CreatedOn
								,ModifiedOn
								,ParentTable
							)
							SELECT
								NEWID()
								,@ProductID
								,'vertaxTaxAreaId'
								,ISNULL(@vertaxTaxAreaId,'')
								,@LastModified
								,@LastModified
								,'Product'
						INSERT INTO dbo.CustomProperty
							(
								Id
								,ParentId
								,Name
								,Value
								,CreatedOn
								,ModifiedOn
								,ParentTable
							)
							SELECT
								NEWID()
								,@ProductID
								,'vertaxLegalEntity'
								,ISNULL(@vertaxLegalEntity,'')
								,@LastModified
								,@LastModified
								,'Product'
						-- for document
						IF @FilePath1 <> ''
						BEGIN
							INSERT INTO dbo.Document
								(
									Id
									,[Name]
									,[Description]
									,CreatedOn
									,FilePath
									,DocumentType
									,LanguageId
									,ModifiedOn
									,ParentId
									,ParentTable
								)
								SELECT
										NEWID()
										,CAST(@EntityID AS NVARCHAR(100))
										,'PIMItem.ItemVideoFile1URL'
										,@LastModified
										,@FilePath1
										,'Video'
										,@LanguageID
										,@LastModified
										,@ProductID
										,'Product'
						END	-- @FilePath1 <> ''
						IF @FilePath2 <> ''
						BEGIN
							INSERT INTO dbo.Document
								(
									Id
									,[Name]
									,[Description]
									,CreatedOn
									,FilePath
									,DocumentType
									,LanguageId
									,ModifiedOn
									,ParentId
									,ParentTable
								)
								SELECT
										NEWID()
										,'PIMItem.ItemVideoFile2URL'
										,CAST(@EntityID AS NVARCHAR(100))
										,@LastModified
										,@FilePath2
										,'Video'
										,@LanguageID
										,@LastModified
										,@ProductID
										,'Product'
						END	-- @FilePath2 <> ''
						IF @FilePath3 <> ''
						BEGIN
							INSERT INTO dbo.Document
								(
									Id
									,[Name]
									,[Description]
									,CreatedOn
									,FilePath
									,DocumentType
									,LanguageId
									,ModifiedOn
									,ParentId
									,ParentTable
								)
								SELECT
										NEWID()
										,'PIMItem.ItemVideoFile3URL'
										,CAST(@EntityID AS NVARCHAR(100))
										,@LastModified
										,@FilePath3
										,'Video'
										,@LanguageID
										,@LastModified
										,@ProductID
										,'Product'
						END	-- @FilePath3 <> ''
						IF @FilePath4 <> ''
						BEGIN
							INSERT INTO dbo.Document
								(
									Id
									,[Name]
									,[Description]
									,CreatedOn
									,FilePath
									,DocumentType
									,LanguageId
									,ModifiedOn
									,ParentId
									,ParentTable
								)
								SELECT
										NEWID()
										,'PIMItem.ItemVideoFile4URL'
										,CAST(@EntityID AS NVARCHAR(100))
										,@LastModified
										,@FilePath4
										,'Video'
										,@LanguageID
										,@LastModified
										,@ProductID
										,'Product'
						END	-- @FilePath4 <> ''
						IF @ProductType IN ('configurable','bundle')
						BEGIN
							SET @SectionID = NULL
							SELECT @SectionID = Id
								FROM dbo.ProductKitSection
								WHERE ProductId = @ParentProductID
							IF @SectionID IS NULL
							BEGIN
								SET @SectionID = NEWID()
								INSERT INTO dbo.ProductKitSection
									(
										Id
										,ProductId
										,SectionName
										,CreatedOn
										,ModifiedOn
									)
									SELECT
										@SectionID
										,@ParentProductID
										,@ParentProductName
										,@LastModified
										,@LastModified
							END	-- @SectionID IS NULL
							SET @IsSelected = 0
							IF @Index <= 
								ISNULL
								  (
									(
										SELECT MIN(p.SortOrder)
											FROM dbo.Product p
											INNER JOIN dbo.PRFTProductExtension pe 
												ON (pe.PIMItemEntityID IS NOT NULL AND pe.PIMProductEntityID = @SourceEntityID)
									)
									,0
								  )
								SET @IsSelected = 1
							ELSE
								SET @IsSelected = 0
							INSERT INTO dbo.ProductKitSectionOption
								(
									Id
									,ProductKitSectionId
									,ProductId
									,Selected
									,SortOrder
									,CreatedOn
									,ModifiedOn
								)
								SELECT
									NEWID()
									,@SectionID
									,@ProductID
									,@IsSelected
									,@Index
									,@LastModified
									,@LastModified
						END	-- @ProductType IN ('configurable','bundle')
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
						-- Log Error for Content/Custom Property/Document/Kit related data
						INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error when Adding Content/Custom Property/Document/Kit related data for Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
										+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
										+'; Item Name = '+ISNULL(@ItemName,@ItemSKUStockNumber)
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
				END	-- insert Content/Document/Kit related data 
			END	-- insert new row for with item data
		END	-- @Action = 'A'
		ELSE IF @Action = 'U'
		BEGIN
			SET @ProductID = NULL
			SET @ContentManagerID = NULL
			TRUNCATE TABLE #TempItems	-- flush data
			-- in case of 'Link', base product to which the item is associated is available
			IF @SourceTable = 'Link'
			BEGIN
				INSERT INTO #TempItems (ProductID,ContentManagerID,ProductExtensionID)
					SELECT p.Id,p.ContentManagerID,pe.Id
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe ON 
							(
								pe.PIMItemEntityID IS NOT NULL 
								AND pe.PIMProductEntityID = @SourceEntityID
								AND pe.PIMItemEntityID = @EntityID
								AND p.Id = pe.ProductID
							)
			END	-- @SourceTable = 'Link'
			-- in case of 'Entity', base product to which the item is associated is not available and item can be associated to multiple products
			ELSE
			BEGIN	-- @SourceTable = 'Entity'
				INSERT INTO #TempItems (ProductID,ContentManagerID,ProductExtensionID)
					SELECT p.Id,p.ContentManagerID,pe.Id
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe ON 
							(
								pe.PIMItemEntityID IS NOT NULL 
								AND pe.PIMItemEntityID = @EntityID
								AND p.Id = pe.ProductID
							)
			END	-- @SourceTable = 'Entity'
			IF NOT EXISTS (SELECT 1 FROM #TempItems)
			BEGIN	-- product does not exist in Insite
				BEGIN TRY
					RAISERROR ('Custom Error - Cannot Update Item as it does not exist in Insite', -- Message text.  
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
					-- Log Error for Update Item
					INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Update Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Item Name = '+ISNULL(@ItemName,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- product does not exist in Insite
			ELSE
			BEGIN	-- product exists in Insite
				DECLARE curTempItems CURSOR LOCAL FAST_FORWARD FOR
					SELECT ProductID,ContentManagerID,ProductExtensionID
						FROM #TempParents
				OPEN curTempItems
				FETCH NEXT FROM curTempItems INTO @ProductID,@ContentManagerID,@ProductExtensionID
				WHILE @@FETCH_STATUS = 0 
				BEGIN
					BEGIN TRY
						IF @SourceTable = 'Link'
						BEGIN
							UPDATE dbo.Product SET SortOrder = @Index
								WHERE Id = @ProductID
						END	-- @SourceTable = 'Link'
						ELSE
						BEGIN	 -- @SourceTable = 'Entity'
							SELECT
									@ItemName = 
										CASE 
											WHEN LEN(ISNULL(ItemName,'')) > 255 THEN LEFT(ItemName,255) 
											ELSE ItemName
										END						-- Name,ShortDescription
									,@ItemSKUStockNumber = 
										CASE 
											WHEN LEN(ISNULL(ItemSKUStockNumber,'')) > 100 THEN LEFT(ItemName,100) 
											ELSE ItemSKUStockNumber 
										END						-- Sku,UrlSegment
									-- 2018/12/21 - ItemSKUStockNumber is unique in PIM hence as per new mapping ItemSKUStockNumber => ERPNumber
									--,@ItemNumber = 
									--	CASE 
									--		WHEN LEN(ISNULL(ItemNumber,'')) > 50 THEN LEFT(ItemNumber,50) 
									--		ELSE ItemNumber  
									--	END						-- ERPNumber
									,@ItemNumber = 
										CASE 
											WHEN LEN(ISNULL(ItemSKUStockNumber,'')) > 50 THEN LEFT(ItemSKUStockNumber,50) 
											ELSE ItemSKUStockNumber  
										END						-- ERPNumber
									,@ShippingWeight = 
										CASE 
											WHEN LTRIM(RTRIM(ItemBoxPackageWeight)) = '' THEN 0
											ELSE CAST(ISNULL(ItemBoxPackageWeight,'0') AS DECIMAL(18,3)) 
										END
									,@ShippingLength = 
										CASE 
											WHEN LTRIM(RTRIM(ItemBoxPackageLength)) = '' THEN 0
											ELSE CAST(ISNULL(ItemBoxPackageLength,'0') AS DECIMAL(18,3)) 
										END
									,@ShippingWidth = 
										CASE 
											WHEN LTRIM(RTRIM(ItemBoxPackageWidth)) = '' THEN 0
											ELSE CAST(ISNULL(ItemBoxPackageWidth,'0') AS DECIMAL(18,3)) 
										END
									,@ShippingHeight = 
										CASE 
											WHEN LTRIM(RTRIM(ItemBoxPackageHeight)) = '' THEN 0
											ELSE CAST(ISNULL(ItemBoxPackageHeight,'0') AS DECIMAL(18,3)) 
										END
									,@QtyPerShippingPackage = 
										CASE 
											WHEN LTRIM(RTRIM(ItemNoOfItemsPerUnit)) = '' THEN 0
											ELSE ISNULL(ItemNoOfItemsPerUnit,'0') 
										END
									,@PackDescription = 
										CASE 
											WHEN LEN(ISNULL(ItemBoxComponentDescription,'')) > 255 THEN LEFT(ItemBoxComponentDescription,255) 
											ELSE ISNULL(ItemBoxComponentDescription,'') 
										END
									,@UPCCode = 
										CASE 
											WHEN LEN(ISNULL(ItemUPCGTINorEAN,'')) > 50 THEN LEFT(ItemUPCGTINorEAN,50) 
											ELSE ISNULL(ItemUPCGTINorEAN,'') 
										END
									,@ModelNumber = 
										CASE 
											WHEN LEN(ISNULL(ItemModel,'')) > 50 THEN LEFT(ItemModel,50) 
											ELSE ISNULL(ItemModel,'') 
										END
									,@vertaxBranch = ItemBranch 
									,@vertaxTaxAreaId = ItemTaxAreaID 
									,@vertaxLegalEntity = ItemLegalEntity 
									-- for Document
									,@FilePath1 = 
										CASE 
											WHEN LEN(ISNULL(ItemVideoFile1URL,'')) > 1024 THEN LEFT(ItemVideoFile1URL,1024) 
											ELSE ISNULL(ItemVideoFile1URL,'') 
										END
									,@FilePath2 = 
										CASE 
											WHEN LEN(ISNULL(ItemVideoFile2URL,'')) > 1024 THEN LEFT(ItemVideoFile2URL,1024) 
											ELSE ISNULL(ItemVideoFile2URL,'') 
										END
									,@FilePath3 = 
										CASE 
											WHEN LEN(ISNULL(ItemVideoFile3URL,'')) > 1024 THEN LEFT(ItemVideoFile3URL,1024) 
											ELSE ISNULL(ItemVideoFile3URL,'') 
										END
									,@FilePath4 = 
										CASE 
											WHEN LEN(ISNULL(ItemVideoFile4URL,'')) > 1024 THEN LEFT(ItemVideoFile4URL,1024) 
											ELSE ISNULL(ItemVideoFile4URL,'') 
										END
									-- for content
									,@ItemShortProductDescription = ItemShortProductDescription
									,@ItemLongProductDescription = ItemLongProductDescription 
									,@ItemBulletFeature1 = ItemBulletFeature1 
									,@ItemBulletFeature2 = ItemBulletFeature2
									,@ItemBulletFeature3 = ItemBulletFeature3
									,@ItemBulletFeature4 = ItemBulletFeature4
									,@ItemBulletFeature5 = ItemBulletFeature5
									,@ItemBulletFeature6 = ItemBulletFeature6
									,@ItemBulletFeature7 = ItemBulletFeature7
									,@ItemBulletFeature8 = ItemBulletFeature8
									,@ItemBulletFeature9 = ItemBulletFeature9
									,@FieldsUpdated = FieldsUpdated
								FROM dbo.PIMItem
								WHERE EntityID = @EntityID AND [Action] = 'U'
							SET @ContentDescription = 
									ISNULL(@ItemShortProductDescription,'') 
									+ CASE 
										WHEN ISNULL(@ItemShortProductDescription,'') <> '' AND ISNULL(@ItemLongProductDescription,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemLongProductDescription,'')
							SET @ContentDescription = @ContentDescription 
									+ CASE 
										WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature1,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature1,'') 
									+ CASE 
										WHEN ISNULL(@ItemBulletFeature1,'') <> '' AND ISNULL(@ItemBulletFeature2,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature2,'')
							SET @ContentDescription = @ContentDescription 
									+ CASE 
										WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature3,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature3,'') 
									+ CASE 
										WHEN ISNULL(@ItemBulletFeature3,'') <> '' AND ISNULL(@ItemBulletFeature4,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature4,'')
							SET @ContentDescription = @ContentDescription 
									+ CASE 
										WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature5,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature5,'') 
									+ CASE 
										WHEN ISNULL(@ItemBulletFeature5,'') <> '' AND ISNULL(@ItemBulletFeature6,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature6,'')
							SET @ContentDescription = @ContentDescription 
									+ CASE 
										WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature7,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature7,'') 
									+ CASE 
										WHEN ISNULL(@ItemBulletFeature7,'') <> '' AND ISNULL(@ItemBulletFeature8,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature8,'')
							SET @ContentDescription = @ContentDescription 
									+ CASE 
										WHEN ISNULL(@ContentDescription,'') <> '' AND ISNULL(@ItemBulletFeature9,'') <> '' 
											THEN CHAR(10) + CHAR(13) 
										ELSE '' 
									  END
									+ ISNULL(@ItemBulletFeature9,'') 
							UPDATE dbo.Product
								SET
									Name = @ItemName
									,ShortDescription = @ItemName
									,Sku = @ItemSKUStockNumber
									,ActivateOn = @LastModified
									,DeactivateOn = 
										CASE
											WHEN @IsInActive = 1
												THEN todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET)))
											ELSE NULL
										END 
									,SortOrder = @Index
									,ShippingWeight = @ShippingWeight
									,ShippingLength = @ShippingLength
									,ShippingWidth = @ShippingWidth
									,ShippingHeight = @ShippingHeight
									,QtyPerShippingPackage = @QtyPerShippingPackage
									,PackDescription = @PackDescription
									,UrlSegment = @ItemSKUStockNumber
									,ERPNumber = @ItemNumber
									,UPCCode = @UPCCode
									,ModelNumber = @ModelNumber
									,ModifiedOn = @LastModified
								WHERE Id = @ProductID
							-- update Content/Custom Property/Document related data
							IF	( 
									@FieldsUpdated LIKE '%ItemShortProductDescription%'
									OR @FieldsUpdated LIKE '%ItemLongProductDescription%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature1%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature2%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature3%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature4%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature5%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature6%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature7%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature8%'
									OR @FieldsUpdated LIKE '%ItemBulletFeature9%'
								)
							BEGIN	-- update content
								UPDATE dbo.Content 
									SET
										Html = @ContentDescription
										,SubmittedForApprovalOn = @LastModified
										,ApprovedOn = @LastModified
										,PublishToProductionOn = @LastModified
										,Revision = Revision + 1
										,ModifiedOn = @LastModified
									WHERE ContentManagerId = @ContentManagerId
										AND DeviceType = 'Desktop'
										AND PersonaId = @PersonaID
										AND LanguageId = @LanguageID
							END -- update content
							-- for custom property
							IF @FieldsUpdated LIKE '%ItemBranch%'
							BEGIN	-- vertaxBranch custom property
								UPDATE dbo.CustomProperty
									SET
										[Value] = ISNULL(@vertaxBranch,'')
										,ModifiedOn = @LastModified
									WHERE ParentId = @ProductID
										AND [Name] = 'vertaxBranch'
										AND ParentTable = 'Product'
							END	-- vertaxBranch custom property
							IF @FieldsUpdated LIKE '%ItemTaxAreaID%'
							BEGIN	-- vertaxTaxAreaId custom property
								UPDATE dbo.CustomProperty
									SET
										[Value] = ISNULL(@vertaxTaxAreaId,'')
										,ModifiedOn = @LastModified
									WHERE ParentId = @ProductID
										AND [Name] = 'vertaxTaxAreaId'
										AND ParentTable = 'Product'
							END	-- vertaxTaxAreaId custom property
							IF @FieldsUpdated LIKE '%ItemLegalEntity%'
							BEGIN	-- vertaxLegalEntity custom property
								UPDATE dbo.CustomProperty
									SET
										[Value] = ISNULL(@vertaxLegalEntity,'')
										,ModifiedOn = @LastModified
									WHERE ParentId = @ProductID
										AND [Name] = 'vertaxLegalEntity'
										AND ParentTable = 'Product'
							END	-- vertaxLegalEntity custom property
							-- for document
							IF @FieldsUpdated LIKE '%ItemVideoFile1URL%'
							BEGIN	-- @FilePath1
								UPDATE dbo.Document
									SET 
										FilePath = @FilePath1
										,ModifiedOn = @LastModified
									WHERE [Name] = CAST(@EntityID AS NVARCHAR(100))
										AND [Description] = 'PIMItem.ItemVideoFile1URL'
										AND DocumentType = 'Video'
										AND LanguageId = @LanguageID
										AND ParentId = @ProductID
										AND ParentTable = 'Product'
							END	-- @FilePath1
							IF @FieldsUpdated LIKE '%ItemVideoFile2URL%'
							BEGIN	-- @FilePath2
								UPDATE dbo.Document
									SET 
										FilePath = @FilePath2
										,ModifiedOn = @LastModified
									WHERE [Name] = CAST(@EntityID AS NVARCHAR(100))
										AND [Description] = 'PIMItem.ItemVideoFile2URL'
										AND DocumentType = 'Video'
										AND LanguageId = @LanguageID
										AND ParentId = @ProductID
										AND ParentTable = 'Product'
							END	-- @FilePath2
							IF @FieldsUpdated LIKE '%ItemVideoFile3URL%'
							BEGIN	-- @FilePath3
								UPDATE dbo.Document
									SET 
										FilePath = @FilePath3
										,ModifiedOn = @LastModified
									WHERE [Name] = CAST(@EntityID AS NVARCHAR(100))
										AND [Description] = 'PIMItem.ItemVideoFile3URL'
										AND DocumentType = 'Video'
										AND LanguageId = @LanguageID
										AND ParentId = @ProductID
										AND ParentTable = 'Product'
							END	-- @FilePath3
							IF @FieldsUpdated LIKE '%ItemVideoFile4URL%'
							BEGIN	-- @FilePath4
								UPDATE dbo.Document
									SET 
										FilePath = @FilePath4
										,ModifiedOn = @LastModified
									WHERE [Name] = CAST(@EntityID AS NVARCHAR(100))
										AND [Description] = 'PIMItem.ItemVideoFile4URL'
										AND DocumentType = 'Video'
										AND LanguageId = @LanguageID
										AND ParentId = @ProductID
										AND ParentTable = 'Product'
							END	-- @FilePath4
						END	 -- @SourceTable = 'Entity'
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
						-- Log Error for Update Item
						INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
							SELECT	'Warn'
									,'Error for Update Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
										+'; Item Name = '+ISNULL(@ItemName,'**NULL**')
										+ '; Error Message = '+@ErrorMessage
									,GETUTCDATE()
					END CATCH
					FETCH NEXT FROM curTempItems INTO @ProductID,@ContentManagerID,@ProductExtensionID
				END
				CLOSE curTempItems
				DEALLOCATE curTempItems
			END	-- product exists in Insite
		END	-- @Action = 'U'
		IF @Action = 'D'
		BEGIN
			SET @ProductID = NULL
			SET @ContentManagerID = NULL
			SET @ItemName = NULL
			SELECT @ProductID = pe.ProductID
					,@ContentManagerID = p.ContentManagerID 
					,@ItemName = p.ShortDescription
				FROM dbo.Product p
				INNER JOIN dbo.PRFTProductExtension pe ON p.Id = pe.ProductID
				WHERE pe.PIMItemEntityID IS NOT NULL 
					AND pe.PIMItemEntityID = @EntityID
			IF @ProductID IS NULL
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Cannot Delete Item as it does not exist in Insite', -- Message text.  
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
					-- Log Error for Delete Item
					INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Delete Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Item Name = '+ISNULL(@ItemName,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @ProductID IS NULL
			ELSE
			BEGIN	-- @ProductID IS NOT NULL
				BEGIN TRY
					-- remove attribute value association for the product
					DELETE FROM dbo.ProductAttributeValue WHERE ProductId = @ProductID
					-- remove trait value association for the product
					DELETE FROM dbo.StyleTraitValueProduct WHERE ProductId = @ProductID
					-- remove from kit, associated product
					DELETE FROM dbo.ProductKitSectionOption WHERE ProductId = @ProductID
					-- remove images for the product
					DELETE FROM dbo.ProductImage WHERE ProductId = @ProductID
					-- remove category association for the product
					DELETE FROM dbo.CategoryProduct WHERE ProductId = @ProductID
					-- remove from document for the product
					DELETE FROM dbo.Document WHERE ParentId = @ProductID AND ParentTable = 'Product'
					-- remove from custom property for the product
					DELETE FROM dbo.CustomProperty WHERE ParentTable = 'Product' AND ParentId = @ProductID
					-- remove from content for the product
					DELETE FROM dbo.Content WHERE ContentManagerId = @ContentManagerId
					-- remove from extension for the product
					DELETE FROM dbo.CategoryProduct WHERE ProductId = @ProductID
					-- remove style parent + content manager association & deactivate the products
					UPDATE p
						SET p.StyleParentId = NULL
							,p.ContentManagerId = ''
							,p.DeactivateOn = todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET)))
							,p.ModifiedOn = @LastModified
						FROM dbo.Product p 
						WHERE p.Id = @ProductID
					-- remove from content manager for parent & child products
					DELETE FROM dbo.ContentManager WHERE Id = @ContentManagerId 
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
					-- Log Error for Update Item
					INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Delete Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Item Name = '+ISNULL(@ItemName,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @ProductID IS NOT NULL
		END	-- @Action = 'D'
		FETCH NEXT FROM Cur_Items INTO 
			@SourceEntityID	
			,@EntityID
			,@Index			--SortOrder
			,@IsInActive		--ActivateOn,DeactivateOn
			,@Action
			,@LastModified	--ModifiedOn
			,@SourceTable
	END
	CLOSE Cur_Items
	DEALLOCATE Cur_Items
	INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Row by Row Import of Item data from PIM ----',GETUTCDATE()
	INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Item Import from PIM Item ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportItemLog				
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
					,'Item Imort Module'
				FROM #ImportItemLog
	END
	IF EXISTS(SELECT 1 FROM #ImportItemLog WHERE LogTypeName = 'Error')
	BEGIN
		DROP TABLE #ImportItemLog
		RETURN -1	
		
	END
	ELSE
	BEGIN
		DROP TABLE #ImportItemLog
		RETURN 0	
	END
END
GO

ALTER PROCEDURE [dbo].[PRFTImportResourceDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS

BEGIN

	--SET XACT_ABORT ON
	--SET NOCOUNT ON
	-- table to hold error/log info. while processing data
	CREATE TABLE #ImportResourceLog	--PRFTImportCategoryLog
		(
			LogKey				INT IDENTITY(1,1)
			,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
			,LogMessage			NVARCHAR(MAX)
			,LogDateTime		DATETIMEOFFSET
		)
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Resource Import from PIM ----',GETUTCDATE()
	--DECLARE @ProductEntityID INT
	DECLARE @TargetEntityID INT
	DECLARE @SourceEntityID INT
	DECLARE @ErrorNumber INT
	DECLARE @ErrorLine INT
	DECLARE @SortOrder INT
	DECLARE @FirstImageOrder INT
	DECLARE @CategoryID UNIQUEIDENTIFIER
	DECLARE @ProductID UNIQUEIDENTIFIER
	DECLARE @ProductImageID UNIQUEIDENTIFIER
	DECLARE @ErrorProcedure NVARCHAR(200)
	DECLARE @SmallImagePath NVARCHAR(1024)
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @Action NVARCHAR(MAX)
	DECLARE @LinkTypeId NVARCHAR(MAX)
	DECLARE @ResourceName NVARCHAR(MAX)
	DECLARE @ResourceFilename NVARCHAR(MAX)
	DECLARE @ResourceURL NVARCHAR(MAX)
	DECLARE @ResourceMimeType NVARCHAR(MAX)
	DECLARE @ResourceType NVARCHAR(MAX)
	DECLARE @ResourcePath NVARCHAR(MAX)
	DECLARE @LastModified DATETIMEOFFSET
	DECLARE @IsInactive BIT
	-- get Resourcepath
	SELECT @ResourcePath = Value 
		FROM SystemSetting WHERE Name='PIM_ImagePathPrefix'
	SET @ResourcePath = ISNULL(@ResourcePath,'')
	-- if new resource already exists in insite then update the Action from 'A' to 'U'
	UPDATE re
		SET re.[Action] = 'U'
		FROM dbo.PIMResource re
		INNER JOIN dbo.PRFTResourceDataFromPIM ir ON re.EntityId = ir.EntityId
		WHERE re.[Action] = 'A'
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Resource Import from PIM to Intermediate Table',GETUTCDATE()
	INSERT INTO dbo.PRFTResourceDataFromPIM
		(
			EntityId
			,ResourceName
			,ResourceDescription
			,ResourceMimeType
			,ResourceFilename
			,ResourceFileId
			,ResourceType
			,ResourceImageType
			,ResourceURL
			,DateCreated
			,LastModified
			,[Action]
			,FieldsUpdated
		)
		SELECT
				CAST(EntityId AS INT)
				,ResourceName
				,ResourceDescription
				,ResourceMimeType
				,ResourceFilename
				,ResourceFileId
				,ResourceType
				,ResourceImageType
				,ResourceURL
				,DateCreated
				,LastModified
				,[Action]
				,FieldsUpdated
			FROM dbo.PIMResource
			WHERE [Action] = 'A'
	UPDATE ir
		SET
			ir.ResourceName = re.ResourceName
			,ir.ResourceDescription = re.ResourceDescription
			,ir.ResourceMimeType = re.ResourceMimeType
			,ir.ResourceFilename = re.ResourceFilename
			,ir.ResourceFileId = re.ResourceFileId
			,ir.ResourceType = re.ResourceType
			,ir.ResourceImageType = re.ResourceImageType
			,ir.ResourceURL = re.ResourceURL
			,ir.DateCreated = re.DateCreated
			,ir.LastModified = re.LastModified
			,ir.[Action] = re.[Action]
			,ir.FieldsUpdated = re.FieldsUpdated
		FROM dbo.PRFTResourceDataFromPIM ir
		INNER JOIN dbo.PIMResource re 
			ON (re.[Action] IN ('U','D') AND ir.EntityID = CAST(re.EntityID AS INT))
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Resource Import from PIM to Intermediate Table',GETUTCDATE()
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Category - Resource Import from PIM',GETUTCDATE()
	DECLARE Cur_CategoryResourceLink CURSOR LOCAL FAST_FORWARD FOR
		SELECT
				l.LinkTypeId
				,CAST(l.TargetEntityId AS INT)
				,r.ResourceFilename
				,r.ResourceMimeType
				,r.ResourceName
				--- 2018/12/10 - temp arrangement commented
				,r.ResourceType
				--,CASE
				--	WHEN (ISNULL(r.ResourceType,'') = '' AND r.ResourceMimeType like '%image%')
				--		THEN 'Images'
				--	ELSE r.ResourceType
				-- END
				,r.ResourceURL
				,CAST(l.SourceEntityId AS INT)
				,c.Id CategoryId
				,CAST(l.[Index] AS INT)
				,CASE
					WHEN ISNULL(l.InActive,'True') = 'True' THEN 1
					ELSE 0
					END InActive
				,l.[Action]
				,CAST(l.LastModified AS DATETIMEOFFSET)
			FROM dbo.PIMLink l
			LEFT JOIN dbo.PRFTResourceDataFromPIM r ON l.TargetEntityId = r.EntityId
			LEFT JOIN
				(
					SELECT 
							cat.Id,catext.PIMEntityID
						FROM dbo.Category cat
						INNER JOIN dbo.PRFTCategoryExtension catext
							ON cat.Id = catext.CategoryID
				) c ON l.SourceEntityID = c.PIMEntityID
			WHERE l.LinkTypeId = 'ChannelNodeResources'
			ORDER BY CAST(l.LastModified AS DATETIMEOFFSET)
	OPEN Cur_CategoryResourceLink
	FETCH NEXT FROM Cur_CategoryResourceLink INTO 
		@LinkTypeId
		,@TargetEntityID
		,@ResourceFilename
		,@ResourceMimeType
		,@ResourceName
		,@ResourceType
		,@ResourceURL
		,@SourceEntityID
		,@CategoryId
		,@SortOrder
		,@IsInactive
		,@Action
		,@LastModified
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF	(
				@CategoryId IS NULL OR 
				(
					ISNULL(@ResourceFilename,'') = '' AND ISNULL(@ResourceURL,'') = ''
				)
			)		
		BEGIN
			BEGIN TRY
				RAISERROR ('Custom Error - Category does not exist in Insite or Resource File Name and Resource URL not provided in PIM', -- Message text.  
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
				-- Log Error for Invalid Category/Resource in Linking
				INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Category - Resource Linking - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
								+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
								+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
								+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
								+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
								+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- (@CategoryId IS NULL OR ISNULL(@ResourceFilename,'') = '')
		ELSE IF @ResourceType = 'Images'
		BEGIN
			BEGIN TRY
				-- Apply 1st active image to Category 
				IF (@Action IN ('A','U') AND ISNULL(@IsInactive,0) = 0)
				BEGIN
					IF EXISTS
						(
							SELECT 1 
								FROM dbo.Category 
								WHERE Id = @CategoryID AND SmallImagePath = ''
						)
					BEGIN	-- Image is not associated with Category
						UPDATE dbo.Category
							SET SmallImagePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
							WHERE Id = @CategoryID
						UPDATE dbo.PRFTCategoryExtension
							SET 
								ImagePIMResourceID = @TargetEntityID
								,ImagePIMSortOrder = @SortOrder
							WHERE PIMEntityID = @SourceEntityID
					END	-- Image is not associated with Category
					ELSE	
					BEGIN	-- Image is already associated with Category
						-- sort order of the associated image should be less than existing sort order in category
						IF EXISTS
							(
								SELECT 1 
									FROM dbo.Category c
									INNER JOIN dbo.PRFTCategoryExtension ce
										ON c.Id = ce.CategoryID
									WHERE c.Id = @CategoryID 
										AND ISNULL(ce.ImagePIMSortOrder,0) >= @SortOrder
							)
						BEGIN
							UPDATE dbo.Category
								SET SmallImagePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
								WHERE Id = @CategoryID
							UPDATE dbo.PRFTCategoryExtension
								SET 
									ImagePIMResourceID = @TargetEntityID
									,ImagePIMSortOrder = @SortOrder
								WHERE PIMEntityID = @SourceEntityID
						END
					END	-- Image is already associated with Category
				END	-- (@Action IN ('A','U') AND ISNULL(@IsInactive,0) = 0)
				-- what if first link is removed ?? delta does not have info about the next image to be associated to category
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
				-- Log Error for Linking Category-Resource (Image)
				INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Add/Update/Delete Image to Category - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
								+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
								+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
								+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
								+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
								+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @ResourceType = 'Images'
		ELSE	-- @ResourceType <> 'Images'
		BEGIN
			IF (@Action IN ('A','U') AND ISNULL(@IsInactive,0) = 0)
			BEGIN
				BEGIN TRY
					IF EXISTS
						(
							SELECT 1
								FROM dbo.Document 
								WHERE ParentTable = 'Category'
									AND ParentId = @CategoryID
									AND ISNULL([Name],'') = CAST(@TargetEntityID AS NVARCHAR(100))
						)
					BEGIN
						UPDATE dbo.Document
							SET				
								[Description] = 
									CASE
										WHEN LEN(ISNULL(@ResourceType,'')) > 255
											THEN LEFT(@ResourceType,255)
										ELSE @ResourceType
									END
								,FilePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
								,DocumentType = 
									CASE
										WHEN LEN(ISNULL(@ResourceMimeType,'')) > 100
											THEN LEFT(@ResourceMimeType,100)
										ELSE @ResourceMimeType
									END
								,ModifiedOn = @LastModified
							WHERE ParentTable = 'Category'
								AND ParentId = @CategoryID
								AND ISNULL([Name],'') = CAST(@TargetEntityID AS NVARCHAR(100))
					END
					ELSE
					BEGIN
						INSERT INTO dbo.Document
							(
								Id
								,[Name]
								,[Description]
								,CreatedOn
								,FilePath
								,DocumentType
								,LanguageId
								,ModifiedOn
								,ParentId
								,ParentTable
							)
							SELECT
									NEWID()
									,CAST(@TargetEntityID AS NVARCHAR(100))
									,CASE
										WHEN LEN(ISNULL(@ResourceType,'')) > 255
											THEN LEFT(@ResourceType,255)
										ELSE @ResourceType
									 END
									,@LastModified
									,CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									 END
									,CASE
										WHEN LEN(ISNULL(@ResourceMimeType,'')) > 100
											THEN LEFT(@ResourceMimeType,100)
										ELSE @ResourceMimeType
									 END
									,ID
									,@LastModified
									,@CategoryID
									,'Category'
								FROM dbo.[Language]
								WHERE LanguageCode = 'en-US'
					END
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
					-- Log Error for Linking Category-Resource (Image)
					INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Add/Update other Resources to Category - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
									+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
									+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
									+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
									+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
									+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END
			ELSE IF (@Action = 'D' OR ISNULL(@IsInactive,0) = 1)
			BEGIN
				BEGIN TRY
					DELETE 
						FROM dbo.Document 
						WHERE ParentTable = 'Category'
							AND ParentId = @CategoryID
							AND ISNULL([Name],'') = CAST(@TargetEntityID AS NVARCHAR(100))
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
					-- Log Error for Linking Category-Resource (Image)
					INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Delete other Resources to Category - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
									+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
									+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
									+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
									+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
									+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- (@Action = 'D' OR ISNULL(@IsInactive,0) = 1)
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
					INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Invalid Action "'+@Action+'" for other Resources to Category Linking - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
									+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
									+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
									+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
									+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
									+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
									+'; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- @Action <> 'A'/'U'/'D'
		END	-- @ResourceType <> 'Images'
		FETCH NEXT FROM Cur_CategoryResourceLink INTO 
			@LinkTypeId
			,@TargetEntityID
			,@ResourceFilename
			,@ResourceMimeType
			,@ResourceName
			,@ResourceType
			,@ResourceURL
			,@SourceEntityID
			,@CategoryId
			,@SortOrder
			,@IsInactive
			,@Action
			,@LastModified
	END
	CLOSE Cur_CategoryResourceLink
	DEALLOCATE Cur_CategoryResourceLink
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Category - Resource Import from PIM',GETUTCDATE()
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Product - Resource Import from PIM',GETUTCDATE()
	DECLARE Cur_ProductResourceLink CURSOR LOCAL FAST_FORWARD FOR
		SELECT
				l.LinkTypeId
				,CAST(l.TargetEntityId AS INT)
				,r.ResourceName
				,r.ResourceFilename
				,r.ResourceMimeType
				--- 2018/12/10 - temp arrangement commented
				,r.ResourceType
				--,CASE
				--	WHEN (ISNULL(r.ResourceType,'') = '' AND r.ResourceMimeType like '%image%')
				--		THEN 'Images'
				--	ELSE r.ResourceType
				-- END
				,r.ResourceURL
				,CAST(l.SourceEntityId AS INT)
				,p.ProductId
				,CAST(l.[Index] AS INT)
				,CASE
					WHEN ISNULL(l.InActive,'True') = 'True' THEN 1
					ELSE 0
				 END InActive
				,l.[Action]
				,CAST(l.LastModified AS DATETIMEOFFSET)
			FROM dbo.PIMLink l
			LEFT JOIN
				(
					SELECT pr.Id ProductId,pre.PIMProductEntityID,pre.PIMItemEntityID,pre.PIMProductType
						FROM dbo.Product pr
						INNER JOIN dbo.PRFTProductExtension pre ON pr.Id = pre.ProductID
				) p
				ON
					(
						(
							l.LinkTypeId = 'ProductResources' 
							AND (p.PIMItemEntityID IS NULL OR p.PIMProductType = 'simple')
							AND l.SourceEntityId = p.PIMProductEntityID
						)
						OR
						(
							l.LinkTypeId = 'ItemResources' 
							AND l.SourceEntityId = p.PIMItemEntityID
						)
					)
			LEFT JOIN dbo.PRFTResourceDataFromPIM r ON l.TargetEntityId = r.EntityId
			WHERE l.LinkTypeId IN ('ItemResources','ProductResources')
			ORDER BY CAST(l.LastModified AS DATETIMEOFFSET)
	OPEN Cur_ProductResourceLink
	FETCH NEXT FROM Cur_ProductResourceLink INTO 
		@LinkTypeId
		,@TargetEntityID
		,@ResourceName
		,@ResourceFilename
		,@ResourceMimeType
		,@ResourceType
		,@ResourceURL
		,@SourceEntityID
		,@ProductID
		,@SortOrder
		,@IsInactive
		,@Action
		,@LastModified
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF	(
				@ProductID IS NULL OR 
				(
					ISNULL(@ResourceFilename,'') = '' AND ISNULL(@ResourceURL,'') = ''
				)
			)		
		BEGIN
			BEGIN TRY
				RAISERROR ('Custom Error - Product does not exist in Insite or Resource File Name and Resource URL not provided in PIM', -- Message text.  
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
				-- Log Error for Invalid Category/Resource in Linking
				INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Product - Resource Linking - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
								+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
								+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
								+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
								+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
								+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(50)),'**NULL**')
								+'; PIM Link Type = '+ISNULL(@LinkTypeId,'**NULL**')
								+'; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- (@ProductID IS NULL OR ISNULL(@ResourceFilename,'') = '')
		ELSE IF (@Action IN ('A','U') AND ISNULL(@IsInactive,0) = 0)
		BEGIN
			BEGIN TRY
				IF @ResourceType = 'Images'
				BEGIN
					IF EXISTS
						(
							SELECT 1
								FROM dbo.ProductImage p
								INNER JOIN dbo.PRFTProductImageExtension pe ON p.Id = pe.ProductImageID
								WHERE p.ProductID = @ProductID
									AND pe.PIMResourceEntityID = @TargetEntityID
						)
					BEGIN
						UPDATE pimg
							SET
								 pimg.[Name] = 
									CASE
										WHEN LEN(ISNULL(@ResourceName,'')) > 255
											THEN LEFT(@ResourceName,255)
										ELSE @ResourceName
									END
								, pimg.SmallImagePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
								, pimg.MediumImagePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
								, pimg.LargeImagePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
								, pimg.AltText = 
									CASE
										WHEN LEN(ISNULL(@ResourceName,'')) > 2048
											THEN LEFT(@ResourceName,2048)
										ELSE @ResourceName
									END
								, pimg.SortOrder = @SortOrder
								, pimg.ModifiedOn = @LastModified
							FROM dbo.ProductImage pimg
							INNER JOIN PRFTProductImageExtension pie
								ON (pie.PIMResourceEntityID = @TargetEntityID AND pimg.Id = pie.ProductImageID)
							WHERE pimg.ProductId = @ProductID
						UPDATE pie
							SET
								 pie.PIMResourceMimeType = @ResourceMimeType
							FROM PRFTProductImageExtension pie
							INNER JOIN dbo.ProductImage pimg
								ON (pimg.ProductId = @ProductID AND pie.ProductImageID = pimg.Id)
							WHERE pie.PIMResourceEntityID = @TargetEntityID
					END
					ELSE
					BEGIN
						SELECT @ProductImageID = NEWID()
						INSERT INTO dbo.ProductImage
							(
								Id
								,ProductId
								,[Name]
								,SmallImagePath
								,MediumImagePath
								,LargeImagePath
								,AltText
								,SortOrder
								,CreatedOn
								,ModifiedOn
							)
							SELECT
								@ProductImageID
								,@ProductID
								,CASE
									WHEN LEN(ISNULL(@ResourceName,'')) > 255
										THEN LEFT(@ResourceName,255)
									ELSE @ResourceName
								 END
								,CASE
									WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
										CASE
											WHEN LEN(@ResourceURL) > 1024
												THEN LEFT(@ResourceURL,1024)
											ELSE @ResourceURL
										END
									ELSE
										CASE
											WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
												THEN LEFT((@ResourcePath + @ResourceFilename),1024)
											ELSE @ResourcePath + @ResourceFilename
										END
								 END
								,CASE
									WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
										CASE
											WHEN LEN(@ResourceURL) > 1024
												THEN LEFT(@ResourceURL,1024)
											ELSE @ResourceURL
										END
									ELSE
										CASE
											WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
												THEN LEFT((@ResourcePath + @ResourceFilename),1024)
											ELSE @ResourcePath + @ResourceFilename
										END
								 END
								,CASE
									WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
										CASE
											WHEN LEN(@ResourceURL) > 1024
												THEN LEFT(@ResourceURL,1024)
											ELSE @ResourceURL
										END
									ELSE
										CASE
											WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
												THEN LEFT((@ResourcePath + @ResourceFilename),1024)
											ELSE @ResourcePath + @ResourceFilename
										END
								 END
								,CASE
									WHEN LEN(ISNULL(@ResourceName,'')) > 2048
										THEN LEFT(@ResourceName,2048)
									ELSE @ResourceName
								 END
								,@SortOrder
								,@LastModified
								,@LastModified
						INSERT INTO dbo.PRFTProductImageExtension
							(
								Id
								,ProductImageID
								,PIMResourceEntityID
								,PIMResourceMimeType
							)
							SELECT
								NEWID()
								,@ProductImageID
								,@TargetEntityID
								,@ResourceMimeType
					END
				END	-- @ResourceType = 'Images'
				ELSE
				BEGIN	-- @ResourceType <> 'Images'
					IF EXISTS
						(
							SELECT 1
								FROM dbo.Document 
								WHERE ParentTable = 'Product'
									AND ParentId = @ProductID
									AND ISNULL([Name],'') = CAST(@TargetEntityID AS NVARCHAR(100))
						)
					BEGIN
						UPDATE dbo.Document
							SET				
								[Description] = 
									CASE
										WHEN LEN(ISNULL(@ResourceType,'')) > 255
											THEN LEFT(@ResourceType,255)
										ELSE @ResourceType
									END
								,FilePath = 
									CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									END
								,DocumentType = 
									CASE
										WHEN LEN(ISNULL(@ResourceMimeType,'')) > 100
											THEN LEFT(@ResourceMimeType,100)
										ELSE @ResourceMimeType
									END
								,ModifiedOn = @LastModified
							WHERE ParentTable = 'Product'
								AND ParentId = @ProductID
								AND ISNULL([Name],'') = CAST(@TargetEntityID AS NVARCHAR(100))
					END
					ELSE
					BEGIN
						INSERT INTO dbo.Document
							(
								Id
								,[Name]
								,[Description]
								,CreatedOn
								,FilePath
								,DocumentType
								,LanguageID
								,ModifiedOn
								,ParentId
								,ParentTable
							)
							SELECT
									NEWID()
									,CAST(@TargetEntityID AS NVARCHAR(100))
									,CASE
										WHEN LEN(ISNULL(@ResourceType,'')) > 255
											THEN LEFT(@ResourceType,255)
										ELSE @ResourceType
									 END
									,@LastModified
									,CASE
										WHEN ISNULL(@ResourceURL,'') <> ''	THEN 
											CASE
												WHEN LEN(@ResourceURL) > 1024
													THEN LEFT(@ResourceURL,1024)
												ELSE @ResourceURL
											END
										ELSE
											CASE
												WHEN LEN(@ResourcePath + ISNULL(@ResourceFilename,'')) > 1024
													THEN LEFT((@ResourcePath + @ResourceFilename),1024)
												ELSE @ResourcePath + @ResourceFilename
											END
									 END
									,CASE
										WHEN LEN(ISNULL(@ResourceMimeType,'')) > 100
											THEN LEFT(@ResourceMimeType,100)
										ELSE @ResourceMimeType
									 END
									,ID
									,@LastModified
									,@ProductID
									,'Product'
								FROM dbo.[Language]
								WHERE LanguageCode = 'en-US'
					END
				END	-- @ResourceType <> 'Images'
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
				-- Log Error for Linking Category-Resource (Image)
				INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Add/Update Resource to Product - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
								+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
								+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
								+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
								+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
								+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(50)),'**NULL**')
								+'; PIM Link Type = '+ISNULL(@LinkTypeId,'**NULL**')
								+'; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- (@Action IN ('A','U') AND ISNULL(@IsInactive,0) = 0)
		ELSE IF (@Action = 'D' OR ISNULL(@IsInactive,0) = 1)
		BEGIN
			BEGIN TRY
				IF @ResourceType = 'Images'
				BEGIN
					DELETE pimg
						FROM dbo.ProductImage pimg
						INNER JOIN PRFTProductImageExtension pie 
							ON (pie.PIMResourceEntityID = @TargetEntityID AND pimg.Id = pie.ProductImageID)
						WHERE pimg.ProductID = @ProductID
				END	-- @ResourceType = 'Images'
				ELSE
				BEGIN	-- @ResourceType <> 'Images'
					DELETE FROM dbo.Document 
						WHERE ParentTable = 'Product'
							AND ParentId = @ProductID
							AND ISNULL([Name],'') = CAST(@TargetEntityID AS NVARCHAR(100))
				END	-- @ResourceType <> 'Images'
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
				-- Log Error for Linking Category-Resource (Image)
				INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Delete Resources to Product - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
								+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
								+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
								+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
								+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
								+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(50)),'**NULL**')
								+'; PIM Link Type = '+ISNULL(@LinkTypeId,'**NULL**')
								+'; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @Action = 'D' OR ISNULL(@IsInactive,0) = 1
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
				INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Invalid Action "'+@Action+'" for Product - Resource Linking - PIM Target Entity ID = '+ISNULL(CAST(@TargetEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Resource Name = '+ISNULL(@ResourceName,'**NULL**')
								+'; Resource File Name = '+ISNULL(@ResourceFilename,'**NULL**')
								+'; Resource URL = '+ISNULL(@ResourceURL,'**NULL**')
								+'; Resource Mime Type = '+ISNULL(@ResourceMimeType,'**NULL**')
								+'; Resource Type = '+ISNULL(@ResourceType,'**NULL**')
								+'; PIM Source Entity ID = '+ISNULL(CAST(@SourceEntityID AS NVARCHAR(50)),'**NULL**')
								+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(50)),'**NULL**')
								+'; PIM Link Type = '+ISNULL(@LinkTypeId,'**NULL**')
								+'; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @Action <> 'A'/'U'/'D'
		FETCH NEXT FROM Cur_ProductResourceLink INTO 
			@LinkTypeId
			,@TargetEntityID
			,@ResourceName
			,@ResourceFilename
			,@ResourceMimeType
			,@ResourceType
			,@ResourceURL
			,@SourceEntityID
			,@ProductID
			,@SortOrder
			,@IsInactive
			,@Action
			,@LastModified
	END
	CLOSE Cur_ProductResourceLink
	DEALLOCATE Cur_ProductResourceLink
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Product - Resource Import from PIM',GETUTCDATE()
	-- only resource data is updated i.e. Resource Name/Resource FileName/Mime Type/Resource Type etc. and link is not added/updated/deleted
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Resource Data Update from PIM',GETUTCDATE()
	BEGIN TRY
		-- image for category 
		UPDATE c
			SET 
				c.SmallImagePath = 
						CASE
							WHEN ISNULL(r.ResourceURL,'') <> ''	THEN 
								CASE
									WHEN LEN(r.ResourceURL) > 1024
										THEN LEFT(r.ResourceURL,1024)
									ELSE r.ResourceURL
								END
							ELSE
								CASE
									WHEN LEN(@ResourcePath + ISNULL(r.ResourceFilename,'')) > 1024
										THEN LEFT((@ResourcePath + r.ResourceFilename),1024)
									ELSE @ResourcePath + r.ResourceFilename
								END
						END
			FROM dbo.Category c
			INNER JOIN dbo.PRFTCategoryExtension ce ON c.Id = ce.CategoryID
			INNER JOIN dbo.PIMResource r ON ce.ImagePIMResourceID = r.EntityId
			LEFT JOIN dbo.PIMLink l 
				ON 
					(
						l.LinkTypeId = 'ChannelNodeResources'
						AND r.EntityId = l.TargetEntityId
					)
			WHERE l.ID IS NULL
		-- images for product
		UPDATE pimg
			SET 
				pimg.[Name] = 
						CASE
							WHEN LEN(ISNULL(r.ResourceName,'')) > 255
								THEN LEFT((@ResourcePath + r.ResourceName),255)
							ELSE @ResourcePath + r.ResourceName
						END
				, pimg.SmallImagePath = 
						CASE
							WHEN ISNULL(r.ResourceURL,'') <> ''	THEN 
								CASE
									WHEN LEN(r.ResourceURL) > 1024
										THEN LEFT(r.ResourceURL,1024)
									ELSE r.ResourceURL
								END
							ELSE
								CASE
									WHEN LEN(@ResourcePath + ISNULL(r.ResourceFilename,'')) > 1024
										THEN LEFT((@ResourcePath + r.ResourceFilename),1024)
									ELSE @ResourcePath + r.ResourceFilename
								END
						END
				, pimg.MediumImagePath = 
						CASE
							WHEN ISNULL(r.ResourceURL,'') <> ''	THEN 
								CASE
									WHEN LEN(r.ResourceURL) > 1024
										THEN LEFT(r.ResourceURL,1024)
									ELSE r.ResourceURL
								END
							ELSE
								CASE
									WHEN LEN(@ResourcePath + ISNULL(r.ResourceFilename,'')) > 1024
										THEN LEFT((@ResourcePath + r.ResourceFilename),1024)
									ELSE @ResourcePath + r.ResourceFilename
								END
						END
				, pimg.LargeImagePath = 
						CASE
							WHEN ISNULL(r.ResourceURL,'') <> ''	THEN 
								CASE
									WHEN LEN(r.ResourceURL) > 1024
										THEN LEFT(r.ResourceURL,1024)
									ELSE r.ResourceURL
								END
							ELSE
								CASE
									WHEN LEN(@ResourcePath + ISNULL(r.ResourceFilename,'')) > 1024
										THEN LEFT((@ResourcePath + r.ResourceFilename),1024)
									ELSE @ResourcePath + r.ResourceFilename
								END
						END
				, pimg.AltText = 
						CASE
							WHEN LEN(@ResourcePath + ISNULL(r.ResourceName,'')) > 2048
								THEN LEFT((@ResourcePath + r.ResourceName),2048)
							ELSE @ResourcePath + r.ResourceName
						END
				, pimg.ModifiedOn = @LastModified
			FROM dbo.ProductImage pimg
			INNER JOIN PRFTProductImageExtension pie
				ON pimg.Id = pie.ProductImageID
			INNER JOIN dbo.PIMResource r ON pie.PIMResourceEntityID = r.EntityId
			LEFT JOIN dbo.PIMLink l 
				ON 
					(
						l.LinkTypeId IN ('ItemResources','ProductResources')
						AND r.EntityId = l.TargetEntityId
					)
			WHERE l.ID IS NULL
		UPDATE pie
			SET 
				pie.PIMResourceMimeType = r.ResourceMimeType
			FROM PRFTProductImageExtension pie
			INNER JOIN dbo.ProductImage pimg
				ON pie.ProductImageID = pimg.Id
			INNER JOIN dbo.PIMResource r ON pie.PIMResourceEntityID = r.EntityId
			LEFT JOIN dbo.PIMLink l 
				ON 
					(
						l.LinkTypeId IN ('ItemResources','ProductResources')
						AND r.EntityId = l.TargetEntityId
					)
			WHERE l.ID IS NULL
		-- other resources for product & category 
		UPDATE d
			SET				
				d.[Description] = 
						CASE
							WHEN LEN(ISNULL(r.ResourceType,'')) > 255
								THEN LEFT(r.ResourceType,255)
							ELSE r.ResourceType
						END
				,d.FilePath = 
						CASE
							WHEN ISNULL(r.ResourceURL,'') <> ''	THEN 
								CASE
									WHEN LEN(r.ResourceURL) > 1024
										THEN LEFT(r.ResourceURL,1024)
									ELSE r.ResourceURL
								END
							ELSE
								CASE
									WHEN LEN(@ResourcePath + ISNULL(r.ResourceFilename,'')) > 1024
										THEN LEFT((@ResourcePath + r.ResourceFilename),1024)
									ELSE @ResourcePath + r.ResourceFilename
								END
						END
				,d.DocumentType = 
						CASE
							WHEN LEN(ISNULL(r.ResourceMimeType,'')) > 100
								THEN LEFT(r.ResourceMimeType,100)
							ELSE r.ResourceMimeType
						END
			FROM dbo.Document d
			INNER JOIN dbo.PIMResource r ON d.[Name] = CAST(r.EntityId AS NVARCHAR(100))
			LEFT JOIN dbo.PIMLink l 
				ON 
					(
						l.LinkTypeId IN ('ChannelNodeResources','ItemResources','ProductResources')
						AND r.EntityId = l.TargetEntityId
					)
			WHERE d.ParentTable IN ('Category','Product')
				AND l.ID IS NULL
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
		-- Log Error for Resource Update
		INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
			SELECT	'Warn'
					,'Error while Updating Resource data'
						+'; Error Message = '+@ErrorMessage
					,GETUTCDATE()
	END CATCH
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Resource Data Update from PIM',GETUTCDATE()
	INSERT INTO #ImportResourceLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Resource Import from PIM ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportResourceLog				
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
					,'Resource Import Module'
				FROM #ImportResourceLog
	END
	IF EXISTS(SELECT 1 FROM #ImportResourceLog WHERE LogTypeName = 'Error')
	BEGIN
		DROP TABLE #ImportResourceLog
		RETURN -1	
	END
	ELSE
	BEGIN
		DROP TABLE #ImportResourceLog
		RETURN 0	
	END

END
GO
