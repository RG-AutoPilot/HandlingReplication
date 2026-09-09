SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] ADD
[ReplicatingColumnChange03] [nvarchar] (30) NULL
GO
PRINT N'Creating [dbo].[ReplicatingTable]'
GO
CREATE TABLE [dbo].[ReplicatingTable]
(
[Test1] [int] NULL
)
GO

