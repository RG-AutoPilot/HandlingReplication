SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_AgentSkillLevel](@AgentId INT, @SkillId INT)
RETURNS TINYINT
AS
BEGIN
    DECLARE @Result TINYINT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
