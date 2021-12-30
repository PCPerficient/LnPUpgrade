ALTER PROCEDURE [dbo].[PRFTImportProductDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	--SET XACT_ABORT ON
	--SET NOCOUNT ON
	-- table to hold error/log info. while processing data
	CREATE TABLE #ImportProductLog	--PRFTImportCategoryLog
		(
			LogKey				INT IDENTITY(1,1)
			,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
			,LogMessage			NVARCHAR(MAX)
			,LogDateTime		DATETIMEOFFSET
		)
	INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Product Import from PIM Product ----',GETUTCDATE()
	CREATE TABLE #DeleteContManList(ContentManagerId UNIQUEIDENTIFIER)
	DECLARE @EntityID INT
	DECLARE @ErrorNumber INT
	DECLARE @ErrorLine INT
	DECLARE @ProductID UNIQUEIDENTIFIER
	DECLARE @ProductExtensionID UNIQUEIDENTIFIER
	DECLARE @ContentManagerID UNIQUEIDENTIFIER
	DECLARE @PersonaID UNIQUEIDENTIFIER
	DECLARE @LanguageID UNIQUEIDENTIFIER
	DECLARE @VendorID UNIQUEIDENTIFIER
	DECLARE @StyleClassID UNIQUEIDENTIFIER
	DECLARE @ProductCode NVARCHAR(50)
	DECLARE @ERPNumber NVARCHAR(50)
	DECLARE @Sku NVARCHAR(100)
	DECLARE @ProductType NVARCHAR(50)
	DECLARE @ErrorProcedure NVARCHAR(200)
	DECLARE @Name NVARCHAR(255)
	DECLARE @UrlSegment NVARCHAR(255)
	DECLARE @VendorName NVARCHAR(255)
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @Action NVARCHAR(MAX)
	DECLARE @FieldsUpdated NVARCHAR(MAX)
	DECLARE @CountryofOrigin NVARCHAR(MAX)
	DECLARE @ProductRomanceCopy NVARCHAR(MAX)
	DECLARE @DateCreated DATETIME
	DECLARE @LastModified DATETIME

	-- if new product already exists in insite then update the Action from 'A' to 'U'
	UPDATE pr
		SET pr.[Action] = 'U'
		FROM dbo.PIMProduct pr
		INNER JOIN dbo.PRFTProductExtension pe 
			ON (pr.EntityId = pe.PIMProductEntityID)
		WHERE pr.[Action] = 'A'
	-- get Product data from PIM
	DECLARE Cur_Product CURSOR LOCAL FAST_FORWARD FOR
		SELECT
				CAST(EntityId AS INT)
				,CASE
					WHEN LEN(ISNULL(ProductID,'')) > 255 THEN LEFT(ProductID,255)
					ELSE ProductID
				 END				-- Name,ShortDescription
				,CASE
					WHEN LEN(ISNULL(EntityId,'') + '-' + ISNULL(ProductID,'')) > 255 THEN LEFT(EntityId + '-' + ProductID,255)
					ELSE EntityId + '-' + ProductID
				 END				-- UrlSegment
				,CASE
					WHEN LEN(ISNULL(ProductID,'')) > 50 THEN LEFT(ProductID,50)
					ELSE ProductID
				 END				-- ProductCode,ERPNumber
				,CASE
					WHEN LEN(ISNULL(ProductID,'')) > 100 THEN LEFT(ProductID,100)
					ELSE ProductID
				 END				-- Sku
				,CASE
					WHEN LEN(ISNULL(ProductManufacturerName,'')) > 255 THEN LEFT(ProductManufacturerName,255)
					ELSE ProductManufacturerName
				 END				-- VendorName
				,CASE
					WHEN LEN(ISNULL(ProductInsiteProductType,'')) > 50 THEN LEFT(ProductInsiteProductType,50)
					ELSE ProductInsiteProductType
				 END							-- PIMProductType
				,CAST(DateCreated AS DATETIMEOFFSET)	--CreatedOn
				,CAST(LastModified AS DATETIMEOFFSET)	--ModifiedOn
				,ProductRomanceCopy
				,ProductCountryofOrigin_Value
				,[Action]
				,FieldsUpdated
			FROM dbo.PIMProduct p
		ORDER BY LastModified
	OPEN Cur_Product
	--INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
	--	SELECT 'Info','Started - Import Product data from PIM',GETUTCDATE()
	FETCH NEXT FROM Cur_Product INTO 
		@EntityID
		,@Name
		,@UrlSegment
		,@ERPNumber
		,@Sku
		,@VendorName
		,@ProductType
		,@DateCreated
		,@LastModified
		,@ProductRomanceCopy
		,@CountryofOrigin
		,@Action
		,@FieldsUpdated
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @ProductID = NULL
		SELECT @PersonaID = Id FROM dbo.Persona WHERE Name = 'Default'
		SELECT @LanguageID = Id FROM dbo.Language WHERE LanguageCode = 'en-US'
		-- get VendorId w.r.t. VendorName
		SET @VendorID = NULL
		IF ISNULL(@VendorName,'') <> ''
		BEGIN
			SELECT @VendorID = Id FROM dbo.Vendor WHERE Name = @VendorName
			-- if not exists then create
			IF @VendorID IS NULL
			BEGIN
				SELECT @VendorID = NEWID()
				INSERT INTO dbo.Vendor
					(
						Id
						,Name
						,VendorNumber
						,CreatedOn
						,ModifiedOn
					)
					SELECT 
						@VendorID
						,@VendorName
						,@VendorName
						,@DateCreated
						,@LastModified
			END	-- @VendorID IS NULL
		END	-- ISNULL(@VendorName,'') <> ''
		IF @Action = 'A'
		BEGIN
			BEGIN TRY
				SELECT @ContentManagerID = NEWID()
				SELECT @ProductID = NEWID()
				SELECT @ProductExtensionID = NEWID()
				SELECT @StyleClassID = NULL
				IF @ProductType = 'style'
				BEGIN
					SELECT @StyleClassID = Id 
						FROM dbo.StyleClass
						WHERE Name = @ERPNumber
					IF @StyleClassID IS NULL
					BEGIN
						SELECT @StyleClassID = NEWID()
						INSERT INTO dbo.StyleClass
							(
								Id
								,Name
								,[Description]
								,IsActive
								,CreatedOn
								,ModifiedOn
							)
							SELECT
								@StyleClassID
								,@ERPNumber
								,@ERPNumber
								,1
								,@DateCreated
								,@LastModified
					END
				END
				ELSE
				BEGIN
					SELECT @StyleClassID = NULL
				END
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
						,@DateCreated
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
						,UrlSegment
						,ContentManagerID
						,ERPNumber
						,VendorID
						,StyleClassID
						,IsConfigured
						,IsFixedConfiguration
						,CreatedOn
						,ModifiedOn
					)
					SELECT
							@ProductID ProductID
							,@Name [Name]
							,@Name ShortDescription
							,@ERPNumber ProductCode
							,@Sku SKU
							,todatetimeoffset(cast(dateadd(day,-1,cast(@DateCreated as datetime)) as datetime2),datepart(tz,CAST(@DateCreated AS DATETIMEOFFSET))) ActivateOn
							,NULL DeactivateOn
							,@UrlSegment UrlSegment
							,@ContentManagerID ContentManagerID
							,@ERPNumber ERPNumber
							,@VendorID VendorID
							,@StyleClassID StyleClassID
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
							,@DateCreated CreatedOn
							,@LastModified ModifiedOn
				INSERT INTO dbo.PRFTProductExtension
					(
						ID
						,ProductID
						,PIMProductEntityID
						,PIMProductType
						,ProductCountryofOrigin_Value
					)
					SELECT
							@ProductExtensionID ExtnID
							,@ProductID ProductID
							,@EntityID PIMProductEntityID
							,@ProductType ProductType
							,@CountryofOrigin ProductCountryofOrigin_Value
				IF ISNULL(@ProductRomanceCopy,'') <> '' AND @ProductType in ('style','configurable','bundle')
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
							,@ProductRomanceCopy
							,@LastModified
							,@LastModified
							,@LastModified
							,@LastModified
							,1
							,'Desktop'
							,@PersonaID
							,@LanguageID
							,@LastModified
				END	-- ISNULL(@ProductRomanceCopy,'') <> '' AND @ProductType in ('style','configurable','bundle')
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
				-- Log Error for New Product
				INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for New Product  - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
								+'; Product Name = '+ISNULL(@ERPNumber,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END		-- Action = 'A'
		ELSE IF @Action = 'U'
		BEGIN
			-- Product Type modification not allowed
			IF @FieldsUpdated  LIKE '%ProductInsiteProductType%'
			BEGIN	-- ignore & log error for Product Type update
				BEGIN TRY
					RAISERROR ('Custom Error - Changing Product Type of a Product not supported...', -- Message text.  
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
					-- Log Error for Update Product Type
					INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Update Product'+''''+'s Product Type  - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Product Name = '+ISNULL(@ERPNumber,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- ignore & log error for Product Type update
			ELSE
			BEGIN	-- Product Type not changed
				SELECT @ProductID = p.Id, @ContentManagerID = p.ContentManagerID
					FROM dbo.Product p
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMItemEntityID IS NULL AND pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				BEGIN TRY
					IF @ProductID IS NOT NULL
					BEGIN	-- base product or product with no item associated
						UPDATE dbo.Product
							SET 
								[Name] = @Name
								,ShortDescription = @Name
								,ProductCode = @ERPNumber
								,SKU = @Sku
								,UrlSegment = 
										CASE
											WHEN @FieldsUpdated  LIKE '%ProductID%' THEN @UrlSegment
											ELSE UrlSegment
										END
								,ERPNumber = 
										CASE
											WHEN @FieldsUpdated  LIKE '%ProductID%' THEN @ERPNumber
											ELSE ERPNumber
										END
								,VendorID = @VendorID
								,ModifiedOn = @LastModified
							WHERE Id = @ProductID
						UPDATE dbo.PRFTProductExtension														
							SET
								ProductCountryofOrigin_Value = @CountryofOrigin 
							WHERE ProductID = @ProductID
						IF	( 
								ISNULL(@ProductRomanceCopy,'') <> '' 
								AND @FieldsUpdated LIKE '%ProductRomanceCopy%'
							)
						BEGIN	-- ProductRomanceCopy field modified
							DELETE FROM dbo.Content WHERE ContentManagerId = @ContentManagerID
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
									,@ProductRomanceCopy
									,@LastModified
									,@LastModified
									,@LastModified
									,@LastModified
									,1
									,'Desktop'
									,@PersonaID
									,@LanguageID
									,@LastModified
						END	-- ProductRomanceCopy field modified
					END	-- base product or product with no item associated
					ELSE
					BEGIN	-- update product related columns only for children items
						UPDATE p
							SET 
								p.ProductCode = @ERPNumber
								,p.VendorID = @VendorID
								,p.ModifiedOn = @LastModified
							FROM dbo.Product p
							INNER JOIN dbo.PRFTProductExtension pe
								ON (pe.PIMProductEntityID = @EntityID AND pe.PIMItemEntityID IS NOT NULL AND p.Id = pe.ProductID)
						UPDATE dbo.PRFTProductExtension
							SET 
								ProductCountryofOrigin_Value = @CountryofOrigin
							WHERE PIMProductEntityID = @EntityID AND PIMItemEntityID IS NOT NULL
					END	-- update product related columns only for children items
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
					INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Update Product - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Product Name = '+ISNULL(@ERPNumber,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- Product Type not changed
		END	-- @Action = 'U'
		ELSE IF @Action = 'D'
		BEGIN
			BEGIN TRY
				SET @StyleClassID = NULL
				TRUNCATE TABLE #DeleteContManList
				-- get content managers for parent & child products
				INSERT INTO #DeleteContManList(ContentManagerId)
					SELECT p.ContentManagerId 
						FROM dbo.Product p 
						INNER JOIN dbo.PRFTProductExtension pe 
							ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- get style class from base product
				SELECT @StyleClassID = p.StyleClassID
					FROM dbo.Product p 
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND pe.PIMItemEntityID IS NULL AND p.Id = pe.ProductID)
				-- remove attribute value association for parent & child products
				DELETE pav
					FROM dbo.ProductAttributeValue pav
					INNER JOIN dbo.Product p ON pav.ProductId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove trait value association for parent & child products
				DELETE tvp
					FROM dbo.StyleTraitValueProduct tvp
					INNER JOIN dbo.Product p ON tvp.ProductId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove from kit, associated child product
				DELETE pkso
					FROM dbo.ProductKitSectionOption pkso
					INNER JOIN dbo.Product p ON pkso.ProductId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove kit associated to parent config/bundle product
				DELETE pks
					FROM dbo.ProductKitSection pks
					INNER JOIN dbo.Product p ON pks.ProductId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove style class association for parent product
				UPDATE dbo.Product
					SET StyleClassId = NULL
					WHERE StyleClassId = @StyleClassID
				-- remove style class 
				DELETE FROM dbo.StyleClass WHERE Id = @StyleClassID
				-- remove images for parent & child products
				DELETE img
					FROM dbo.ProductImage img
					INNER JOIN dbo.Product p ON img.ProductId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove category association for parent & child products
				DELETE cp
					FROM dbo.CategoryProduct cp
					INNER JOIN dbo.Product p ON cp.ProductId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove from document for parent & child products
				DELETE doc
					FROM dbo.Document doc
					INNER JOIN dbo.Product p ON doc.ParentId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
					WHERE doc.ParentTable = 'Product'
				-- remove from custom property for parent & child products
				DELETE cusprop
					FROM dbo.CustomProperty cusprop
					INNER JOIN dbo.Product p ON cusprop.ParentId = p.Id
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
					WHERE cusprop.ParentTable = 'Product'
				-- remove from content for parent & child products
				DELETE cont
					FROM dbo.Content cont
					INNER JOIN #DeleteContManList dcml ON cont.ContentManagerId = dcml.ContentManagerId
				-- remove style parent + content manager association & deactivate the products
				UPDATE p
					SET p.StyleParentId = NULL
						,p.ContentManagerId = ''
						,p.DeactivateOn = todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET)))
						,p.UrlSegment = CAST(@EntityID AS NVARCHAR(255))
						,p.ErpNumber = CAST(@EntityID AS NVARCHAR(50))
						,p.ModifiedOn = @LastModified
					FROM dbo.Product p 
					INNER JOIN dbo.PRFTProductExtension pe 
						ON (pe.PIMProductEntityID = @EntityID AND p.Id = pe.ProductID)
				-- remove from extension for parent & child products
				DELETE FROM dbo.PRFTProductExtension WHERE PIMProductEntityID = @EntityID
				-- remove from content manager for parent & child products
				DELETE contman
					FROM dbo.ContentManager contman
					INNER JOIN #DeleteContManList dcml ON contman.Id = dcml.ContentManagerId
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
				-- Log Error for Delete Product
				INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Delete Product  - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
								+'; Product Name = '+ISNULL(@ERPNumber,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
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
				SELECT @ErrorMessage = 'Error#: '+CAST(@ErrorNumber AS NVARCHAR(20))
										+' Error Procedure: '+@ErrorProcedure
										+' Error Line#: '+CAST(@ErrorLine AS NVARCHAR(20))
										+' Error Message: '+@ErrorMessage
				-- Log Error for Invalid Action Type in Product
				INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Product - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
								+'; Product Name = '+ISNULL(@Name,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @Action <> 'A'/'U'/'D'
		FETCH NEXT FROM Cur_Product INTO 				
			@EntityID									
			,@Name
			,@UrlSegment										
			,@ERPNumber
			,@Sku
			,@VendorName
			,@ProductType
			,@DateCreated
			,@LastModified
			,@ProductRomanceCopy
			,@CountryofOrigin
			,@Action
			,@FieldsUpdated
	END
	CLOSE Cur_Product
	DEALLOCATE Cur_Product
	INSERT INTO #ImportProductLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Product Import from PIM Product ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportProductLog				
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
					,'Product Import Module'
				FROM #ImportProductLog
	END
	IF EXISTS(SELECT 1 FROM #ImportProductLog WHERE LogTypeName = 'Error')
	BEGIN
		DROP TABLE #ImportProductLog
		RETURN -1	
		
	END
	ELSE
	BEGIN
		DROP TABLE #ImportProductLog
		RETURN 0	
	END
END
GO
