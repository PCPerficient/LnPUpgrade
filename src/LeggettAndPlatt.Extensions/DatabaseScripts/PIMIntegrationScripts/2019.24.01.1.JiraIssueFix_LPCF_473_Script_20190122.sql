BEGIN
	SELECT
			tv.Id,tv.[Value],tv.SortOrder,MIN(p.SortOrder) NewSortOrder,tv.StyleTraitId,tr.[Name],tr.StyleClassId
		INTO #NewSortOrder
		FROM dbo.StyleTraitValue tv
		INNER JOIN dbo.StyleTrait tr ON tv.StyleTraitId = tr.Id
		INNER JOIN dbo.StyleTraitValueProduct tvp ON tv.Id = tvp.StyleTraitValueId
		INNER JOIN dbo.Product p ON tvp.ProductId = p.Id
		GROUP BY tr.StyleClassId,tv.StyleTraitId,tr.[Name],tv.Id,tv.[Value],tv.SortOrder
		ORDER BY tr.StyleClassId,tr.[Name],MIN(p.SortOrder)
	UPDATE stv
		SET stv.SortOrder = nu.NewSortOrder
		FROM dbo.StyleTraitValue stv
		INNER JOIN	
			(
				SELECT DISTINCT Id,NewSortOrder
					FROM #NewSortOrder
			) nu ON stv.Id = nu.Id
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
								,SortOrder
								,[Description]
								,CreatedOn
								,ModifiedOn
							)
							SELECT
								@StyleTraitValueID
								,@StyleTraitId
								,@TraitValue
								,@SortOrder
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
					,'Style Trait Import Module'
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
