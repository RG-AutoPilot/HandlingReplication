SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetAgentDisplayName](@AgentId INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Result NVARCHAR(200) = N'';
    -- Placeholder logic only.
    RETURN @Result;
END

GO
