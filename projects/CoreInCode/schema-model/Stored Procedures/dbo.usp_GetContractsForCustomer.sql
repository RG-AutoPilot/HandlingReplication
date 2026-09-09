SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetContractsForCustomer]
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.CustomerContracts in the NodeA database.
    SELECT CAST(NULL AS BIGINT) AS ContractId, CAST(NULL AS NVARCHAR(20)) AS Status
    WHERE 1 = 0;
END

GO
