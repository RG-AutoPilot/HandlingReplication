-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[IngestErrorQueue]
(
[ErrorId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceJobId] [bigint] NULL,
[ErrorMessage] [nvarchar] (max) NOT NULL,
[FailedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_IngestErrorQueue_FailedUtc] DEFAULT (sysutcdatetime()),
[RetryCount] [int] NOT NULL CONSTRAINT [DF_IngestErrorQueue_RetryCount] DEFAULT (0)
)
GO
ALTER TABLE [dbo].[IngestErrorQueue] ADD CONSTRAINT [PK_IngestErrorQueue] PRIMARY KEY CLUSTERED ([ErrorId])
GO
