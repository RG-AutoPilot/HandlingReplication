-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[IngestBatchLog]
(
[BatchId] [bigint] NOT NULL IDENTITY(1, 1),
[BatchName] [nvarchar] (200) NOT NULL,
[RowsProcessed] [bigint] NOT NULL CONSTRAINT [DF_IngestBatchLog_RowsProcessed] DEFAULT ((0)),
[StartedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_IngestBatchLog_StartedUtc] DEFAULT (sysutcdatetime()),
[CompletedUtc] [datetime2] (0) NULL,
[RowsNeedingProcessed] [int] NULL,
[RowsProcessedTen] [int] NULL,
[RobNon] [int] NULL,
[version2Test] [int] NULL,
[version3Test] [int] NULL,
[ReplicChange] [int] NULL,
[ReplicatingChange] [int] NULL,
[ReplicatingChange2] [int] NULL,
[ReplicatingChange3] [int] NULL,
[ReplicatingChange4] [int] NULL,
[ReplicatingChange5] [int] NULL,
[ReplicatingChange6] [int] NULL,
[NonReplicatingChange7] [int] NULL,
[NonReplicatingChange8] [int] NULL,
[NonReplicatingChange9] [int] NULL,
[TestSmokeFlag] [bit] NULL,
[NonReplicatingChange10] [int] NULL,
[CheckReportSmoke1] [int] NULL,
[CheckReportSmoke2] [int] NULL,
[CheckReportSmoke3] [int] NULL,
[NonReplicatingObjectChange01] [int] NULL,
[NonReplicatingObjectChange02] [int] NULL,
[NonReplicatingObjectChange03] [int] NULL,
[Smoke_NonReplNote] [nvarchar] (50) NULL,
[Smoke_NonReplNoteDrift] [nvarchar] (50) NULL,
[Smoke_NonReplNoteDrift2] [nvarchar] (50) NULL
)
GO
ALTER TABLE [dbo].[IngestBatchLog] ADD CONSTRAINT [PK_IngestBatchLog] PRIMARY KEY CLUSTERED ([BatchId])
GO
