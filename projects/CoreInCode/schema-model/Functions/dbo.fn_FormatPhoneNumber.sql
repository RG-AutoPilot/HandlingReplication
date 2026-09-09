SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_FormatPhoneNumber](@Phone NVARCHAR(50))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Result NVARCHAR(50) = @Phone;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
