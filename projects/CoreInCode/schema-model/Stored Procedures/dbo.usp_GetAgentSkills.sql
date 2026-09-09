SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetAgentSkills]
    @AgentId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.AgentSkills in the NodeA database.
    SELECT CAST(NULL AS INT) AS SkillId, CAST(NULL AS TINYINT) AS ProficiencyLevel
    WHERE 1 = 0;
END

GO
