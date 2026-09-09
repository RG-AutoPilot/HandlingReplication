# ===========================
# Script Name: Generate-NonReplTables-Migration.ps1
# Description: Diff & generate a Flyway migration + undo pair for the
#              NON-REPLICATED tables only. Uses Filter.NonReplTables.scpf
#              so the diff sees only tables flagged replicated: false in
#              manifest.yaml. Output lands in migrations/NonReplTables.
#
#              Changes in this bucket are routine and deploy directly to
#              both nodes on every release. Safe cadence.
#
#              Companion script: Generate-ReplTables-Migration.ps1
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
$FILTER_FILE           = Join-Path $WORKING_DIRECTORY 'Filter.NonReplTables.scpf'
$MIGRATIONS_OUTPUT     = Join-Path $WORKING_DIRECTORY 'migrations\NonReplTables'
$ARTIFACT_FILENAME     = "$env:TEMP\Artifacts\Flyway.InData.NonReplTables.differences-$(Get-Date -Format yyyyMMdd).zip"

$SOURCE_ENVIRONMENT    = "schemaModel"
$TARGET_ENVIRONMENT    = "migrations"
$BUILD_ENVIRONMENT     = "shadow"

$FLYWAY_VERSION_DESCRIPTION = "NonRepl_AutomatedMigrationScript"

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
# diff only surfaces objects that pass the NonReplTables filter, i.e. only
# the tables flagged replicated: false.
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


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
