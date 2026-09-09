SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[usp_Smoke_PingDrift2]
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
