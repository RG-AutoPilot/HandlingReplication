SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 5. fn_IsAgentLicensed — take an as-of date so licence expiry can be back-tested
CREATE   FUNCTION [dbo].[fn_IsAgentLicensed]
(
    @AgentId  INT,
    @AsOfUtc  DATETIME2(0) = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    RETURN @Result;
END
GO
