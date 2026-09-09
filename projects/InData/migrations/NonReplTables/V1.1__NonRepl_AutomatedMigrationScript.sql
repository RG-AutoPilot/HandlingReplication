SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[ActiveCallSessions]'
GO
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
PRINT N'Creating primary key [PK_ActiveCallSessions] on [dbo].[ActiveCallSessions]'
GO
ALTER TABLE [dbo].[ActiveCallSessions] ADD CONSTRAINT [PK_ActiveCallSessions] PRIMARY KEY CLUSTERED ([SessionId])
GO
PRINT N'Creating [dbo].[ActiveNodeConfig]'
GO
CREATE TABLE [dbo].[ActiveNodeConfig]
(
[ConfigKey] [nvarchar] (100) NOT NULL,
[ConfigValue] [nvarchar] (max) NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeConfig_UpdatedUtc] DEFAULT (sysutcdatetime()),
[TestID] [nchar] (10) NULL,
[new] [nchar] (10) NULL,
[steven] [nchar] (10) NULL
)
GO
PRINT N'Creating primary key [PK_ActiveNodeConfig] on [dbo].[ActiveNodeConfig]'
GO
ALTER TABLE [dbo].[ActiveNodeConfig] ADD CONSTRAINT [PK_ActiveNodeConfig] PRIMARY KEY CLUSTERED ([ConfigKey])
GO
PRINT N'Creating [dbo].[ActiveNodeJobQueue]'
GO
CREATE TABLE [dbo].[ActiveNodeJobQueue]
(
[JobId] [bigint] NOT NULL IDENTITY(1, 1),
[JobType] [nvarchar] (100) NOT NULL,
[PayloadJson] [nvarchar] (max) NULL,
[EnqueuedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeJobQueue_EnqueuedUtc] DEFAULT (sysutcdatetime()),
[ProcessedUtc] [datetime2] (0) NULL
)
GO
PRINT N'Creating primary key [PK_ActiveNodeJobQueue] on [dbo].[ActiveNodeJobQueue]'
GO
ALTER TABLE [dbo].[ActiveNodeJobQueue] ADD CONSTRAINT [PK_ActiveNodeJobQueue] PRIMARY KEY CLUSTERED ([JobId])
GO
PRINT N'Creating [dbo].[ActiveNodeMetrics]'
GO
CREATE TABLE [dbo].[ActiveNodeMetrics]
(
[MetricId] [bigint] NOT NULL IDENTITY(1, 1),
[MetricName] [nvarchar] (100) NOT NULL,
[MetricValue] [bigint] NOT NULL,
[CapturedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeMetrics_CapturedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_ActiveNodeMetrics] on [dbo].[ActiveNodeMetrics]'
GO
ALTER TABLE [dbo].[ActiveNodeMetrics] ADD CONSTRAINT [PK_ActiveNodeMetrics] PRIMARY KEY CLUSTERED ([MetricId])
GO
PRINT N'Creating [dbo].[AgentPresence]'
GO
CREATE TABLE [dbo].[AgentPresence]
(
[AgentPresenceId] [bigint] NOT NULL IDENTITY(1, 1),
[AgentId] [int] NOT NULL,
[StatusCode] [nvarchar] (20) NOT NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_AgentPresence_UpdatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_AgentPresence] on [dbo].[AgentPresence]'
GO
ALTER TABLE [dbo].[AgentPresence] ADD CONSTRAINT [PK_AgentPresence] PRIMARY KEY CLUSTERED ([AgentPresenceId])
GO
PRINT N'Creating [dbo].[DailyAgentActivityRollup]'
GO
CREATE TABLE [dbo].[DailyAgentActivityRollup]
(
[RollupId] [bigint] NOT NULL IDENTITY(1, 1),
[RollupDate] [date] NOT NULL,
[AgentId] [int] NOT NULL,
[CallsHandled] [int] NOT NULL CONSTRAINT [DF_DailyAgentActivityRollup_CallsHandled] DEFAULT ((0)),
[MinutesActive] [int] NOT NULL CONSTRAINT [DF_DailyAgentActivityRollup_MinutesActive] DEFAULT ((0))
)
GO
PRINT N'Creating primary key [PK_DailyAgentActivityRollup] on [dbo].[DailyAgentActivityRollup]'
GO
ALTER TABLE [dbo].[DailyAgentActivityRollup] ADD CONSTRAINT [PK_DailyAgentActivityRollup] PRIMARY KEY CLUSTERED ([RollupId])
GO
PRINT N'Creating [dbo].[FailoverReadinessLog]'
GO
CREATE TABLE [dbo].[FailoverReadinessLog]
(
[LogId] [bigint] NOT NULL IDENTITY(1, 1),
[RecordedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_FailoverReadinessLog_RecordedUtc] DEFAULT (sysutcdatetime()),
[ReadyForFailover] [bit] NOT NULL,
[Notes] [nvarchar] (max) NULL
)
GO
PRINT N'Creating primary key [PK_FailoverReadinessLog] on [dbo].[FailoverReadinessLog]'
GO
ALTER TABLE [dbo].[FailoverReadinessLog] ADD CONSTRAINT [PK_FailoverReadinessLog] PRIMARY KEY CLUSTERED ([LogId])
GO
PRINT N'Creating [dbo].[IngestBatchLog]'
GO
CREATE TABLE [dbo].[IngestBatchLog]
(
[BatchId] [bigint] NOT NULL IDENTITY(1, 1),
[BatchName] [nvarchar] (200) NOT NULL,
[RowsProcessed] [bigint] NOT NULL CONSTRAINT [DF_IngestBatchLog_RowsProcessed] DEFAULT ((0)),
[StartedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_IngestBatchLog_StartedUtc] DEFAULT (sysutcdatetime()),
[CompletedUtc] [datetime2] (0) NULL,
[RowsNeedingProcessed] [int] NULL,
[RowsProcessedTen] [int] NULL,
[RobNon] [int] NULL,
[version2Test] [int] NULL,
[version3Test] [int] NULL,
[ReplicChange] [int] NULL,
[ReplicatingChange] [int] NULL,
[ReplicatingChange2] [int] NULL,
[ReplicatingChange3] [int] NULL,
[ReplicatingChange4] [int] NULL,
[ReplicatingChange5] [int] NULL,
[ReplicatingChange6] [int] NULL
)
GO
PRINT N'Creating primary key [PK_IngestBatchLog] on [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] ADD CONSTRAINT [PK_IngestBatchLog] PRIMARY KEY CLUSTERED ([BatchId])
GO
PRINT N'Creating [dbo].[IngestErrorQueue]'
GO
CREATE TABLE [dbo].[IngestErrorQueue]
(
[ErrorId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceJobId] [bigint] NULL,
[ErrorMessage] [nvarchar] (max) NOT NULL,
[FailedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_IngestErrorQueue_FailedUtc] DEFAULT (sysutcdatetime()),
[RetryCount] [int] NOT NULL CONSTRAINT [DF_IngestErrorQueue_RetryCount] DEFAULT ((0))
)
GO
PRINT N'Creating primary key [PK_IngestErrorQueue] on [dbo].[IngestErrorQueue]'
GO
ALTER TABLE [dbo].[IngestErrorQueue] ADD CONSTRAINT [PK_IngestErrorQueue] PRIMARY KEY CLUSTERED ([ErrorId])
GO
PRINT N'Creating [dbo].[LicenseAuditSnapshot]'
GO
CREATE TABLE [dbo].[LicenseAuditSnapshot]
(
[SnapshotId] [bigint] NOT NULL IDENTITY(1, 1),
[SnapshotUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LicenseAuditSnapshot_SnapshotUtc] DEFAULT (sysutcdatetime()),
[LicenseId] [int] NOT NULL,
[CustomerId] [int] NULL,
[IsActive] [bit] NOT NULL
)
GO
PRINT N'Creating primary key [PK_LicenseAuditSnapshot] on [dbo].[LicenseAuditSnapshot]'
GO
ALTER TABLE [dbo].[LicenseAuditSnapshot] ADD CONSTRAINT [PK_LicenseAuditSnapshot] PRIMARY KEY CLUSTERED ([SnapshotId])
GO
PRINT N'Creating [dbo].[LocalIngestStaging]'
GO
CREATE TABLE [dbo].[LocalIngestStaging]
(
[StagingId] [bigint] NOT NULL IDENTITY(1, 1),
[SourceSystem] [nvarchar] (100) NOT NULL,
[RawPayload] [nvarchar] (max) NULL,
[ReceivedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LocalIngestStaging_ReceivedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_LocalIngestStaging] on [dbo].[LocalIngestStaging]'
GO
ALTER TABLE [dbo].[LocalIngestStaging] ADD CONSTRAINT [PK_LocalIngestStaging] PRIMARY KEY CLUSTERED ([StagingId])
GO
PRINT N'Creating [dbo].[PassiveNodeConfig]'
GO
CREATE TABLE [dbo].[PassiveNodeConfig]
(
[ConfigKey] [nvarchar] (100) NOT NULL,
[ConfigValue] [nvarchar] (max) NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_PassiveNodeConfig_UpdatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_PassiveNodeConfig] on [dbo].[PassiveNodeConfig]'
GO
ALTER TABLE [dbo].[PassiveNodeConfig] ADD CONSTRAINT [PK_PassiveNodeConfig] PRIMARY KEY CLUSTERED ([ConfigKey])
GO
PRINT N'Creating [dbo].[PassiveNodeHealthCheck]'
GO
CREATE TABLE [dbo].[PassiveNodeHealthCheck]
(
[HealthCheckId] [bigint] NOT NULL IDENTITY(1, 1),
[CheckedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_PassiveNodeHealthCheck_CheckedUtc] DEFAULT (sysutcdatetime()),
[IsHealthy] [bit] NOT NULL,
[Details] [nvarchar] (max) NULL
)
GO
PRINT N'Creating primary key [PK_PassiveNodeHealthCheck] on [dbo].[PassiveNodeHealthCheck]'
GO
ALTER TABLE [dbo].[PassiveNodeHealthCheck] ADD CONSTRAINT [PK_PassiveNodeHealthCheck] PRIMARY KEY CLUSTERED ([HealthCheckId])
GO
PRINT N'Creating [dbo].[ReportRunHistory]'
GO
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
PRINT N'Creating primary key [PK_ReportRunHistory] on [dbo].[ReportRunHistory]'
GO
ALTER TABLE [dbo].[ReportRunHistory] ADD CONSTRAINT [PK_ReportRunHistory] PRIMARY KEY CLUSTERED ([RunId])
GO
PRINT N'Creating [dbo].[ReportSchedule]'
GO
CREATE TABLE [dbo].[ReportSchedule]
(
[ScheduleId] [int] NOT NULL IDENTITY(1, 1),
[ReportName] [nvarchar] (200) NOT NULL,
[CronExpression] [nvarchar] (100) NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_ReportSchedule_IsEnabled] DEFAULT ((1)),
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ReportSchedule_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
PRINT N'Creating primary key [PK_ReportSchedule] on [dbo].[ReportSchedule]'
GO
ALTER TABLE [dbo].[ReportSchedule] ADD CONSTRAINT [PK_ReportSchedule] PRIMARY KEY CLUSTERED ([ScheduleId])
GO
PRINT N'Creating [dbo].[RoutingDecisionCache]'
GO
CREATE TABLE [dbo].[RoutingDecisionCache]
(
[DecisionId] [bigint] NOT NULL IDENTITY(1, 1),
[IncomingKey] [nvarchar] (200) NOT NULL,
[TargetAgentId] [int] NULL,
[DecidedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_RoutingDecisionCache_DecidedUtc] DEFAULT (sysutcdatetime()),
[ExpiresUtc] [datetime2] (0) NULL
)
GO
PRINT N'Creating primary key [PK_RoutingDecisionCache] on [dbo].[RoutingDecisionCache]'
GO
ALTER TABLE [dbo].[RoutingDecisionCache] ADD CONSTRAINT [PK_RoutingDecisionCache] PRIMARY KEY CLUSTERED ([DecisionId])
GO
PRINT N'Creating [dbo].[WarmStandbyProbeLog]'
GO
CREATE TABLE [dbo].[WarmStandbyProbeLog]
(
[ProbeId] [bigint] NOT NULL IDENTITY(1, 1),
[ProbeName] [nvarchar] (100) NOT NULL,
[ProbedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_WarmStandbyProbeLog_ProbedUtc] DEFAULT (sysutcdatetime()),
[Success] [bit] NOT NULL,
[DetailsJson] [nvarchar] (max) NULL
)
GO
PRINT N'Creating primary key [PK_WarmStandbyProbeLog] on [dbo].[WarmStandbyProbeLog]'
GO
ALTER TABLE [dbo].[WarmStandbyProbeLog] ADD CONSTRAINT [PK_WarmStandbyProbeLog] PRIMARY KEY CLUSTERED ([ProbeId])
GO
PRINT N'Creating [dbo].[HistoricalCallSummary]'
GO
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
PRINT N'Creating primary key [PK_HistoricalCallSummary] on [dbo].[HistoricalCallSummary]'
GO
ALTER TABLE [dbo].[HistoricalCallSummary] ADD CONSTRAINT [PK_HistoricalCallSummary] PRIMARY KEY CLUSTERED ([SummaryId])
GO
PRINT N'Creating [dbo].[LocalReportCache]'
GO
CREATE TABLE [dbo].[LocalReportCache]
(
[CacheKey] [nvarchar] (200) NOT NULL,
[CachedValue] [nvarchar] (max) NULL,
[ExpiresUtc] [datetime2] (0) NULL
)
GO
PRINT N'Creating primary key [PK_LocalReportCache] on [dbo].[LocalReportCache]'
GO
ALTER TABLE [dbo].[LocalReportCache] ADD CONSTRAINT [PK_LocalReportCache] PRIMARY KEY CLUSTERED ([CacheKey])
GO
PRINT N'Creating [dbo].[ReplicationWatermark]'
GO
CREATE TABLE [dbo].[ReplicationWatermark]
(
[WatermarkId] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (200) NOT NULL,
[LastSyncedUtc] [datetime2] (0) NOT NULL,
[Test] [nchar] (10) NULL
)
GO
PRINT N'Creating primary key [PK_ReplicationWatermark] on [dbo].[ReplicationWatermark]'
GO
ALTER TABLE [dbo].[ReplicationWatermark] ADD CONSTRAINT [PK_ReplicationWatermark] PRIMARY KEY CLUSTERED ([WatermarkId])
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
PRINT N'Adding foreign keys to [dbo].[ReportRunHistory]'
GO
ALTER TABLE [dbo].[ReportRunHistory] ADD CONSTRAINT [FK_ReportRunHistory_ReportSchedule] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[ReportSchedule] ([ScheduleId])
GO

