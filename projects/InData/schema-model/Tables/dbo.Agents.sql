-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Agents]
(
[AgentId] [int] NOT NULL IDENTITY(1, 1),
[AgentGroupId] [int] NOT NULL,
[AgentName] [nvarchar] (200) NOT NULL,
[LastHeartbeatUtc] [datetime2] (0) NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Agents_CreatedUtc] DEFAULT (sysutcdatetime()),
[Steve] [nchar] (10) NULL,
[PhoneNumber] [nvarchar] (30) NULL,
[PhoneNumberx] [nvarchar] (30) NULL,
[PhoneNumberTen] [nvarchar] (30) NULL,
[RobReplic] [nvarchar] (30) NULL,
[version2Test] [nvarchar] (30) NULL,
[version3Test] [nvarchar] (30) NULL,
[NonReplic] [nvarchar] (30) NULL,
[NonReplicating2] [nvarchar] (30) NULL,
[NonReplicating3] [nvarchar] (30) NULL,
[NonReplicating4] [nvarchar] (30) NULL,
[NonReplicating5] [nvarchar] (30) NULL,
[NonReplicating6] [nvarchar] (30) NULL,
[ReplicatingChange7] [nvarchar] (30) NULL,
[ReplicatingChange8] [nvarchar] (30) NULL,
[ReplicatingChange9] [nvarchar] (30) NULL,
[ReplicatingChange10] [nvarchar] (30) NULL,
[CheckReportSmoke1] [nvarchar] (30) NULL,
[CheckReportSmoke2] [nvarchar] (30) NULL,
[CheckReportSmoke3] [nvarchar] (30) NULL,
[ReplicatingColumnChange01] [nvarchar] (30) NULL,
[ReplicatingColumnChange02] [nvarchar] (30) NULL,
[ReplicatingColumnChange03] [nvarchar] (30) NULL
)
GO
ALTER TABLE [dbo].[Agents] ADD CONSTRAINT [PK_Agents] PRIMARY KEY CLUSTERED ([AgentId])
GO
ALTER TABLE [dbo].[Agents] ADD CONSTRAINT [FK_Agents_AgentGroups] FOREIGN KEY ([AgentGroupId]) REFERENCES [dbo].[AgentGroups] ([AgentGroupId])
GO
