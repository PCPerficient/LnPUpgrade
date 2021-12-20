IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Cart_ShowTaxAndShipping')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'false'
WHERE Name = 'Cart_ShowTaxAndShipping'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Cart_ShowTaxAndShipping',NULL,'false',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END