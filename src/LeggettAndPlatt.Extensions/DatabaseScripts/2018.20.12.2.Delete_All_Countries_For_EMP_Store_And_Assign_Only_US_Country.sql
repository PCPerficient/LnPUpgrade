IF((SELECT COUNT(1) FROM [dbo].[WebSiteCountry]  WHERE  [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee'))=0)
BEGIN
INSERT INTO [dbo].[WebSiteCountry]
           ([WebSiteId]
           ,[CountryId])
     VALUES
           ((SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
           ,(SELECT Id FROM [dbo].[Country] WHERE Name = 'United States'))

END
ELSE
BEGIN

DELETE FROM [dbo].[WebSiteCountry]  WHERE  [WebsiteId] = (SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')

INSERT INTO [dbo].[WebSiteCountry]
           ([WebSiteId]
           ,[CountryId])
     VALUES
           ((SELECT Id FROM [dbo].[WebSite] WHERE Name = 'Employee')
           ,(SELECT Id FROM [dbo].[Country] WHERE Name = 'United States'))
END 

