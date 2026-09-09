-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[CustomerContracts]
(
[ContractId] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerId] [int] NOT NULL,
[ServiceTierId] [int] NOT NULL,
[StartUtc] [datetime2] (0) NOT NULL,
[EndUtc] [datetime2] (0) NULL,
[Status] [nvarchar] (20) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_CustomerContracts_CreatedUtc] DEFAULT (sysutcdatetime())
)
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [PK_CustomerContracts] PRIMARY KEY CLUSTERED ([ContractId])
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [FK_CustomerContracts_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerContracts] ADD CONSTRAINT [FK_CustomerContracts_ServiceTiers] FOREIGN KEY ([ServiceTierId]) REFERENCES [dbo].[ServiceTiers] ([ServiceTierId])
GO
