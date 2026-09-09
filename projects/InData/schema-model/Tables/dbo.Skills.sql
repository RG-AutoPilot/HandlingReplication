-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Skills]
(
[SkillId] [int] NOT NULL IDENTITY(1, 1),
[SkillName] [nvarchar] (100) NOT NULL,
[Category] [nvarchar] (50) NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Skills_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[Skills] ADD CONSTRAINT [PK_Skills] PRIMARY KEY CLUSTERED ([SkillId])
GO
