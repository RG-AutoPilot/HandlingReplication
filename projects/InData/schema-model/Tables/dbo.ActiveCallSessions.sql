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
