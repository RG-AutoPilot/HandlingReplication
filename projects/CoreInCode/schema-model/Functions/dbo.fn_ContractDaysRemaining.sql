SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_ContractDaysRemaining](@ContractId BIGINT)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
