# ===========================
# Script Name: Check-ReplTables.ps1
# Description: Runs `flyway check -changes` against the current primary
#              production node (Aprod) using only the ReplTables
#              migrations, and writes an HTML change report. Applies
#              nothing.
#
#              Pair with:  Deploy-ReplTables.ps1
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
$LOCATIONS             = "filesystem:$WORKING_DIRECTORY\migrations\ReplTables"
# Reports root: Release.ps1 sets RELEASE_REPORTS_ROOT to <repo>/reports
# so every project + client + node lands under one folder per release.
# Standalone runs fall back to this project's local reports/ folder.
$REPORTS_DIR           = if ($env:RELEASE_REPORTS_ROOT) { $env:RELEASE_REPORTS_ROOT } else { Join-Path $WORKING_DIRECTORY 'reports' }
if ($env:RELEASE_LABEL)  { $REPORTS_DIR = Join-Path $REPORTS_DIR $env:RELEASE_LABEL }
$TIMESTAMP             = Get-Date -Format 'yyyyMMdd-HHmmss'

# Client-scoped target. Release.ps1 sets RELEASE_CLIENT (e.g. "CL1") so
# this bucket checks against that client's A node. Standalone runs fall
# back to bare "Aprod", which no longer exists in flyway.toml -- see the
# matching note in Deploy-ReplTables.ps1.
$TARGET_ENVIRONMENT    = if ($env:RELEASE_CLIENT) { "$($env:RELEASE_CLIENT)Aprod" } else { "Aprod" }
$BUILD_ENVIRONMENT     = "Check"

# Filename encodes bucket + client.node so a report is self-identifying
# even when opened out of the folder that groups the release.
$CLIENT_TAG            = if ($env:RELEASE_CLIENT) { $env:RELEASE_CLIENT } else { 'nocli' }
$REPORT_PATH           = Join-Path $REPORTS_DIR "Repl-$CLIENT_TAG.Aprod-$TIMESTAMP.html"


# --- Sanity checks ----------------------------------------------------------
if (-not (Test-Path $REPORTS_DIR)) {
    New-Item -ItemType Directory -Path $REPORTS_DIR -Force | Out-Null
}

# --- Change report ----------------------------------------------------------
# ignoreMigrationPatterns=*:missing is required because the target
# environment's flyway_schema_history spans BOTH ReplTables and
# NonReplTables deploys, but this check only points -locations at the
# ReplTables subfolder. Every NonRepl entry in the target's history
# would otherwise look "missing" from this check's perspective and
# fail validation. The pattern tells Flyway that missing entries are
# expected here, not a real drift.
Write-Host ""
Write-Host "=== flyway check -changes -drift ($TARGET_ENVIRONMENT, ReplTables) ==="
Write-Host "    locations : $LOCATIONS"
Write-Host "    report    : $REPORT_PATH"

# If RELEASE_TARGET is set (Release.ps1 orchestrator), pass it as

# -target=<version> so flyway stops at that release.

$TARGET_ARG = if ($env:RELEASE_TARGET) { "-target=$env:RELEASE_TARGET" } else { $null }


flyway check -changes -drift `
    $TARGET_ARG `
    "-environment=$TARGET_ENVIRONMENT" `
    "-locations=$LOCATIONS" `
    "-check.buildEnvironment=$BUILD_ENVIRONMENT" `
    "-reportFilename=$REPORT_PATH" `
    -workingDirectory="$WORKING_DIRECTORY"

if ($LASTEXITCODE -ne 0) {
    throw "check failed against $TARGET_ENVIRONMENT (exit $LASTEXITCODE)."
}

Write-Host ""
Write-Host "Report: $REPORT_PATH"


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
