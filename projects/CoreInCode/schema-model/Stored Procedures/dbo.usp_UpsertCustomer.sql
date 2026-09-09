SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_UpsertCustomer]
    @CustomerId INT,
    @CustomerName NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation merges into
    -- dbo.Customers in the NodeA database.
    RETURN;
END

GO
