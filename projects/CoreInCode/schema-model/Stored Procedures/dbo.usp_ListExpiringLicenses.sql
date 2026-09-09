SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 7. new proc — list expiring licences within N days
CREATE   PROCEDURE [dbo].[usp_ListExpiringLicenses]
    @WithinDays INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(NULL AS INT) AS LicenseId,
           CAST(NULL AS NVARCHAR(100)) AS LicenseKey,
           CAST(NULL AS DATETIME2(0)) AS ExpiresUtc
    WHERE 1 = 0 AND @WithinDays > 0;
END
GO
