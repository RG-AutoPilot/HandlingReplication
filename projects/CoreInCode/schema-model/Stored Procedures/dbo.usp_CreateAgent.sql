SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 4. usp_CreateAgent — add @CreatedBy audit column
CREATE   PROCEDURE [dbo].[usp_CreateAgent]
    @AgentGroupId INT,
    @AgentName    NVARCHAR(200),
    @CreatedBy    NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(NULL AS INT) AS AgentId;
END
GO
