# ===========================
# Script Name: Check.ps1  (InCode)
# Description: Runs `flyway check -changes` against every production
#              target in $TARGET_ENVIRONMENTS, writes one HTML change
#              report per node. Applies nothing.
#
#              Pair with:  Deploy.ps1 (run this first to review the
#              per-node change report before deploying).
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
# Reports root: Release.ps1 sets RELEASE_REPORTS_ROOT to <repo>/reports
# so every project + client + node lands under one folder per release.
# Standalone runs fall back to this project's local reports/ folder.
$REPORTS_DIR           = if ($env:RELEASE_REPORTS_ROOT) { $env:RELEASE_REPORTS_ROOT } else { Join-Path $WORKING_DIRECTORY 'reports' }
if ($env:RELEASE_LABEL) { $REPORTS_DIR = Join-Path $REPORTS_DIR $env:RELEASE_LABEL }
$TIMESTAMP             = Get-Date -Format 'yyyyMMdd-HHmmss'

# InCode is single-bucket so no -locations override, Flyway uses the
# project default (filesystem:migrations) from flyway.toml.
# Client-scoped target. See matching note in Deploy.ps1.
$TARGET_ENVIRONMENTS   = if ($env:RELEASE_CLIENT) { @("$($env:RELEASE_CLIENT)Prod") } else { @('Prod') }
$BUILD_ENVIRONMENT     = "shadow"

# --- Sanity checks ----------------------------------------------------------
if (-not (Test-Path $REPORTS_DIR)) {
    New-Item -ItemType Directory -Path $REPORTS_DIR -Force | Out-Null
}

# --- Change report per node -------------------------------------------------
$CLIENT_TAG            = if ($env:RELEASE_CLIENT) { $env:RELEASE_CLIENT } else { 'nocli' }

foreach ($env in $TARGET_ENVIRONMENTS) {
    # InCode is client-agnostic today (single Prod env), but keep the
    # client tag in the filename so all reports in a release folder line
    # up on the same naming scheme.
    $reportPath = Join-Path $REPORTS_DIR "InCode-$CLIENT_TAG.$env-$TIMESTAMP.html"

    Write-Host ""
    Write-Host "=== flyway check -changes -drift ($env, InCode) ==="
    Write-Host "    report : $reportPath"

    # If RELEASE_TARGET is set (Release.ps1 orchestrator), pass it as

    # -target=<version> so flyway stops at that release.

    $TARGET_ARG = if ($env:RELEASE_TARGET) { "-target=$env:RELEASE_TARGET" } else { $null }


    flyway check -changes -drift -code `
        $TARGET_ARG `
        "-environment=$env" `
        "-check.buildEnvironment=$BUILD_ENVIRONMENT" `
        "-reportFilename=$reportPath" `
        -workingDirectory="$WORKING_DIRECTORY"

    if ($LASTEXITCODE -ne 0) {
        throw "check failed against $env (exit $LASTEXITCODE)."
    }
}

Write-Host ""
Write-Host "Reports written to: $REPORTS_DIR"


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
