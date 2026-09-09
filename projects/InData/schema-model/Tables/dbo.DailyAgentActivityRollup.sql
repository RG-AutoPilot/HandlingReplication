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
