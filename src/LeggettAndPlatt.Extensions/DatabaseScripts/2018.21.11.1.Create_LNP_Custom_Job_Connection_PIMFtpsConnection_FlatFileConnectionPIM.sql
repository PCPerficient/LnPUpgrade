IF((SELECT COUNT(1) FROM [dbo].[IntegrationConnection] WHERE Name='PIMFtpsConnection')=0)
BEGIN
INSERT INTO [dbo].[IntegrationConnection]
           ([Id]
           ,[Name]
           ,[TypeName]
           ,[DataSource]
           ,[RunsOn]
           ,[DebuggingEnabled]
           ,[Delimiter]
           ,[Url]
           ,[LogOn]
           ,[Password]
           ,[ConnectionString]
           ,[ArchiveFolder]
           ,[ArchiveRetentionDays]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[IntegratedSecurity]
           ,[SystemNumber]
           ,[Client]
           ,[Language]
           ,[ConnectionsLimit]
           ,[ConnectionTimeout]
           ,[AppServerHost]
           ,[AppServerService]
           ,[MessageServerHost]
           ,[MessageServerService]
           ,[GatewayHost]
           ,[GatewayService]
           ,[SystemId]
           ,[SystemIds]
           ,[LogonGroup]
           ,[SourceServerTimeZone])
     VALUES
           (NEWID()
           ,'PIMFtpsConnection'
           ,'ApiEndpoint'
           ,''
           ,''
           ,1
           ,','
           ,'12.51.139.190:990'
           ,'lpudigitalFTPTest'
           ,'fJte+3UGt8P89kCjli8MJA=='
           ,''
           ,''
           ,30
           ,GETUTCDATE()
           ,'admin_admin'
			,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,'Central Standard Time')
END

IF((SELECT COUNT(1) FROM [dbo].[IntegrationConnection] WHERE Name='FlatFileConnectionPIM')=0)
BEGIN
INSERT INTO [dbo].[IntegrationConnection]
           ([Id]
           ,[Name]
           ,[TypeName]
           ,[DataSource]
           ,[RunsOn]
           ,[DebuggingEnabled]
           ,[Delimiter]
           ,[Url]
           ,[LogOn]
           ,[Password]
           ,[ConnectionString]
           ,[ArchiveFolder]
           ,[ArchiveRetentionDays]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[IntegratedSecurity]
           ,[SystemNumber]
           ,[Client]
           ,[Language]
           ,[ConnectionsLimit]
           ,[ConnectionTimeout]
           ,[AppServerHost]
           ,[AppServerService]
           ,[MessageServerHost]
           ,[MessageServerService]
           ,[GatewayHost]
           ,[GatewayService]
           ,[SystemId]
           ,[SystemIds]
           ,[LogonGroup]
           ,[SourceServerTimeZone])
     VALUES
           (NEWID()
           ,'FlatFileConnectionPIM'
           ,'FlatFile'
           ,''
           ,''
           ,1
           ,','
           ,''
           ,''
           ,''
           ,''
           ,''
           ,30
           ,GETUTCDATE()
           ,'admin_admin'
			,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,'Central Standard Time')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import')=0)
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
           ,(SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnectionPIM')
           ,'LNP PIM Files Import'
           ,'Importing PIM Files to TEMP Tables'
           ,'Import'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'CustomFlatFile'
           ,'BulkInsertPIMTables'
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





IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Link' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,7
           ,'Link'
           ,'PIMLink'
           ,NULL
           ,''
           ,'Id,LinkTypeId,SourceEntityId,TargetEntityId,Index,Inactive,LinkEntityId,Action'
           ,'Link.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Channel' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,2
           ,'Channel'
           ,'PIMChannel'
           ,NULL
           ,''
           ,'EntityId,ChannelName,ChannelPublished,DateCreated,LastModified,Action,FieldsUpdated'
           ,'Channel.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='ChannelNode' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,3
           ,'ChannelNode'
           ,'PIMChannelNode'
           ,NULL
           ,''
           ,'EntityId,ChannelNodeID,ChannelNodeName,ChannelNodeDescription,ChannelNodeIsActive,ChannelNodeMetaDescription,ChannelNodeMetaKeywords,ChannelNodeMetaTitle,DateCreated,LastModified,Action,FieldsUpdated'
           ,'ChannelNode.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Item' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,4
           ,'Item'
           ,'PIMItem'
           ,NULL
           ,''
           ,'EntityId,ItemSKUStockNumber,ItemModel,ItemNumber,ItemName,ItemShortProductDescription,ItemRetailCategory,ItemRetailCategory_Value,ItemSizeName,ItemSizeName_Value,ItemQuickShipAvailability,ItemQuickShipAvailability_Value,ItemExternalIDType,ItemUPCGTINorEAN,ItemLongProductDescription,ItemFamilyGrouping,ItemWoodFinish,ItemWoodFinish_Value,ItemWoodType,ItemWoodType_Value,ItemMetalFinish,ItemMetalFinish_Value,ItemMetalType,ItemMetalType_Value,ItemFabricFinish,ItemFabricFinish_Value,ItemFabricType,ItemFabricType_Value,ItemColorName,ItemColorName_Value,ItemFootType,ItemFootType_Value,ItemSleepingPosition,ItemSleepingPosition_Value,ItemStyleCategory,ItemStyleCategory_Value,ItemPieceperMasterCarton,ItemNoOfItemsPerUnit,ItemAssembledLengthinches,ItemAssembledWidthinches,ItemAssembledHeightDepthinches,ItemProductWeightpounds,ItemTotalCube,ItemFreightClass,ItemShipping,ItemShipping_Value,ItemBoxComponentDescription,ItemBoxPackageLength,ItemBoxPackageWidth,ItemBoxPackageHeight,ItemBoxPackageLxWxH,ItemIsAssemblyRequired,ItemIsAssemblyRequired_Value,ItemShipsinMultipleBoxes,ItemShipsinMultipleBoxes_Value,ItemBoxPackageWeight,ItemBoxCuFt,ItemBoxGirth,ItemSeatSize,ItemSeatMaterial,ItemSeatMaterial_Value,ItemSeatStyle,ItemSeatStyle_Value,ItemFootrestHeight,ItemWeightCapacity,ItemContainerMinimumperSKU,ItemContainer20foot,ItemContainer40foot,ItemCompatibility,ItemItemParentSKU,ItemPriceDealer,ItemBulletFeature1,ItemBulletFeature2,ItemBulletFeature3,ItemBulletFeature4,ItemBulletFeature5,ItemBulletFeature6,ItemBulletFeature7,ItemBulletFeature8,ItemBulletFeature9,ItemPriceDropshipFreight,ItemPriceQualified,ItemIMAPPrice,ItemPriceeCommerce,ItemPriceContainer,ItemPromoIMAP,ItemMSRP,ItemAMPPageTitle,ItemAMPPageOrder,ItemAMPItemOrder,ItemAMPItemNumber,ItemAMPProductID,ItemAMPItemNotes,ItemAMPSystemUPC,ItemAMPItemName,ItemAMPPhotoMainSTAGED,ItemAMPPhotoMain,ItemAMPPhotoSecondary,ItemAMPVideoHyperlink1,ItemAMPVideoHyperlink2,ItemAMPVideoHyperlink3,ItemAMPDocuments,ItemAMPMarketIntroductions,ItemAMPNewProducts,ItemAMPBedroomFurniture,ItemAMPAdjustableBases,ItemAMPStoolsandTables,ItemAMPBedSupport,ItemAMPTextiles,ItemAMPPOP,ItemAMPSubCategories,ItemAMPExclusives,ItemAMPMonthlyCloseout,ItemAMPCategory,ItemSwivelRange,ItemContainerPortofDischarge,ItemContainerLeadTimetoCHI,ItemNMFCNumber,ItemAMPProductAvailability,ItemAMPRetailAvailability,ItemAMPShipping,ItemSellable,ItemSellable_Value,ItemPackagedForReship,ItemPackagedForReship_Value,ItemSKUsIncluded,ItemVideoFile1URL,ItemVideoFile2URL,ItemVideoFile3URL,ItemVideoFile4URL,ItemBranch,ItemBranch_Value,ItemLegalEntity,ItemLegalEntity_Value,ItemTaxAreaID,ItemTaxAreaID_Value,DateCreated,LastModified,Action,FieldsUpdated'
           ,'Item.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Product' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,5
           ,'Product'
           ,'PIMProduct'
           ,NULL
           ,''
           ,'EntityId,ProductID,ProductRomanceCopy,ProductManufacturerName,ProductCountryofOrigin,ProductCountryofOrigin_Value,ProductContainerVendorCode,ProductIsthisavariationitem,ProductIsthisavariationitem_Value,ProductVariationThemeName,ProductVariationThemeName_Value,ProductMaterials,ProductMaterials_Value,ProductFinishes,ProductFinishes_Value,ProductWarranty,ProductWarranty_Value,ProductNotes,ProductReleaseDate,DateCreated,LastModified,Action,FieldsUpdated'
           ,'Product.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Resource' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,6
           ,'Resource'
           ,'PIMResource'
           ,NULL
           ,''
           ,'EntityId,ResourceName,ResourceDescription,ResourceMimeType,ResourceFilename,ResourceFileId,ResourceType,ResourceType_Value,ResourceImageType,ResourceImageType_Value,ResourceURL,DateCreated,LastModified,Action,FieldsUpdated'
           ,'Resource.csv'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END



IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='DownloadFilesFromFTPS' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,1
           ,'DownloadFilesFromFTPS'
           ,''
           ,(select Id from dbo.IntegrationConnection where name = 'PIMFtpsConnection')
           ,'DownloadFilesFromFtpsPIM'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'')
END




IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='MovePIMFoldersToArchiveLocation' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP PIM Files Import'))=0)
BEGIN

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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,8
           ,'MovePIMFoldersToArchiveLocation'
           ,''
           ,NULL
           ,'MovePIMFoldersToArchiveLocation'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'')
END



IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionParameter] WHERE Name='FTPSRemoteFolderPath')=0)
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
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP PIM Files Import')
           ,0
           ,'String'
           ,'/LPPMCOutbound/B2B/DailyDelta/'
           ,''
           ,'FTPSRemoteFolderPath'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin');
END
