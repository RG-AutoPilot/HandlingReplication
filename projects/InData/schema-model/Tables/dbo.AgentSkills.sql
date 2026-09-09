-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[AgentSkills]
(
[AgentSkillId] [bigint] NOT NULL IDENTITY(1, 1),
[AgentId] [int] NOT NULL,
[SkillId] [int] NOT NULL,
[ProficiencyLevel] [tinyint] NOT NULL,
[AssignedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_AgentSkills_AssignedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [PK_AgentSkills] PRIMARY KEY CLUSTERED ([AgentSkillId])
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [FK_AgentSkills_Agents] FOREIGN KEY ([AgentId]) REFERENCES [dbo].[Agents] ([AgentId])
GO
ALTER TABLE [dbo].[AgentSkills] ADD CONSTRAINT [FK_AgentSkills_Skills] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[Skills] ([SkillId])
GO
