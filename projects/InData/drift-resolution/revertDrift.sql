SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] DROP CONSTRAINT [FK_Agents_AgentGroups]
GO
PRINT N'Dropping foreign keys from [dbo].[AgentGroups]'
GO
ALTER TABLE [dbo].[AgentGroups] DROP CONSTRAINT [FK_AgentGroups_Customers]
GO
PRINT N'Dropping foreign keys from [dbo].[AgentSkills]'
GO
ALTER TABLE [dbo].[AgentSkills] DROP CONSTRAINT [FK_AgentSkills_Agents]
GO
ALTER TABLE [dbo].[AgentSkills] DROP CONSTRAINT [FK_AgentSkills_Skills]
GO
PRINT N'Dropping foreign keys from [dbo].[CustomerContracts]'
GO
ALTER TABLE [dbo].[CustomerContracts] DROP CONSTRAINT [FK_CustomerContracts_Customers]
GO
ALTER TABLE [dbo].[CustomerContracts] DROP CONSTRAINT [FK_CustomerContracts_ServiceTiers]
GO
PRINT N'Dropping foreign keys from [dbo].[Licenses]'
GO
ALTER TABLE [dbo].[Licenses] DROP CONSTRAINT [FK_Licenses_Customers]
GO
PRINT N'Dropping foreign keys from [dbo].[Sites]'
GO
ALTER TABLE [dbo].[Sites] DROP CONSTRAINT [FK_Sites_Regions]
GO
PRINT N'Dropping constraints from [dbo].[AgentGroups]'
GO
ALTER TABLE [dbo].[AgentGroups] DROP CONSTRAINT [PK_AgentGroups]
GO
PRINT N'Dropping constraints from [dbo].[AgentSkills]'
GO
ALTER TABLE [dbo].[AgentSkills] DROP CONSTRAINT [PK_AgentSkills]
GO
PRINT N'Dropping constraints from [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] DROP CONSTRAINT [PK_Agents]
GO
PRINT N'Dropping constraints from [dbo].[CustomerContracts]'
GO
ALTER TABLE [dbo].[CustomerContracts] DROP CONSTRAINT [PK_CustomerContracts]
GO
PRINT N'Dropping constraints from [dbo].[Customers]'
GO
ALTER TABLE [dbo].[Customers] DROP CONSTRAINT [PK_Customers]
GO
PRINT N'Dropping constraints from [dbo].[Licenses]'
GO
ALTER TABLE [dbo].[Licenses] DROP CONSTRAINT [PK_Licenses]
GO
PRINT N'Dropping constraints from [dbo].[Regions]'
GO
ALTER TABLE [dbo].[Regions] DROP CONSTRAINT [PK_Regions]
GO
PRINT N'Dropping constraints from [dbo].[ServiceTiers]'
GO
ALTER TABLE [dbo].[ServiceTiers] DROP CONSTRAINT [PK_ServiceTiers]
GO
PRINT N'Dropping constraints from [dbo].[Sites]'
GO
ALTER TABLE [dbo].[Sites] DROP CONSTRAINT [PK_Sites]
GO
PRINT N'Dropping constraints from [dbo].[Skills]'
GO
ALTER TABLE [dbo].[Skills] DROP CONSTRAINT [PK_Skills]
GO
PRINT N'Dropping constraints from [dbo].[AgentSkills]'
GO
ALTER TABLE [dbo].[AgentSkills] DROP CONSTRAINT [DF_AgentSkills_AssignedUtc]
GO
PRINT N'Dropping constraints from [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] DROP CONSTRAINT [DF_Agents_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[CustomerContracts]'
GO
ALTER TABLE [dbo].[CustomerContracts] DROP CONSTRAINT [DF_CustomerContracts_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[Customers]'
GO
ALTER TABLE [dbo].[Customers] DROP CONSTRAINT [DF_Customers_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[Regions]'
GO
ALTER TABLE [dbo].[Regions] DROP CONSTRAINT [DF_Regions_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[ServiceTiers]'
GO
ALTER TABLE [dbo].[ServiceTiers] DROP CONSTRAINT [DF_ServiceTiers_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[Sites]'
GO
ALTER TABLE [dbo].[Sites] DROP CONSTRAINT [DF_Sites_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[Skills]'
GO
ALTER TABLE [dbo].[Skills] DROP CONSTRAINT [DF_Skills_CreatedUtc]
GO
PRINT N'Dropping [dbo].[coreINCodeSproc8]'
GO
DROP PROCEDURE [dbo].[coreINCodeSproc8]
GO
PRINT N'Dropping [dbo].[ReplicatingTable]'
GO
DROP TABLE [dbo].[ReplicatingTable]
GO
PRINT N'Dropping [dbo].[NodeADrift]'
GO
DROP TABLE [dbo].[NodeADrift]
GO
PRINT N'Dropping [dbo].[Sites]'
GO
DROP TABLE [dbo].[Sites]
GO
PRINT N'Dropping [dbo].[Regions]'
GO
DROP TABLE [dbo].[Regions]
GO
PRINT N'Dropping [dbo].[Licenses]'
GO
DROP TABLE [dbo].[Licenses]
GO
PRINT N'Dropping [dbo].[ServiceTiers]'
GO
DROP TABLE [dbo].[ServiceTiers]
GO
PRINT N'Dropping [dbo].[CustomerContracts]'
GO
DROP TABLE [dbo].[CustomerContracts]
GO
PRINT N'Dropping [dbo].[Skills]'
GO
DROP TABLE [dbo].[Skills]
GO
PRINT N'Dropping [dbo].[AgentSkills]'
GO
DROP TABLE [dbo].[AgentSkills]
GO
PRINT N'Dropping [dbo].[Agents]'
GO
DROP TABLE [dbo].[Agents]
GO
PRINT N'Dropping [dbo].[AgentGroups]'
GO
DROP TABLE [dbo].[AgentGroups]
GO
PRINT N'Dropping [dbo].[Customers]'
GO
DROP TABLE [dbo].[Customers]
GO

