-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Customers]
(
[CustomerId] [int] NOT NULL IDENTITY(1, 1),
[CustomerName] [nvarchar] (200) NOT NULL,
[CreatedUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_Customers_CreatedUtc] DEFAULT (sysutcdatetime()),
[TestSmokeColumn] [nvarchar] (50) NULL
)
GO
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerId])
GO
