IF((SELECT COUNT(1) FROM dbo.SystemSetting where name = 'OrderManagementGeneral_OrderNumberPrefix')>0)
BEGIN

UPDATE dbo.SystemSetting
SET Value = 'DFT'
WHERE Name = 'OrderManagementGeneral_OrderNumberPrefix'

END