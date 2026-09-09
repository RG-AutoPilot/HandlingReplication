# ===========================
# Script Name: Update-SchemaModel-FromDev.ps1
# Description: Flyway-Desktop-free capture of dev-database changes into
#              version control. Diffs the live dev database ("development"
#              environment in flyway.user.toml) against the checked-in
#              schema-model and applies the delta to the schema-model
#              folder. No migration scripts are produced by this step,
#              this is the equivalent of FWD's "save changes" action.
#
#              Workflow:
#                1. Developer changes objects in CoreInData_Dev.
#                2. This script rewrites projects/InData/schema-model/
#                   so it mirrors the dev database.
#                3. Developer commits the schema-model changes.
#                4. Later, Generate-ReplTables-Migration.ps1 and
#                   Generate-NonReplTables-Migration.ps1 turn those
#                   schema-model changes into versioned + undo migrations
#                   in the correct migrations/ subfolder.
#
#              This split (capture vs generate) keeps the version-
#              controlled state and the migration history as separate
#              commits, and lets a reviewer see the schema-model diff
#              and the migration diff independently.
#
#              Runs against ALL tables, no filter. Bucket routing (Repl
#              vs NonRepl) is a migration-generation concern, not a
#              schema-model concern, the schema-model always holds every
#              table this project owns.
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
$ARTIFACT_FILENAME     = "$env:TEMP\Artifacts\Flyway.InData.SchemaModel.FromDev.differences-$(Get-Date -Format yyyyMMdd).zip"

# Source: live dev DB (from flyway.user.toml [environments.development]).
# Target: the checked-in schema-model folder.
$SOURCE_ENVIRONMENT    = "development"
$TARGET_ENVIRONMENT    = "schemaModel"
$BUILD_ENVIRONMENT     = "shadow"

# --- Sanity checks ----------------------------------------------------------
$artifactDir = Split-Path $ARTIFACT_FILENAME -Parent
if (-not (Test-Path $artifactDir)) {
    New-Item -ItemType Directory -Path $artifactDir -Force | Out-Null
}

# --- Diff & apply -----------------------------------------------------------
# `flyway diff apply` computes the source-vs-target delta and writes it
# straight into the target. With target=schemaModel that means the
# schema-model folder is rewritten to mirror the dev database. No
# migration SQL is produced by this call.
Write-Host ""
Write-Host "=== flyway diff apply (dev -> schemaModel) ==="
Write-Host "    source : $SOURCE_ENVIRONMENT"
Write-Host "    target : $TARGET_ENVIRONMENT"

flyway diff model `
    "-diff.source=$SOURCE_ENVIRONMENT" `
    "-diff.target=$TARGET_ENVIRONMENT" `
    "-diff.buildEnvironment=$BUILD_ENVIRONMENT" `
    "-diff.artifactFilename=$ARTIFACT_FILENAME" `
    "-apply.artifactFilename=$ARTIFACT_FILENAME" `
    -workingDirectory="$WORKING_DIRECTORY" `
    -schemaModelSchemas=""


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
