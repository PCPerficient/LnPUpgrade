IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'PIM_ImagePathPrefix')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = '/UserFiles/Images/PIMImages/'
WHERE Name = 'PIM_ImagePathPrefix'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'PIM_ImagePathPrefix',NULL,'/UserFiles/Images/PIMImages/',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
