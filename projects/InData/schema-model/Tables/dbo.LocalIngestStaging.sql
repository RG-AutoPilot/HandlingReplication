-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LocalIngestStaging]
(
[StagingId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceSystem] [nvarchar] (100) NOT NULL,
[RawPayload] [nvarchar] (max) NULL,
[ReceivedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LocalIngestStaging_ReceivedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[LocalIngestStaging] ADD CONSTRAINT [PK_LocalIngestStaging] PRIMARY KEY CLUSTERED ([StagingId])
GO
