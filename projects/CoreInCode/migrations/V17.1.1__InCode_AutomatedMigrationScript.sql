SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[usp_Smoke_Ping]'
GO

CREATE   PROCEDURE [dbo].[usp_Smoke_Ping]
    @Message NVARCHAR(100) = N'hello'
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        @Message                    AS Message,
        SYSUTCDATETIME()            AS UtcNow,
        DB_NAME()                   AS DatabaseName,
        HOST_NAME()                 AS HostName;
END;
GO

