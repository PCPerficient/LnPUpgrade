IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'PIM_VariantAttributeName')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'ItemSizeName,ItemColorName'
WHERE Name = 'PIM_VariantAttributeName'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'PIM_VariantAttributeName',NULL,'ItemSizeName,ItemColorName',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
