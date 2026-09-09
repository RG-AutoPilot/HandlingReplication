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
