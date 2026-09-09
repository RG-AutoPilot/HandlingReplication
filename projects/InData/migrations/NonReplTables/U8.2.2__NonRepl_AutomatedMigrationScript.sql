SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping [dbo].[coreINCodeSproc9]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc9]
GO
PRINT N'Altering [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] DROP
COLUMN [NonReplicatingChange10]
GO
PRINT N'Altering [dbo].[ReplicationWatermark]'
GO
ALTER TABLE [dbo].[ReplicationWatermark] DROP
COLUMN [nodeAnodeBChange3]
GO

