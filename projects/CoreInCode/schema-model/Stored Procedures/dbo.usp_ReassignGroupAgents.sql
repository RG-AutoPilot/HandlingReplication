SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 8. new proc — reassign every agent in one group to another
CREATE   PROCEDURE [dbo].[usp_ReassignGroupAgents]
    @FromGroupId INT,
    @ToGroupId   INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(0 AS INT) AS ReassignedCount;
END
GO
