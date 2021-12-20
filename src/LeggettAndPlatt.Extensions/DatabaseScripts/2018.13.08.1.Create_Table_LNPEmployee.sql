IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = N'LNPEmployee')
BEGIN

CREATE TABLE [dbo].[LNPEmployee](
	[Id] [uniqueidentifier] NOT NULL DEFAULT (newsequentialid()),
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Unique] [int] NOT NULL,
	[Clock] [nvarchar](4) NOT NULL,
	[CreatedOn] [datetimeoffset](7) NOT NULL,
	[CreatedBy] [nvarchar](100) NOT NULL,
	[ModifiedOn] [datetimeoffset](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_LNPEmployee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[LNPEmployee] ADD  CONSTRAINT [DF_LNPEmployee_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]

ALTER TABLE [dbo].[LNPEmployee] ADD  CONSTRAINT [DF_LNPEmployee_ModifiedOn]  DEFAULT (getutcdate()) FOR [ModifiedOn]

END