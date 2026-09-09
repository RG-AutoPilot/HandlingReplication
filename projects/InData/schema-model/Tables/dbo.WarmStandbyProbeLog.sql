-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[WarmStandbyProbeLog]
(
[ProbeId] [bigint] NOT NULL IDENTITY(1, 1),
[ProbeName] [nvarchar] (100) NOT NULL,
[ProbedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_WarmStandbyProbeLog_ProbedUtc] DEFAULT (sysutcdatetime()),
[Success] [bit] NOT NULL,
[DetailsJson] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[WarmStandbyProbeLog] ADD CONSTRAINT [PK_WarmStandbyProbeLog] PRIMARY KEY CLUSTERED ([ProbeId])
GO
