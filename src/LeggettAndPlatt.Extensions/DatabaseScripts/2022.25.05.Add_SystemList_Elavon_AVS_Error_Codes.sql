IF NOT EXISTS(SELECT NAME FROM SystemList WHERE NAME = 'Elavon3DS2ErrorCodes')

BEGIN
 INSERT INTO [dbo].[SystemList]
           ([Id],[Name],[Description] ,[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
 VALUES(NEWID(),'Elavon3DS2ErrorCodes','Elavon3DS2ErrorCodes',getdate()
           ,'admin_admin',GETDATE(),'admin_admin')
End
Go

DECLARE @SystemListId UNIQUEIDENTIFIER
SELECT @SystemListId=ID FROM SystemList WHERE NAME = 'Elavon3DS2ErrorCodes'


IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '101' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'101','Message Invalid','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '102' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'102','Message version is not supported','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '103' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'103','Sent Messages Limit Exceeded','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '201' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'201','Missing required data element','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '202' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'202','Critical Message Extension Not Recognized','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '203' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'203','Format of one or more Data Elements is Invalid according to the EMV Specification','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '204' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'204','Duplicate Data Element','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '301' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'301','Unknown transaction ID','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '302' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'302','Data Decryption Failure','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '303' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'303','Access Denied, Invalid Endpoint','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '304' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'304','ISO Code Invalid','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '305' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'305','Transaction data not valid','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '306' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'306','Merchant Category Code (MCC) Not Valid for Payment System','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '402' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'402','Transaction Timed Out','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '403' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'403','Transient System Failure','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '404' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'404','Permanent System Failure','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = '405' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'405','System Connection Failure','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
-----------------------------------------------
IF NOT EXISTS(SELECT NAME FROM SystemList WHERE NAME = 'ElavonAVSResponseCodes')

BEGIN
 INSERT INTO [dbo].[SystemList]
           ([Id],[Name],[Description] ,[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
 VALUES(NEWID(),'ElavonAVSResponseCodes','ElavonAVSResponseCodes',getdate()
           ,'admin_admin',GETDATE(),'admin_admin')
End
Go

DECLARE @SystemListId UNIQUEIDENTIFIER
SELECT @SystemListId=ID FROM SystemList WHERE NAME = 'ElavonAVSResponseCodes'


IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'A' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'A','Address matches - ZIP Code does not match','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'B' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'B','	Street address match, Postal code in wrong format (international issuer)','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'C' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'C','Street address and postal code in wrong formats','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'D' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'D','Street address and postal code match (international issuer)','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'E' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'E','AVS Error','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'F' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'F','Address does compare and five-digit ZIP code does compare (UK only)','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'G' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'G','Service not supported by non-US issuer','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'I' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'I','Address information not verified by international issuer','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'M' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'M','	Street Address and Postal code match (international issuer)','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'N' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'N','	No Match on Address (Street) or ZIP','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'O' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'O','No Response sent','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'P' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'P','Postal codes match, Street address not verified due to incompatible formats','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'R' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'R','Retry, System unavailable or Timed out','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'S' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'S','Service not supported by issuer','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'U' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'U','Address information is unavailable','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'W' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'W','9-digit ZIP matches, Address (Street) does not match','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'X' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'X','Exact AVS Match','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'Y' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'Y','Address (Street) and 5-digit ZIP match','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END
IF NOT EXISTS(SELECT NAME FROM [SystemListValue] WHERE NAME = 'Z' and SystemListId= @SystemListId)
BEGIN
Insert into [dbo].[SystemListValue]
(ID,SystemListId,[Name],[Description],[AdditionalInfo],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
Values( NEWID(),@SystemListId,'Z','5-digit ZIP matches, Address (Street) does not match','',getdate(),'admin_admin',GETDATE(),'admin_admin')
		  
END


