SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] ADD
[NonReplicatingChange9] [int] NULL
GO
PRINT N'Altering [dbo].[ReplicationWatermark]'
GO
ALTER TABLE [dbo].[ReplicationWatermark] ADD
[nodeAnodeBChange2] [int] NULL
GO

