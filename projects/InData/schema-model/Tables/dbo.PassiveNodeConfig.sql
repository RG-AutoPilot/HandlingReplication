-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[PassiveNodeConfig]
(
[ConfigKey] [nvarchar] (100) NOT NULL,
[ConfigValue] [nvarchar] (max) NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_PassiveNodeConfig_UpdatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[PassiveNodeConfig] ADD CONSTRAINT [PK_PassiveNodeConfig] PRIMARY KEY CLUSTERED ([ConfigKey])
GO
