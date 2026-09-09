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
