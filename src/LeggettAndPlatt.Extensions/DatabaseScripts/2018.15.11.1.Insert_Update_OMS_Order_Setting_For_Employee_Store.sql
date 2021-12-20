IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_AllocationRuleID' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'LP_E_SCH'
WHERE Name = 'Order_AllocationRuleID' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_AllocationRuleID',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'),'LP_E_SCH',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_DepartmentCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'EMPWEBC'
WHERE Name = 'Order_DepartmentCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_DepartmentCode',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'),'EMPWEBC',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_EnterpriseCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'LP_EMP_STORE' 
WHERE Name = 'Order_EnterpriseCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_EnterpriseCode',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'),'LP_EMP_STORE',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_PaymentRuleId' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'LP_EMP_PR1'
WHERE Name = 'Order_PaymentRuleId' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_PaymentRuleId',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'LP_EMP_PR1',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_SendOrderEmail' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'false'
WHERE Name = 'Order_SendOrderEmail' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_SendOrderEmail',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'false',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ValidateItem' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Y'
WHERE Name = 'Order_ValidateItem' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ValidateItem',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Y',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ByPassPricing' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Y'
WHERE Name = 'Order_ByPassPricing' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ByPassPricing',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Y',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_AuthorizedClient' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'InsiteCommerce'
WHERE Name = 'Order_AuthorizedClient' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_AuthorizedClient',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'InsiteCommerce',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_DocumentType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = '0001'
WHERE Name = 'Order_DocumentType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_DocumentType',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'0001',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_EntryType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'WEB'
WHERE Name = 'Order_EntryType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_EntryType',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'WEB',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_PaymentStatus' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'AUTHORIZED'
WHERE Name = 'Order_PaymentStatus' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_PaymentStatus',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'AUTHORIZED',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_PaymentType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'CREDIT_CARD'
WHERE Name = 'Order_PaymentType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_PaymentType',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'CREDIT_CARD',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ChargeType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'AUTHORIZATION'
WHERE Name = 'Order_ChargeType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ChargeType',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'AUTHORIZATION',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_CarrierServiceCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Standard'
WHERE Name = 'Order_CarrierServiceCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_CarrierServiceCode',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Standard',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_DeliveryMethod' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'SHP'
WHERE Name = 'Order_DeliveryMethod' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_DeliveryMethod',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'SHP',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ItemGroupCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'PROD'
WHERE Name = 'Order_ItemGroupCode' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ItemGroupCode',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'PROD',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_LineType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'DTC'
WHERE Name = 'Order_LineType' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_LineType',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'DTC',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ChargeCategory' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Sales'
WHERE Name = 'Order_ChargeCategory' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ChargeCategory',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Sales',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_TaxName' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'SalesTax'
WHERE Name = 'Order_TaxName' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_TaxName',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'SalesTax',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ChargeName' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Sales'
WHERE Name = 'Order_ChargeName' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ChargeName',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Sales',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_ProductClass' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'GOOD'
WHERE Name = 'Order_ProductClass' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_ProductClass',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'GOOD',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_TaxableFlag' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Y'
WHERE Name = 'Order_TaxableFlag' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_TaxableFlag',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Y',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END
IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'Order_IsPriceLocked' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'Y'
WHERE Name = 'Order_IsPriceLocked' AND WebsiteId = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')  

END
ELSE
BEGIN

INSERT INTO [dbo].[SystemSetting]
([Id],[Name],[WebsiteId],[Value],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
VALUES
(NEWID(),'Order_IsPriceLocked',(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee') ,'Y',SYSDATETIMEOFFSET(),'admin_admin',SYSDATETIMEOFFSET(),'admin_admin')
END