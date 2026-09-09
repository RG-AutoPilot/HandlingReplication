Drift was detected when performing your last deployment. This folder contains scripts which may help handle it.

If you want to revert the drift in your target environment, you can use the generated revert script.
If you want to incorporate the drift into your previous environments, you can use the generated incorporate script.
If you want to ignore the drift by filtering it out, you can use the generated filter file. Note that this can currently only be generated for SQL Server and Oracle databases.

For more information on handling drift, see [the associated Flyway documentation](https://documentation.red-gate.com/flyway/deploying-database-changes-using-flyway/checking-production-environments-for-drift).
