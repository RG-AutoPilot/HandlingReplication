/*
    Create-Databases.sql
    ====================
    Creates every non-dev database this repo's Flyway projects target,
    each one empty. Flyway migrations (Release.ps1 -Action Deploy) then
    populate them.

    Databases created:
      CoreInCode       (InCode      -> Prod)
      CoreInData_A     (InData      -> Aprod)
      CoreInData_B     (InData      -> Bprod)
      CoreInCheck      (InData      -> Check env for check -changes)

    The dev databases (CoreInCode_Dev, CoreInData_Dev) are NOT created
    here. Populate-DevDatabases.ps1 runs each project's own
    CreateDevDatabase.sql to create them and inject the schema.

    Idempotent: existing databases are left alone. This script only
    creates the ones that don't already exist. If you want a full
    reset, drop the databases first (or use Setup.ps1 -Reset which
    does that for you).
*/

IF DB_ID(N'CoreInCode') IS NULL
BEGIN
    CREATE DATABASE CoreInCode;
    PRINT 'Created CoreInCode';
END
ELSE PRINT 'CoreInCode already exists';
GO

IF DB_ID(N'CoreInData_A') IS NULL
BEGIN
    CREATE DATABASE CoreInData_A;
    PRINT 'Created CoreInData_A';
END
ELSE PRINT 'CoreInData_A already exists';
GO

IF DB_ID(N'CoreInData_B') IS NULL
BEGIN
    CREATE DATABASE CoreInData_B;
    PRINT 'Created CoreInData_B';
END
ELSE PRINT 'CoreInData_B already exists';
GO

IF DB_ID(N'CoreInCheck') IS NULL
BEGIN
    CREATE DATABASE CoreInCheck;
    PRINT 'Created CoreInCheck';
END
ELSE PRINT 'CoreInCheck already exists';
GO
