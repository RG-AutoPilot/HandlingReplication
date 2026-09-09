SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetAgentGroupMembers]
    @AgentGroupId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Agents in the NodeA database, filtered by AgentGroupId.
    SELECT CAST(NULL AS INT) AS AgentId, CAST(NULL AS NVARCHAR(200)) AS AgentName
    WHERE 1 = 0;
END

GO
