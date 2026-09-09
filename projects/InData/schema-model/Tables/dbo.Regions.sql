-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Regions]
(
[RegionId] [int] NOT NULL IDENTITY(1, 1),
[RegionCode] [nvarchar] (10) NOT NULL,
[RegionName] [nvarchar] (100) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Regions_CreatedUtc] DEFAULT (sysutcdatetime()),
[Smoke_ReplNote] [nvarchar] (50) NULL,
[Smoke_ReplNoteDrift] [nvarchar] (50) NULL,
[Smoke_ReplNoteDrift2] [nvarchar] (50) NULL
)
GO
ALTER TABLE [dbo].[Regions] ADD CONSTRAINT [PK_Regions] PRIMARY KEY CLUSTERED ([RegionId])
GO
