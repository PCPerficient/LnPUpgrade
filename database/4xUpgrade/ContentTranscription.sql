-- Script to move content from an older system up to 4x
-- The process starts by inserting data into ContentTransfer db from the production system
-- and restoring it to Pilot and then running these scripts to clear the webpage/webpage content
-- and re-establishing it in the target database

use [insite.commerce.MySite_New]
delete from contentmanager where name = 'WebPage'
delete from contentmanager where name = 'WebPageContent'
delete from webpage
delete from webpagecontent

declare @DefaultLanguage uniqueidentifier
declare @DefaultPersona uniqueidentifier
select @DefaultLanguage = id from language where IsDefault = 1
select @DefaultPersona = id from persona where IsDefault = 1

-- ContentManager
insert into ContentManager (Id,Name)
SELECT ContentManagerId,Name FROM ContentTransfer.dbo.ContentManager where name in ('WebPage','WebPageContent')

-- Content
insert into Content (Id, ContentManagerId,HTML,SubmittedForApprovalOn,ApprovedOn,
PublishToProductionOn,CreatedOn,CreatedById,ApprovedById,Revision,PersonaId,LanguageId)
SELECT c.ContentId,c.ContentManagerId,HTML,SubmittedForApproval,Approved,
PublishToProduction,Created,CreatedById,ApprovedById,Revision,@DefaultPersona,@DefaultLanguage
from ContentTransfer.dbo.Content c join ContentTransfer.dbo.Contentmanager cm on
cm.ContentManagerId = c.ContentManagerId 
where cm.name in ('WebPage','WebPageContent')

-- WebPage
insert into WebPage (Id,WebSiteId,Name,Description,Title,ContentManagerId,MetaKeywords,
MetaDescription,PageContent,StyleSheet,BodyOnLoad,ViewName,Inherit)
SELECT WebPageId,WebSiteId,Name,Description,Title,ContentManagerId,MetaKeywords,
MetaDescription,PageContent,StyleSheet,BodyOnLoad,ViewName,Inherit
from ContentTransfer.dbo.WebPage

-- WebPageContent
insert into WebPageContent (Id,WebsiteId,Name,PageTitle,ContentTitle,MetaKeywords,
MetaDescription,PageContent,OverrideParent,ContentManagerId,WebPageId)
select WebPageContentId,WebSiteId,Name,PageTitle,ContentTitle,MetaTags,
MetaDescription,PageContent,OverrideParent,ContentManagerId,WebPageId
from ContentTransfer.dbo.WebPageContent




