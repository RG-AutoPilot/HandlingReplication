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
