IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_CarrierServiceCode')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Standard'
WHERE Name = 'Order_CarrierServiceCode'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_CarrierServiceCode',NULL,'Standard',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END



IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_DeliveryMethod')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'SHP'
WHERE Name = 'Order_DeliveryMethod'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_DeliveryMethod',NULL,'SHP',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END




IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ItemGroupCode')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'PROD'
WHERE Name = 'Order_ItemGroupCode'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ItemGroupCode',NULL,'PROD',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END