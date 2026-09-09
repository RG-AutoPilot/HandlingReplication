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
