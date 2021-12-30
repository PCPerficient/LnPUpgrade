IF((SELECT COUNT(1) FROM dbo.ApplicationMessage where name = 'EmailSubscription_EmailIsRequiredErrorMessage')>0)
BEGIN

UPDATE dbo.ApplicationMessage
SET Message = 'The Email field is required.'
WHERE Name = 'EmailSubscription_EmailIsRequiredErrorMessage'

END