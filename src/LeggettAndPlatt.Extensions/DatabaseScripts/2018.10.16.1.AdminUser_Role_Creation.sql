
--------------/////////////////////////ISC_Creative-Services/////////////////////////////////////////--------------------------------

------Create New Role ------------------------------------------------------------
IF((select count(1) from [AspNetRoles] where [name]='ISC_CreativeServices')=0)
BEGIN
INSERT INTO [dbo].[AspNetRoles]
           ([Id]
           ,[Name])
     VALUES
           (newid()
           ,'ISC_CreativeServices')
End 

---------Added full permission to new user------------------------------------------

INSERT INTO [AppDict].[EntityPermission] 
	SELECT NEWID(),ec.Id,'ISC_CreativeServices',GETDATE(),'admin_admin',GETDATE(),'admin_admin',1,1,1,1
		FROM AppDict.EntityConfiguration ec
		LEFT JOIN AppDict.EntityPermission ep ON (ep.RoleName='ISC_CreativeServices' AND ec.Id = ep.EntityConfigurationId)
		WHERE ep.Id IS NULL
		
---------Price Matrix: View Only------------------------------------------

	UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='priceMatrix')
	WHERE ep.RoleName='ISC_CreativeServices'

---------Product Pricing Fields: View only------------------------------------------

INSERT INTO [AppDict].[PropertyPermission] 
	SELECT NEWID(),
	(select Id from [AppDict].[PropertyConfiguration] where EntityConfigurationId In(
select Id from AppDict.EntityConfiguration where Name='Product') and name = 'basicSalePrice'),
'ISC_CreativeServices','admin_admin',GETDATE(),'admin_admin',GETDATE(),1,0

INSERT INTO [AppDict].[PropertyPermission] 
	SELECT NEWID(),
	(select Id from [AppDict].[PropertyConfiguration] where EntityConfigurationId In(
select Id from AppDict.EntityConfiguration where Name='Product') and name = 'basicListPrice'),
'ISC_CreativeServices','admin_admin',GETDATE(),'admin_admin',GETDATE(),1,0

---------Administration > Console Users	Read/View Only------------------------------------------
	

UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='adminUserProfile')
	WHERE ep.RoleName='ISC_CreativeServices'
	
---------Administration > Console Users	Read/View Only------------------------------------------


UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='role')
	WHERE ep.RoleName='ISC_CreativeServices'
		
---------Administration > PunchOut	Hide the link or make it Read/View Only------------------------------------------

UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='punchOutOrderRequest')
	WHERE ep.RoleName='ISC_CreativeServices'


	UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='punchOutCustomerUserProfileMap')
	WHERE ep.RoleName='ISC_CreativeServices'
	
---------Administration > System > Full Control Except following:
-------------Application Logs, Audit Logs, Application Dictionary should be Read/View Only

	UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId in (select Id from AppDict.EntityConfiguration where name in('applicationLog','audit','entityConfiguration','propertyConfiguration','entityPermission','propertyPermission'))
	WHERE ep.RoleName='ISC_CreativeServices'

--------------//////////////////////////////ISC_ReadOnly////////////////////////////////////-----------------------------------------
------Create New Role ------------------------------------------------------------
IF((select count(1) from [AspNetRoles] where [name]='ISC_ReadOnly')=0)
BEGIN
INSERT INTO [dbo].[AspNetRoles]
           ([Id]
           ,[Name])
     VALUES
           (newid()
           ,'ISC_ReadOnly')
End 

-------------------------------------------------------------------------------------
INSERT INTO [AppDict].[EntityPermission] 
	SELECT NEWID(),ec.Id,'ISC_ReadOnly',GETDATE(),'admin_admin',GETDATE(),'admin_admin',1,0,0,0
		FROM AppDict.EntityConfiguration ec
		LEFT JOIN AppDict.EntityPermission ep ON (ep.RoleName='ISC_ReadOnly' AND ec.Id = ep.EntityConfigurationId)
		WHERE ep.Id IS NULL

--------------//////////////////////////////ISC_Security////////////////////////////////////-----------------------------------------
------Create New Role ------------------------------------------------------------
IF((select count(1) from [AspNetRoles] where [name]='ISC_Security')=0)
BEGIN
INSERT INTO [dbo].[AspNetRoles]
           ([Id]
           ,[Name])
     VALUES
           (newid()
           ,'ISC_Security')
End 

-------------------------------------------------------------------------------------
INSERT INTO [AppDict].[EntityPermission] 
	SELECT NEWID(),ec.Id,'ISC_Security',GETDATE(),'admin_admin',GETDATE(),'admin_admin',0,0,0,0
		FROM AppDict.EntityConfiguration ec
		LEFT JOIN AppDict.EntityPermission ep ON (ep.RoleName='ISC_Security' AND ec.Id = ep.EntityConfigurationId)
		WHERE ep.Id IS NULL
---------Administration > Console Users	and Website Users------------------------------------------

UPDATE ep
	set ep.CanCreate=1,ep.CanDelete=1,ep.CanEdit=1,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='adminUserProfile')
	WHERE ep.RoleName='ISC_Security'

UPDATE ep
	set ep.CanCreate=0,ep.CanDelete=0,ep.CanEdit=0,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='UserProfile')
	WHERE ep.RoleName='ISC_Security'

---------Administration > Console Users	Read/View Only------------------------------------------


UPDATE ep
	set ep.CanCreate=1,ep.CanDelete=1,ep.CanEdit=1,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId = (select Id from AppDict.EntityConfiguration where name ='role')
	WHERE ep.RoleName='ISC_Security'

---------Administration > Application Logs, Audit Logs, Application Dictionary should be Full Control.--------------

		UPDATE ep
	set ep.CanCreate=1,ep.CanDelete=1,ep.CanEdit=1,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId in (select Id from AppDict.EntityConfiguration where name in('applicationLog','audit','entityConfiguration'))
	WHERE ep.RoleName='ISC_Security'

			UPDATE ep
	set ep.CanCreate=1,ep.CanDelete=1,ep.CanEdit=1,ep.CanView=1
	FROM AppDict.EntityPermission ep 
	INNER JOIN AppDict.EntityConfiguration ec ON ep.EntityConfigurationId in (select Id from AppDict.EntityConfiguration where name in('customProperty','propertyConfiguration','propertyPermission','entityPermission'))
	WHERE ep.RoleName='ISC_Security'


