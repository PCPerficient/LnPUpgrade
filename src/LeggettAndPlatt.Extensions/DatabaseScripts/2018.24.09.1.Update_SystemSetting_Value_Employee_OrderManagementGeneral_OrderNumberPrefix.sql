IF((SELECT COUNT(1) FROM dbo.SystemSetting where WebsiteId = (select Id from dbo.WebSite where name='Employee') and Name = 'OrderManagementGeneral_OrderNumberPrefix')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'LES'
where WebsiteId = (select Id from dbo.WebSite where name='Employee') and Name = 'OrderManagementGeneral_OrderNumberPrefix'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'OrderManagementGeneral_OrderNumberPrefix',(select Id from dbo.WebSite where name='Employee'),'LES',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END