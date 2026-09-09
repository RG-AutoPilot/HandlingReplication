-- Replicated: true  (merge-replication pool — deploys to primary, propagates to secondary via SQL Server merge replication)
CREATE TABLE [dbo].[Licenses]
(
[LicenseId] [int] NOT NULL IDENTITY(1, 1),
[CustomerId] [int] NOT NULL,
[LicenseKey] [nvarchar] (100) NOT NULL,
[ExpiresUtc] [datetime2] (0) NULL
)
GO
ALTER TABLE [dbo].[Licenses] ADD CONSTRAINT [PK_Licenses] PRIMARY KEY CLUSTERED ([LicenseId])
GO
ALTER TABLE [dbo].[Licenses] ADD CONSTRAINT [FK_Licenses_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId])
GO
