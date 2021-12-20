IF((SELECT COUNT(1) FROM dbo.SystemSetting where WebsiteId = (select Id from dbo.WebSite where name='Employee') and Name = 'Security_StorefrontAccess')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'SignInRequiredToBrowse'
where WebsiteId = (select Id from dbo.WebSite where name='Employee') and Name = 'Security_StorefrontAccess'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Security_StorefrontAccess',(select Id from dbo.WebSite where name='Employee'),'SignInRequiredToBrowse',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END