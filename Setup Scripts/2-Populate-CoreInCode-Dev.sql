/*
    CreateDevDatabase.sql
    Project: InCode

    Creates a standalone dev database for the InCode Flyway project.

    InCode contains stored procedures and functions only, no tables. In
    production this database is deployed identically to both node A and
    node B on every release. It is never part of SQL Server replication.

    This script intentionally configures NO replication. It creates a plain
    database with a small set of illustrative objects so the first Flyway
    capture (diff / model / generate) has something realistic to work from.

    Run once against your dev SQL Server instance.
*/

IF DB_ID(N'CoreInCode_Dev') IS NULL
BEGIN
    CREATE DATABASE CoreInCode_Dev;
END
GO

ALTER DATABASE CoreInCode_Dev SET RECOVERY SIMPLE;
GO

USE CoreInCode_Dev;
GO

-- Illustrative starting objects, themed on the client's own "Agents"
-- example. Replace or extend once real objects are captured. -------------

IF OBJECT_ID(N'dbo.usp_GetActiveAgents', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetActiveAgents;
GO
CREATE PROCEDURE dbo.usp_GetActiveAgents
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Agents in the CoreInData database.
    SELECT CAST(NULL AS INT) AS AgentId, CAST(NULL AS NVARCHAR(200)) AS AgentName
    WHERE 1 = 0;
END
GO

IF OBJECT_ID(N'dbo.usp_UpdateAgentHeartbeat', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdateAgentHeartbeat;
GO
CREATE PROCEDURE dbo.usp_UpdateAgentHeartbeat
    @AgentId INT,
    @HeartbeatUtc DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only.
    SELECT @AgentId AS AgentId, @HeartbeatUtc AS HeartbeatUtc;
END
GO

IF OBJECT_ID(N'dbo.usp_GetAgentGroupSummary', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetAgentGroupSummary;
GO
CREATE PROCEDURE dbo.usp_GetAgentGroupSummary
    @AgentGroupId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only.
    SELECT @AgentGroupId AS AgentGroupId, CAST(0 AS INT) AS AgentCount
    WHERE 1 = 0;
END
GO

IF OBJECT_ID(N'dbo.fn_IsAgentLicensed', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_IsAgentLicensed;
GO
CREATE FUNCTION dbo.fn_IsAgentLicensed(@AgentId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END
GO
