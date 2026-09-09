-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ReplicationWatermark]
(
[WatermarkId] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (200) NOT NULL,
[LastSyncedUtc] [datetime2] (0) NOT NULL,
[Test] [nchar] (10) NULL,
[nodeAnodeBChange] [int] NULL,
[nodeAnodeBChange2] [int] NULL,
[nodeAnodeBChange3] [int] NULL,
[CheckReportSmoke1] [int] NULL,
[CheckReportSmoke2] [int] NULL,
[CheckReportSmoke3] [int] NULL,
[NonReplicatingObjectChange01] [int] NULL,
[NonReplicatingObjectChange02] [int] NULL,
[NonReplicatingObjectChange03] [int] NULL
)
GO
ALTER TABLE [dbo].[ReplicationWatermark] ADD CONSTRAINT [PK_ReplicationWatermark] PRIMARY KEY CLUSTERED ([WatermarkId])
GO
