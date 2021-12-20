IF((SELECT COUNT(1) FROM SystemSetting WHERE name = 'Employee_EmployeeWebsiteName')=1)
BEGIN
Update SystemSetting  SET value = (SELECT LOWER(id) FROM website where name = 'Employee'), websiteid = NULL WHERE name = 'Employee_EmployeeWebsiteName';
END
ELSE
BEGIN
INSERT INTO [dbo].[SystemSetting]
           ([id]
           ,[name]
           ,[websiteid]
           ,[value]
           ,[createdon]
           ,[createdby]
           ,[modifiedon]
           ,[modifiedby])
     VALUES
           (NEWID()
           ,'Employee_EmployeeWebsiteName'
           ,NULL
           ,(select LOWER(id) from website where name ='Employee')
           ,SYSDATETIMEOFFSET()
           ,'admin_admin'
           ,SYSDATETIMEOFFSET()
           ,'admin_admin')
END

