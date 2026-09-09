/*
    CreateDevDatabase.sql
    Project: InData

    Creates a single, standalone dev database for the InData project and
    populates it with every table this project owns. In dev there is only
    one physical database, no node A / node B split, no replication
    configured. The production-side split (replicated pool vs
    non-replicated, deployed across two nodes) is encoded via manifest.yaml
    and the migrations/ReplTables and migrations/NonReplTables folders,
    NOT simulated at the dev-database level.

    Every table below carries a "Replicated: true/false" comment above its
    DDL, matching the flag in manifest.yaml and the header comment already
    present in each schema-model file. The DEV database treats them all as
    ordinary tables, but downstream tooling and CLAUDE.md's routing rules
    read the flag to decide deploy behaviour and migration folder.

    Idempotent by short-circuit: if the database already exists with tables
    in it, the script bails without re-running the DDL. Wipe the database
    to get a clean re-run.

    Run once against your dev SQL Server instance.
*/

IF DB_ID(N'CoreInData_Dev') IS NULL
BEGIN
    CREATE DATABASE CoreInData_Dev;
END
GO

ALTER DATABASE CoreInData_Dev SET RECOVERY SIMPLE;
GO

USE CoreInData_Dev;
GO

-- Short-circuit: if the DB is already populated, don't re-run the DDL.
IF EXISTS (SELECT 1 FROM sys.tables WHERE [name] = N'Customers' AND SCHEMA_NAME([schema_id]) = N'dbo')
BEGIN
    PRINT 'CoreInData_Dev already populated; skipping table creation.';
    SET NOEXEC ON;
END
GO

-- =========================================================================
-- dbo.Customers
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Customers]
(
[CustomerId] [int] NOT NULL IDENTITY(1, 1),
[CustomerName] [nvarchar] (200) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Customers_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerId])
GO

-- =========================================================================
-- dbo.Regions
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Regions]
(
[RegionId] [int] NOT NULL IDENTITY(1, 1),
[RegionCode] [nvarchar] (10) NOT NULL,
[RegionName] [nvarchar] (100) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Regions_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Regions] ADD CONSTRAINT [PK_Regions] PRIMARY KEY CLUSTERED ([RegionId])
GO

-- =========================================================================
-- dbo.ServiceTiers
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[ServiceTiers]
(
[ServiceTierId] [int] NOT NULL IDENTITY(1, 1),
[TierName] [nvarchar] (50) NOT NULL,
[PriorityRank] [int] NOT NULL,
[SlaMinutes] [int] NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ServiceTiers_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[ServiceTiers] ADD CONSTRAINT [PK_ServiceTiers] PRIMARY KEY CLUSTERED ([ServiceTierId])
GO

-- =========================================================================
-- dbo.Skills
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Skills]
(
[SkillId] [int] NOT NULL IDENTITY(1, 1),
[SkillName] [nvarchar] (100) NOT NULL,
[Category] [nvarchar] (50) NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Skills_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Skills] ADD CONSTRAINT [PK_Skills] PRIMARY KEY CLUSTERED ([SkillId])
GO

-- =========================================================================
-- dbo.ReportSchedule
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ReportSchedule]
(
[ScheduleId] [int] NOT NULL IDENTITY(1, 1),
[ReportName] [nvarchar] (200) NOT NULL,
[CronExpression] [nvarchar] (100) NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_ReportSchedule_IsEnabled] DEFAULT (1),
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ReportSchedule_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[ReportSchedule] ADD CONSTRAINT [PK_ReportSchedule] PRIMARY KEY CLUSTERED ([ScheduleId])
GO

-- =========================================================================
-- dbo.AgentGroups
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[AgentGroups]
(
[AgentGroupId] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [nvarchar] (200) NOT NULL,
[CustomerId] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[AgentGroups] ADD CONSTRAINT [PK_AgentGroups] PRIMARY KEY CLUSTERED ([AgentGroupId])
GO
ALTER TABLE [dbo].[AgentGroups] ADD CONSTRAINT [FK_AgentGroups_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO

-- =========================================================================
-- dbo.Sites
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Sites]
(
[SiteId] [int] NOT NULL IDENTITY(1, 1),
[SiteName] [nvarchar] (200) NOT NULL,
[RegionId] [int] NOT NULL,
[IsActive] [bit] NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Sites_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Sites] ADD CONSTRAINT [PK_Sites] PRIMARY KEY CLUSTERED ([SiteId])
GO
ALTER TABLE [dbo].[Sites] ADD CONSTRAINT [FK_Sites_Regions] FOREIGN KEY ([RegionId]) REFERENCES [dbo].[Regions] ([RegionId])
GO

-- =========================================================================
-- dbo.CustomerContracts
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
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
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [PK_CustomerContracts] PRIMARY KEY CLUSTERED ([ContractId])
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [FK_CustomerContracts_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [FK_CustomerContracts_ServiceTiers] FOREIGN KEY ([ServiceTierId]) REFERENCES [dbo].[ServiceTiers] ([ServiceTierId])
GO

-- =========================================================================
-- dbo.Licenses
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Licenses]
(
[LicenseId] [int] NOT NULL IDENTITY(1, 1),
[CustomerId] [int] NOT NULL,
[LicenseKey] [nvarchar] (100) NOT NULL,
[ExpiresUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[Licenses] ADD CONSTRAINT [PK_Licenses] PRIMARY KEY CLUSTERED ([LicenseId])
GO
ALTER TABLE [dbo].[Licenses] ADD CONSTRAINT [FK_Licenses_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO

-- =========================================================================
-- dbo.ReportRunHistory
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ReportRunHistory]
(
[RunId] [bigint] NOT NULL IDENTITY(1, 1),
[ScheduleId] [int] NOT NULL,
[StartedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ReportRunHistory_StartedUtc] DEFAULT (sysutcdatetime()),
[CompletedUtc] [datetime2] (0) NULL,
[Status] [nvarchar] (20) NOT NULL,
[RowsProduced] [bigint] NULL
)
GO
ALTER TABLE [dbo].[ReportRunHistory] ADD CONSTRAINT [PK_ReportRunHistory] PRIMARY KEY CLUSTERED ([RunId])
GO
ALTER TABLE [dbo].[ReportRunHistory] ADD CONSTRAINT [FK_ReportRunHistory_ReportSchedule] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[ReportSchedule] ([ScheduleId])
GO

-- =========================================================================
-- dbo.Agents
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Agents]
(
[AgentId] [int] NOT NULL IDENTITY(1, 1),
[AgentGroupId] [int] NOT NULL,
[AgentName] [nvarchar] (200) NOT NULL,
[LastHeartbeatUtc] [datetime2] (0) NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Agents_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Agents] ADD CONSTRAINT [PK_Agents] PRIMARY KEY CLUSTERED ([AgentId])
GO
ALTER TABLE [dbo].[Agents] ADD CONSTRAINT [FK_Agents_AgentGroups] FOREIGN KEY ([AgentGroupId]) REFERENCES [dbo].[AgentGroups] ([AgentGroupId])
GO

-- =========================================================================
-- dbo.AgentSkills
-- =========================================================================
-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[AgentSkills]
(
[AgentSkillId] [bigint] NOT NULL IDENTITY(1, 1),
[AgentId] [int] NOT NULL,
[SkillId] [int] NOT NULL,
[ProficiencyLevel] [tinyint] NOT NULL,
[AssignedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_AgentSkills_AssignedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [PK_AgentSkills] PRIMARY KEY CLUSTERED ([AgentSkillId])
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [FK_AgentSkills_Agents] FOREIGN KEY ([AgentId]) REFERENCES [dbo].[Agents] ([AgentId])
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [FK_AgentSkills_Skills] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[Skills] ([SkillId])
GO

-- =========================================================================
-- dbo.ActiveCallSessions
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ActiveCallSessions]
(
[SessionId] [bigint] NOT NULL IDENTITY(1, 1),
[AgentId] [int] NOT NULL,
[CustomerId] [int] NULL,
[StartedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveCallSessions_StartedUtc] DEFAULT (sysutcdatetime()),
[LastActivityUtc] [datetime2] (0) NULL,
[State] [nvarchar] (30) NOT NULL
)
GO
ALTER TABLE [dbo].[ActiveCallSessions] ADD CONSTRAINT [PK_ActiveCallSessions] PRIMARY KEY CLUSTERED ([SessionId])
GO

-- =========================================================================
-- dbo.ActiveNodeConfig
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ActiveNodeConfig]
(
[ConfigKey] [nvarchar] (100) NOT NULL,
[ConfigValue] [nvarchar] (max) NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeConfig_UpdatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[ActiveNodeConfig] ADD CONSTRAINT [PK_ActiveNodeConfig] PRIMARY KEY CLUSTERED ([ConfigKey])
GO

-- =========================================================================
-- dbo.ActiveNodeJobQueue
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ActiveNodeJobQueue]
(
[JobId] [bigint] NOT NULL IDENTITY(1, 1),
[JobType] [nvarchar] (100) NOT NULL,
[PayloadJson] [nvarchar] (max) NULL,
[EnqueuedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeJobQueue_EnqueuedUtc] DEFAULT (sysutcdatetime()),
[ProcessedUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[ActiveNodeJobQueue] ADD CONSTRAINT [PK_ActiveNodeJobQueue] PRIMARY KEY CLUSTERED ([JobId])
GO

-- =========================================================================
-- dbo.ActiveNodeMetrics
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ActiveNodeMetrics]
(
[MetricId] [bigint] NOT NULL IDENTITY(1, 1),
[MetricName] [nvarchar] (100) NOT NULL,
[MetricValue] [bigint] NOT NULL,
[CapturedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeMetrics_CapturedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[ActiveNodeMetrics] ADD CONSTRAINT [PK_ActiveNodeMetrics] PRIMARY KEY CLUSTERED ([MetricId])
GO

-- =========================================================================
-- dbo.AgentPresence
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[AgentPresence]
(
[AgentPresenceId] [bigint] NOT NULL IDENTITY(1, 1),
[AgentId] [int] NOT NULL,
[StatusCode] [nvarchar] (20) NOT NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_AgentPresence_UpdatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[AgentPresence] ADD CONSTRAINT [PK_AgentPresence] PRIMARY KEY CLUSTERED ([AgentPresenceId])
GO

-- =========================================================================
-- dbo.DailyAgentActivityRollup
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[DailyAgentActivityRollup]
(
[RollupId] [bigint] NOT NULL IDENTITY(1, 1),
[RollupDate] [date] NOT NULL,
[AgentId] [int] NOT NULL,
[CallsHandled] [int] NOT NULL CONSTRAINT [DF_DailyAgentActivityRollup_CallsHandled] DEFAULT (0),
[MinutesActive] [int] NOT NULL CONSTRAINT [DF_DailyAgentActivityRollup_MinutesActive] DEFAULT (0)
)
GO
ALTER TABLE [dbo].[DailyAgentActivityRollup] ADD CONSTRAINT [PK_DailyAgentActivityRollup] PRIMARY KEY CLUSTERED ([RollupId])
GO

-- =========================================================================
-- dbo.FailoverReadinessLog
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[FailoverReadinessLog]
(
[LogId] [bigint] NOT NULL IDENTITY(1, 1),
[RecordedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_FailoverReadinessLog_RecordedUtc] DEFAULT (sysutcdatetime()),
[ReadyForFailover] [bit] NOT NULL,
[Notes] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[FailoverReadinessLog] ADD CONSTRAINT [PK_FailoverReadinessLog] PRIMARY KEY CLUSTERED ([LogId])
GO

-- =========================================================================
-- dbo.HistoricalCallSummary
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[HistoricalCallSummary]
(
[SummaryId] [bigint] NOT NULL IDENTITY(1, 1),
[CallSessionId] [bigint] NOT NULL,
[AgentId] [int] NOT NULL,
[CustomerId] [int] NULL,
[DurationSeconds] [int] NOT NULL,
[EndedUtc] [datetime2] (0) NOT NULL
)
GO
ALTER TABLE [dbo].[HistoricalCallSummary] ADD CONSTRAINT [PK_HistoricalCallSummary] PRIMARY KEY CLUSTERED ([SummaryId])
GO

-- =========================================================================
-- dbo.IngestBatchLog
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LocalIngestStaging]
(
[StagingId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceSystem] [nvarchar] (100) NOT NULL,
[RawPayload] [nvarchar] (max) NULL,
[ReceivedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LocalIngestStaging_ReceivedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[LocalIngestStaging] ADD CONSTRAINT [PK_LocalIngestStaging] PRIMARY KEY CLUSTERED ([StagingId])
GO

-- =========================================================================
-- dbo.LocalReportCache
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LocalReportCache]
(
[CacheKey] [nvarchar] (200) NOT NULL,
[CachedValue] [nvarchar] (max) NULL,
[ExpiresUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[LocalReportCache] ADD CONSTRAINT [PK_LocalReportCache] PRIMARY KEY CLUSTERED ([CacheKey])
GO

-- =========================================================================
-- dbo.PassiveNodeConfig
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[PassiveNodeConfig]
(
[ConfigKey] [nvarchar] (100) NOT NULL,
[ConfigValue] [nvarchar] (max) NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_PassiveNodeConfig_UpdatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[PassiveNodeConfig] ADD CONSTRAINT [PK_PassiveNodeConfig] PRIMARY KEY CLUSTERED ([ConfigKey])
GO

-- =========================================================================
-- dbo.PassiveNodeHealthCheck
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[PassiveNodeHealthCheck]
(
[HealthCheckId] [bigint] NOT NULL IDENTITY(1, 1),
[CheckedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_PassiveNodeHealthCheck_CheckedUtc] DEFAULT (sysutcdatetime()),
[IsHealthy] [bit] NOT NULL,
[Details] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[PassiveNodeHealthCheck] ADD CONSTRAINT [PK_PassiveNodeHealthCheck] PRIMARY KEY CLUSTERED ([HealthCheckId])
GO

-- =========================================================================
-- dbo.ReplicationWatermark
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ReplicationWatermark]
(
[WatermarkId] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (200) NOT NULL,
[LastSyncedUtc] [datetime2] (0) NOT NULL
)
GO
ALTER TABLE [dbo].[ReplicationWatermark] ADD CONSTRAINT [PK_ReplicationWatermark] PRIMARY KEY CLUSTERED ([WatermarkId])
GO

-- =========================================================================
-- dbo.RoutingDecisionCache
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[RoutingDecisionCache]
(
[DecisionId] [bigint] NOT NULL IDENTITY(1, 1),
[IncomingKey] [nvarchar] (200) NOT NULL,
[TargetAgentId] [int] NULL,
[DecidedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_RoutingDecisionCache_DecidedUtc] DEFAULT (sysutcdatetime()),
[ExpiresUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[RoutingDecisionCache] ADD CONSTRAINT [PK_RoutingDecisionCache] PRIMARY KEY CLUSTERED ([DecisionId])
GO

-- =========================================================================
-- dbo.WarmStandbyProbeLog
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[WarmStandbyProbeLog]
(
[ProbeId] [bigint] NOT NULL IDENTITY(1, 1),
[ProbeName] [nvarchar] (100) NOT NULL,
[ProbedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_WarmStandbyProbeLog_ProbedUtc] DEFAULT (sysutcdatetime()),
[Success] [bit] NOT NULL,
[DetailsJson] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[WarmStandbyProbeLog] ADD CONSTRAINT [PK_WarmStandbyProbeLog] PRIMARY KEY CLUSTERED ([ProbeId])
GO

-- =========================================================================
-- dbo.IngestErrorQueue
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[IngestErrorQueue]
(
[ErrorId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceJobId] [bigint] NULL,
[ErrorMessage] [nvarchar] (max) NOT NULL,
[FailedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_IngestErrorQueue_FailedUtc] DEFAULT (sysutcdatetime()),
[RetryCount] [int] NOT NULL CONSTRAINT [DF_IngestErrorQueue_RetryCount] DEFAULT (0)
)
GO
ALTER TABLE [dbo].[IngestErrorQueue] ADD CONSTRAINT [PK_IngestErrorQueue] PRIMARY KEY CLUSTERED ([ErrorId])
GO

-- =========================================================================
-- dbo.LicenseAuditSnapshot
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LicenseAuditSnapshot]
(
[SnapshotId] [bigint] NOT NULL IDENTITY(1, 1),
[SnapshotUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LicenseAuditSnapshot_SnapshotUtc] DEFAULT (sysutcdatetime()),
[LicenseId] [int] NOT NULL,
[CustomerId] [int] NULL,
[IsActive] [bit] NOT NULL
)
GO
ALTER TABLE [dbo].[LicenseAuditSnapshot] ADD CONSTRAINT [PK_LicenseAuditSnapshot] PRIMARY KEY CLUSTERED ([SnapshotId])
GO

-- =========================================================================
-- dbo.LocalIngestStaging
-- =========================================================================
-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LocalIngestStaging]
(
[StagingId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceSystem] [nvarchar] (100) NOT NULL,
[RawPayload] [nvarchar] (max) NULL,
[ReceivedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LocalIngestStaging_ReceivedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[LocalIngestStaging] ADD CONSTRAINT [PK_LocalIngestStaging] PRIMARY KEY CLUSTERED ([StagingId])
GO

SET NOEXEC OFF;
GO
