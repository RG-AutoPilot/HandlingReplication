SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_ListLicensesForCustomer]
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Licenses in the NodeA database.
    SELECT CAST(NULL AS INT) AS LicenseId, CAST(NULL AS NVARCHAR(50)) AS LicenseType
    WHERE 1 = 0;
END

GO
