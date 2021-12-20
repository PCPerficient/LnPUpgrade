update [IntegrationConnection] set URL=RTRIM(URL)+':21' where Name='DriftFtpConnection'

--LNP OMS Pricing For Product
delete from [dbo].[IntegrationJobParameter] where JobDefinitionParameterId in(
select Id from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP OMS Pricing For Product'))

delete from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP OMS Pricing For Product')

--LNP Order Submit
delete from [dbo].[IntegrationJobParameter] where JobDefinitionParameterId in(
select Id from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP Order Submit'))

delete from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP Order Submit')


--LNP OMS Order Notifications
delete from [dbo].[IntegrationJobParameter] where JobDefinitionParameterId in(
select Id from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP OMS Order Notifications'))

delete from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP OMS Order Notifications')

--LNP Order History Refresh
delete from [dbo].[IntegrationJobParameter] where JobDefinitionParameterId in(
select Id from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP Order History Refresh'))

delete from [dbo].[JobDefinitionParameter] where name='FTPPort' and  JobDefinitionId= (
select Id from [dbo].[JobDefinition] where name='LNP Order History Refresh')





