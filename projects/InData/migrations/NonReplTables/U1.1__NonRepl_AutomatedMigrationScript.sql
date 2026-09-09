SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [dbo].[ReportRunHistory]'
GO
ALTER TABLE [dbo].[ReportRunHistory] DROP CONSTRAINT [FK_ReportRunHistory_ReportSchedule]
GO
PRINT N'Dropping constraints from [dbo].[ActiveCallSessions]'
GO
ALTER TABLE [dbo].[ActiveCallSessions] DROP CONSTRAINT [PK_ActiveCallSessions]
GO
PRINT N'Dropping constraints from [dbo].[ActiveNodeConfig]'
GO
ALTER TABLE [dbo].[ActiveNodeConfig] DROP CONSTRAINT [PK_ActiveNodeConfig]
GO
PRINT N'Dropping constraints from [dbo].[ActiveNodeJobQueue]'
GO
ALTER TABLE [dbo].[ActiveNodeJobQueue] DROP CONSTRAINT [PK_ActiveNodeJobQueue]
GO
PRINT N'Dropping constraints from [dbo].[ActiveNodeMetrics]'
GO
ALTER TABLE [dbo].[ActiveNodeMetrics] DROP CONSTRAINT [PK_ActiveNodeMetrics]
GO
PRINT N'Dropping constraints from [dbo].[AgentPresence]'
GO
ALTER TABLE [dbo].[AgentPresence] DROP CONSTRAINT [PK_AgentPresence]
GO
PRINT N'Dropping constraints from [dbo].[DailyAgentActivityRollup]'
GO
ALTER TABLE [dbo].[DailyAgentActivityRollup] DROP CONSTRAINT [PK_DailyAgentActivityRollup]
GO
PRINT N'Dropping constraints from [dbo].[FailoverReadinessLog]'
GO
ALTER TABLE [dbo].[FailoverReadinessLog] DROP CONSTRAINT [PK_FailoverReadinessLog]
GO
PRINT N'Dropping constraints from [dbo].[HistoricalCallSummary]'
GO
ALTER TABLE [dbo].[HistoricalCallSummary] DROP CONSTRAINT [PK_HistoricalCallSummary]
GO
PRINT N'Dropping constraints from [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] DROP CONSTRAINT [PK_IngestBatchLog]
GO
PRINT N'Dropping constraints from [dbo].[IngestErrorQueue]'
GO
ALTER TABLE [dbo].[IngestErrorQueue] DROP CONSTRAINT [PK_IngestErrorQueue]
GO
PRINT N'Dropping constraints from [dbo].[LicenseAuditSnapshot]'
GO
ALTER TABLE [dbo].[LicenseAuditSnapshot] DROP CONSTRAINT [PK_LicenseAuditSnapshot]
GO
PRINT N'Dropping constraints from [dbo].[LocalIngestStaging]'
GO
ALTER TABLE [dbo].[LocalIngestStaging] DROP CONSTRAINT [PK_LocalIngestStaging]
GO
PRINT N'Dropping constraints from [dbo].[LocalReportCache]'
GO
ALTER TABLE [dbo].[LocalReportCache] DROP CONSTRAINT [PK_LocalReportCache]
GO
PRINT N'Dropping constraints from [dbo].[PassiveNodeConfig]'
GO
ALTER TABLE [dbo].[PassiveNodeConfig] DROP CONSTRAINT [PK_PassiveNodeConfig]
GO
PRINT N'Dropping constraints from [dbo].[PassiveNodeHealthCheck]'
GO
ALTER TABLE [dbo].[PassiveNodeHealthCheck] DROP CONSTRAINT [PK_PassiveNodeHealthCheck]
GO
PRINT N'Dropping constraints from [dbo].[ReplicationWatermark]'
GO
ALTER TABLE [dbo].[ReplicationWatermark] DROP CONSTRAINT [PK_ReplicationWatermark]
GO
PRINT N'Dropping constraints from [dbo].[ReportRunHistory]'
GO
ALTER TABLE [dbo].[ReportRunHistory] DROP CONSTRAINT [PK_ReportRunHistory]
GO
PRINT N'Dropping constraints from [dbo].[ReportSchedule]'
GO
ALTER TABLE [dbo].[ReportSchedule] DROP CONSTRAINT [PK_ReportSchedule]
GO
PRINT N'Dropping constraints from [dbo].[RoutingDecisionCache]'
GO
ALTER TABLE [dbo].[RoutingDecisionCache] DROP CONSTRAINT [PK_RoutingDecisionCache]
GO
PRINT N'Dropping constraints from [dbo].[WarmStandbyProbeLog]'
GO
ALTER TABLE [dbo].[WarmStandbyProbeLog] DROP CONSTRAINT [PK_WarmStandbyProbeLog]
GO
PRINT N'Dropping constraints from [dbo].[ActiveCallSessions]'
GO
ALTER TABLE [dbo].[ActiveCallSessions] DROP CONSTRAINT [DF_ActiveCallSessions_StartedUtc]
GO
PRINT N'Dropping constraints from [dbo].[ActiveNodeConfig]'
GO
ALTER TABLE [dbo].[ActiveNodeConfig] DROP CONSTRAINT [DF_ActiveNodeConfig_UpdatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[ActiveNodeJobQueue]'
GO
ALTER TABLE [dbo].[ActiveNodeJobQueue] DROP CONSTRAINT [DF_ActiveNodeJobQueue_EnqueuedUtc]
GO
PRINT N'Dropping constraints from [dbo].[ActiveNodeMetrics]'
GO
ALTER TABLE [dbo].[ActiveNodeMetrics] DROP CONSTRAINT [DF_ActiveNodeMetrics_CapturedUtc]
GO
PRINT N'Dropping constraints from [dbo].[AgentPresence]'
GO
ALTER TABLE [dbo].[AgentPresence] DROP CONSTRAINT [DF_AgentPresence_UpdatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[DailyAgentActivityRollup]'
GO
ALTER TABLE [dbo].[DailyAgentActivityRollup] DROP CONSTRAINT [DF_DailyAgentActivityRollup_CallsHandled]
GO
PRINT N'Dropping constraints from [dbo].[DailyAgentActivityRollup]'
GO
ALTER TABLE [dbo].[DailyAgentActivityRollup] DROP CONSTRAINT [DF_DailyAgentActivityRollup_MinutesActive]
GO
PRINT N'Dropping constraints from [dbo].[FailoverReadinessLog]'
GO
ALTER TABLE [dbo].[FailoverReadinessLog] DROP CONSTRAINT [DF_FailoverReadinessLog_RecordedUtc]
GO
PRINT N'Dropping constraints from [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] DROP CONSTRAINT [DF_IngestBatchLog_RowsProcessed]
GO
PRINT N'Dropping constraints from [dbo].[IngestBatchLog]'
GO
ALTER TABLE [dbo].[IngestBatchLog] DROP CONSTRAINT [DF_IngestBatchLog_StartedUtc]
GO
PRINT N'Dropping constraints from [dbo].[IngestErrorQueue]'
GO
ALTER TABLE [dbo].[IngestErrorQueue] DROP CONSTRAINT [DF_IngestErrorQueue_FailedUtc]
GO
PRINT N'Dropping constraints from [dbo].[IngestErrorQueue]'
GO
ALTER TABLE [dbo].[IngestErrorQueue] DROP CONSTRAINT [DF_IngestErrorQueue_RetryCount]
GO
PRINT N'Dropping constraints from [dbo].[LicenseAuditSnapshot]'
GO
ALTER TABLE [dbo].[LicenseAuditSnapshot] DROP CONSTRAINT [DF_LicenseAuditSnapshot_SnapshotUtc]
GO
PRINT N'Dropping constraints from [dbo].[LocalIngestStaging]'
GO
ALTER TABLE [dbo].[LocalIngestStaging] DROP CONSTRAINT [DF_LocalIngestStaging_ReceivedUtc]
GO
PRINT N'Dropping constraints from [dbo].[PassiveNodeConfig]'
GO
ALTER TABLE [dbo].[PassiveNodeConfig] DROP CONSTRAINT [DF_PassiveNodeConfig_UpdatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[PassiveNodeHealthCheck]'
GO
ALTER TABLE [dbo].[PassiveNodeHealthCheck] DROP CONSTRAINT [DF_PassiveNodeHealthCheck_CheckedUtc]
GO
PRINT N'Dropping constraints from [dbo].[ReportRunHistory]'
GO
ALTER TABLE [dbo].[ReportRunHistory] DROP CONSTRAINT [DF_ReportRunHistory_StartedUtc]
GO
PRINT N'Dropping constraints from [dbo].[ReportSchedule]'
GO
ALTER TABLE [dbo].[ReportSchedule] DROP CONSTRAINT [DF_ReportSchedule_IsEnabled]
GO
PRINT N'Dropping constraints from [dbo].[ReportSchedule]'
GO
ALTER TABLE [dbo].[ReportSchedule] DROP CONSTRAINT [DF_ReportSchedule_CreatedUtc]
GO
PRINT N'Dropping constraints from [dbo].[RoutingDecisionCache]'
GO
ALTER TABLE [dbo].[RoutingDecisionCache] DROP CONSTRAINT [DF_RoutingDecisionCache_DecidedUtc]
GO
PRINT N'Dropping constraints from [dbo].[WarmStandbyProbeLog]'
GO
ALTER TABLE [dbo].[WarmStandbyProbeLog] DROP CONSTRAINT [DF_WarmStandbyProbeLog_ProbedUtc]
GO
PRINT N'Dropping [dbo].[huxChangeTwo]'
GO
DROP PROCEDURE [dbo].[huxChangeTwo]
GO
PRINT N'Dropping [dbo].[ReplicationWatermark]'
GO
DROP TABLE [dbo].[ReplicationWatermark]
GO
PRINT N'Dropping [dbo].[LocalReportCache]'
GO
DROP TABLE [dbo].[LocalReportCache]
GO
PRINT N'Dropping [dbo].[HistoricalCallSummary]'
GO
DROP TABLE [dbo].[HistoricalCallSummary]
GO
PRINT N'Dropping [dbo].[WarmStandbyProbeLog]'
GO
DROP TABLE [dbo].[WarmStandbyProbeLog]
GO
PRINT N'Dropping [dbo].[RoutingDecisionCache]'
GO
DROP TABLE [dbo].[RoutingDecisionCache]
GO
PRINT N'Dropping [dbo].[ReportSchedule]'
GO
DROP TABLE [dbo].[ReportSchedule]
GO
PRINT N'Dropping [dbo].[ReportRunHistory]'
GO
DROP TABLE [dbo].[ReportRunHistory]
GO
PRINT N'Dropping [dbo].[PassiveNodeHealthCheck]'
GO
DROP TABLE [dbo].[PassiveNodeHealthCheck]
GO
PRINT N'Dropping [dbo].[PassiveNodeConfig]'
GO
DROP TABLE [dbo].[PassiveNodeConfig]
GO
PRINT N'Dropping [dbo].[LocalIngestStaging]'
GO
DROP TABLE [dbo].[LocalIngestStaging]
GO
PRINT N'Dropping [dbo].[LicenseAuditSnapshot]'
GO
DROP TABLE [dbo].[LicenseAuditSnapshot]
GO
PRINT N'Dropping [dbo].[IngestErrorQueue]'
GO
DROP TABLE [dbo].[IngestErrorQueue]
GO
PRINT N'Dropping [dbo].[IngestBatchLog]'
GO
DROP TABLE [dbo].[IngestBatchLog]
GO
PRINT N'Dropping [dbo].[FailoverReadinessLog]'
GO
DROP TABLE [dbo].[FailoverReadinessLog]
GO
PRINT N'Dropping [dbo].[DailyAgentActivityRollup]'
GO
DROP TABLE [dbo].[DailyAgentActivityRollup]
GO
PRINT N'Dropping [dbo].[AgentPresence]'
GO
DROP TABLE [dbo].[AgentPresence]
GO
PRINT N'Dropping [dbo].[ActiveNodeMetrics]'
GO
DROP TABLE [dbo].[ActiveNodeMetrics]
GO
PRINT N'Dropping [dbo].[ActiveNodeJobQueue]'
GO
DROP TABLE [dbo].[ActiveNodeJobQueue]
GO
PRINT N'Dropping [dbo].[ActiveNodeConfig]'
GO
DROP TABLE [dbo].[ActiveNodeConfig]
GO
PRINT N'Dropping [dbo].[ActiveCallSessions]'
GO
DROP TABLE [dbo].[ActiveCallSessions]
GO

