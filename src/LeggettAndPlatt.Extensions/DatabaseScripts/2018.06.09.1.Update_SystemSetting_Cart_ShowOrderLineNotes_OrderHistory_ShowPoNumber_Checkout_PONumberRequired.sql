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
(NEWID(),'Checkout_AllowPONumbers',NULL,'false',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END

IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'OrderHistory_ShowPoNumber')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'false'
WHERE Name = 'OrderHistory_ShowPoNumber'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'OrderHistory_ShowPoNumber',NULL,'false',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END

IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Cart_ShowOrderLineNotes')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'false'
WHERE Name = 'Cart_ShowOrderLineNotes'

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Cart_ShowOrderLineNotes',NULL,'false',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END