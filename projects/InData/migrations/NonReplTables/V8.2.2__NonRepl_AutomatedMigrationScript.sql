SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] ADD
[NonReplicatingChange10] [int] NULL
GO
PRINT N'Altering [dbo].[ReplicationWatermark]'
GO
ALTER TABLE [dbo].[ReplicationWatermark] ADD
[nodeAnodeBChange3] [int] NULL
GO
PRINT N'Creating [dbo].[coreINCodeSproc9]'
GO

CREATE PROCEDURE [dbo].[coreINCodeSproc9]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO

