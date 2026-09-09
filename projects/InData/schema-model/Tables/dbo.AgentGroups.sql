-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[AgentGroups]
(
[AgentGroupId] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [nvarchar] (200) NOT NULL,
[CustomerId] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[AgentGroups] ADD CONSTRAINT [PK_AgentGroups] PRIMARY KEY CLUSTERED ([AgentGroupId])
GO
ALTER TABLE [dbo].[AgentGroups] ADD CONSTRAINT [FK_AgentGroups_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
