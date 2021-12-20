
/****** Object:  Table [dbo].[PIMResource]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMResource]
GO
/****** Object:  Table [dbo].[PIMProduct]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMProduct]
GO
/****** Object:  Table [dbo].[PIMLink]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMLink]
GO
/****** Object:  Table [dbo].[PIMItem]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMItem]
GO
/****** Object:  Table [dbo].[PIMCVLData]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMCVLData]
GO
/****** Object:  Table [dbo].[PIMChannelNode]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMChannelNode]
GO
/****** Object:  Table [dbo].[PIMChannel]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMChannel]
GO
/****** Object:  Table [dbo].[PIMAttributeModel]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMAttributeModel]
GO
/****** Object:  Table [dbo].[PIMAttribute]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMAttribute]
GO
/****** Object:  Table [dbo].[PIMChannelNode_Locale]    Script Date: 12/4/2018 5:48:28 PM ******/
DROP TABLE IF EXISTS [dbo].[PIMChannelNode_Locale]
GO

/****** Object:  Table [dbo].[PIMAttribute]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMAttribute]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMAttribute](
	[Entity_Type] [nvarchar](max) NULL,
	[Entity_Id] [nvarchar](max) NULL,
	[AttributeName] [nvarchar](max) NULL,
	[AttributeValue] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMAttributeModel]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMAttributeModel]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMAttributeModel](
	[Entity_Type] [nvarchar](max) NULL,
	[AttributeName] [nvarchar](max) NULL,
	[AttributeLabel] [nvarchar](max) NULL,
	[AttributeDataType] [nvarchar](max) NULL,
	[AttributeMultiSelect] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMChannel]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMChannel]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMChannel](
	[EntityId] [nvarchar](max) NULL,
	[ChannelName] [nvarchar](max) NULL,
	[ChannelPublished] [nvarchar](max) NULL,
	[DateCreated] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[Action] [nvarchar](max) NULL,
	[FieldsUpdated] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMChannelNode]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMChannelNode]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMChannelNode](
	[EntityId] [nvarchar](max) NULL,
	[ChannelNodeID] [nvarchar](max) NULL,
	[ChannelNodeName] [nvarchar](max) NULL,
	[ChannelNodeDescription] [nvarchar](max) NULL,
	[ChannelNodeIsActive] [nvarchar](max) NULL,
	[ChannelNodeMetaDescription] [nvarchar](max) NULL,
	[ChannelNodeMetaKeywords] [nvarchar](max) NULL,
	[ChannelNodeMetaTitle] [nvarchar](max) NULL,
	[DateCreated] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[Action] [nvarchar](max) NULL,
	[FieldsUpdated] [nvarchar](max) NULL
) 
END

GO
/****** Object:  Table [dbo].[PIMCVLData]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMCVLData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMCVLData](
	[CvlId] [nvarchar](max) NULL,
	[DataType] [nvarchar](max) NULL,
	[CvlKeyId] [nvarchar](max) NULL,
	[Key] [nvarchar](max) NULL,
	[Value] [nvarchar](max) NULL,
	[Index] [nvarchar](max) NULL,
	[ParentKey] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[DateCreated] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMItem]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMItem](
	[EntityId] [nvarchar](max) NULL,
	[ItemSKUStockNumber] [nvarchar](max) NULL,
	[ItemModel] [nvarchar](max) NULL,
	[ItemNumber] [nvarchar](max) NULL,
	[ItemName] [nvarchar](max) NULL,
	[ItemShortProductDescription] [nvarchar](max) NULL,
	[ItemRetailCategory] [nvarchar](max) NULL,
	[ItemRetailCategory_Value] [nvarchar](max) NULL,
	[ItemQuickShipAvailability] [nvarchar](max) NULL,
	[ItemQuickShipAvailability_Value] [nvarchar](max) NULL,
	[ItemExternalIDType] [nvarchar](max) NULL,
	[ItemUPCGTINorEAN] [nvarchar](max) NULL,
	[ItemLongProductDescription] [nvarchar](max) NULL,
	[ItemFamilyGrouping] [nvarchar](max) NULL,
	[ItemStyleCategory] [nvarchar](max) NULL,
	[ItemStyleCategory_Value] [nvarchar](max) NULL,
	[ItemPieceperMasterCarton] [nvarchar](max) NULL,
	[ItemNoOfItemsPerUnit] [nvarchar](max) NULL,
	[ItemAssembledLengthinches] [nvarchar](max) NULL,
	[ItemAssembledWidthinches] [nvarchar](max) NULL,
	[ItemAssembledHeightDepthinches] [nvarchar](max) NULL,
	[ItemProductWeightpounds] [nvarchar](max) NULL,
	[ItemTotalCube] [nvarchar](max) NULL,
	[ItemFreightClass] [nvarchar](max) NULL,
	[ItemShipping] [nvarchar](max) NULL,
	[ItemShipping_Value] [nvarchar](max) NULL,
	[ItemBoxComponentDescription] [nvarchar](max) NULL,
	[ItemBoxPackageLength] [nvarchar](max) NULL,
	[ItemBoxPackageWidth] [nvarchar](max) NULL,
	[ItemBoxPackageHeight] [nvarchar](max) NULL,
	[ItemBoxPackageLxWxH] [nvarchar](max) NULL,
	[ItemIsAssemblyRequired] [nvarchar](max) NULL,
	[ItemIsAssemblyRequired_Value] [nvarchar](max) NULL,
	[ItemShipsinMultipleBoxes] [nvarchar](max) NULL,
	[ItemShipsinMultipleBoxes_Value] [nvarchar](max) NULL,
	[ItemBoxPackageWeight] [nvarchar](max) NULL,
	[ItemBoxCuFt] [nvarchar](max) NULL,
	[ItemBoxGirth] [nvarchar](max) NULL,
	[ItemWeightCapacity] [nvarchar](max) NULL,
	[ItemContainerMinimumperSKU] [nvarchar](max) NULL,
	[ItemContainer20foot] [nvarchar](max) NULL,
	[ItemContainer40foot] [nvarchar](max) NULL,
	[ItemCompatibility] [nvarchar](max) NULL,
	[ItemItemParentSKU] [nvarchar](max) NULL,
	[ItemPriceDealer] [nvarchar](max) NULL,
	[ItemBulletFeature1] [nvarchar](max) NULL,
	[ItemBulletFeature2] [nvarchar](max) NULL,
	[ItemBulletFeature3] [nvarchar](max) NULL,
	[ItemBulletFeature4] [nvarchar](max) NULL,
	[ItemBulletFeature5] [nvarchar](max) NULL,
	[ItemBulletFeature6] [nvarchar](max) NULL,
	[ItemBulletFeature7] [nvarchar](max) NULL,
	[ItemBulletFeature8] [nvarchar](max) NULL,
	[ItemBulletFeature9] [nvarchar](max) NULL,
	[ItemPriceDropshipFreight] [nvarchar](max) NULL,
	[ItemPriceQualified] [nvarchar](max) NULL,
	[ItemIMAPPrice] [nvarchar](max) NULL,
	[ItemPriceeCommerce] [nvarchar](max) NULL,
	[ItemPriceContainer] [nvarchar](max) NULL,
	[ItemPromoIMAP] [nvarchar](max) NULL,
	[ItemAMPPageTitle] [nvarchar](max) NULL,
	[ItemAMPPageOrder] [nvarchar](max) NULL,
	[ItemAMPItemOrder] [nvarchar](max) NULL,
	[ItemAMPItemNumber] [nvarchar](max) NULL,
	[ItemAMPProductID] [nvarchar](max) NULL,
	[ItemAMPItemNotes] [nvarchar](max) NULL,
	[ItemAMPSystemUPC] [nvarchar](max) NULL,
	[ItemAMPItemName] [nvarchar](max) NULL,
	[ItemAMPPhotoMainSTAGED] [nvarchar](max) NULL,
	[ItemAMPPhotoMain] [nvarchar](max) NULL,
	[ItemAMPPhotoSecondary] [nvarchar](max) NULL,
	[ItemAMPVideoHyperlink1] [nvarchar](max) NULL,
	[ItemAMPVideoHyperlink2] [nvarchar](max) NULL,
	[ItemAMPVideoHyperlink3] [nvarchar](max) NULL,
	[ItemAMPDocuments] [nvarchar](max) NULL,
	[ItemAMPMarketIntroductions] [nvarchar](max) NULL,
	[ItemAMPNewProducts] [nvarchar](max) NULL,
	[ItemAMPBedroomFurniture] [nvarchar](max) NULL,
	[ItemAMPAdjustableBases] [nvarchar](max) NULL,
	[ItemAMPStoolsandTables] [nvarchar](max) NULL,
	[ItemAMPBedSupport] [nvarchar](max) NULL,
	[ItemAMPTextiles] [nvarchar](max) NULL,
	[ItemAMPPOP] [nvarchar](max) NULL,
	[ItemAMPSubCategories] [nvarchar](max) NULL,
	[ItemAMPExclusives] [nvarchar](max) NULL,
	[ItemAMPMonthlyCloseout] [nvarchar](max) NULL,
	[ItemAMPCategory] [nvarchar](max) NULL,
	[ItemSwivelRange] [nvarchar](max) NULL,
	[ItemContainerPortofDischarge] [nvarchar](max) NULL,
	[ItemContainerLeadTimetoCHI] [nvarchar](max) NULL,
	[ItemNMFCNumber] [nvarchar](max) NULL,
	[ItemAMPProductAvailability] [nvarchar](max) NULL,
	[ItemAMPRetailAvailability] [nvarchar](max) NULL,
	[ItemAMPShipping] [nvarchar](max) NULL,
	[ItemSellable] [nvarchar](max) NULL,
	[ItemSellable_Value] [nvarchar](max) NULL,
	[ItemPackagedForReship] [nvarchar](max) NULL,
	[ItemPackagedForReship_Value] [nvarchar](max) NULL,
	[ItemSKUsIncluded] [nvarchar](max) NULL,
	[ItemVideoFile1URL] [nvarchar](max) NULL,
	[ItemVideoFile2URL] [nvarchar](max) NULL,
	[ItemVideoFile3URL] [nvarchar](max) NULL,
	[ItemVideoFile4URL] [nvarchar](max) NULL,
	[ItemBranch] [nvarchar](max) NULL,
	[ItemBranch_Value] [nvarchar](max) NULL,
	[ItemLegalEntity] [nvarchar](max) NULL,
	[ItemLegalEntity_Value] [nvarchar](max) NULL,
	[ItemTaxAreaID] [nvarchar](max) NULL,
	[ItemTaxAreaID_Value] [nvarchar](max) NULL,
	[ItemEmployeeStore] [nvarchar](max) NULL,
	[ItemEmployeeStore_Value] [nvarchar](max) NULL,
	[DateCreated] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[Action] [nvarchar](max) NULL,
	[FieldsUpdated] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMLink]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMLink]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMLink](
	[Id] [nvarchar](max) NULL,
	[LinkTypeId] [nvarchar](max) NULL,
	[SourceEntityId] [nvarchar](max) NULL,
	[TargetEntityId] [nvarchar](max) NULL,
	[Index] [nvarchar](max) NULL,
	[Inactive] [nvarchar](max) NULL,
	[LinkEntityId] [nvarchar](max) NULL,
	[Action] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[ChannelEntityId] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMProduct]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMProduct]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMProduct](
	[EntityId] [nvarchar](max) NULL,
	[ProductID] [nvarchar](max) NULL,
	[ProductRomanceCopy] [nvarchar](max) NULL,
	[ProductManufacturerName] [nvarchar](max) NULL,
	[ProductCountryofOrigin] [nvarchar](max) NULL,
	[ProductCountryofOrigin_Value] [nvarchar](max) NULL,
	[ProductContainerVendorCode] [nvarchar](max) NULL,
	[ProductIsthisavariationitem] [nvarchar](max) NULL,
	[ProductIsthisavariationitem_Value] [nvarchar](max) NULL,
	[ProductVariationThemeName] [nvarchar](max) NULL,
	[ProductVariationThemeName_Value] [nvarchar](max) NULL,
	[ProductMaterials] [nvarchar](max) NULL,
	[ProductMaterials_Value] [nvarchar](max) NULL,
	[ProductFinishes] [nvarchar](max) NULL,
	[ProductFinishes_Value] [nvarchar](max) NULL,
	[ProductWarranty] [nvarchar](max) NULL,
	[ProductWarranty_Value] [nvarchar](max) NULL,
	[ProductNotes] [nvarchar](max) NULL,
	[ProductReleaseDate] [nvarchar](max) NULL,
	[ProductInsiteProductType] [nvarchar](max) NULL,
	[ProductInsiteProductType_Value] [nvarchar](max) NULL,
	[DateCreated] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[Action] [nvarchar](max) NULL,
	[FieldsUpdated] [nvarchar](max) NULL
) 
END
GO
/****** Object:  Table [dbo].[PIMResource]    Script Date: 12/4/2018 5:48:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIMResource]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PIMResource](
	[EntityId] [nvarchar](max) NULL,
	[ResourceName] [nvarchar](max) NULL,
	[ResourceDescription] [nvarchar](max) NULL,
	[ResourceMimeType] [nvarchar](max) NULL,
	[ResourceFilename] [nvarchar](max) NULL,
	[ResourceFileId] [nvarchar](max) NULL,
	[ResourceType] [nvarchar](max) NULL,
	[ResourceType_Value] [nvarchar](max) NULL,
	[ResourceImageType] [nvarchar](max) NULL,
	[ResourceImageType_Value] [nvarchar](max) NULL,
	[ResourceURL] [nvarchar](max) NULL,
	[DateCreated] [nvarchar](max) NULL,
	[LastModified] [nvarchar](max) NULL,
	[Action] [nvarchar](max) NULL,
	[FieldsUpdated] [nvarchar](max) NULL
) 
END
GO


/****** Object:  StoredProcedure [dbo].[PRFTTruncatePIMTempTables]    Script Date: 12/4/2018 6:08:39 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PRFTTruncatePIMTempTables]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRFTTruncatePIMTempTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PRFTTruncatePIMTempTables] AS' 
END
GO
ALTER PROCEDURE [dbo].[PRFTTruncatePIMTempTables]
AS
BEGIN
	TRUNCATE TABLE PIMAttribute
	TRUNCATE TABLE PIMAttributeModel
	TRUNCATE TABLE PIMChannel
	TRUNCATE TABLE PIMChannelNode	
	TRUNCATE TABLE PIMCVLData
	TRUNCATE TABLE PIMItem
	TRUNCATE TABLE PIMLink
	TRUNCATE TABLE PIMProduct
	TRUNCATE TABLE PIMResource

END
GO
