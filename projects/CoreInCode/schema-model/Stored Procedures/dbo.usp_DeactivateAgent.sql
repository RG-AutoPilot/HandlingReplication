SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_DeactivateAgent]
    @AgentId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation updates
    -- dbo.Agents in the NodeA database to mark the agent inactive.
    RETURN;
END

GO
