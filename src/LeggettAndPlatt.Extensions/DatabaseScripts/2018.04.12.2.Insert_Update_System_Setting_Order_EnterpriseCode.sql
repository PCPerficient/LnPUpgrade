IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_EnterpriseCode' AND WebsiteId IS NULL )>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Please enter the updated enterprise code'
WHERE Name = 'Order_EnterpriseCode' AND WebsiteId IS NULL

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),
'Order_EnterpriseCode',
NULL,
'Please enter the updated enterprise code',
SYSDATETIMEOFFSET(),
'admin_admin',
SYSDATETIMEOFFSET(),
'admin_admin'
)
END 


-----------------------------------------------------------------------------------------------------------

IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_EnterpriseCode' AND WebsiteId = (SELECT Id FROM WebSite where Name = 'Driftotr') )>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'LP_DRIFT_STORE'
WHERE Name = 'Order_EnterpriseCode' AND 
WebsiteId = (SELECT Id FROM WebSite where Name = 'Driftotr')

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),
'Order_EnterpriseCode',
(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Driftotr'),
'LP_DRIFT_STORE',
SYSDATETIMEOFFSET(),
'admin_admin',
SYSDATETIMEOFFSET(),
'admin_admin'
)
END

-----------------------------------------------------------------------------------------------------------


IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_EnterpriseCode' AND WebsiteId = (SELECT Id FROM WebSite where Name = 'Employee') )>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'LP_EMP_STORE'
WHERE Name = 'Order_EnterpriseCode' AND 
WebsiteId = (SELECT Id FROM WebSite where Name = 'Employee')
END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_EnterpriseCode',(SELECT Id FROM WebSite where Name = 'Employee'),'LP_EMP_STORE',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END 
 

Delete from [dbo].[SystemListValue] where SystemListId=(select id from [dbo].[SystemList] where Name='WebsiteEnterpriseCodeMapping')
Delete from [dbo].[SystemList] where Name='WebsiteEnterpriseCodeMapping'
