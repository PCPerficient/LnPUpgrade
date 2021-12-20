delete from UserProfileWebsite

IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Security_RestrictUsersToAssignedWebsites')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'true'
WHERE Name = 'Security_RestrictUsersToAssignedWebsites'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Security_RestrictUsersToAssignedWebsites',NULL,'true',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END


insert into UserProfileWebsite(Id,UserProfileId,WebsiteId) select NEWID(),a.Id,b.Id from UserProfile a cross join (select Id from WebSite where name = 'Driftotr') b