IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'OrderHistory_ReorderEnabled')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'false'
WHERE Name = 'OrderHistory_ReorderEnabled'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'OrderHistory_ReorderEnabled',NULL,'false',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END