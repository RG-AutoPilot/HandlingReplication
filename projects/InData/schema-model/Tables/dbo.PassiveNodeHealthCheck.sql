-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[PassiveNodeHealthCheck]
(
[HealthCheckId] [bigint] NOT NULL IDENTITY(1, 1),
[CheckedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_PassiveNodeHealthCheck_CheckedUtc] DEFAULT (sysutcdatetime()),
[IsHealthy] [bit] NOT NULL,
[Details] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[PassiveNodeHealthCheck] ADD CONSTRAINT [PK_PassiveNodeHealthCheck] PRIMARY KEY CLUSTERED ([HealthCheckId])
GO
