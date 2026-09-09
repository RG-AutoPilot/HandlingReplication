-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[ServiceTiers]
(
[ServiceTierId] [int] NOT NULL IDENTITY(1, 1),
[TierName] [nvarchar] (50) NOT NULL,
[PriorityRank] [int] NOT NULL,
[SlaMinutes] [int] NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ServiceTiers_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[ServiceTiers] ADD CONSTRAINT [PK_ServiceTiers] PRIMARY KEY CLUSTERED ([ServiceTierId])
GO
