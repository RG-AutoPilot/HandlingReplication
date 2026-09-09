SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping [dbo].[usp_UpsertCustomer]'
GO
DROP PROCEDURE [dbo].[usp_UpsertCustomer]
GO
PRINT N'Dropping [dbo].[usp_UpdateContractStatus]'
GO
DROP PROCEDURE [dbo].[usp_UpdateContractStatus]
GO
PRINT N'Dropping [dbo].[usp_UpdateAgentHeartbeat]'
GO
DROP PROCEDURE [dbo].[usp_UpdateAgentHeartbeat]
GO
PRINT N'Dropping [dbo].[usp_SearchAgentsByName]'
GO
DROP PROCEDURE [dbo].[usp_SearchAgentsByName]
GO
PRINT N'Dropping [dbo].[usp_RevokeLicense]'
GO
DROP PROCEDURE [dbo].[usp_RevokeLicense]
GO
PRINT N'Dropping [dbo].[usp_ReassignGroupAgents]'
GO
DROP PROCEDURE [dbo].[usp_ReassignGroupAgents]
GO
PRINT N'Dropping [dbo].[usp_ListSitesForRegion]'
GO
DROP PROCEDURE [dbo].[usp_ListSitesForRegion]
GO
PRINT N'Dropping [dbo].[usp_ListRegions]'
GO
DROP PROCEDURE [dbo].[usp_ListRegions]
GO
PRINT N'Dropping [dbo].[usp_ListLicensesForCustomer]'
GO
DROP PROCEDURE [dbo].[usp_ListLicensesForCustomer]
GO
PRINT N'Dropping [dbo].[usp_ListExpiringLicenses]'
GO
DROP PROCEDURE [dbo].[usp_ListExpiringLicenses]
GO
PRINT N'Dropping [dbo].[usp_GrantLicense]'
GO
DROP PROCEDURE [dbo].[usp_GrantLicense]
GO
PRINT N'Dropping [dbo].[usp_GetServiceTierById]'
GO
DROP PROCEDURE [dbo].[usp_GetServiceTierById]
GO
PRINT N'Dropping [dbo].[usp_GetCustomerById]'
GO
DROP PROCEDURE [dbo].[usp_GetCustomerById]
GO
PRINT N'Dropping [dbo].[usp_GetContractsForCustomer]'
GO
DROP PROCEDURE [dbo].[usp_GetContractsForCustomer]
GO
PRINT N'Dropping [dbo].[usp_GetAgentSkills]'
GO
DROP PROCEDURE [dbo].[usp_GetAgentSkills]
GO
PRINT N'Dropping [dbo].[usp_GetAgentGroupSummary]'
GO
DROP PROCEDURE [dbo].[usp_GetAgentGroupSummary]
GO
PRINT N'Dropping [dbo].[usp_GetAgentGroupMembers]'
GO
DROP PROCEDURE [dbo].[usp_GetAgentGroupMembers]
GO
PRINT N'Dropping [dbo].[usp_GetActiveAgents]'
GO
DROP PROCEDURE [dbo].[usp_GetActiveAgents]
GO
PRINT N'Dropping [dbo].[usp_DeactivateIdleAgents]'
GO
DROP PROCEDURE [dbo].[usp_DeactivateIdleAgents]
GO
PRINT N'Dropping [dbo].[usp_DeactivateAgent]'
GO
DROP PROCEDURE [dbo].[usp_DeactivateAgent]
GO
PRINT N'Dropping [dbo].[usp_CreateAgent]'
GO
DROP PROCEDURE [dbo].[usp_CreateAgent]
GO
PRINT N'Dropping [dbo].[usp_AssignSkillToAgent]'
GO
DROP PROCEDURE [dbo].[usp_AssignSkillToAgent]
GO
PRINT N'Dropping [dbo].[usp_AssignAgentToGroup]'
GO
DROP PROCEDURE [dbo].[usp_AssignAgentToGroup]
GO
PRINT N'Dropping [dbo].[huxChange]'
GO
DROP PROCEDURE [dbo].[huxChange]
GO
PRINT N'Dropping [dbo].[huxChangeTwo]'
GO
DROP PROCEDURE [dbo].[huxChangeTwo]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc6]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc6]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc5]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc5]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc4]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc4]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc3]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc3]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc2]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc2]
GO
PRINT N'Dropping [dbo].[fn_ServiceTierPriority]'
GO
DROP FUNCTION [dbo].[fn_ServiceTierPriority]
GO
PRINT N'Dropping [dbo].[fn_RegionCode]'
GO
DROP FUNCTION [dbo].[fn_RegionCode]
GO
PRINT N'Dropping [dbo].[fn_LicenseIsExpired]'
GO
DROP FUNCTION [dbo].[fn_LicenseIsExpired]
GO
PRINT N'Dropping [dbo].[fn_IsAgentLicensed]'
GO
DROP FUNCTION [dbo].[fn_IsAgentLicensed]
GO
PRINT N'Dropping [dbo].[fn_GetAgentDisplayName]'
GO
DROP FUNCTION [dbo].[fn_GetAgentDisplayName]
GO
PRINT N'Dropping [dbo].[fn_FormatPhoneNumber]'
GO
DROP FUNCTION [dbo].[fn_FormatPhoneNumber]
GO
PRINT N'Dropping [dbo].[fn_CustomerHasActiveContract]'
GO
DROP FUNCTION [dbo].[fn_CustomerHasActiveContract]
GO
PRINT N'Dropping [dbo].[fn_ContractIsSlaBreached]'
GO
DROP FUNCTION [dbo].[fn_ContractIsSlaBreached]
GO
PRINT N'Dropping [dbo].[fn_ContractDaysRemaining]'
GO
DROP FUNCTION [dbo].[fn_ContractDaysRemaining]
GO
PRINT N'Dropping [dbo].[fn_AgentSkillLevel]'
GO
DROP FUNCTION [dbo].[fn_AgentSkillLevel]
GO
PRINT N'Dropping [dbo].[fn_AgentGroupSize]'
GO
DROP FUNCTION [dbo].[fn_AgentGroupSize]
GO
PRINT N'Dropping [dbo].[fn_AgentGroupLabel]'
GO
DROP FUNCTION [dbo].[fn_AgentGroupLabel]
GO

