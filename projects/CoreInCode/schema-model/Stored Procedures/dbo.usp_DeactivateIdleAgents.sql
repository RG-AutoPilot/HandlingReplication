SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- -----------------------------------------------------------------------
-- 5 NEW OBJECTS
-- -----------------------------------------------------------------------

-- 6. new proc — bulk-deactivate agents idle since a threshold
CREATE   PROCEDURE [dbo].[usp_DeactivateIdleAgents]
    @IdleSinceUtc DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(0 AS INT) AS DeactivatedCount;
END
GO
