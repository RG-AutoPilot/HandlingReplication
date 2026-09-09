SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 2. usp_UpdateAgentHeartbeat — return rowcount instead of echoing inputs
CREATE   PROCEDURE [dbo].[usp_UpdateAgentHeartbeat]
    @AgentId          INT,
    @HeartbeatUtc     DATETIME2(0),
    @RowsAffected     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @RowsAffected = 0;
END
GO
