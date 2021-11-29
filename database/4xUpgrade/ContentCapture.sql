-- This query is to populate the transfer tables

use [Insite.Commerce.MyDatabase]
drop table contenttransfer.dbo.Content
drop table contenttransfer.dbo.ContentManager 
drop table contenttransfer.dbo.WebPage 
drop table contenttransfer.dbo.WebPageContent 

select * into contenttransfer.dbo.Content from Content
select * into contenttransfer.dbo.ContentManager from ContentManager
select * into contenttransfer.dbo.WebPage from WebPage
select * into contenttransfer.dbo.WebPageContent from WebPageContent