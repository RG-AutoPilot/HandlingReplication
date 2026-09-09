# ===========================
# Script Name: Deploy-NonReplTables.ps1
# Description: Runs `flyway migrate` for the NonReplTables bucket
#              against BOTH production nodes (Aprod, then Bprod).
#              These migrations carry no .sql.conf gate, they must run
#              against every environment on every release.
#
#              Sequential per node. If Aprod fails the script throws
#              and Bprod is skipped, so the two nodes don't diverge
#              silently, someone has to decide how to re-sync before
#              Bprod is attempted.
#
#              Pair with:  Check-NonReplTables.ps1 (run first to
#              review the per-node change reports before deploying).
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

# Client-scoped targets. Release.ps1 sets RELEASE_CLIENT (e.g. "CL1") so
# this bucket deploys to both nodes of that client. Standalone runs fall
# back to bare "Aprod"/"Bprod", which no longer exist in flyway.toml --
# see the matching note in Deploy-ReplTables.ps1.
$TARGET_ENVIRONMENTS   = if ($env:RELEASE_CLIENT) {
    @("$($env:RELEASE_CLIENT)Aprod", "$($env:RELEASE_CLIENT)Bprod")
} else {
    @('Aprod', 'Bprod')
}

# --- Migrate per node -------------------------------------------------------
foreach ($env in $TARGET_ENVIRONMENTS) {
    Write-Host ""
    Write-Host "=== flyway migrate ($env, NonReplTables) ==="
    Write-Host "    locations : $LOCATIONS"

    # ignoreMigrationPatterns=*:missing tolerates Repl history entries
    # in the target's flyway_schema_history that aren't present in
    # -locations here. See the matching comment in Check-NonReplTables.ps1.
    # If RELEASE_TARGET is set (Release.ps1 orchestrator), pass it as
    # -target=<version> so flyway stops at that release.
    $TARGET_ARG = if ($env:RELEASE_TARGET) { "-target=$env:RELEASE_TARGET" } else { $null }

    flyway migrate `
        $TARGET_ARG `
        "-environment=$env" `
        "-locations=$LOCATIONS" `
        -workingDirectory="$WORKING_DIRECTORY"

    if ($LASTEXITCODE -ne 0) {
        throw "migrate failed against $env (exit $LASTEXITCODE)."
    }
}


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
