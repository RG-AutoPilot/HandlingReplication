SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_AssignSkillToAgent]
    @AgentId INT,
    @SkillId INT,
    @ProficiencyLevel TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation inserts into
    -- dbo.AgentSkills in the NodeA database.
    RETURN;
END

GO
