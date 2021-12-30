IF((SELECT COUNT(1) FROM [dbo].[IntegrationConnection] WHERE Name='FlatFileConnectionEmployeeOrderHistory')=0)
BEGIN
INSERT INTO [dbo].[IntegrationConnection]
           ([Id]
           ,[Name]
           ,[TypeName]
           ,[DataSource]
           ,[RunsOn]
           ,[DebuggingEnabled]
           ,[Delimiter]
           ,[Url]
           ,[LogOn]
           ,[Password]
           ,[ConnectionString]
           ,[ArchiveFolder]
           ,[ArchiveRetentionDays]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[IntegratedSecurity]
           ,[SystemNumber]
           ,[Client]
           ,[Language]
           ,[ConnectionsLimit]
           ,[ConnectionTimeout]
           ,[AppServerHost]
           ,[AppServerService]
           ,[MessageServerHost]
           ,[MessageServerService]
           ,[GatewayHost]
           ,[GatewayService]
           ,[SystemId]
           ,[SystemIds]
           ,[LogonGroup]
           ,[SourceServerTimeZone])
     VALUES
           (NEWID()
           ,'FlatFileConnectionEmployeeOrderHistory'
           ,'FlatFile'
           ,''
           ,''
           ,1
           ,','
           ,''
           ,''
           ,''
           ,''
           ,''
           ,30
           ,GETUTCDATE()
           ,'admin_admin'
			,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,'Central Standard Time')
END







IF((SELECT COUNT(1) FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')=0)
BEGIN
INSERT INTO [dbo].[JobDefinition]
           ([Id]
           ,[IntegrationConnectionId]
           ,[Name]
           ,[Description]
           ,[JobType]
           ,[DebuggingEnabled]
           ,[PassThroughJob]
           ,[NotifyEmail]
           ,[NotifyCondition]
           ,[LinkedJobId]
           ,[PassDataSetToLinkedJob]
           ,[UseDeltaDataSet]
           ,[PreProcessor]
           ,[IntegrationProcessor]
           ,[PostProcessor]
           ,[LastRunDateTime]
           ,[LastRunJobNumber]
           ,[LastRunStatus]
           ,[RecurringJob]
           ,[RecurringStartDateTime]
           ,[RecurringEndDateTime]
           ,[RecurringInterval]
           ,[RecurringType]
           ,[RecurringStartTime]
           ,[RecurringStartDay]
           ,[EmailTemplateId]
           ,[RunStepsInParallel]
           ,[LinkedJobCondition]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[MaxErrorsBeforeFail]
           ,[MaxWarningsBeforeFail]
           ,[MaxRetries]
           ,[MaxDeactivationPercent]
           ,[MaxTimeoutMinutes]
           ,[StandardJobName])
     VALUES
           (NEWID()
           ,(SELECT Id FROM IntegrationConnection WHERE Name='FlatFileConnectionEmployeeOrderHistory')
           ,'LNP_OrderHistory_Import_Employee'
           ,'Import OrderHistory and OrderHistoryLine for EMP'
           ,'Refresh'
           ,1
           ,0
           ,''
           ,'Completion'
           ,NULL
           ,0
           ,0
           ,'None'
           ,'FlatFile'
           ,'FieldMap'
           ,NULL
           ,''
           ,''
           ,0
           ,NULL
           ,NULL
           ,1
           ,'Days'
           ,NULL
           ,0
           ,NULL
           ,0
           ,'SuccessOnly'
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,0
           ,0
           ,0
           ,0
           ,0
           ,'')
END








IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee'))=0)
BEGIN

INSERT INTO [dbo].[JobDefinitionStep]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[Name]
           ,[ObjectName]
           ,[IntegrationConnectionOverrideId]
           ,[IntegrationProcessorOverride]
           ,[SelectClause]
           ,[FromClause]
           ,[WhereClause]
           ,[ParameterizedWhereClause]
           ,[DeleteAction]
           ,[DeleteActionFieldToSet]
           ,[DeleteActionValueToSet]
           ,[SkipHeaderRow]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[FlatFileErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP_OrderHistory_Import_Employee')
           ,1
           ,'OrderHistory'
           ,'orderHistory'
           ,NULL
           ,''
           ,'Order Date,ERP Order Number,Web Order Number,Status,Customer Number,BT Address 1,BT Address 2,BT City,BT Company Name,BT Country,BT Postal Code,BT State,Conversion Rate,Created By,Created On,Currency Code,Customer PO,Customer Sequence,Less Orer Promotions (OrderDiscountAmount),Product Discount Amount,Modified By,Notes,Order Grand Total,Other Charges,Product Total,Sales Rep,Ship Code,Shipping Charges,Handling Charges,ST Address 1,ST Address 2,ST City,ST Company Name,ST Country,ST Postal Code,ST State,Tax Amount,Terms,Requested Delivery Date,Impersonated By Admin User Profile,Is Guest Order,Is Tax TBD,BT Phone,ST Last Name,ST First Name,ST Email,BT Last Name,BT First Name,BT Email,ST Phone,Modified On,Id'
           ,'EmployeeStore_OrderHistory_*.csv'
           ,''
           ,''
           ,'Ignore'
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END







IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStep] WHERE name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee'))=0)
BEGIN

INSERT INTO [dbo].[JobDefinitionStep]
           ([Id]
           ,[JobDefinitionId]
           ,[Sequence]
           ,[Name]
           ,[ObjectName]
           ,[IntegrationConnectionOverrideId]
           ,[IntegrationProcessorOverride]
           ,[SelectClause]
           ,[FromClause]
           ,[WhereClause]
           ,[ParameterizedWhereClause]
           ,[DeleteAction]
           ,[DeleteActionFieldToSet]
           ,[DeleteActionValueToSet]
           ,[SkipHeaderRow]
           ,[CreatedOn]
           ,[CreatedBy]
           ,[ModifiedOn]
           ,[ModifiedBy]
           ,[FlatFileErrorHandling])
     VALUES
           (NEWID()
           ,(SELECT Id FROM JobDefinition WHERE Name='LNP_OrderHistory_Import_Employee')
           ,2
           ,'Order History Line'
           ,'orderHistoryLine'
           ,NULL
           ,''
           ,'ERP Order Number,Product Number,Description,U/M,Qty Ordered,Qty Shipped,Unit Regular Price,Total Price,Status,Created By,Created On,Customer Number,Customer Product Number,Customer Sequence,Unit Discount Amount,Discount Percent,Inventory Qty Ordered,Inventory Qty Shiped,Last Ship Date,Line Number,Line PO Reference,Line Type,Modified By,Notes,Release Number,Required Date,Rma Qty Received,Rma Qty Requested,Unit Net Price,Warehouse,Order Line Other Charges,Unit Cost,Unit List Price,Config Data Set,Total Regular Price,Tax Amount,Modified On,Id'
           ,'EmployeeStore_OrderHistoryLines_*.csv'
           ,''
           ,''
           ,'Ignore'
           ,''
           ,''
           ,1
           ,GETUTCDATE()
           ,'admin_admin'
           ,GETUTCDATE()
           ,'admin_admin'
           ,'Ignore')
END


IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStepFieldMap] WHERE JobDefinitionStepId in(select Id from JobDefinitionStep WHERE name = 'OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Order Date','OrderDate',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ERP Order Number','ErpOrderNumber',0,1,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Web Order Number','WebOrderNumber',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Status','Status',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Customer Number','CustomerNumber',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Address 1','BtAddress1',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Address 2','BtAddress2',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT City','BtCity',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Company Name','BtCompanyName',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Country','BtCountry',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Postal Code','BtPostalCode',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT State','BtState',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Conversion Rate','ConversionRate',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Currency Code','CurrencyCode',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Customer PO','CustomerPO',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Customer Sequence','CustomerSequence',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Less Orer Promotions (OrderDiscountAmount)','OrderDiscountAmount',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Product Discount Amount','ProductDiscountAmount',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Notes','Notes',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Order Grand Total','OrderTotal',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Other Charges','OtherCharges',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Product Total','ProductTotal',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Sales Rep','Salesperson',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Ship Code','ShipCode',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Shipping Charges','ShippingCharges',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Handling Charges','HandlingCharges',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Handling Charges','HandlingCharges',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Handling Charges','HandlingCharges',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Address 1','StAddress1',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Address 2','StAddress2',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST City','StCity',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Company Name','StCompanyName',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Country','StCountry',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Postal Code','StPostalCode',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST State','StState',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Tax Amount','TaxAmount',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Terms','Terms',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Terms','Terms',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Is Guest Order','IsGuestOrder',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Is Tax TBD','IsTaxTBD',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Phone','BtPhone',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Last Name','StLastName',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST First Name','StFirstName',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Email','StEmail',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Last Name','StLastName',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT First Name','BtFirstName',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','BT Email','BtEmail',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','ST Phone','StPhone',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='OrderHistory' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Requested Delivery Date','RequestedDeliveryDate',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
END





IF((SELECT COUNT(1) FROM [dbo].[JobDefinitionStepFieldMap] WHERE JobDefinitionStepId in(select Id from JobDefinitionStep WHERE name = 'Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')))=0)
BEGIN
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Lookup','ERP Order Number','OrderHistory',0,1,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Product Number','ProductErpNumber',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Description','Description',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','U/M','UnitOfMeasure',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Qty Ordered','QtyOrdered',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Qty Shipped','QtyShipped',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Unit Regular Price','UnitRegularPrice',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Total Price','TotalNetPrice',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Status','Status',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Customer Number','CustomerNumber',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Customer Product Number','CustomerProductNumber',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Customer Sequence','CustomerSequence',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Unit Discount Amount','UnitDiscountAmount',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Discount Percent','DiscountPercent',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Inventory Qty Ordered','InventoryQtyOrdered',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Line Number','LineNumber',0,1,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Line PO Reference','LinePOReference',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Line Type','LineType',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Notes','Notes',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Release Number','ReleaseNumber',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Required Date','RequiredDate',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','RMA Qty Received','RmaQtyReceived',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Rma Qty Requested','RmaQtyRequested',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Unit Net Price','UnitNetPrice',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Warehouse','Warehouse',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Order Line Other Charges','OrderLineOtherCharges',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Unit Cost','UnitCost',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Unit List Price','UnitListPrice',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Config Data Set','ConfigDataSet',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Total Regular Price','TotalRegularPrice',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Tax Amount','TaxAmount',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
INSERT INTO [dbo].[JobDefinitionStepFieldMap] VALUES (NEWID(),(select Id from JobDefinitionStep WHERE Name='Order History Line' and JobDefinitionId in(SELECT Id FROM [dbo].[JobDefinition] WHERE Name='LNP_OrderHistory_Import_Employee')),'Field','Last Ship Date','LastShipDate',0,0,GETUTCDATE(),'admin_admin',GETUTCDATE(),'admin_admin','Warning')
END