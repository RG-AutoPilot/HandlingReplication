SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Agents]'
GO
ALTER TABLE [dbo].[Agents] ADD
[ReplicatingChange10] [nvarchar] (30) NULL
GO
PRINT N'Altering [dbo].[Customers]'
GO
ALTER TABLE [dbo].[Customers] ADD
[TestSmokeColumn] [nvarchar] (50) NULL
GO

