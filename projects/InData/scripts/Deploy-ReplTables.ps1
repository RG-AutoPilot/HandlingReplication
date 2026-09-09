# ===========================
# Script Name: Deploy-ReplTables.ps1
# Description: Runs `flyway migrate` for the ReplTables bucket against
#              the current primary production node (Aprod). Node B is
#              never touched by this script, replication propagates
#              the change from A to B in production. The .sql.conf
#              sibling on every ReplTables migration also carries
#              `shouldExecute=${flyway:environment}!=Bprod` as a
#              belt-and-braces gate.
#
#              Pair with:  Check-ReplTables.ps1 (run first to review
#              the change report before deploying).
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

# Client-scoped target. Release.ps1 sets RELEASE_CLIENT (e.g. "CL1") so
# this bucket deploys to that client's A node. When run standalone the env
# var is unset and we fall back to a bare "Aprod" -- kept only so a
# double-clicked run doesn't crash; there is no bare "Aprod" env in
# flyway.toml today, so standalone runs will fail with a Flyway env-not-found
# error until someone either adds one or invokes via Release.ps1.
$TARGET_ENVIRONMENT    = if ($env:RELEASE_CLIENT) { "$($env:RELEASE_CLIENT)Aprod" } else { "Aprod" }

# --- Migrate ----------------------------------------------------------------
Write-Host ""
Write-Host "=== flyway migrate ($TARGET_ENVIRONMENT, ReplTables) ==="
Write-Host "    locations : $LOCATIONS"

# ignoreMigrationPatterns=*:missing tolerates NonRepl history entries
# in the target's flyway_schema_history that aren't present in
# -locations here. See the matching comment in Check-ReplTables.ps1.
# If RELEASE_TARGET is set (Release.ps1 orchestrator), pass it as
# -target=<version> so flyway stops at that release.
$TARGET_ARG = if ($env:RELEASE_TARGET) { "-target=$env:RELEASE_TARGET" } else { $null }

flyway migrate `
    $TARGET_ARG `
    "-environment=$TARGET_ENVIRONMENT" `
    "-locations=$LOCATIONS" `
    -workingDirectory="$WORKING_DIRECTORY"

if ($LASTEXITCODE -ne 0) {
    throw "migrate failed against $TARGET_ENVIRONMENT (exit $LASTEXITCODE)."
}


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
