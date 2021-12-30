--------------------------------------
-- Script to flush data from Insite --
--------------------------------------

-- flush Resource data
DELETE FROM dbo.PRFTResourceDataFromPIM
GO
DELETE FROM dbo.Document WHERE ParentTable = 'Category' and ParentId in(
select id from dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup'))
)
GO
DELETE FROM dbo.Document WHERE ParentTable = 'Product' and ParentId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.ProductImage where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO

-- flush Specification data
DELETE FROM dbo.Specification WHERE ProductId IS NOT NULL and ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.Specification WHERE CategoryId IS NOT NULL and CategoryId in(
select id from dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup'))
)
GO
DELETE FROM dbo.Content
	WHERE ContentManagerID IN (SELECT ID FROM dbo.ContentManager WHERE [Name] = 'Specification')
GO
DELETE FROM dbo.ContentManager WHERE [Name] = 'Specification'
GO

-- flush Attribute data
DELETE FROM dbo.TranslationDictionary
	WHERE [Source] IN ('Attribute','AttributeValue','UnitOfMeasure')
GO
DELETE FROM dbo.CategoryAttributeValue where CategoryId in(
select id from dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup'))
)
GO
DELETE FROM dbo.CategoryAttributeType where CategoryId in(
select id from dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup'))
)
GO
DELETE FROM dbo.PRFTProductAttributeValueExtension where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
)
GO
DELETE FROM dbo.ProductAttributeValue where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.AttributeValue
GO
DELETE FROM dbo.AttributeType
GO

-- flush Product data
DELETE FROM dbo.Content
	WHERE ContentManagerID IN (SELECT ContentManagerID FROM dbo.Product WHERE Id not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
))
GO
DELETE FROM dbo.ContentManager WHERE Id IN (SELECT ContentManagerID FROM dbo.Product WHERE Id not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
))
GO
DELETE FROM dbo.TranslationProperty WHERE ParentTable = 'Product' and ParentId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.OrderLine where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.CategoryProduct where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.ProductRelatedProduct where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) and RelatedProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.CustomerProduct  where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.RestrictionGroupProductAddition where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.RestrictionGroupProductException where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.RestrictionGroupProduct where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.PRFTProductExtension where ProductId not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
DELETE FROM dbo.Product where Id not in(
'F25611C0-48F0-4B18-8645-A92700885683',
'BDC31C76-AE48-43A4-A1B9-A927009325A9',
'AC4AB490-AD78-4A5F-8511-A92700934834'
) 
GO
delete  from StyleClass where id not in ('5A11C939-B118-4A1F-914C-A9270093DC64') 
GO

-- flush Category data
DELETE FROM dbo.Content
	WHERE ContentManagerID IN (SELECT ContentManagerID FROM dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup')))
GO
DELETE FROM dbo.ContentManager WHERE Id IN (SELECT ContentManagerID FROM dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup')))
GO
DELETE FROM dbo.TranslationProperty WHERE ParentTable = 'Product' and ParentId in(
SELECT Id FROM dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup'))) 
GO
DELETE FROM dbo.PRFTCategoryExtension where CategoryId in(
SELECT Id FROM dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup')))
GO
DELETE FROM dbo.Category where WebSiteId in(select id from Website where name in ('Employee','FashionBedGroup'))
GO

