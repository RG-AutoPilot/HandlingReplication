-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ActiveNodeJobQueue]
(
[JobId] [bigint] NOT NULL IDENTITY(1, 1),
[JobType] [nvarchar] (100) NOT NULL,
[PayloadJson] [nvarchar] (max) NULL,
[EnqueuedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeJobQueue_EnqueuedUtc] DEFAULT (sysutcdatetime()),
[ProcessedUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[ActiveNodeJobQueue] ADD CONSTRAINT [PK_ActiveNodeJobQueue] PRIMARY KEY CLUSTERED ([JobId])
GO
