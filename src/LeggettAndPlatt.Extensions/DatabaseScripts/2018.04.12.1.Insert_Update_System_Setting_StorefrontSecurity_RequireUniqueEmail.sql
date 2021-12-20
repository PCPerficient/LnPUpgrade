IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'StorefrontSecurity_RequireUniqueEmail')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'true'
WHERE Name = 'StorefrontSecurity_RequireUniqueEmail'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'StorefrontSecurity_RequireUniqueEmail',NULL,'true',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END 