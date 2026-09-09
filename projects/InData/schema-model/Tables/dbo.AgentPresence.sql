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
