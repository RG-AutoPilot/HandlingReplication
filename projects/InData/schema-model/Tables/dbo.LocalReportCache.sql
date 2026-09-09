-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LocalReportCache]
(
[CacheKey] [nvarchar] (200) NOT NULL,
[CachedValue] [nvarchar] (max) NULL,
[ExpiresUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[LocalReportCache] ADD CONSTRAINT [PK_LocalReportCache] PRIMARY KEY CLUSTERED ([CacheKey])
GO
