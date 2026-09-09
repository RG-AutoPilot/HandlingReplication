-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[ActiveNodeConfig]
(
[ConfigKey] [nvarchar] (100) NOT NULL,
[ConfigValue] [nvarchar] (max) NULL,
[UpdatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_ActiveNodeConfig_UpdatedUtc] DEFAULT (sysutcdatetime()),
[TestID] [nchar] (10) NULL,
[new] [nchar] (10) NULL,
[steven] [nchar] (10) NULL
)
GO
ALTER TABLE [dbo].[ActiveNodeConfig] ADD CONSTRAINT [PK_ActiveNodeConfig] PRIMARY KEY CLUSTERED ([ConfigKey])
GO
