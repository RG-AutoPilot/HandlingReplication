SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] DROP
COLUMN [NonReplicatingObjectChange01],
COLUMN [NonReplicatingObjectChange02]
GO
PRINT N'Altering [dbo].[ReplicationWatermark]'
GO
ALTER TABLE [dbo].[ReplicationWatermark] DROP
COLUMN [NonReplicatingObjectChange01],
COLUMN [NonReplicatingObjectChange02]
GO

