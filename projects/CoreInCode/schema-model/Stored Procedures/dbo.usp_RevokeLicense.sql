SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_RevokeLicense]
    @LicenseId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation updates
    -- dbo.Licenses in the NodeA database to revoke the licence.
    RETURN;
END

GO
