SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =========================================================================
-- InCode demo change set: 5 alters + 5 new
-- Run against CoreInCode_Dev. Uses CREATE OR ALTER so the 5 "alters"
-- work whether or not the object was seeded by CreateDevDatabase.sql.
-- =========================================================================


-- -----------------------------------------------------------------------
-- 5 ALTERS  (existing objects, adjusted signature or logic)
-- -----------------------------------------------------------------------

-- 1. usp_GetActiveAgents — add a @SinceUtc filter
CREATE   PROCEDURE [dbo].[usp_GetActiveAgents]
    @SinceUtc DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(NULL AS INT) AS AgentId, CAST(NULL AS NVARCHAR(200)) AS AgentName
    WHERE 1 = 0 AND (@SinceUtc IS NULL OR @SinceUtc <= SYSUTCDATETIME());
END
GO
