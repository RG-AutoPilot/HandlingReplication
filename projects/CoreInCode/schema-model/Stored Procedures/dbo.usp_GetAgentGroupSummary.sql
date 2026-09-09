SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 3. usp_GetAgentGroupSummary — add @IncludeInactive flag
CREATE   PROCEDURE [dbo].[usp_GetAgentGroupSummary]
    @AgentGroupId     INT,
    @IncludeInactive  BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @AgentGroupId AS AgentGroupId, CAST(0 AS INT) AS AgentCount, @IncludeInactive AS IncludeInactive
    WHERE 1 = 0;
END
GO
