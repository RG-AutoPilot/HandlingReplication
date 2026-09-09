SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CustomerHasActiveContract](@CustomerId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
