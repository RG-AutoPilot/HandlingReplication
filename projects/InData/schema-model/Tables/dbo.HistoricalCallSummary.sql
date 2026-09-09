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
