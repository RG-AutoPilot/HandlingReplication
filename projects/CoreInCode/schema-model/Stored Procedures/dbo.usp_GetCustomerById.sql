SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetCustomerById]
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Customers in the NodeA database.
    SELECT CAST(NULL AS INT) AS CustomerId, CAST(NULL AS NVARCHAR(200)) AS CustomerName
    WHERE 1 = 0;
END

GO
