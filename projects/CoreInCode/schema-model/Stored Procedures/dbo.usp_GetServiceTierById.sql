SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetServiceTierById]
    @ServiceTierId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.ServiceTiers in the NodeA database.
    SELECT CAST(NULL AS INT) AS ServiceTierId, CAST(NULL AS NVARCHAR(50)) AS TierName
    WHERE 1 = 0;
END

GO
