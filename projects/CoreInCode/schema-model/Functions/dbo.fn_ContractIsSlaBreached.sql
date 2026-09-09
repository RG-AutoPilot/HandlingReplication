SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 9. new function — compute a headline SLA breach flag for a contract
CREATE   FUNCTION [dbo].[fn_ContractIsSlaBreached]
(
    @ContractId BIGINT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Breached BIT = 0;
    RETURN @Breached;
END
GO
