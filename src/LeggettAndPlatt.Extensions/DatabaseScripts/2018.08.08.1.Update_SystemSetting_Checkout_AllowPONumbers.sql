IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Checkout_AllowPONumbers')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'false'
WHERE Name = 'Checkout_AllowPONumbers'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Checkout_AllowPONumbers',NULL,'true',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END