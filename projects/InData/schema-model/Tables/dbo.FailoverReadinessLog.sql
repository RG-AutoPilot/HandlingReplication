-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[FailoverReadinessLog]
(
[LogId] [bigint] NOT NULL IDENTITY(1, 1),
[RecordedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_FailoverReadinessLog_RecordedUtc] DEFAULT (sysutcdatetime()),
[ReadyForFailover] [bit] NOT NULL,
[Notes] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[FailoverReadinessLog] ADD CONSTRAINT [PK_FailoverReadinessLog] PRIMARY KEY CLUSTERED ([LogId])
GO
