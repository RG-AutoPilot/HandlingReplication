SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 10. new function — build a display label for an agent group
CREATE   FUNCTION [dbo].[fn_AgentGroupLabel]
(
    @AgentGroupId INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    RETURN CAST(N'' AS NVARCHAR(300));
END
GO
