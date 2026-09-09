SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[fn_AgentGroupLabel]'
GO

-- 10. new function — build a display label for an agent group
CREATE   FUNCTION [dbo].[fn_AgentGroupLabel]
(
    @AgentGroupId INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    RETURN CAST(N'' AS NVARCHAR(300));
END
GO
PRINT N'Creating [dbo].[fn_AgentGroupSize]'
GO
CREATE FUNCTION [dbo].[fn_AgentGroupSize](@AgentGroupId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
PRINT N'Creating [dbo].[fn_AgentSkillLevel]'
GO
CREATE FUNCTION [dbo].[fn_AgentSkillLevel](@AgentId INT, @SkillId INT)
RETURNS TINYINT
AS
BEGIN
    DECLARE @Result TINYINT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
PRINT N'Creating [dbo].[fn_ContractDaysRemaining]'
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
PRINT N'Creating [dbo].[fn_ContractIsSlaBreached]'
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
PRINT N'Creating [dbo].[fn_CustomerHasActiveContract]'
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
PRINT N'Creating [dbo].[fn_FormatPhoneNumber]'
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
PRINT N'Creating [dbo].[fn_GetAgentDisplayName]'
GO
CREATE FUNCTION [dbo].[fn_GetAgentDisplayName](@AgentId INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Result NVARCHAR(200) = N'';
    -- Placeholder logic only.
    RETURN @Result;
END

GO
PRINT N'Creating [dbo].[fn_IsAgentLicensed]'
GO

-- 5. fn_IsAgentLicensed — take an as-of date so licence expiry can be back-tested
CREATE   FUNCTION [dbo].[fn_IsAgentLicensed]
(
    @AgentId  INT,
    @AsOfUtc  DATETIME2(0) = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    RETURN @Result;
END
GO
PRINT N'Creating [dbo].[fn_LicenseIsExpired]'
GO
CREATE FUNCTION [dbo].[fn_LicenseIsExpired](@LicenseId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
PRINT N'Creating [dbo].[fn_RegionCode]'
GO
CREATE FUNCTION [dbo].[fn_RegionCode](@RegionId INT)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @Result NVARCHAR(10) = N'';
    -- Placeholder logic only.
    RETURN @Result;
END

GO
PRINT N'Creating [dbo].[fn_ServiceTierPriority]'
GO
CREATE FUNCTION [dbo].[fn_ServiceTierPriority](@ServiceTierId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT = 0;
    -- Placeholder logic only.
    RETURN @Result;
END

GO
PRINT N'Creating [dbo].[coreINCodeSproc2]'
GO

CREATE PROCEDURE [dbo].[coreINCodeSproc2]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[coreINCodeSproc3]'
GO

CREATE PROCEDURE [dbo].[coreINCodeSproc3]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[coreINCodeSproc4]'
GO

CREATE PROCEDURE [dbo].[coreINCodeSproc4]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[coreINCodeSproc5]'
GO

CREATE PROCEDURE [dbo].[coreINCodeSproc5]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[coreINCodeSproc6]'
GO

CREATE PROCEDURE [dbo].[coreINCodeSproc6]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[coreINCodeSproc]'
GO
CREATE PROCEDURE [dbo].[coreINCodeSproc]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[huxChangeTwo]'
GO
CREATE PROCEDURE [dbo].[huxChangeTwo]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[huxChange]'
GO
CREATE PROCEDURE [dbo].[huxChange]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Creating [dbo].[usp_AssignAgentToGroup]'
GO
CREATE PROCEDURE [dbo].[usp_AssignAgentToGroup]
    @AgentId INT,
    @AgentGroupId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation updates
    -- dbo.Agents in the NodeA database.
    RETURN;
END

GO
PRINT N'Creating [dbo].[usp_AssignSkillToAgent]'
GO
CREATE PROCEDURE [dbo].[usp_AssignSkillToAgent]
    @AgentId INT,
    @SkillId INT,
    @ProficiencyLevel TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation inserts into
    -- dbo.AgentSkills in the NodeA database.
    RETURN;
END

GO
PRINT N'Creating [dbo].[usp_CreateAgent]'
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
PRINT N'Creating [dbo].[usp_DeactivateAgent]'
GO
CREATE PROCEDURE [dbo].[usp_DeactivateAgent]
    @AgentId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation updates
    -- dbo.Agents in the NodeA database to mark the agent inactive.
    RETURN;
END

GO
PRINT N'Creating [dbo].[usp_DeactivateIdleAgents]'
GO


-- -----------------------------------------------------------------------
-- 5 NEW OBJECTS
-- -----------------------------------------------------------------------

-- 6. new proc — bulk-deactivate agents idle since a threshold
CREATE   PROCEDURE [dbo].[usp_DeactivateIdleAgents]
    @IdleSinceUtc DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(0 AS INT) AS DeactivatedCount;
END
GO
PRINT N'Creating [dbo].[usp_GetActiveAgents]'
GO

-- =========================================================================
-- InCode demo change set: 5 alters + 5 new
-- Run against CoreInCode_Dev. Uses CREATE OR ALTER so the 5 "alters"
-- work whether or not the object was seeded by CreateDevDatabase.sql.
-- =========================================================================


-- -----------------------------------------------------------------------
-- 5 ALTERS  (existing objects, adjusted signature or logic)
-- -----------------------------------------------------------------------

-- 1. usp_GetActiveAgents — add a @SinceUtc filter
CREATE   PROCEDURE [dbo].[usp_GetActiveAgents]
    @SinceUtc DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(NULL AS INT) AS AgentId, CAST(NULL AS NVARCHAR(200)) AS AgentName
    WHERE 1 = 0 AND (@SinceUtc IS NULL OR @SinceUtc <= SYSUTCDATETIME());
END
GO
PRINT N'Creating [dbo].[usp_GetAgentGroupMembers]'
GO
CREATE PROCEDURE [dbo].[usp_GetAgentGroupMembers]
    @AgentGroupId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Agents in the NodeA database, filtered by AgentGroupId.
    SELECT CAST(NULL AS INT) AS AgentId, CAST(NULL AS NVARCHAR(200)) AS AgentName
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_GetAgentGroupSummary]'
GO

-- 3. usp_GetAgentGroupSummary — add @IncludeInactive flag
CREATE   PROCEDURE [dbo].[usp_GetAgentGroupSummary]
    @AgentGroupId     INT,
    @IncludeInactive  BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @AgentGroupId AS AgentGroupId, CAST(0 AS INT) AS AgentCount, @IncludeInactive AS IncludeInactive
    WHERE 1 = 0;
END
GO
PRINT N'Creating [dbo].[usp_GetAgentSkills]'
GO
CREATE PROCEDURE [dbo].[usp_GetAgentSkills]
    @AgentId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.AgentSkills in the NodeA database.
    SELECT CAST(NULL AS INT) AS SkillId, CAST(NULL AS TINYINT) AS ProficiencyLevel
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_GetContractsForCustomer]'
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
PRINT N'Creating [dbo].[usp_GetCustomerById]'
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
PRINT N'Creating [dbo].[usp_GetServiceTierById]'
GO
CREATE PROCEDURE [dbo].[usp_GetServiceTierById]
    @ServiceTierId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.ServiceTiers in the NodeA database.
    SELECT CAST(NULL AS INT) AS ServiceTierId, CAST(NULL AS NVARCHAR(50)) AS TierName
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_GrantLicense]'
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
PRINT N'Creating [dbo].[usp_ListExpiringLicenses]'
GO

-- 7. new proc — list expiring licences within N days
CREATE   PROCEDURE [dbo].[usp_ListExpiringLicenses]
    @WithinDays INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(NULL AS INT) AS LicenseId,
           CAST(NULL AS NVARCHAR(100)) AS LicenseKey,
           CAST(NULL AS DATETIME2(0)) AS ExpiresUtc
    WHERE 1 = 0 AND @WithinDays > 0;
END
GO
PRINT N'Creating [dbo].[usp_ListLicensesForCustomer]'
GO
CREATE PROCEDURE [dbo].[usp_ListLicensesForCustomer]
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Licenses in the NodeA database.
    SELECT CAST(NULL AS INT) AS LicenseId, CAST(NULL AS NVARCHAR(50)) AS LicenseType
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_ListRegions]'
GO
CREATE PROCEDURE [dbo].[usp_ListRegions]
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Regions in the NodeA database.
    SELECT CAST(NULL AS INT) AS RegionId, CAST(NULL AS NVARCHAR(100)) AS RegionName
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_ListSitesForRegion]'
GO
CREATE PROCEDURE [dbo].[usp_ListSitesForRegion]
    @RegionId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Sites in the NodeA database.
    SELECT CAST(NULL AS INT) AS SiteId, CAST(NULL AS NVARCHAR(200)) AS SiteName
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_ReassignGroupAgents]'
GO

-- 8. new proc — reassign every agent in one group to another
CREATE   PROCEDURE [dbo].[usp_ReassignGroupAgents]
    @FromGroupId INT,
    @ToGroupId   INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(0 AS INT) AS ReassignedCount;
END
GO
PRINT N'Creating [dbo].[usp_RevokeLicense]'
GO
CREATE PROCEDURE [dbo].[usp_RevokeLicense]
    @LicenseId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation updates
    -- dbo.Licenses in the NodeA database to revoke the licence.
    RETURN;
END

GO
PRINT N'Creating [dbo].[usp_SearchAgentsByName]'
GO
CREATE PROCEDURE [dbo].[usp_SearchAgentsByName]
    @NamePattern NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation reads from
    -- dbo.Agents in the NodeA database with a LIKE match on AgentName.
    SELECT CAST(NULL AS INT) AS AgentId, CAST(NULL AS NVARCHAR(200)) AS AgentName
    WHERE 1 = 0;
END

GO
PRINT N'Creating [dbo].[usp_UpdateAgentHeartbeat]'
GO

-- 2. usp_UpdateAgentHeartbeat — return rowcount instead of echoing inputs
CREATE   PROCEDURE [dbo].[usp_UpdateAgentHeartbeat]
    @AgentId          INT,
    @HeartbeatUtc     DATETIME2(0),
    @RowsAffected     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @RowsAffected = 0;
END
GO
PRINT N'Creating [dbo].[usp_UpdateContractStatus]'
GO
CREATE PROCEDURE [dbo].[usp_UpdateContractStatus]
    @ContractId BIGINT,
    @Status NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder logic only. The real implementation updates
    -- dbo.CustomerContracts in the NodeA database.
    RETURN;
END

GO
PRINT N'Creating [dbo].[usp_UpsertCustomer]'
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

