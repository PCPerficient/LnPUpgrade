IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Cart_TotalCountDisplay')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'TotalItemQty'
WHERE Name = 'Cart_TotalCountDisplay'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Cart_TotalCountDisplay',NULL,'TotalItemQty',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END