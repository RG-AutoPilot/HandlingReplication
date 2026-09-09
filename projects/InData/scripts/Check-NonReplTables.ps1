# ===========================
# Script Name: Check-NonReplTables.ps1
# Description: Runs `flyway check -changes` against BOTH production
#              nodes (Aprod, then Bprod) using only the NonReplTables
#              migrations, and writes one HTML change report per node.
#              Applies nothing.
#
#              Pair with:  Deploy-NonReplTables.ps1
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
$LOCATIONS             = "filesystem:$WORKING_DIRECTORY\migrations\NonReplTables"
# Bucket-scoped filter used ONLY on B-node drift checks. B is a merge-repl
# subscriber on CL1, so the replicated tables (Agents, Customers, ...) and
# all the MSmerge_*/sysmerge* metadata appear on B without Flyway having
# put them there -- they'd otherwise dominate the drift report as noise.
# Applying the NonRepl bucket filter narrows the drift analysis to the
# tables this bucket actually owns, which is exactly what we want to see
# drift on. A-node checks skip this filter because A is Flyway's direct
# deploy target for both buckets, so full-schema drift there is meaningful.
$FILTER_FILE           = Join-Path $WORKING_DIRECTORY 'Filter.NonReplTables.scpf'
# Reports root: Release.ps1 sets RELEASE_REPORTS_ROOT to <repo>/reports
# so every project + client + node lands under one folder per release.
# Standalone runs fall back to this project's local reports/ folder.
$REPORTS_DIR           = if ($env:RELEASE_REPORTS_ROOT) { $env:RELEASE_REPORTS_ROOT } else { Join-Path $WORKING_DIRECTORY 'reports' }
if ($env:RELEASE_LABEL)  { $REPORTS_DIR = Join-Path $REPORTS_DIR $env:RELEASE_LABEL }
$TIMESTAMP             = Get-Date -Format 'yyyyMMdd-HHmmss'

# Client-scoped targets. Release.ps1 sets RELEASE_CLIENT (e.g. "CL1") so
# this bucket checks against both nodes of that client. Standalone runs
# fall back to bare "Aprod"/"Bprod" -- see the matching note in
# Deploy-NonReplTables.ps1.
$TARGET_ENVIRONMENTS   = if ($env:RELEASE_CLIENT) {
    @("$($env:RELEASE_CLIENT)Aprod", "$($env:RELEASE_CLIENT)Bprod")
} else {
    @('Aprod', 'Bprod')
}
$BUILD_ENVIRONMENT     = "shadow"

# --- Sanity checks ----------------------------------------------------------
if (-not (Test-Path $REPORTS_DIR)) {
    New-Item -ItemType Directory -Path $REPORTS_DIR -Force | Out-Null
}

# --- Change report per node -------------------------------------------------
# ignoreMigrationPatterns=*:missing is required because each target's
# flyway_schema_history spans BOTH ReplTables and NonReplTables deploys,
# but this check only points -locations at the NonReplTables subfolder.
# Every Repl entry in the target's history would otherwise look "missing"
# from this check's perspective and fail validation. The pattern tells
# Flyway that missing entries are expected here, not a real drift.
$CLIENT_TAG            = if ($env:RELEASE_CLIENT) { $env:RELEASE_CLIENT } else { 'nocli' }

foreach ($env in $TARGET_ENVIRONMENTS) {
    # Encode bucket + client.node role. $env here is the loop var (Aprod
    # or Bprod, or CLxAprod/CLxBprod); strip the client prefix for the
    # node-role token so the filename is Repl-CL1.Aprod, not
    # Repl-CL1.CL1Aprod.
    $nodeRole = if ($env:RELEASE_CLIENT -and $env.StartsWith($env:RELEASE_CLIENT)) { $env.Substring($env:RELEASE_CLIENT.Length) } else { $env }
    $reportPath = Join-Path $REPORTS_DIR "NonRepl-$CLIENT_TAG.$nodeRole-$TIMESTAMP.html"

    Write-Host ""
    Write-Host "=== flyway check -changes -drift ($env, NonReplTables) ==="
    Write-Host "    locations : $LOCATIONS"
    Write-Host "    report    : $reportPath"

    # If RELEASE_TARGET is set (Release.ps1 orchestrator), pass it as

    # -target=<version> so flyway stops at that release.

    $TARGET_ARG = if ($env:RELEASE_TARGET) { "-target=$env:RELEASE_TARGET" } else { $null }

    # B-node drift check applies the NonRepl bucket filter to hide merge-repl
    # noise (replicated tables + MSmerge_*/sysmerge* metadata). See the note
    # on $FILTER_FILE above.
    $FILTER_ARG = if ($env -like '*Bprod') { "-check.filterFile=$FILTER_FILE" } else { $null }

    flyway check -changes -drift `
        $TARGET_ARG `
        $FILTER_ARG `
        "-environment=$env" `
        "-locations=$LOCATIONS" `
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
