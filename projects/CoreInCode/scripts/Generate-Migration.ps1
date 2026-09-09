# ===========================
# Script Name: Generate-Migration.ps1  (InCode)
# Description: Diff & generate a Flyway migration + undo pair for every
#              change captured in the schema-model. Output lands in the
#              single migrations/ folder. No filter file: InCode is a
#              single-bucket project, every change deploys directly to
#              both nodes on every release.
#
#              Pair with:  Update-SchemaModel-FromDev.ps1 (run first to
#              capture dev changes into schema-model).
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
$MIGRATIONS_OUTPUT     = Join-Path $WORKING_DIRECTORY 'migrations'
$ARTIFACT_FILENAME     = "$env:TEMP\Artifacts\Flyway.InCode.differences-$(Get-Date -Format yyyyMMdd).zip"

$SOURCE_ENVIRONMENT    = "schemaModel"
$TARGET_ENVIRONMENT    = "migrations"
$BUILD_ENVIRONMENT     = "shadow"

$FLYWAY_VERSION_DESCRIPTION = "InCode_AutomatedMigrationScript"

# --- Sanity checks ----------------------------------------------------------
if (-not (Test-Path $MIGRATIONS_OUTPUT)) {
    New-Item -ItemType Directory -Path $MIGRATIONS_OUTPUT -Force | Out-Null
}
$artifactDir = Split-Path $ARTIFACT_FILENAME -Parent
if (-not (Test-Path $artifactDir)) {
    New-Item -ItemType Directory -Path $artifactDir -Force | Out-Null
}

# --- Diff & generate --------------------------------------------------------
Write-Host ""
Write-Host "=== flyway diff generate (schemaModel -> migrations) ==="
Write-Host "    output : $MIGRATIONS_OUTPUT"

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
