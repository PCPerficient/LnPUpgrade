IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'City' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'City'
		   ,'City'
		   ,30
		   ,1
		   ,1
		   ,1
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'City'
	  ,[FieldName] = 'City'
	  ,[MaxFieldLength] = 30
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 1
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'City' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END 


-----------------------------------------------------------------------------------------------

IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField] WHERE [FieldName] = 'Attention' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Attention'
		   ,'Attention'
		   ,50
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Attention'
	  ,[FieldName] = 'Attention'
	  ,[MaxFieldLength] = 50
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Attention' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

-----------------------------------------------------------------------------------------------

IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'FirstName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'First Name'
		   ,'FirstName'
		   ,30
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'First Name'
	  ,[FieldName] = 'FirstName'
	  ,[MaxFieldLength] = 30
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'FirstName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')

END
-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'CompanyName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN


INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Company Name'
		   ,'CompanyName'
		   ,40
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Company Name'
	  ,[FieldName] = 'CompanyName'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'CompanyName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'LastName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Last Name'
		   ,'LastName'
		   ,30
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Last Name'
	  ,[FieldName] = 'LastName'
	  ,[MaxFieldLength] = 30
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'LastName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Email' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Email'
		   ,'Email'
		   ,50
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Email'
	  ,[FieldName] = 'Email'
	  ,[MaxFieldLength] = 50
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Email' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Address1' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 1'
		   ,'Address1'
		   ,40
		   ,1
		   ,1
		   ,1
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Address 1'
	  ,[FieldName] = 'Address1'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 1
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address1' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Address2' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 2'
		   ,'Address2'
		   ,40
		   ,0
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Address 2'
	  ,[FieldName] = 'Address2'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address2' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Address3' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 3'
		   ,'Address3'
		   ,40
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Address 3'
	  ,[FieldName] = 'Address3'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address3' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Address4' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 4'
		   ,'Address4'
		   ,40
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Address 4'
	  ,[FieldName] = 'Address4'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address4' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Phone' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Phone'
		   ,'Phone'
		   ,20
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Phone'
	  ,[FieldName] = 'Phone'
	  ,[MaxFieldLength] = 20
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Phone' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Fax' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Fax'
		   ,'Fax'
		   ,20
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Fax'
	  ,[FieldName] = 'Fax'
	  ,[MaxFieldLength] = 20
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Fax' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'Country' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Country'
		   ,'Country'
		   ,NULL
		   ,1
		   ,1
		   ,1
		   ,0
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Country'
	  ,[FieldName] = 'Country'
	  ,[MaxFieldLength] = NULL
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 1
	  ,[IsMaxFieldLengthRequired] = 0
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Country' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'PostalCode' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Postal Code'
		   ,'PostalCode'
		   ,10
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'Postal Code'
	  ,[FieldName] = 'PostalCode'
	  ,[MaxFieldLength] = 10
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'PostalCode' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[BillToAddressField]  WHERE [FieldName] = 'State' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[BillToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'State'
		   ,'State'
		   ,NULL
		   ,0
		   ,0
		   ,0
		   ,0
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
		   
END
ELSE
BEGIN

UPDATE [dbo].[BillToAddressField]
   SET [DisplayName] = 'State'
	  ,[FieldName] = 'State'
	  ,[MaxFieldLength] = NULL
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 0
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'State' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

---------------------------------------------------Ship to address fields ----------------------------------

IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'City' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'City'
		   ,'City'
		   ,30
		   ,1
		   ,1
		   ,1
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'City'
	  ,[FieldName] = 'City'
	  ,[MaxFieldLength] = 30
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 1
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'City' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END 


-----------------------------------------------------------------------------------------------

IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField] WHERE [FieldName] = 'Attention' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Attention'
		   ,'Attention'
		   ,50
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Attention'
	  ,[FieldName] = 'Attention'
	  ,[MaxFieldLength] = 50
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Attention' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

-----------------------------------------------------------------------------------------------

IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'FirstName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'First Name'
		   ,'FirstName'
		   ,30
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'First Name'
	  ,[FieldName] = 'FirstName'
	  ,[MaxFieldLength] = 30
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'FirstName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')

END
-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'CompanyName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN


INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Company Name'
		   ,'CompanyName'
		   ,40
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Company Name'
	  ,[FieldName] = 'CompanyName'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'CompanyName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'LastName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Last Name'
		   ,'LastName'
		   ,30
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Last Name'
	  ,[FieldName] = 'LastName'
	  ,[MaxFieldLength] = 30
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'LastName' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Email' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Email'
		   ,'Email'
		   ,50
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Email'
	  ,[FieldName] = 'Email'
	  ,[MaxFieldLength] = 50
	  ,[IsRequired] = 0
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Email' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Address1' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 1'
		   ,'Address1'
		   ,40
		   ,1
		   ,1
		   ,1
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Address 1'
	  ,[FieldName] = 'Address1'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 1
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address1' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Address2' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 2'
		   ,'Address2'
		   ,40
		   ,0
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Address 2'
	  ,[FieldName] = 'Address2'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address2' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Address3' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 3'
		   ,'Address3'
		   ,40
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Address 3'
	  ,[FieldName] = 'Address3'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address3' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Address4' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Address 4'
		   ,'Address4'
		   ,40
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Address 4'
	  ,[FieldName] = 'Address4'
	  ,[MaxFieldLength] = 40
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Address4' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Phone' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Phone'
		   ,'Phone'
		   ,20
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Phone'
	  ,[FieldName] = 'Phone'
	  ,[MaxFieldLength] = 20
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Phone' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Fax' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Fax'
		   ,'Fax'
		   ,20
		   ,0
		   ,0
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Fax'
	  ,[FieldName] = 'Fax'
	  ,[MaxFieldLength] = 20
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Fax' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END



-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'Country' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN

INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Country'
		   ,'Country'
		   ,NULL
		   ,1
		   ,1
		   ,1
		   ,0
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Country'
	  ,[FieldName] = 'Country'
	  ,[MaxFieldLength] = NULL
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 1
	  ,[IsMaxFieldLengthRequired] = 0
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'Country' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END

-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'PostalCode' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'Postal Code'
		   ,'PostalCode'
		   ,10
		   ,1
		   ,1
		   ,0
		   ,1
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'Postal Code'
	  ,[FieldName] = 'PostalCode'
	  ,[MaxFieldLength] = 10
	  ,[IsRequired] = 1
	  ,[IsVisible] = 1
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 1
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'PostalCode' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END


-----------------------------------------------------------------------------------------------
IF((SELECT COUNT(1) FROM [dbo].[ShipToAddressField]  WHERE [FieldName] = 'State' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[ShipToAddressField]
		   ([Id]
		   ,[DisplayName]
		   ,[FieldName]
		   ,[MaxFieldLength]
		   ,[IsRequired]
		   ,[IsVisible]
		   ,[IsSystemField]
		   ,[IsMaxFieldLengthRequired]
		   ,[WebsiteId]
		   ,[CreatedOn]
		   ,[CreatedBy]
		   ,[ModifiedOn]
		   ,[ModifiedBy])
	 VALUES
		   (NEWID()
		   ,'State'
		   ,'State'
		   ,NULL
		   ,0
		   ,0
		   ,0
		   ,0
		   ,(SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin'
		   ,SYSDATETIMEOFFSET()
		   ,'admin_admin')
		   
END
ELSE
BEGIN

UPDATE [dbo].[ShipToAddressField]
   SET [DisplayName] = 'State'
	  ,[FieldName] = 'State'
	  ,[MaxFieldLength] = NULL
	  ,[IsRequired] = 0
	  ,[IsVisible] = 0
	  ,[IsSystemField] = 0
	  ,[IsMaxFieldLengthRequired] = 0
	  ,[WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
	  ,[CreatedOn] = SYSDATETIMEOFFSET()
	  ,[CreatedBy] = 'admin_admin'
	  ,[ModifiedOn] = SYSDATETIMEOFFSET()
	  ,[ModifiedBy] = 'admin_admin'
 WHERE [FieldName] = 'State' AND [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
END