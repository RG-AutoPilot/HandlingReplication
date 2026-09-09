SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_ListSitesForRegion]
    @RegionId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Sites in the NodeA database.
    SELECT CAST(NULL AS INT) AS SiteId, CAST(NULL AS NVARCHAR(200)) AS SiteName
    WHERE 1 = 0;
END

GO
