SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[Customers]'
GO
CREATE TABLE [dbo].[Customers]
(
[CustomerId] [int] NOT NULL IDENTITY(1, 1),
[CustomerName] [nvarchar] (200) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Customers_CreatedUtc] DEFAULT (sysutcdatetime()),
[TestSmokeColumn] [nvarchar] (50) NULL
)
GO
PRINT N'Creating primary key [PK_Customers] on [dbo].[Customers]'
GO
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerId])
GO
PRINT N'Creating [dbo].[AgentGroups]'
GO
CREATE TABLE [dbo].[AgentGroups]
(
[AgentGroupId] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [nvarchar] (200) NOT NULL,
[CustomerId] [int] NOT NULL
)
GO
PRINT N'Creating primary key [PK_AgentGroups] on [dbo].[AgentGroups]'
GO
ALTER TABLE [dbo].[AgentGroups] ADD CONSTRAINT [PK_AgentGroups] PRIMARY KEY CLUSTERED ([AgentGroupId])
GO
PRINT N'Creating [dbo].[Agents]'
GO
CREATE TABLE [dbo].[Agents]
(
[AgentId] [int] NOT NULL IDENTITY(1, 1),
[AgentGroupId] [int] NOT NULL,
[AgentName] [nvarchar] (200) NOT NULL,
[LastHeartbeatUtc] [datetime2] (0) NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Agents_CreatedUtc] DEFAULT (sysutcdatetime()),
[Steve] [nchar] (10) NULL,
[PhoneNumber] [nvarchar] (30) NULL,
[PhoneNumberx] [nvarchar] (30) NULL,
[PhoneNumberTen] [nvarchar] (30) NULL,
[RobReplic] [nvarchar] (30) NULL,
[version2Test] [nvarchar] (30) NULL,
[version3Test] [nvarchar] (30) NULL,
[NonReplic] [nvarchar] (30) NULL,
[NonReplicating2] [nvarchar] (30) NULL,
[NonReplicating3] [nvarchar] (30) NULL,
[NonReplicating4] [nvarchar] (30) NULL,
[NonReplicating5] [nvarchar] (30) NULL,
[NonReplicating6] [nvarchar] (30) NULL,
[ReplicatingChange7] [nvarchar] (30) NULL,
[ReplicatingChange8] [nvarchar] (30) NULL,
[ReplicatingChange9] [nvarchar] (30) NULL,
[ReplicatingChange10] [nvarchar] (30) NULL,
[CheckReportSmoke1] [nvarchar] (30) NULL,
[CheckReportSmoke2] [nvarchar] (30) NULL,
[CheckReportSmoke3] [nvarchar] (30) NULL,
[ReplicatingColumnChange01] [nvarchar] (30) NULL,
[ReplicatingColumnChange02] [nvarchar] (30) NULL,
[ReplicatingColumnChange03] [nvarchar] (30) NULL
)
GO
PRINT N'Creating primary key [PK_Agents] on [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] ADD CONSTRAINT [PK_Agents] PRIMARY KEY CLUSTERED ([AgentId])
GO
PRINT N'Creating [dbo].[AgentSkills]'
GO
CREATE TABLE [dbo].[AgentSkills]
(
[AgentSkillId] [bigint] NOT NULL IDENTITY(1, 1),
[AgentId] [int] NOT NULL,
[SkillId] [int] NOT NULL,
[ProficiencyLevel] [tinyint] NOT NULL,
[AssignedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_AgentSkills_AssignedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_AgentSkills] on [dbo].[AgentSkills]'
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [PK_AgentSkills] PRIMARY KEY CLUSTERED ([AgentSkillId])
GO
PRINT N'Creating [dbo].[Skills]'
GO
CREATE TABLE [dbo].[Skills]
(
[SkillId] [int] NOT NULL IDENTITY(1, 1),
[SkillName] [nvarchar] (100) NOT NULL,
[Category] [nvarchar] (50) NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Skills_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_Skills] on [dbo].[Skills]'
GO
ALTER TABLE [dbo].[Skills] ADD CONSTRAINT [PK_Skills] PRIMARY KEY CLUSTERED ([SkillId])
GO
PRINT N'Creating [dbo].[CustomerContracts]'
GO
CREATE TABLE [dbo].[CustomerContracts]
(
[ContractId] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerId] [int] NOT NULL,
[ServiceTierId] [int] NOT NULL,
[StartUtc] [datetime2] (0) NOT NULL,
[EndUtc] [datetime2] (0) NULL,
[Status] [nvarchar] (20) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_CustomerContracts_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_CustomerContracts] on [dbo].[CustomerContracts]'
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [PK_CustomerContracts] PRIMARY KEY CLUSTERED ([ContractId])
GO
PRINT N'Creating [dbo].[ServiceTiers]'
GO
CREATE TABLE [dbo].[ServiceTiers]
(
[ServiceTierId] [int] NOT NULL IDENTITY(1, 1),
[TierName] [nvarchar] (50) NOT NULL,
[PriorityRank] [int] NOT NULL,
[SlaMinutes] [int] NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ServiceTiers_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_ServiceTiers] on [dbo].[ServiceTiers]'
GO
ALTER TABLE [dbo].[ServiceTiers] ADD CONSTRAINT [PK_ServiceTiers] PRIMARY KEY CLUSTERED ([ServiceTierId])
GO
PRINT N'Creating [dbo].[Licenses]'
GO
CREATE TABLE [dbo].[Licenses]
(
[LicenseId] [int] NOT NULL IDENTITY(1, 1),
[CustomerId] [int] NOT NULL,
[LicenseKey] [nvarchar] (100) NOT NULL,
[ExpiresUtc] [datetime2] (0) NULL
)
GO
PRINT N'Creating primary key [PK_Licenses] on [dbo].[Licenses]'
GO
ALTER TABLE [dbo].[Licenses] ADD CONSTRAINT [PK_Licenses] PRIMARY KEY CLUSTERED ([LicenseId])
GO
PRINT N'Creating [dbo].[Regions]'
GO
CREATE TABLE [dbo].[Regions]
(
[RegionId] [int] NOT NULL IDENTITY(1, 1),
[RegionCode] [nvarchar] (10) NOT NULL,
[RegionName] [nvarchar] (100) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Regions_CreatedUtc] DEFAULT (sysutcdatetime()),
[Smoke_ReplNote] [nvarchar] (50) NULL,
[Smoke_ReplNoteDrift] [nvarchar] (50) NULL
)
GO
PRINT N'Creating primary key [PK_Regions] on [dbo].[Regions]'
GO
ALTER TABLE [dbo].[Regions] ADD CONSTRAINT [PK_Regions] PRIMARY KEY CLUSTERED ([RegionId])
GO
PRINT N'Creating [dbo].[Sites]'
GO
CREATE TABLE [dbo].[Sites]
(
[SiteId] [int] NOT NULL IDENTITY(1, 1),
[SiteName] [nvarchar] (200) NOT NULL,
[RegionId] [int] NOT NULL,
[IsActive] [bit] NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Sites_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_Sites] on [dbo].[Sites]'
GO
ALTER TABLE [dbo].[Sites] ADD CONSTRAINT [PK_Sites] PRIMARY KEY CLUSTERED ([SiteId])
GO
PRINT N'Creating [dbo].[NodeADrift]'
GO
CREATE TABLE [dbo].[NodeADrift]
(
[Drift] [int] NULL
)
GO
PRINT N'Creating [dbo].[ReplicatingTable]'
GO
CREATE TABLE [dbo].[ReplicatingTable]
(
[Test1] [int] NULL
)
GO
PRINT N'Creating [dbo].[coreINCodeSproc8]'
GO
CREATE PROCEDURE [dbo].[coreINCodeSproc8]
    @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
    PRINT @@SERVERNAME
END
GO
PRINT N'Adding foreign keys to [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] ADD CONSTRAINT [FK_Agents_AgentGroups] FOREIGN KEY ([AgentGroupId]) REFERENCES [dbo].[AgentGroups] ([AgentGroupId])
GO
PRINT N'Adding foreign keys to [dbo].[AgentGroups]'
GO
ALTER TABLE [dbo].[AgentGroups] ADD CONSTRAINT [FK_AgentGroups_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
PRINT N'Adding foreign keys to [dbo].[AgentSkills]'
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [FK_AgentSkills_Agents] FOREIGN KEY ([AgentId]) REFERENCES [dbo].[Agents] ([AgentId])
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [FK_AgentSkills_Skills] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[Skills] ([SkillId])
GO
PRINT N'Adding foreign keys to [dbo].[CustomerContracts]'
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [FK_CustomerContracts_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [FK_CustomerContracts_ServiceTiers] FOREIGN KEY ([ServiceTierId]) REFERENCES [dbo].[ServiceTiers] ([ServiceTierId])
GO
PRINT N'Adding foreign keys to [dbo].[Licenses]'
GO
ALTER TABLE [dbo].[Licenses] ADD CONSTRAINT [FK_Licenses_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
PRINT N'Adding foreign keys to [dbo].[Sites]'
GO
ALTER TABLE [dbo].[Sites] ADD CONSTRAINT [FK_Sites_Regions] FOREIGN KEY ([RegionId]) REFERENCES [dbo].[Regions] ([RegionId])
GO

