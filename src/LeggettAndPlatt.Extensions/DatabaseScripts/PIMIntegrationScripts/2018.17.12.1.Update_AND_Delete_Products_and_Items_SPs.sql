ALTER PROCEDURE [dbo].[PRFTImportAttributeDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	DECLARE @TabVarDelAttVal TABLE
		(
			ProductID			UNIQUEIDENTIFIER
			,AttributeValueID	UNIQUEIDENTIFIER
		)
	CREATE TABLE #ImportAttributeLog	--PRFTImportCategoryLog
			(
				LogKey				INT IDENTITY(1,1)
				,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
				,LogMessage			NVARCHAR(MAX)
				,LogDateTime		DATETIMEOFFSET
			)
	INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Attribute Types & Values Import from PIM ----',GETUTCDATE()

	DECLARE @Entity_Id						INT
	DECLARE @ErrorNumber					INT
	DECLARE @ErrorLine						INT
	DECLARE @SortOrder						INT
	DECLARE @StartPKey						INT = 0
	DECLARE @ProductID						UNIQUEIDENTIFIER
	DECLARE @AttributeTypeID				UNIQUEIDENTIFIER
	DECLARE @AttributeValueID				UNIQUEIDENTIFIER
	DECLARE @separator						VARCHAR(1) = '~'
	DECLARE @AttributeDataType				NVARCHAR(50)
	DECLARE @AttributeMultiSelect			NVARCHAR(50)
	DECLARE @Entity_Type					NVARCHAR(50)
	DECLARE @OldAttributeValueEntity_Type	NVARCHAR(50)
	DECLARE @ErrorProcedure					NVARCHAR(200)
	DECLARE @AttributeTypeName				NVARCHAR(MAX)
	DECLARE @AttributeLabel					NVARCHAR(MAX)
	DECLARE @AttributeValue					NVARCHAR(MAX)
	DECLARE @ErrorMessage					NVARCHAR(MAX)
	DECLARE @SplitValue						NVARCHAR(MAX)
	DECLARE @CurrDate						DATETIMEOFFSET
	SELECT @CurrDate = GETDATE()
	INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Import Attribute Type data from PIM',GETUTCDATE()
	--remove Item/Product prefix => ItemGoForGold = GoForGold
	SELECT DISTINCT 
			CASE
				WHEN LEFT(AttributeName,4) = 'Item' THEN RIGHT(AttributeName,LEN(AttributeName)-4)
				WHEN LEFT(AttributeName,7) = 'Product' THEN RIGHT(AttributeName,LEN(AttributeName)-7)
				ELSE AttributeName
			END AttributeName
			,CASE
				-- Label not in PIM or Label same as columnname => Label will be same as Attribute Name derived above
				WHEN (AttributeName = AttributeLabel OR ISNULL(AttributeLabel,'') = '') THEN
					CASE
						WHEN LEFT(AttributeName,4) = 'Item' THEN RIGHT(AttributeName,LEN(AttributeName)-4)
						WHEN LEFT(AttributeName,7) = 'Product' THEN RIGHT(AttributeName,LEN(AttributeName)-7)
						ELSE AttributeName
					END
				ELSE AttributeLabel
			 END AttributeLabel
		INTO #AttributeTypes
		FROM dbo.PIMAttributeModel
	DECLARE Cur_AttributeTypes CURSOR LOCAL FAST_FORWARD FOR
		-- for two same derived names with different labels
		-- 'ItemMaterialUsed' & 'ProductMaterialUsed' will have same derived name as 'Material Used'
		-- but ItemMaterial has label = 'Material Used' & ProductMaterial has label = 'Mat Used'
		-- => label for derived name 'MaterialUsed' will be 'Material Used'
		SELECT 
				AttributeName
				,MAX(AttributeLabel) AttributeLabel
			FROM #AttributeTypes
			GROUP BY AttributeName
	OPEN Cur_AttributeTypes
	FETCH NEXT FROM Cur_AttributeTypes INTO  
		@AttributeTypeName
		,@AttributeLabel
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @AttributeTypeID = NULL
		SELECT @AttributeTypeID = Id 
			FROM dbo.AttributeType 
			WHERE [Name] = @AttributeTypeName
		IF @AttributeTypeID IS NULL
		BEGIN
			BEGIN TRY
				SET @AttributeTypeID = NEWID()
				INSERT INTO dbo.AttributeType
					(
						Id
						,[Name]
						,Label
						,CreatedOn
						,ModifiedOn
					)
					SELECT
						@AttributeTypeID
						,@AttributeTypeName
						,@AttributeLabel
						,@CurrDate
						,@CurrDate
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
				-- Log Error for New Attribute Type
				INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for New Attribute Type = '+ISNULL(@AttributeTypeName,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @AttributeTypeID IS NULL
		ELSE	-- @AttributeTypeID IS NOT NULL
		BEGIN
			BEGIN TRY
				UPDATE dbo.AttributeType
					SET
						Label = @AttributeLabel
						,ModifiedOn = @CurrDate
					WHERE Id = @AttributeTypeID
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
				-- Log Error for Update Attribute Type
				INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Update Attribute Type = '+ISNULL(@AttributeTypeName,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- EXISTS (SELECT 1 FROM dbo.AttributeType WHERE [Name] = @AttributeTypeName)
		FETCH NEXT FROM Cur_AttributeTypes INTO  
			@AttributeTypeName
			,@AttributeLabel
	END	
	CLOSE Cur_AttributeTypes
	DEALLOCATE Cur_AttributeTypes
	DROP TABLE #AttributeTypes
	INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Import Attribute Type data from PIM',GETUTCDATE()
	INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Import Attribute Value data from PIM',GETUTCDATE()
	UPDATE dbo.PIMAttribute SET AttributeValue = LEFT(AttributeValue,255)
		WHERE LEN(ISNULL(AttributeValue,'')) > 255
	DECLARE Cur_AttributeValues CURSOR LOCAL FAST_FORWARD FOR
		SELECT 
				a.Entity_Type
				,a.[Entity_Id]
				,pe.ProductID
				,aty.Id AttributeTypeID
				,a.AttributeName
				,ISNULL(a.AttributeValue,'') AttributeValue
				,a.AttributeDataType
				,a.AttributeMultiSelect
			FROM 
				(
					SELECT
							atv.Entity_Type
							,atv.[Entity_Id]
							,CASE
								WHEN LEFT(atv.AttributeName,4) = 'Item' THEN RIGHT(atv.AttributeName,LEN(atv.AttributeName)-4)
								WHEN LEFT(atv.AttributeName,7) = 'Product' THEN RIGHT(atv.AttributeName,LEN(atv.AttributeName)-7)
								ELSE atv.AttributeName
							 END AttributeName
							,atv.AttributeValue
							,atm.AttributeDataType
							,atm.AttributeMultiSelect
						FROM dbo.PIMAttribute atv
						INNER JOIN dbo.PIMAttributeModel atm ON atv.AttributeName = atm.AttributeName
				) a
			LEFT JOIN dbo.AttributeType aty ON a.AttributeName = aty.[Name]
			LEFT JOIN 
				(
					SELECT 
							pr.ID ProductID
							,pre.PIMProductEntityID
							,ISNULL(pre.PIMItemEntityID,0) PIMItemEntityID
							,ISNULL(pre.PIMProductType,'') ProductType
						FROM dbo.Product pr
						INNER JOIN dbo.PRFTProductExtension pre ON pr.ID = pre.ProductID
				) pe ON 
					(
						-- attributes to be associated to products that are not the base products
						-- i.e.Simple Products or Items of Non-simple Products
						(
							a.Entity_Type = 'Product' 
							AND 
							(
								-- get simple products
								pe.ProductType = 'simple'
								OR
								-- get items for base product associated to attribute
								pe.PIMItemEntityID IS NOT NULL 
							)
							AND a.[Entity_Id] = pe.PIMProductEntityID
						)
						OR
						-- get items associated to attribute
						(
							a.Entity_Type = 'Item' 
							AND a.[Entity_Id] = pe.PIMItemEntityID
						)
					)
	OPEN Cur_AttributeValues
	FETCH NEXT FROM Cur_AttributeValues INTO
		@Entity_Type
		,@Entity_Id
		--,@CategoryID
		,@ProductID
		,@AttributeTypeID
		,@AttributeTypeName
		,@AttributeValue
		,@AttributeDataType
		,@AttributeMultiSelect
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF (@ProductID IS NULL OR @AttributeTypeID IS NULL)
		BEGIN
			BEGIN TRY
				RAISERROR ('Custom Error - Product and/or Attribute Type does not exist in Insite', -- Message text.  
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
				-- Log Error for Blank Product/Attribute Type IDs Link
				INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Product - Attribute Linking - PIM Target Entity ID = '+ISNULL(CAST(@Entity_Id AS NVARCHAR(50)),'**NULL**')	
								+'; Entity Type = '+ISNULL(@Entity_Type,'**NULL**')				
								+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
								+'; Attribute Type ID = '+ISNULL(CAST(@AttributeTypeID AS NVARCHAR(100)),'**NULL**')
								+'; Attribute Value = '+ISNULL(@AttributeValue,'**NULL**')
								+'; Attribute Data Type = '+ISNULL(@AttributeDataType,'**NULL**')				
								+'; Attribute Multi-Select = '+ISNULL(@AttributeMultiSelect,'**NULL**')				
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- (@ProductID IS NULL OR @AttributeTypeID IS NULL)
		ELSE
		BEGIN 
			--SET @OldAttributeValue = NULL
			--SET @OldAttributeValueID = NULL
			--SET @OldProductAttributeValueID = NULL
			SET @OldAttributeValueEntity_Type = 'Product'
			--SELECT @OldAttributeValueID = av.ID
			--		,@OldAttributeValue = av.[Value]
			--		,@OldProductAttributeValueID = pav.ID
			--		,@OldAttributeValueEntity_Type = MAX(ISNULL(pave.EntityType,'Product'))
			SELECT @OldAttributeValueEntity_Type = MAX(ISNULL(pave.PIMSourceEntityType,'Product'))
				FROM dbo.AttributeValue av
				INNER JOIN dbo.ProductAttributeValue pav 
					ON (pav.ProductID = @ProductID AND av.ID = pav.AttributeValueId)
				LEFT JOIN dbo.PRFTProductAttributeValueExtension pave 
					ON (pav.ProductId = pave.ProductId AND pav.AttributeValueId = pave.AttributeValueID)
				WHERE av.AttributeTypeId = @AttributeTypeID
			SELECT @OldAttributeValueEntity_Type = ISNULL(@OldAttributeValueEntity_Type,'Product')
			-- current value is blank => old attribute value is dis-associated with the product
			IF ISNULL(@AttributeValue,'') = ''
			BEGIN
				BEGIN TRY
					-- item-level attribute precedence
					-- retain values if current entity type is product and previous entity type is item
					-- dis-associate if current entity type is product and previous entity type is product
					-- dis-associate if current entity type is item irrespective of previous entity type
					IF	(
							@Entity_Type = 'Item' 
							OR 
							-- if current Entity_Type is product and previous Entity_Type is product
							(@Entity_Type = 'Product' AND @OldAttributeValueEntity_Type = 'Product')
						)
					BEGIN
						-- there can be multiple attribute values of same attribute type associated to a product in case of multi-select cvl
						DELETE FROM pave
							FROM dbo.PRFTProductAttributeValueExtension pave
							INNER JOIN dbo.ProductAttributeValue pav 
								ON (pav.ProductID = @ProductID AND pave.ProductId = pav.ProductId AND pave.AttributeValueID = pav.AttributeValueId)
							INNER JOIN dbo.AttributeValue av 
								ON (av.AttributeTypeId = @AttributeTypeID AND pav.AttributeValueID = av.Id)
						DELETE FROM @TabVarDelAttVal
						DELETE FROM pav
							OUTPUT DELETED.* INTO @TabVarDelAttVal
							FROM dbo.ProductAttributeValue pav
							INNER JOIN dbo.AttributeValue av 
								ON (av.AttributeTypeId = @AttributeTypeID AND pav.AttributeValueID = av.Id)
							WHERE pav.ProductID = @ProductID
						-- if no other product of the category is associated to the old attribute values, then delete
						DELETE FROM cav
							FROM dbo.CategoryAttributeValue cav
							INNER JOIN @TabVarDelAttVal dpav ON cav.AttributeValueID = dpav.AttributeValueID
							INNER JOIN dbo.CategoryProduct cp 
								ON (dpav.ProductID = cp.ProductID AND cav.CategoryID = cp.CategoryID)
							LEFT JOIN
								(
									SELECT cp1.CategoryID, pav.AttributeValueID
										FROM dbo.ProductAttributeValue pav
										INNER JOIN dbo.CategoryProduct cp1 ON pav.ProductID = cp1.ProductID
								) oldcav
									ON (cav.CategoryID = oldcav.CategoryID AND cav.AttributeValueID = oldcav.AttributeValueID)
							WHERE oldcav.AttributeValueID IS NULL
						-- if no other attribute values of the attribute type is associated to the category, then delete
						DELETE FROM cat
							FROM dbo.CategoryAttributeType cat
							INNER JOIN	
								(
									SELECT DISTINCT 
											b1.CategoryID,c1.AttributeTypeID
										FROM @TabVarDelAttVal a1
										INNER JOIN dbo.CategoryProduct b1 
											ON (b1.ProductID = @ProductID AND a1.ProductID = b1.ProductID)
										INNER JOIN dbo.AttributeValue c1 
											ON (c1.AttributeTypeId = @AttributeTypeID AND a1.AttributeValueID = c1.ID)
								) delcat
									ON (cat.CategoryID = delcat.CategoryID AND cat.AttributeTypeID = delcat.AttributeTypeID)
							LEFT JOIN
								(
									SELECT DISTINCT 
											a1.CategoryID,a2.AttributeTypeID
										FROM dbo.CategoryAttributeValue a1
										INNER JOIN dbo.AttributeValue a2 
											ON (a2.AttributeTypeId = @AttributeTypeID AND a1.AttributeValueID = a2.Id)
								) oldcat
									ON (cat.CategoryID = oldcat.CategoryID AND cat.AttributeTypeID = oldcat.AttributeTypeID)
							WHERE oldcat.AttributeTypeID IS NULL
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
					-- Log Error for Action Type for Product-Attribute Link
					INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Product - Attribute Linking - PIM Target Entity ID = '+ISNULL(CAST(@Entity_Id AS NVARCHAR(50)),'**NULL**')	
									+'; Entity Type = '+ISNULL(@Entity_Type,'**NULL**')				
									+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
									+'; Attribute Type ID = '+ISNULL(CAST(@AttributeTypeID AS NVARCHAR(100)),'**NULL**')
									+'; Attribute Value = '+ISNULL(@AttributeValue,'**NULL**')
									+'; Attribute Data Type = '+ISNULL(@AttributeDataType,'**NULL**')				
									+'; Attribute Multi-Select = '+ISNULL(@AttributeMultiSelect,'**NULL**')				
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- ISNULL(@AttributeValue,'') = ''
			-- current value is non-blank => create new row in AttributeValue table if new value does not exist
			-- associate new attibute value & dis-associate old attribute value with the product 
			ELSE	-- ISNULL(@AttributeValue,'') <> ''
			BEGIN
				BEGIN TRY
					-- item-level attribute precedence
					-- retain values if current entity type is product and previous entity type is item
					-- add/update if current entity type is product and previous entity type is product
					-- add/update if current entity type is item irrespective of previous entity type
					IF	(
							@Entity_Type = 'Item' 
							OR 
							-- if current Entity_Type is product and previous Entity_Type is product
							(@Entity_Type = 'Product' AND @OldAttributeValueEntity_Type = 'Product')
						)
					BEGIN	-- add/update attribute
						-- dis-associate old attribute value with the product 
						DELETE FROM pave
							FROM dbo.PRFTProductAttributeValueExtension pave
							INNER JOIN dbo.ProductAttributeValue pav 
								ON (pav.ProductID = @ProductID AND pave.ProductId = pav.ProductId AND pave.AttributeValueId = pav.AttributeValueId)
							INNER JOIN dbo.AttributeValue av 
								ON (av.AttributeTypeId = @AttributeTypeID AND pav.AttributeValueID = av.Id)
						DELETE FROM @TabVarDelAttVal
						DELETE FROM pav
							OUTPUT DELETED.* INTO @TabVarDelAttVal
							FROM dbo.ProductAttributeValue pav
							INNER JOIN dbo.AttributeValue av 
								ON (av.AttributeTypeId = @AttributeTypeID AND pav.AttributeValueID = av.Id)
							WHERE pav.ProductID = @ProductID
						-- if no other product of the category is associated to the old attribute values, then delete
						DELETE FROM cav
							FROM dbo.CategoryAttributeValue cav
							INNER JOIN @TabVarDelAttVal dpav ON cav.AttributeValueID = dpav.AttributeValueID
							INNER JOIN dbo.CategoryProduct cp 
								ON (dpav.ProductID = cp.ProductID AND cav.CategoryID = cp.CategoryID)
							LEFT JOIN
								(
									SELECT cp1.CategoryID, pav.AttributeValueID
										FROM dbo.ProductAttributeValue pav
										INNER JOIN dbo.CategoryProduct cp1 ON pav.ProductID = cp1.ProductID
								) oldcav
									ON (cav.CategoryID = oldcav.CategoryID AND cav.AttributeValueID = oldcav.AttributeValueID)
							WHERE oldcav.AttributeValueID IS NULL
						-- if no other attribute values of the attribute type is associated to the category, then delete
						DELETE FROM cat
							FROM dbo.CategoryAttributeType cat
							INNER JOIN	
								(
									SELECT DISTINCT 
											b1.CategoryID,c1.AttributeTypeID
										FROM @TabVarDelAttVal a1
										INNER JOIN dbo.CategoryProduct b1 
											ON (b1.ProductID = @ProductID AND a1.ProductID = b1.ProductID)
										INNER JOIN dbo.AttributeValue c1 
											ON (c1.AttributeTypeId = @AttributeTypeID AND a1.AttributeValueID = c1.ID)
								) delcat
									ON (cat.CategoryID = delcat.CategoryID AND cat.AttributeTypeID = delcat.AttributeTypeID)
							LEFT JOIN
								(
									SELECT DISTINCT 
											a1.CategoryID,a2.AttributeTypeID
										FROM dbo.CategoryAttributeValue a1
										INNER JOIN dbo.AttributeValue a2 
											ON (a2.AttributeTypeId = @AttributeTypeID AND a1.AttributeValueID = a2.Id)
								) oldcat
									ON (cat.CategoryID = oldcat.CategoryID AND cat.AttributeTypeID = oldcat.AttributeTypeID)
							WHERE oldcat.AttributeTypeID IS NULL
						-- associate new attribute value with the product 
						-- handle multi-select cvl data, ~ separated => Red~Blue to be considered as 2 diff values Red and Blue
						IF UPPER(ISNULL(@AttributeMultiSelect,'FALSE')) = 'TRUE'
						BEGIN
							SET @SplitValue = NULL
							DECLARE Cur_MultiSelectValues CURSOR LOCAL FAST_FORWARD FOR
								SELECT [value]
									FROM STRING_SPLIT(@AttributeValue, @separator)
									-- ignore empty values
									WHERE RTRIM([value]) <> ''
							OPEN Cur_MultiSelectValues
							FETCH NEXT FROM Cur_MultiSelectValues INTO @SplitValue
							WHILE @@FETCH_STATUS = 0 
							BEGIN
								-- check whether new value exists for the attribute type
								SET @AttributeValueID = NULL
								SELECT @AttributeValueID = ID
									FROM dbo.AttributeValue
									WHERE AttributeTypeID = @AttributeTypeID
										AND [Value] = @SplitValue
								-- if not exists, create new value for the attribute type
								IF @AttributeValueID IS NULL
								BEGIN
									SELECT @AttributeValueID = NEWID()
									INSERT INTO dbo.AttributeValue
										(
											Id
											,AttributeTypeId
											,[Value]
											,CreatedOn
											,ModifiedOn
										)
										SELECT
											@AttributeValueID
											,@AttributeTypeID
											,@SplitValue
											,@CurrDate
											,@CurrDate
								END
								INSERT INTO dbo.ProductAttributeValue
									(
										ProductID
										,AttributeValueID
									)
									SELECT
										@ProductID
										,@AttributeValueID
								INSERT INTO dbo.PRFTProductAttributeValueExtension
									(
										ProductID
										,AttributeValueID
										,PIMSourceEntityType
									)
									SELECT
										@ProductID
										,@AttributeValueID
										,@Entity_Type
								-- if attribute value of the attribute type is not associated to the category, then associate it
								INSERT INTO dbo.CategoryAttributeValue
									(
										CategoryID
										,AttributeValueID
									)
									SELECT
											cp.CategoryID
											,@AttributeValueID
										FROM dbo.CategoryProduct cp
										LEFT JOIN dbo.CategoryAttributeValue cav
											ON (cav.AttributeValueID = @AttributeValueID AND cp.CategoryId = cav.CategoryId)
										WHERE cp.ProductId = @ProductID
											AND cav.AttributeValueId IS NULL
								-- if attribute type is not associated to the category, then associate it
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
										,cp.CategoryID
										,@AttributeTypeID
										,@CurrDate
										,@CurrDate
									FROM dbo.CategoryProduct cp
									LEFT JOIN dbo.CategoryAttributeType cat
										ON (cat.AttributeTypeID = @AttributeTypeID AND cp.CategoryId = cat.CategoryId)
									WHERE cp.ProductId = @ProductID
										AND cat.AttributeTypeID IS NULL
								FETCH NEXT FROM Cur_MultiSelectValues INTO @SplitValue
							END
							CLOSE Cur_MultiSelectValues
							DEALLOCATE Cur_MultiSelectValues
						END	-- UPPER(ISNULL(@AttributeMultiSelect,'FALSE')) = 'TRUE'
						ELSE	-- UPPER(ISNULL(@AttributeMultiSelect,'FALSE')) = 'FALSE'
						BEGIN	 
							-- check whether new value exists for the attribute type
							SET @AttributeValueID = NULL
							SELECT @AttributeValueID = ID
								FROM dbo.AttributeValue
								WHERE AttributeTypeID = @AttributeTypeID
									AND [Value] = @AttributeValue
							-- if not exists, create new value for the attribute type
							IF @AttributeValueID IS NULL
							BEGIN
								SELECT @AttributeValueID = NEWID()
								INSERT INTO dbo.AttributeValue
									(
										Id
										,AttributeTypeId
										,[Value]
										,CreatedOn
										,ModifiedOn
									)
									SELECT
										@AttributeValueID
										,@AttributeTypeID
										,@AttributeValue
										,@CurrDate
										,@CurrDate
							END
							INSERT INTO dbo.ProductAttributeValue
								(
									ProductID
									,AttributeValueID
								)
								SELECT
									@ProductID
									,@AttributeValueID
							INSERT INTO dbo.PRFTProductAttributeValueExtension
								(
									ProductID
									,AttributeValueID
									,PIMSourceEntityType
								)
								SELECT
									@ProductID
									,@AttributeValueID
									,@Entity_Type
							-- if attribute value of the attribute type is not associated to the category, then associate it
							INSERT INTO dbo.CategoryAttributeValue
								(
									CategoryID
									,AttributeValueID
								)
								SELECT
										cp.CategoryID
										,@AttributeValueID
									FROM dbo.CategoryProduct cp
									LEFT JOIN dbo.CategoryAttributeValue cav
										ON (cav.AttributeValueID = @AttributeValueID AND cp.CategoryId = cav.CategoryId)
									WHERE cp.ProductId = @ProductID
										AND cav.AttributeValueId IS NULL
							-- if attribute type is not associated to the category, then associate it
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
									,cp.CategoryID
									,@AttributeTypeID
									,@CurrDate
									,@CurrDate
								FROM dbo.CategoryProduct cp
								LEFT JOIN dbo.CategoryAttributeType cat
									ON (cat.AttributeTypeID = @AttributeTypeID AND cp.CategoryId = cat.CategoryId)
								WHERE cp.ProductId = @ProductID
									AND cat.AttributeTypeID IS NULL
						END	-- UPPER(ISNULL(@AttributeMultiSelect,'FALSE')) = 'FALSE'
					END	-- add/update attribute
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
					-- Log Error for Action Type for Product-Attribute Link
					INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Product - Attribute Linking - PIM Target Entity ID = '+ISNULL(CAST(@Entity_Id AS NVARCHAR(50)),'**NULL**')	
									+'; Entity Type = '+ISNULL(@Entity_Type,'**NULL**')				
									+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
									+'; Attribute Type ID = '+ISNULL(CAST(@AttributeTypeID AS NVARCHAR(100)),'**NULL**')
									+'; Attribute Value = '+ISNULL(@AttributeValue,'**NULL**')
									+'; Attribute Data Type = '+ISNULL(@AttributeDataType,'**NULL**')				
									+'; Attribute Multi-Select = '+ISNULL(@AttributeMultiSelect,'**NULL**')				
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- ISNULL(@AttributeValue,'') <> ''
		END	-- (@ProductID IS NOT NULL AND @AttributeTypeID IS NOT NULL)
		FETCH NEXT FROM Cur_AttributeValues INTO
			@Entity_Type
			,@Entity_Id
			--,@CategoryID
			,@ProductID
			,@AttributeTypeID
			,@AttributeTypeName
			,@AttributeValue
			,@AttributeDataType
			,@AttributeMultiSelect
	END
	CLOSE Cur_AttributeValues
	DEALLOCATE Cur_AttributeValues
	INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Import Attribute Value data from PIM',GETUTCDATE()
	INSERT INTO #ImportAttributeLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Attribute Types & Values Import from PIM ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportAttributeLog				
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
					,'Attrribute Imort Module'
				FROM #ImportAttributeLog
	END
	IF EXISTS(SELECT 1 FROM #ImportAttributeLog WHERE LogTypeName = 'Error')
	BEGIN
		DROP TABLE #ImportAttributeLog
		RETURN -1	
		
	END
	ELSE
	BEGIN
		DROP TABLE #ImportAttributeLog
		RETURN 0	
	END
END
GO

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
				,CAST(LastModified AS DATETIMEOFFSET) LastModified
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
					,'Category-Product Link Imort Module'
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
					,@ItemNumber = 
						CASE 
							WHEN LEN(ISNULL(ItemNumber,'')) > 50 THEN LEFT(ItemNumber,50) 
							ELSE ItemNumber  
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
									,@ItemNumber = 
										CASE 
											WHEN LEN(ISNULL(ItemNumber,'')) > 50 THEN LEFT(ItemNumber,50) 
											ELSE ItemNumber  
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
							,p.ContentManagerId = NULL
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
								,'Error for Update Item - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
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
				 END				-- Name,ShortDescription,UrlSegment
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
				IF @ProductType = 'style'
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
							,@Name UrlSegment
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
					SELECT	'Info'
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
					INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Update Product'+''''+'s Product Type  - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
									+'; Product Name = '+ISNULL(@ERPNumber,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- ignore & log error for Product Type update
			SELECT @ProductID = p.Id, @ContentManagerID = p.ContentManagerID
				FROM dbo.Product p
				INNER JOIN dbo.PRFTProductExtension pe 
					ON (pe.PIMItemEntityID IS NULL AND p.Id = pe.ProductID)
			BEGIN TRY
				IF @ProductID IS NOT NULL
				BEGIN	-- base product or product with no item associated
					UPDATE dbo.Product
						SET 
							[Name] = @Name
							,ShortDescription = @Name
							,ProductCode = @ERPNumber
							,SKU = @Sku
							,UrlSegment = @Name
							,ERPNumber = @ERPNumber
							,VendorID = @VendorID
							,ModifiedOn = @LastModified
						WHERE Id = @ProductID
					UPDATE dbo.PRFTProductExtension														
						SET
							PIMProductEntityID = @EntityID 
							,ProductCountryofOrigin_Value = @CountryofOrigin 
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
				INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
					SELECT	'Warn'
							,'Error for Update Product - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
								+'; Product Name = '+ISNULL(@ERPNumber,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
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
						,p.ContentManagerId = NULL
						,p.DeactivateOn = todatetimeoffset(cast(dateadd(day,-1,cast(@LastModified as datetime)) as datetime2),datepart(tz,CAST(@LastModified AS DATETIMEOFFSET)))
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
				INSERT INTO #ImportItemLog(LogTypeName,LogMessage,LogDateTime)
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
					SELECT	'Info'
							,'Error for Product - PIM Entity ID = '+CAST(@EntityID AS NVARCHAR(50))
								+'; Product Name = '+ISNULL(@Name,'**NULL**')
								+ '; Error Message = '+@ErrorMessage
							,GETUTCDATE()
			END CATCH
		END	-- @Action <> 'A'/'U'/'D'
		FETCH NEXT FROM Cur_Product INTO 				
			@EntityID									
			,@Name										
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
					,'Product Imort Module'
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
				,d.ModifiedOn = @LastModified
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

ALTER PROCEDURE [dbo].[PRFTImportStyleTraitDelta]
(
	@IntegrationJobId	UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	DECLARE @TabVarDelStyleTraitVal TABLE
		(
			ProductID			UNIQUEIDENTIFIER
			,StyleTraitValueID	UNIQUEIDENTIFIER
		)
	CREATE TABLE #ImportStyleTraitLog	--PRFTImportCategoryLog
			(
				LogKey				INT IDENTITY(1,1)
				,LogTypeName		NVARCHAR(50)	--'Error'/'Info'
				,LogMessage			NVARCHAR(MAX)
				,LogDateTime		DATETIMEOFFSET
			)
	INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Started - Style Traits & Values Import from PIM ----',GETUTCDATE()

	DECLARE @Entity_Id						INT
	DECLARE @ErrorNumber					INT
	DECLARE @ErrorLine						INT
	DECLARE @SortOrder						INT
	DECLARE @MinIndex						INT
	DECLARE @PKey							INT
	DECLARE @ProductID						UNIQUEIDENTIFIER
	DECLARE @StyleTraitID					UNIQUEIDENTIFIER
	DECLARE @StyleTraitValueID				UNIQUEIDENTIFIER
	DECLARE @StyleClassID					UNIQUEIDENTIFIER
	DECLARE @separator						VARCHAR(1) = '~'
	DECLARE @Entity_Type					NVARCHAR(50)
	DECLARE @ErrorProcedure					NVARCHAR(200)
	DECLARE @AttributeName					NVARCHAR(MAX)
	DECLARE @TraitLabel						NVARCHAR(MAX)
	DECLARE @TraitValue						NVARCHAR(MAX)
	DECLARE @ErrorMessage					NVARCHAR(MAX)
	DECLARE @SplitValue						NVARCHAR(MAX)
	DECLARE @StyleTraitList					NVARCHAR(MAX) 
	DECLARE @CurrDate						DATETIMEOFFSET
	SELECT @CurrDate = GETDATE()
	INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Import Style Trait data from PIM',GETUTCDATE()
	-- get columns that are defined as Style Traits in Insite
	SELECT @StyleTraitList = Value 
		FROM SystemSetting WHERE Name='PIM_VariantAttributeName'
	CREATE TABLE #ValidTraitList(PKey INT IDENTITY(1,1),TraitColName NVARCHAR(MAX))
	INSERT INTO #ValidTraitList(TraitColName)
		SELECT [value]
			FROM STRING_SPLIT(@StyleTraitList, ',')
	-- Get Style Traits & Values from Attributes
	SELECT 
			pa.Entity_Type
			,pa.[Entity_Id]
			,list.PKey
			,pa.AttributeName
			,RIGHT(pa.AttributeName,LEN(pa.AttributeName)-4) TraitName
			,CASE
				-- Label not in PIM or Label same as columnname => Label will be same as Attribute Name derived above
				WHEN (pa.AttributeName = pam.AttributeLabel OR ISNULL(pam.AttributeLabel,'') = '') THEN RIGHT(pa.AttributeName,LEN(pa.AttributeName)-4)
				ELSE pam.AttributeLabel
			 END TraitLabel
			-- Trait values can't be multi-select
			,REPLACE(pa.AttributeValue,'~',' / ') TraitValue
			,prod.PIMProductEntityID
			,prod.ProductID
			,prod.SortOrder
			,baseprod.BaseProductID
			,baseprod.StyleClassID
		INTO #StyleTraitsAndValues
		FROM dbo.PIMAttribute pa
		INNER JOIN #ValidTraitList list ON pa.AttributeName = list.TraitColName
		INNER JOIN PIMAttributeModel pam ON pa.AttributeName = pam.AttributeName
		LEFT JOIN 
			(
				SELECT pe.PIMProductEntityID,pe.PIMItemEntityID,p.Id ProductID,p.StyleParentId,ISNULL(p.SortOrder,0) SortOrder
					FROM dbo.PRFTProductExtension pe 
					INNER JOIN dbo.Product p ON pe.ProductID = p.Id 
					WHERE pe.PIMProductType = 'style' 
						AND pe.PIMItemEntityID IS NOT NULL 
			) prod ON pa.[Entity_Id] = prod.PIMItemEntityID
		LEFT JOIN 
			(
				SELECT pe.PIMProductEntityID,pe.PIMItemEntityID,p.Id BaseProductID,p.StyleClassId
					FROM dbo.PRFTProductExtension pe 
					INNER JOIN dbo.Product p ON pe.ProductID = p.Id 
					WHERE pe.PIMProductType = 'style' 
						AND pe.PIMItemEntityID IS NULL 
			) baseprod ON prod.StyleParentId = baseprod.BaseProductID 
		WHERE pa.Entity_Type = 'Item'
		ORDER BY baseprod.StyleClassID,list.PKey,pa.[Entity_Id]
	DROP TABLE #ValidTraitList
	-- for Style Traits
	DECLARE Cur_StyleTraits CURSOR LOCAL FAST_FORWARD FOR
		SELECT DISTINCT
				PKey
				,AttributeName
				,TraitLabel
				,StyleClassID
			FROM #StyleTraitsAndValues
			WHERE StyleClassID IS NOT NULL
	OPEN Cur_StyleTraits
	FETCH NEXT FROM Cur_StyleTraits INTO  
		@PKey
		,@AttributeName
		,@TraitLabel
		,@StyleClassID
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @StyleTraitID = NULL
		SELECT @StyleTraitID = Id
			FROM dbo.StyleTrait
			WHERE StyleClassID = @StyleClassID
				AND [Description] = @AttributeName
		BEGIN TRY
			IF @StyleTraitID IS NULL
			BEGIN
				INSERT INTO dbo.StyleTrait
					(
						Id
						,StyleClassId
						,Name
						,SortOrder
						,[Description]
						,CreatedOn
						,ModifiedOn
					)
					SELECT
						NEWID()
						,@StyleClassID
						,@TraitLabel
						,@PKey
						,@AttributeName
						,@CurrDate
						,@CurrDate
			END	-- @StyleTraitID IS NULL
			ELSE
			BEGIN	-- @StyleTraitID IS NOT NULL
				UPDATE dbo.StyleTrait
					SET
						Name = @TraitLabel
						,SortOrder = @PKey
						,ModifiedOn = @CurrDate
					WHERE Id = @StyleTraitID
			END	-- @StyleTraitID IS NOT NULL
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
			-- Log Error for Add/Update Style Trait
			INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
				SELECT	'Warn'
						,'Error while '
							+CASE
								WHEN @StyleTraitID IS NULL THEN 'Adding'
								ELSE 'Updating'
							 END
							+' Style Trait for - '+ISNULL(@AttributeName,'**NULL**')	
							+'; Style Class ID = '+ISNULL(CAST(@StyleClassID AS NVARCHAR(100)),'**NULL**')				
							+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
							+ '; Error Message = '+@ErrorMessage
						,GETUTCDATE()
		END CATCH
		FETCH NEXT FROM Cur_StyleTraits INTO  
			@PKey
			,@AttributeName
			,@TraitLabel
			,@StyleClassID
	END	
	CLOSE Cur_StyleTraits
	DEALLOCATE Cur_StyleTraits
	INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Import Style Trait data from PIM',GETUTCDATE()
	-- Trait values length could not be > 255
	UPDATE #StyleTraitsAndValues SET TraitValue = LEFT(TraitValue,255)
		WHERE LEN(ISNULL(TraitValue,'')) > 255
	INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Started - Import Style Trait Values data from PIM',GETUTCDATE()
	-- for Style Trait Values
	DECLARE Cur_StyleTraitValues CURSOR LOCAL FAST_FORWARD FOR
		SELECT
				stav.[Entity_Id]
				,stav.ProductID
				,stav.SortOrder
				,stav.PKey
				,stav.AttributeName
				,ISNULL(stav.TraitValue,'')
				,st.Id StyleTraitId
				,ISNULL(oth.MinIndex,0) MinIndex
			FROM #StyleTraitsAndValues stav
			LEFT JOIN dbo.StyleTrait st 
				ON (
						ISNULL(CAST(stav.StyleClassID AS NVARCHAR(100)),'') = ISNULL(CAST(st.StyleClassId AS NVARCHAR(100)),'') 
						AND stav.AttributeName = st.[Description]
					)
			LEFT JOIN 
				(
					SELECT pe.PIMProductEntityID,MIN(p.SortOrder) MinIndex
						FROM dbo.Product p
						INNER JOIN dbo.PRFTProductExtension pe 
							ON (pe.PIMProductType = 'style' AND pe.PIMItemEntityID IS NOT NULL AND p.Id = pe.ProductID)
						GROUP BY pe.PIMProductEntityID
				) oth ON ISNULL(stav.PIMProductEntityID,-1) = oth.PIMProductEntityID
	OPEN Cur_StyleTraitValues
	FETCH NEXT FROM Cur_StyleTraitValues INTO  
		@Entity_Id
		,@ProductID
		,@SortOrder
		,@PKey
		,@AttributeName
		,@TraitValue
		,@StyleTraitId
		,@MinIndex
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF (@ProductID IS NULL OR @StyleTraitId IS NULL)
		BEGIN
			IF	(
					@ProductID IS NOT NULL 
					AND EXISTS (SELECT 1 FROM dbo.PRFTProductExtension WHERE PIMProductType = 'style')
				)
			BEGIN
				BEGIN TRY
					RAISERROR ('Custom Error - Product and/or Style Trait does not exist in Insite', -- Message text.  
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
					-- Log Error for Blank Product/Attribute Type IDs Link
					INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Product - Style Trait Value Linking - PIM Target Entity ID = '+ISNULL(CAST(@Entity_Id AS NVARCHAR(50)),'**NULL**')	
									+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
									+'; Style Trait ID = '+ISNULL(CAST(@StyleTraitId AS NVARCHAR(100)),'**NULL**')
									+'; Style Trait Description = '+ISNULL(@AttributeName,'**NULL**')				
									+'; Style Trait Value = '+ISNULL(@TraitValue,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END
		END	-- (@ProductID IS NULL OR @StyleTraitId IS NULL)
		ELSE	
		BEGIN	-- (@ProductID IS NOT NULL AND @StyleTraitId IS NOT NULL)
			-- current value is blank => old trait value is dis-associated with the product
			IF ISNULL(@TraitValue,'') = ''
			BEGIN
				BEGIN TRY
					DELETE FROM @TabVarDelStyleTraitVal
					DELETE FROM stvp
						OUTPUT DELETED.* INTO @TabVarDelStyleTraitVal
						FROM dbo.StyleTraitValueProduct stvp
						INNER JOIN dbo.StyleTraitValue stv 
							ON (stv.StyleTraitId = @StyleTraitId AND stvp.StyleTraitValueId = stv.Id)
						WHERE stvp.ProductID = @ProductID
					-- if no other product of the style trait is associated to the old trait values, then delete
					DELETE FROM stv
						FROM dbo.StyleTraitValue stv
						INNER JOIN @TabVarDelStyleTraitVal dpav ON stv.Id = dpav.StyleTraitValueID
						WHERE NOT EXISTS
							(SELECT 1 FROM dbo.StyleTraitValueProduct WHERE StyleTraitValueID = stv.Id)
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
					-- Log Error for Blank Product/Attribute Type IDs Link
					INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Product - Style Trait Value Linking - PIM Target Entity ID = '+ISNULL(CAST(@Entity_Id AS NVARCHAR(50)),'**NULL**')	
									+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
									+'; Style Trait ID = '+ISNULL(CAST(@StyleTraitId AS NVARCHAR(100)),'**NULL**')
									+'; Style Trait Description = '+ISNULL(@AttributeName,'**NULL**')				
									+'; Style Trait Value = '+ISNULL(@TraitValue,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- ISNULL(@TraitValue,'') = ''
			-- current value is non-blank => create new row in StyleTraitValue table if new value does not exist
			-- associate new style trait value & dis-associate old style trait value with the product 
			ELSE	-- ISNULL(@TraitValue,'') <> ''
			BEGIN
				BEGIN TRY
					-- dis-associate old style trait value with the product 
					DELETE FROM @TabVarDelStyleTraitVal
					DELETE FROM stvp
						OUTPUT DELETED.* INTO @TabVarDelStyleTraitVal
						FROM dbo.StyleTraitValueProduct stvp
						INNER JOIN dbo.StyleTraitValue stv 
							ON (stv.Value <> @TraitValue AND stv.StyleTraitId = @StyleTraitId AND stvp.StyleTraitValueId = stv.Id)
						WHERE stvp.ProductID = @ProductID
					-- if no other product of the style trait is associated to the old trait values, then delete
					DELETE FROM stv
						FROM dbo.StyleTraitValue stv
						INNER JOIN @TabVarDelStyleTraitVal dpav ON stv.Id = dpav.StyleTraitValueID
						WHERE NOT EXISTS
							(SELECT 1 FROM dbo.StyleTraitValueProduct WHERE StyleTraitValueID = stv.Id)
					-- check whether new value exists for the style trait
					SET @StyleTraitValueID = NULL
					SELECT @StyleTraitValueID = ID
						FROM dbo.StyleTraitValue
						WHERE StyleTraitId = @StyleTraitId
							AND [Value] = @TraitValue
					-- if not exists, create new value for the style trait
					IF @StyleTraitValueID IS NULL
					BEGIN
						SELECT @StyleTraitValueID = NEWID()
						INSERT INTO dbo.StyleTraitValue
							(
								Id
								,StyleTraitId
								,[Value]
								,[Description]
								,CreatedOn
								,ModifiedOn
							)
							SELECT
								@StyleTraitValueID
								,@StyleTraitId
								,@TraitValue
								,@TraitValue
								,@CurrDate
								,@CurrDate
					END	-- @StyleTraitValueID IS NULL
					-- set the Trait Value for Product with least Sort Order as default
					IF @SortOrder <= @MinIndex
					BEGIN
						UPDATE dbo.StyleTraitValue 
							SET IsDefault = 
								CASE
									WHEN Id = @StyleTraitValueID THEN 1
									ELSE 0
								END
							WHERE StyleTraitId = @StyleTraitId
					END
					IF NOT EXISTS
						(
							SELECT 1 FROM dbo.StyleTraitValueProduct
								WHERE ProductID = @ProductID
									AND StyleTraitValueID = @StyleTraitValueID
						)
					BEGIN
						INSERT INTO dbo.StyleTraitValueProduct
							(
								ProductID
								,StyleTraitValueID
							)
							SELECT
								@ProductID
								,@StyleTraitValueID
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
					-- Log Error for Blank Product/Attribute Type IDs Link
					INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
						SELECT	'Warn'
								,'Error for Product - Style Trait Value Linking - PIM Target Entity ID = '+ISNULL(CAST(@Entity_Id AS NVARCHAR(50)),'**NULL**')	
									+'; Product ID = '+ISNULL(CAST(@ProductID AS NVARCHAR(100)),'**NULL**')				
									+'; Style Trait ID = '+ISNULL(CAST(@StyleTraitId AS NVARCHAR(100)),'**NULL**')
									+'; Style Trait Description = '+ISNULL(@AttributeName,'**NULL**')				
									+'; Style Trait Value = '+ISNULL(@TraitValue,'**NULL**')
									+ '; Error Message = '+@ErrorMessage
								,GETUTCDATE()
				END CATCH
			END	-- ISNULL(@TraitValue,'') <> ''
		END	-- (@ProductID IS NOT NULL AND @StyleTraitId IS NOT NULL)
		FETCH NEXT FROM Cur_StyleTraitValues INTO  
			@Entity_Id
			,@ProductID
			,@SortOrder
			,@PKey
			,@AttributeName
			,@TraitValue
			,@StyleTraitId
			,@MinIndex
	END	
	CLOSE Cur_StyleTraitValues
	DEALLOCATE Cur_StyleTraitValues
	DROP TABLE #StyleTraitsAndValues
	INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','Finished - Import Style Trait Values data from PIM',GETUTCDATE()
	INSERT INTO #ImportStyleTraitLog(LogTypeName,LogMessage,LogDateTime)
		SELECT 'Info','---- Finished - Style Traits & Values Import from PIM ----',GETUTCDATE()
	IF @IntegrationJobId IS NULL
			SELECT * FROM #ImportStyleTraitLog				
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
					,'Style Trait Imort Module'
				FROM #ImportStyleTraitLog
	END
	IF EXISTS(SELECT 1 FROM #ImportStyleTraitLog WHERE LogTypeName = 'Error')
	BEGIN
		DROP TABLE #ImportStyleTraitLog
		RETURN -1	
		
	END
	ELSE
	BEGIN
		DROP TABLE #ImportStyleTraitLog
		RETURN 0	
	END
END

GO
