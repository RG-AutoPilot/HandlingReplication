-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Sites]
(
[SiteId] [int] NOT NULL IDENTITY(1, 1),
[SiteName] [nvarchar] (200) NOT NULL,
[RegionId] [int] NOT NULL,
[IsActive] [bit] NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Sites_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Sites] ADD CONSTRAINT [PK_Sites] PRIMARY KEY CLUSTERED ([SiteId])
GO
ALTER TABLE [dbo].[Sites] ADD CONSTRAINT [FK_Sites_Regions] FOREIGN KEY ([RegionId]) REFERENCES [dbo].[Regions] ([RegionId])
GO
