# ===========================
# Script Name: Deploy.ps1  (InCode)
# Description: Runs `flyway migrate` for every generated InCode migration
#              against every production target in $TARGET_ENVIRONMENTS.
#              InCode deploys directly and identically to both nodes on
#              every release, no replication involvement, no per-migration
#              gate.
#
#              Sequential per node. If one node fails the script throws
#              and the next is skipped, so nodes don't diverge silently.
#              Someone has to decide how to re-sync before the next node
#              is attempted.
#
#              Pair with:  Generate-Migration.ps1 (run first to produce
#              versioned + undo migrations from the schema-model).
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

# Client-scoped target. Release.ps1 sets RELEASE_CLIENT (e.g. "CL1") so
# this deploys to that client's InCode env. Standalone runs fall back to
# bare "Prod" for backward compatibility with double-clicked launches.
$TARGET_ENVIRONMENTS   = if ($env:RELEASE_CLIENT) { @("$($env:RELEASE_CLIENT)Prod") } else { @('Prod') }

# --- Migrate per node -------------------------------------------------------
foreach ($env in $TARGET_ENVIRONMENTS) {
    Write-Host ""
    Write-Host "=== flyway migrate ($env, InCode) ==="

    # If RELEASE_TARGET is set (Release.ps1 orchestrator), pass it as

    # -target=<version> so flyway stops at that release.

    $TARGET_ARG = if ($env:RELEASE_TARGET) { "-target=$env:RELEASE_TARGET" } else { $null }


    flyway migrate `
        $TARGET_ARG `
        "-environment=$env" `
        -workingDirectory="$WORKING_DIRECTORY"

    if ($LASTEXITCODE -ne 0) {
        throw "migrate failed against $env (exit $LASTEXITCODE)."
    }
}


Write-Host ""
if (-not $env:RELEASE_ORCHESTRATOR_QUIET) { Read-Host -Prompt 'Press Enter to close' | Out-Null }
