SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_ListRegions]
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Regions in the NodeA database.
    SELECT CAST(NULL AS INT) AS RegionId, CAST(NULL AS NVARCHAR(100)) AS RegionName
    WHERE 1 = 0;
END

GO
