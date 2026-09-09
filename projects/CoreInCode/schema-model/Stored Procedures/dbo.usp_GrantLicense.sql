SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GrantLicense]
    @CustomerId INT,
    @LicenseType NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation inserts into
    -- dbo.Licenses in the NodeA database.
    RETURN;
END

GO
