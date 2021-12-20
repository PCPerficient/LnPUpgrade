
truncate table [dbo].[ApplicationLog]
delete from [dbo].[ELMAH_Error]
truncate table [dbo].[IntegrationJobLog]
delete from [dbo].[IntegrationJob] where Status<>'Queued'
truncate table [dbo].[Audit]
delete from [dbo].[AspNetUsers] where UserName not like 'admin_%'
delete from CustomerOrder
delete from [dbo].[UserProfile]
delete from [dbo].[OrderHistoryLine]
delete from OrderHistory
delete from [dbo].[CustomerUserProfile]
delete from Customer
delete from [dbo].[CustomerProduct]
truncate table [SeqOrderNumber]
truncate table [dbo].[CreditCardTransaction]
truncate table [dbo].[SeqCustomerNumber]
delete from [dbo].[Shipment]
delete from [dbo].[ShipmentPackage]
truncate table [dbo].[ShipmentPackageLine]
truncate table [dbo].[WishListProduct]
delete from [dbo].[EmailMessage]
truncate table [dbo].[EmailMessageAddress]
truncate table [dbo].[EmailMessageDeliveryAttempt]
delete from [dbo].[EmailSubscriber]
truncate table [dbo].[EmailSubscriberEmailList]
delete from [dbo].[WishList]
truncate table [dbo].[WishListShare]
