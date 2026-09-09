# ===========================
# Script Name: Generate-ReplTables-Migration.ps1
# Description: Diff & generate a Flyway migration + undo pair for the
#              REPLICATED table pool only. Uses Filter.ReplTables.scpf so
#              the diff sees only tables flagged replicated: true in
#              manifest.yaml. Output lands in migrations/ReplTables.
#
#              Changes in this bucket are the twice-yearly, high-risk ones
#              in production because they trigger a full replication
#              rebuild. Do not use this script for routine changes.
#
#              After generation, drops a .sql.conf sibling next to every
#              new migration with a shouldExecute rule that ONLY allows
#              the migration to run against a whitelist of envs: every
#              client's A node (discovered from flyway.toml), plus the
#              Check build DB and the shadow build DB. Every other env
#              (B nodes, dev, etc.) skips the migration. This is the
#              routing gate that stops a ReplTables migration from ever
#              hitting a merge-replication subscriber directly.
#              Inclusion-list rather than exclusion so a forgotten env
#              fails safe (skipped, loud) rather than silently deployed.
#
#              Companion script: Generate-NonReplTables-Migration.ps1
# ===========================

$ErrorActionPreference = 'Stop'
trap {
    Write-Host ""
    Write-Host "Script failed:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
    exit 1
}

# --- Variables --------------------------------------------------------------
$SCRIPT_ROOT           = $PSScriptRoot
$WORKING_DIRECTORY     = (Resolve-Path (Join-Path $SCRIPT_ROOT '..')).Path
$FILTER_FILE           = Join-Path $WORKING_DIRECTORY 'Filter.ReplTables.scpf'
$MIGRATIONS_OUTPUT     = Join-Path $WORKING_DIRECTORY 'migrations\ReplTables'
$ARTIFACT_FILENAME     = "$env:TEMP\Artifacts\Flyway.InData.ReplTables.differences-$(Get-Date -Format yyyyMMdd).zip"

$SOURCE_ENVIRONMENT    = "schemaModel"
$TARGET_ENVIRONMENT    = "migrations"
$BUILD_ENVIRONMENT     = "shadow"

$FLYWAY_VERSION_DESCRIPTION = "Repl_AutomatedMigrationScript"

# Envs that ARE allowed to run generated Repl migrations. Anything not
# on this list (notably any B node) is skipped by shouldExecute. Client
# A-node envs are discovered dynamically from flyway.toml — any env name
# ending in "Aprod" is treated as a client A node. That means adding a
# new client is just adding [environments.<prefix>Aprod] +
# [environments.<prefix>Bprod] to flyway.toml; this generator picks it
# up next time it runs. Add non-client entries (Check, shadow, dev, ...)
# to $EXTRA_ALLOWED_ENVIRONMENTS below.
$FLYWAY_TOML_PATH             = Join-Path $WORKING_DIRECTORY 'flyway.toml'
$EXTRA_ALLOWED_ENVIRONMENTS   = @('Check', 'shadow')

$clientAprodEnvs = @()
if (Test-Path $FLYWAY_TOML_PATH) {
    Get-Content $FLYWAY_TOML_PATH | ForEach-Object {
        if ($_ -match '^\s*\[environments\.([A-Za-z0-9]+Aprod)\]\s*$') {
            if ($clientAprodEnvs -notcontains $matches[1]) {
                $clientAprodEnvs += $matches[1]
            }
        }
    }
}
if (-not $clientAprodEnvs) {
    throw "No client A-node envs (*Aprod) found in $FLYWAY_TOML_PATH. Add at least one before generating a Repl migration."
}

$ALLOWED_ENVIRONMENTS = @($clientAprodEnvs) + $EXTRA_ALLOWED_ENVIRONMENTS

# --- Sanity checks ----------------------------------------------------------
if (-not (Test-Path $FILTER_FILE)) {
    throw "Filter file not found: $FILTER_FILE"
}
if (-not (Test-Path $MIGRATIONS_OUTPUT)) {
    New-Item -ItemType Directory -Path $MIGRATIONS_OUTPUT -Force | Out-Null
}
$artifactDir = Split-Path $ARTIFACT_FILENAME -Parent
if (-not (Test-Path $artifactDir)) {
    New-Item -ItemType Directory -Path $artifactDir -Force | Out-Null
}

# --- Diff & generate --------------------------------------------------------
# Filter is applied by overriding redgateCompare.sqlserver.filterFile so the
# diff only surfaces objects that pass the ReplTables filter, i.e. only the
# tables flagged replicated: true.
# If RELEASE_VERSION is set (Release.ps1 orchestrator), use it as
# the explicit Flyway version; otherwise fall back to a timestamp.
if ($env:RELEASE_VERSION) {
    $VERSION_ARG   = "-generate.version=$env:RELEASE_VERSION"
    $TIMESTAMP_ARG = "-generate.addTimestamp=false"
} else {
    $VERSION_ARG   = $null
    $TIMESTAMP_ARG = "-generate.addTimestamp=true"
}

flyway diff generate `
    "-diff.source=$SOURCE_ENVIRONMENT" `
    "-diff.target=$TARGET_ENVIRONMENT" `
    "-diff.buildEnvironment=$BUILD_ENVIRONMENT" `
    "-redgateCompare.sqlserver.filterFile=$FILTER_FILE" `
    "-diff.artifactFilename=$ARTIFACT_FILENAME" `
    "-generate.artifactFilename=$ARTIFACT_FILENAME" `
    "-generate.description=$FLYWAY_VERSION_DESCRIPTION" `
    "-generate.location=$MIGRATIONS_OUTPUT" `
    "-generate.types=versioned,undo" `
    $VERSION_ARG `
    $TIMESTAMP_ARG `
    -workingDirectory="$WORKING_DIRECTORY" `
    -schemaModelSchemas=""

# --- Emit deploy-rule .sql.conf siblings for every V*/U* migration ----------
# shouldExecute is evaluated by flyway migrate at run time. Any migration in
# this folder without its .conf sibling would deploy to whichever environment
# runs migrate, defeating the routing gate.
# Inclusion-list expression: shouldExecute is true only when the target
# env matches one of the allowed names. Flyway's shouldExecute parser
# accepts only ==, !=, &&, || (no NOT IN, no wildcards); env names on
# the RHS are bare identifiers, no quotes. See CLAUDE.md.
$clauses  = $ALLOWED_ENVIRONMENTS | ForEach-Object { "`${flyway:environment}==$_" }
$confBody = "shouldExecute=$($clauses -join '||')"

Get-ChildItem -Path $MIGRATIONS_OUTPUT -Filter '*.sql' -File | ForEach-Object {
    $confPath = "$($_.FullName).conf"
    if (-not (Test-Path $confPath)) {
        Set-Content -Path $confPath -Value $confBody -NoNewline -Encoding UTF8
        Write-Host "Wrote deploy rule: $confPath"
    }
}


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
