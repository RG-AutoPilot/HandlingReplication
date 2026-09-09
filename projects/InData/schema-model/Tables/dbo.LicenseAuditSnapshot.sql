-- Replicated: false (deploys directly to both nodes on every release)
CREATE TABLE [dbo].[LicenseAuditSnapshot]
(
[SnapshotId] [bigint] NOT NULL IDENTITY(1, 1),
[SnapshotUtc] [datetime2] (0) NOT NULL CONSTRAINT [DF_LicenseAuditSnapshot_SnapshotUtc] DEFAULT (sysutcdatetime()),
[LicenseId] [int] NOT NULL,
[CustomerId] [int] NULL,
[IsActive] [bit] NOT NULL
)
GO
ALTER TABLE [dbo].[LicenseAuditSnapshot] ADD CONSTRAINT [PK_LicenseAuditSnapshot] PRIMARY KEY CLUSTERED ([SnapshotId])
GO
