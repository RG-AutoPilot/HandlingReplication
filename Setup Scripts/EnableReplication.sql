USE master;

-- 1a) Register this server as its own distributor.
EXEC sp_adddistributor
    @distributor = @@SERVERNAME,
    @password    = N'Redg@teReplication';

-- 1b) Create the distribution database (stores repl metadata + snapshots).
EXEC sp_adddistributiondb
    @database                 = N'distribution',
    @security_mode            = 1;  -- Windows auth

-- 1c) Register this server as a publisher, tell it which distribution DB to
--     use, and where the snapshot files land.
EXEC sp_adddistpublisher
    @publisher         = @@SERVERNAME,
    @distribution_db   = N'distribution',
    @working_directory = N'C:\ReplData';




-------

USE master;
EXEC sp_adddistpublisher
    @publisher         = @@SERVERNAME,
    @distribution_db   = N'distribution',
    @working_directory = N'C:\ReplData';

EXEC sp_helpdistributor;

USE distribution;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'ReplDist!DMK2026';
GO

-- Re-encrypt any secrets already stored (from sp_adddistpublisher) with the new DMK.
EXEC sp_MSrefresh_publisher;

-- enable CoreInData Replication
USE master;
EXEC sp_replicationdboption
    @dbname   = N'CoreInData_A',
    @optname  = N'merge publish',
    @value    = N'true';

-- dmk for Publisher
USE CoreInData_A;
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'ReplPub!DMK2026';

-- check contents of Publisher
SELECT name FROM CoreInData_A.sys.tables
WHERE schema_id = SCHEMA_ID('dbo')
ORDER BY name;

-- create publicatoion + snapshot agent

USE CoreInData_A;

-- 3a) Create the merge publication.
EXEC sp_addmergepublication
    @publication              = N'CoreInData_Merge',
    @sync_mode                = N'native',
    @retention                = 14,
    @allow_push               = N'true',
    @allow_pull               = N'true',
    @snapshot_in_defaultfolder = N'true',
    @publication_compatibility_level = N'100RTM';

-- 3b) Create the Snapshot Agent job (runs on demand; we'll trigger it in Step 5).
EXEC sp_addpublication_snapshot
    @publication      = N'CoreInData_Merge',
    @frequency_type   = 1,              -- 1 = on demand only, no schedule
    @job_login        = NULL,           -- inherit SQL Agent service account
    @job_password     = NULL,
    @publisher_security_mode = 1;       -- Windows auth


-- add replication tables as articles

USE CoreInData_A;

DECLARE @tables TABLE (name sysname);
INSERT @tables VALUES
    (N'Agents'), (N'AgentGroups'), (N'Customers'), (N'Licenses'),
    (N'Sites'), (N'Regions'), (N'Skills'), (N'AgentSkills'),
    (N'ServiceTiers'), (N'CustomerContracts'), (N'ReplicatingTable');

DECLARE @t sysname;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT name FROM @tables;
OPEN c;
FETCH NEXT FROM c INTO @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_addmergearticle
        @publication            = N'CoreInData_Merge',
        @article                = @t,
        @source_owner           = N'dbo',
        @source_object          = @t,
        @type                   = N'table',
        @force_reinit_subscription = 1;
    FETCH NEXT FROM c INTO @t;
END
CLOSE c;
DEALLOCATE c;


-- verify expect: 1 row for publication. a row foe each article

EXEC CoreInData_A.dbo.sp_helpmergepublication @publication = N'CoreInData_Merge';
EXEC CoreInData_A.dbo.sp_helpmergearticle    @publication = N'CoreInData_Merge';


-- create initial snapshot of publisher

USE CoreInData_A;
EXEC sp_startpublication_snapshot @publication = N'CoreInData_Merge';

-- poll for status

EXEC distribution.dbo.sp_MSenum_replication_agents @type = 1;


-- if lagging / not making snapshopt -- use to checkfor history:

SELECT TOP 20
    h.run_date, h.run_time, h.step_id, h.step_name, h.run_status,
    LEFT(h.message, 500) AS message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON j.job_id = h.job_id
WHERE j.name LIKE '%CoreInData_Merge%'
ORDER BY h.run_date DESC, h.run_time DESC, h.step_id DESC;


-- job may fail due to service account. Reassign to SA:

DECLARE @jobName sysname;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT j.name
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.syscategories c ON c.category_id = j.category_id
    WHERE c.name LIKE 'REPL-%';
OPEN c;
FETCH NEXT FROM c INTO @jobName;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_update_job @job_name = @jobName, @owner_login_name = N'sa';
    FETCH NEXT FROM c INTO @jobName;
END
CLOSE c;
DEALLOCATE c;

-- rerun snapshot:

EXEC msdb.dbo.sp_start_job @job_name = N'HUXRG-CoreInData_A-CoreInData_Merge-1';

-- poll for status

EXEC distribution.dbo.sp_MSenum_replication_agents @type = 1;


-- Subscription Part

USE CoreInData_A;

-- 6a) Add the subscription record.
EXEC sp_addmergesubscription
    @publication         = N'CoreInData_Merge',
    @subscriber          = @@SERVERNAME,
    @subscriber_db       = N'CoreInData_B',
    @subscription_type   = N'Push',
    @sync_type           = N'automatic',
    @subscriber_type     = N'Local';

-- 6b) Create the Merge Agent job that actually moves the data.
EXEC sp_addmergepushsubscription_agent
    @publication              = N'CoreInData_Merge',
    @subscriber               = @@SERVERNAME,
    @subscriber_db            = N'CoreInData_B',
    @subscriber_security_mode = 1,   -- Windows auth to subscriber
    @job_login                = NULL,
    @job_password             = NULL,
    @publisher_security_mode  = 1;   -- Windows auth to publisher

-- create DMK for Subscriber

USE CoreInData_B;
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'ReplSub!DMK2026';


-- tell subscriber merge job to use SA

DECLARE @jobName sysname;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT j.name
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.syscategories c ON c.category_id = j.category_id
    WHERE c.name LIKE 'REPL-%';
OPEN c;
FETCH NEXT FROM c INTO @jobName;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_update_job @job_name = @jobName, @owner_login_name = N'sa';
    FETCH NEXT FROM c INTO @jobName;
END
CLOSE c;
DEALLOCATE c;


-- find new merge agent job

SELECT j.name
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.syscategories c ON c.category_id = j.category_id
WHERE c.name = 'REPL-Merge';


-- paste into exec command to start the replication

-- EXEC msdb.dbo.sp_start_job @job_name = N'<paste job name here>';
EXEC msdb.dbo.sp_start_job @job_name = N'HUXRG-CoreInData_A-CoreInData_Merge-HuxRG-1';

-- validate replication worked:

SELECT name FROM CoreInData_B.sys.tables
WHERE schema_id = SCHEMA_ID('dbo')
ORDER BY name;

-- smoke test replication:

-- Baseline: pending merge changes should be 0 on both sides.
SELECT 'A' AS node, COUNT(*) AS pending FROM CoreInData_A.dbo.MSmerge_contents
UNION ALL
SELECT 'B', COUNT(*) FROM CoreInData_B.dbo.MSmerge_contents;

-- Insert on the publisher.
INSERT INTO CoreInData_A.dbo.Regions (RegionCode, RegionName)
VALUES (N'RPLTST', N'Replication smoke test');

-- A now has one pending change; B not yet until the merge agent runs.
SELECT 'A' AS node, COUNT(*) FROM CoreInData_A.dbo.MSmerge_contents
UNION ALL
SELECT 'B', COUNT(*) FROM CoreInData_B.dbo.MSmerge_contents;

-- Force the merge agent (paste the REPL-Merge job name).
EXEC msdb.dbo.sp_start_job @job_name = N'HUXRG-CoreInData_A-CoreInData_Merge-HuxRG-1';

-- Wait for it to tick.
WAITFOR DELAY '00:00:10';

-- Verify the row landed on B.
SELECT RegionId, RegionCode, RegionName, CreatedUtc
FROM CoreInData_B.dbo.Regions
WHERE RegionCode = N'RPLTST';

