# ===========================
# Script Name: Release.ps1
# Description: Cross-project entry point. Run with no arguments for an
#              interactive menu, or pass -Action for scripting.
#
#              Release.ps1 is a THIN orchestrator: it does not talk to
#              flyway itself. It just calls the per-project scripts in
#              projects/*/scripts/ and passes the release version to
#              them via env vars:
#
#                 $env:RELEASE_VERSION   picked up by Generate scripts,
#                                        which use it as the Flyway
#                                        version instead of a timestamp.
#                 $env:RELEASE_TARGET    picked up by Check + Deploy
#                                        scripts, which pass it as
#                                        -target=<version> to flyway.
#
#              Everything about a bucket (its filter file, deploy
#              targets, .sql.conf rule, etc.) already lives inside the
#              individual scripts. Release.ps1 only needs to know which
#              include-token maps to which script, and how to increment
#              version slots across a multi-bucket release.
#
# Actions:
#   Update  (dev DB -> schema-model, per project)
#   New     (create versioned release across buckets)
#   Check   (dry-run report per bucket per node, targeted to release)
#   Deploy  (flyway migrate per bucket per node, targeted to release,
#            prompted per client)
#   List    (releases present in migration folders)
#   Run     (call any individual project script by shortname)
#
# For out-of-scope deploys (e.g. "drain everything up to v15" on an empty
# node, or a one-off targeted -target=X.Y), call `flyway migrate` directly
# rather than adding another action here. Release.ps1 is deliberately
# release-scoped -- specific V<version> only.
#
# Version slots:
#   A new sub-component is appended per bucket, starting at 1. So:
#
#     -Version 5 -Include InCode,Replication,NonReplication
#       -> InCode                gets V5.1
#       -> InDataReplication     gets V5.2
#       -> InDataNonReplication  gets V5.3
#
#     -Version 6.1 -Include InCode,Replication,NonReplication
#       -> InCode                gets V6.1.1
#       -> InDataReplication     gets V6.1.2
#       -> InDataNonReplication  gets V6.1.3
#
#   The -Include order determines slot assignment at New time. Check
#   and Deploy do NOT need -Include: they scan the migration folders
#   for files matching V<base>.<slot>__*.sql, discover which bucket
#   each slot belongs to, and process them in slot order (1, 2, 3, ...).
#   So it doesn't matter whether you originally created the release
#   with -Include A,B,C or C,B,A -- Deploy just runs the files in
#   ascending slot order.
#
# Include tokens (case-insensitive):
#   InCode
#   InDataReplication | InDataRepl | ReplTables | Replication
#   InDataNonReplication | InDataNonRepl | NonReplTables | NonReplication
# ===========================

[CmdletBinding()]
param(
    [ValidateSet('','Update','New','Check','Deploy','List','Run','Quit')]
    [string] $Action,

    [string] $Version,
    [string] $Include,
    [string] $Description,
    [string] $Script
)

$ErrorActionPreference = 'Stop'
trap {
    Write-Host ""
    Write-Host "Release.ps1 failed:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Read-Host -Prompt 'Press Enter to close' | Out-Null
    exit 1
}

$REPO_ROOT = $PSScriptRoot

# --- Bucket -> script path map (per action) --------------------------------
# The only knowledge Release.ps1 needs. Everything about how to actually
# talk to flyway lives inside the target scripts.
$BUCKET_SCRIPTS = @{
    'InCode' = @{
        Generate = 'projects\CoreInCode\scripts\Generate-Migration.ps1'
        Check    = 'projects\CoreInCode\scripts\Check.ps1'
        Deploy   = 'projects\CoreInCode\scripts\Deploy.ps1'
        # For the file-presence pre-check (Check/Deploy skip a bucket
        # if the release's V file doesn't exist there yet):
        MigrationsPath = 'projects\CoreInCode\migrations'
    }
    'InDataReplication' = @{
        Generate = 'projects\InData\scripts\Generate-ReplTables-Migration.ps1'
        Check    = 'projects\InData\scripts\Check-ReplTables.ps1'
        Deploy   = 'projects\InData\scripts\Deploy-ReplTables.ps1'
        MigrationsPath = 'projects\InData\migrations\ReplTables'
    }
    'InDataNonReplication' = @{
        Generate = 'projects\InData\scripts\Generate-NonReplTables-Migration.ps1'
        Check    = 'projects\InData\scripts\Check-NonReplTables.ps1'
        Deploy   = 'projects\InData\scripts\Deploy-NonReplTables.ps1'
        MigrationsPath = 'projects\InData\migrations\NonReplTables'
    }
}

# The canonical order of buckets (used when the interactive menu numbers
# them and when the user omits -Include).
$BUCKET_ORDER = @('InCode', 'InDataReplication', 'InDataNonReplication')

$INCLUDE_ALIASES = @{
    'incode'                = 'InCode'
    'indatareplication'     = 'InDataReplication'
    'indatarepl'            = 'InDataReplication'
    'repltables'            = 'InDataReplication'
    'replication'           = 'InDataReplication'
    'indatanonreplication'  = 'InDataNonReplication'
    'indatanonrepl'         = 'InDataNonReplication'
    'nonrepltables'         = 'InDataNonReplication'
    'nonreplication'        = 'InDataNonReplication'
}

# For the "Run" action (single-script launcher):
$SCRIPT_MAP = [ordered]@{
    'InCode.Update'          = 'projects\CoreInCode\scripts\Update-SchemaModel-FromDev.ps1'
    'InCode.Generate'        = 'projects\CoreInCode\scripts\Generate-Migration.ps1'
    'InCode.Check'           = 'projects\CoreInCode\scripts\Check.ps1'
    'InCode.Deploy'          = 'projects\CoreInCode\scripts\Deploy.ps1'
    'InData.Update'          = 'projects\InData\scripts\Update-SchemaModel-FromDev.ps1'
    'InData.GenerateRepl'    = 'projects\InData\scripts\Generate-ReplTables-Migration.ps1'
    'InData.GenerateNonRepl' = 'projects\InData\scripts\Generate-NonReplTables-Migration.ps1'
    'InData.CheckRepl'       = 'projects\InData\scripts\Check-ReplTables.ps1'
    'InData.CheckNonRepl'    = 'projects\InData\scripts\Check-NonReplTables.ps1'
    'InData.DeployRepl'      = 'projects\InData\scripts\Deploy-ReplTables.ps1'
    'InData.DeployNonRepl'   = 'projects\InData\scripts\Deploy-NonReplTables.ps1'
}

# For the "Update" action (one script per project, no buckets):
$UPDATE_SCRIPTS = @{
    'InCode' = 'projects\CoreInCode\scripts\Update-SchemaModel-FromDev.ps1'
    'InData' = 'projects\InData\scripts\Update-SchemaModel-FromDev.ps1'
}

# --- Helpers ----------------------------------------------------------------
function Resolve-IncludedBuckets {
    param([string] $IncludeArg)
    if ([string]::IsNullOrWhiteSpace($IncludeArg)) {
        throw "-Include is required for Action=$Action. Example: -Include InCode,InDataReplication"
    }
    $tokens = $IncludeArg -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $result = @()
    foreach ($t in $tokens) {
        $key = $INCLUDE_ALIASES[$t.ToLowerInvariant()]
        if (-not $key) {
            throw "Unknown -Include token '$t'. Known tokens: $(($INCLUDE_ALIASES.Keys | Sort-Object) -join ', ')"
        }
        if ($result -notcontains $key) { $result += $key }
    }
    return ,$result
}

function Require-Version {
    if ([string]::IsNullOrWhiteSpace($Version)) {
        throw "-Version is required for Action=$Action. Example: -Version 22.2.1"
    }
    if ($Version -notmatch '^\d+(\.\d+)*$') {
        throw "-Version '$Version' is not a valid Flyway version (expected dotted-decimal like 22.2.1)."
    }
}

function Get-VersionForSlot {
    param(
        [Parameter(Mandatory)] [string] $Base,
        [Parameter(Mandatory)] [int] $Slot
    )
    # Append a new sub-component starting at 1:
    #   Base "5"    -> 5.1, 5.2, 5.3, ...
    #   Base "6.1"  -> 6.1.1, 6.1.2, 6.1.3, ...
    return "$Base.$($Slot + 1)"
}

# [version] needs at least Major.Minor to parse. Single-integer versions
# like "1" would blow up. Pad with ".0" so short versions still cast.
function ConvertTo-PaddedVersion {
    param([Parameter(Mandatory)] [string] $VersionString)
    $s = if ($VersionString -match '^\d+$') { "$VersionString.0" } else { $VersionString }
    return [version] $s
}

# Invoke a per-project script with orchestrator env vars set. Version and
# Target are optional; either or neither will be set as env vars for the
# child to consume.
function Invoke-ChildScript {
    param(
        [Parameter(Mandatory)] [string] $ScriptPath,
        [string] $ReleaseVersion,
        [string] $ReleaseTarget,
        [string] $ReleaseLabel,
        [string] $ReleaseClient,
        [string] $Label
    )
    $target = Join-Path $REPO_ROOT $ScriptPath
    if (-not (Test-Path $target)) { throw "Script not found: $target" }

    Write-Host ""
    Write-Host "=== $Label ==="
    Write-Host "    file : $target"
    if ($ReleaseVersion) { Write-Host "    RELEASE_VERSION=$ReleaseVersion" }
    if ($ReleaseTarget)  { Write-Host "    RELEASE_TARGET =$ReleaseTarget" }
    if ($ReleaseLabel)   { Write-Host "    RELEASE_LABEL  =$ReleaseLabel" }
    if ($ReleaseClient)  { Write-Host "    RELEASE_CLIENT =$ReleaseClient" }

    $env:RELEASE_ORCHESTRATOR_QUIET = '1'
    # Unified reports location: <repo>/reports. Individual Check scripts
    # honour this and drop project-local reports/ when set, so a single
    # release folder gathers reports across every project + client + node.
    $env:RELEASE_REPORTS_ROOT = Join-Path $REPO_ROOT 'reports'
    if ($ReleaseVersion) { $env:RELEASE_VERSION = $ReleaseVersion }
    if ($ReleaseTarget)  { $env:RELEASE_TARGET  = $ReleaseTarget }
    if ($ReleaseLabel)   { $env:RELEASE_LABEL   = $ReleaseLabel }
    if ($ReleaseClient)  { $env:RELEASE_CLIENT  = $ReleaseClient }
    try {
        & $target
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
            throw "$Label exited with $LASTEXITCODE."
        }
    } finally {
        $env:RELEASE_ORCHESTRATOR_QUIET = $null
        $env:RELEASE_REPORTS_ROOT = $null
        $env:RELEASE_VERSION = $null
        $env:RELEASE_TARGET  = $null
        $env:RELEASE_LABEL   = $null
        $env:RELEASE_CLIENT  = $null
    }
}

function Has-ReleaseFile {
    param(
        [Parameter(Mandatory)] [string] $BucketName,
        [Parameter(Mandatory)] [string] $VersionForBucket
    )
    $path = Join-Path $REPO_ROOT $BUCKET_SCRIPTS[$BucketName].MigrationsPath
    if (-not (Test-Path $path)) { return $false }
    $hits = Get-ChildItem -Path $path -Filter "V$VersionForBucket`__*.sql" -File -ErrorAction SilentlyContinue
    return [bool] $hits
}

# For Check/Deploy: scan every bucket folder for files that match the
# release base version (e.g. base "5" matches V5.1__, V5.2__, V5.3__).
# Returns them in slot order (1, 2, 3, ...) regardless of which bucket
# they came from. This means the user does NOT have to remember the
# original -Include order they used at New time -- we discover the
# assignment from the files themselves.
function Find-ReleaseSlots {
    param(
        [Parameter(Mandatory)] [string] $BaseVersion
    )
    $escaped = [regex]::Escape($BaseVersion)
    $slotRegex = "^V${escaped}\.(\d+)__"
    $found = @()
    foreach ($name in $BUCKET_ORDER) {
        $path = Join-Path $REPO_ROOT $BUCKET_SCRIPTS[$name].MigrationsPath
        if (-not (Test-Path $path)) { continue }
        Get-ChildItem -Path $path -Filter 'V*__*.sql' -File | ForEach-Object {
            if ($_.Name -match $slotRegex) {
                $found += [PSCustomObject]@{
                    Bucket  = $name
                    Slot    = [int] $Matches[1]
                    Version = "$BaseVersion.$($Matches[1])"
                    File    = $_.Name
                }
            }
        }
    }
    return @($found | Sort-Object Slot)
}

# Highest existing V<version>__ across the given buckets. Returns $null
# if no versioned files are present. Used by Assert-VersionGreaterThanExisting
# to refuse a release that would go backwards.
function Get-MaxExistingVersion {
    param(
        [Parameter(Mandatory)] [string[]] $BucketNames
    )
    $max = $null
    foreach ($name in $BucketNames) {
        $path = Join-Path $REPO_ROOT $BUCKET_SCRIPTS[$name].MigrationsPath
        if (-not (Test-Path $path)) { continue }
        Get-ChildItem -Path $path -Filter 'V*__*.sql' -File | ForEach-Object {
            if ($_.Name -match '^V(\d+(?:\.\d+)*)__') {
                $v = ConvertTo-PaddedVersion $matches[1]
                if (-not $max -or $v -gt $max) { $max = $v }
            }
        }
    }
    return $max
}

# Throw if the caller's -Version is not strictly greater than the highest
# existing version in the included buckets. Prevents accidentally releasing
# an older version number than one already committed.
function Assert-VersionGreaterThanExisting {
    param(
        [Parameter(Mandatory)] [string] $RequestedVersion,
        [Parameter(Mandatory)] [string[]] $BucketNames
    )
    $max = Get-MaxExistingVersion -BucketNames $BucketNames
    if (-not $max) { return }
    # Compare using [version] so 22.2.10 > 22.2.9 (not lexicographic).
    $req = ConvertTo-PaddedVersion $RequestedVersion
    if ($req -le $max) {
        throw ("Requested -Version '$RequestedVersion' is not newer than the highest existing " +
               "version 'v$($max)' already present in the target buckets ($($BucketNames -join ', ')). " +
               "Bump -Version above 'v$($max)' or delete the older file if it was a mistake.")
    }
}

# Discover configured clients by scanning projects/InData/flyway.toml for
# [environments.<prefix>Aprod] section headers. Returns the prefixes as an
# array, e.g. @('CL1', 'RG'). The prefix is used to build node env names:
# ${prefix}Aprod / ${prefix}Bprod (InData) and ${prefix}Prod (InCode).
# For that to work the InCode flyway.toml must have matching ${prefix}Prod
# envs -- see CLAUDE.md's "Adding a new client" section.
function Get-ConfiguredClients {
    $tomlPath = Join-Path $REPO_ROOT 'projects\InData\flyway.toml'
    if (-not (Test-Path $tomlPath)) { return @() }
    $clients = @()
    Get-Content $tomlPath | ForEach-Object {
        if ($_ -match '^\s*\[environments\.([A-Za-z0-9]+)Aprod\]\s*$') {
            if ($clients -notcontains $matches[1]) { $clients += $matches[1] }
        }
    }
    return ,$clients
}

# Interactive prompt: "All clients", or comma-separated list. Returns an
# array of client prefixes to iterate over.
function Prompt-Clients {
    $all = Get-ConfiguredClients
    if (-not $all) {
        throw "No clients found in projects/InData/flyway.toml. Expected at least one [environments.CL<N>Aprod] section."
    }
    Write-Host ""
    Write-Host "Which client(s)?"
    Write-Host "  0) All clients ($($all -join ', '))"
    for ($i = 0; $i -lt $all.Length; $i++) {
        Write-Host ("  {0}) {1}" -f ($i + 1), $all[$i])
    }
    while ($true) {
        $raw = Read-Host "Choice (e.g. 0, or 1,2)"
        if ([string]::IsNullOrWhiteSpace($raw)) { continue }
        if ($raw.Trim() -eq '0') { return ,$all }
        $tokens = $raw -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        $picked = @()
        $bad = $false
        foreach ($t in $tokens) {
            if ($t -notmatch '^\d+$') { $bad = $true; break }
            $n = [int] $t
            if ($n -lt 1 -or $n -gt $all.Length) { $bad = $true; break }
            $name = $all[$n - 1]
            if ($picked -notcontains $name) { $picked += $name }
        }
        if ($bad -or -not $picked) {
            Write-Host "Enter 0 for all, or comma-separated numbers between 1 and $($all.Length)." -ForegroundColor Yellow
            continue
        }
        return ,$picked
    }
}

function List-Releases {
    Write-Host ""
    Write-Host "Migration files present, grouped by version (does NOT reflect deploy status per environment):"
    $rows = @()
    foreach ($name in $BUCKET_ORDER) {
        $path = Join-Path $REPO_ROOT $BUCKET_SCRIPTS[$name].MigrationsPath
        if (-not (Test-Path $path)) { continue }
        Get-ChildItem -Path $path -Filter 'V*__*.sql' -File | ForEach-Object {
            if ($_.Name -match '^V(\d+(?:\.\d+)*)__') {
                $rows += [PSCustomObject]@{
                    Version = $matches[1]
                    Bucket  = $name
                    File    = $_.Name
                }
            }
        }
    }
    if (-not $rows) { Write-Host "  (no versioned migrations found)"; return }
    $rows | Sort-Object @{Expression={ ConvertTo-PaddedVersion $_.Version }}, Bucket | Format-Table -AutoSize
}

function Invoke-Run {
    if ([string]::IsNullOrWhiteSpace($Script)) {
        Write-Host ""
        Write-Host "Usage: .\Release.ps1 -Action Run -Script <shortname>"
        Write-Host "Known shortnames:"
        foreach ($k in $SCRIPT_MAP.Keys) { Write-Host ("  {0,-24} -> {1}" -f $k, $SCRIPT_MAP[$k]) }
        return
    }
    $matchedKey = $SCRIPT_MAP.Keys | Where-Object { $_ -ieq $Script } | Select-Object -First 1
    if (-not $matchedKey) {
        throw "Unknown -Script '$Script'. Run '.\Release.ps1 -Action Run' with no -Script to see the list."
    }
    Invoke-ChildScript -ScriptPath $SCRIPT_MAP[$matchedKey] -Label "Run: $matchedKey"
}

# --- Interactive menu prompts -----------------------------------------------
function Prompt-Choice {
    param(
        [Parameter(Mandatory)] [string] $Prompt,
        [Parameter(Mandatory)] [string[]] $Options
    )
    Write-Host ""
    Write-Host $Prompt
    for ($i = 0; $i -lt $Options.Length; $i++) {
        Write-Host ("  {0}) {1}" -f ($i + 1), $Options[$i])
    }
    while ($true) {
        $raw = Read-Host "Choice"
        if ($raw -match '^\d+$') {
            $n = [int] $raw
            if ($n -ge 1 -and $n -le $Options.Length) { return $Options[$n - 1] }
        }
        Write-Host "Enter a number between 1 and $($Options.Length)." -ForegroundColor Yellow
    }
}

function Prompt-Includes {
    Write-Host ""
    Write-Host "Which buckets? (comma-separated numbers, order matters for version slots)"
    for ($i = 0; $i -lt $BUCKET_ORDER.Length; $i++) {
        Write-Host ("  {0}) {1}" -f ($i + 1), $BUCKET_ORDER[$i])
    }
    while ($true) {
        $raw = Read-Host "Choice (e.g. 1,2,3)"
        if ([string]::IsNullOrWhiteSpace($raw)) { continue }
        $tokens = $raw -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        $picked = @()
        $bad = $false
        foreach ($t in $tokens) {
            if ($t -notmatch '^\d+$') { $bad = $true; break }
            $n = [int] $t
            if ($n -lt 1 -or $n -gt $BUCKET_ORDER.Length) { $bad = $true; break }
            $name = $BUCKET_ORDER[$n - 1]
            if ($picked -notcontains $name) { $picked += $name }
        }
        if ($bad -or -not $picked) {
            Write-Host "Enter comma-separated numbers between 1 and $($BUCKET_ORDER.Length)." -ForegroundColor Yellow
            continue
        }
        return ($picked -join ',')
    }
}

function Get-RecentReleaseBases {
    param([int] $Count = 5)
    # A release is identified by the base version (everything except the
    # last dot component of a slot version). So V5.1, V5.2, V5.3 all
    # belong to release "5"; V6.1.1, V6.1.2, V6.1.3 all belong to release
    # "6.1". Dedup, then return the most recent N by [version] compare.
    $bases = @{}
    foreach ($name in $BUCKET_ORDER) {
        $path = Join-Path $REPO_ROOT $BUCKET_SCRIPTS[$name].MigrationsPath
        if (-not (Test-Path $path)) { continue }
        Get-ChildItem -Path $path -Filter 'V*__*.sql' -File | ForEach-Object {
            if ($_.Name -match '^V(\d+(?:\.\d+)*)__') {
                $parts = $matches[1] -split '\.'
                $base = if ($parts.Length -le 1) { $matches[1] } else { ($parts[0..($parts.Length - 2)]) -join '.' }
                $bases[$base] = $true
            }
        }
    }
    @($bases.Keys | Sort-Object @{Expression={ ConvertTo-PaddedVersion $_ }; Descending=$true} | Select-Object -First $Count)
}

function Prompt-Version {
    param(
        # When set, the entered version must be strictly greater than the
        # highest existing V-file across every bucket. Used for New so we
        # catch a bad version before asking about buckets or description.
        [switch] $MustBeGreater
    )
    $max = Get-MaxExistingVersion -BucketNames $BUCKET_ORDER
    Write-Host ""
    if ($max) {
        if ($MustBeGreater) {
            # New action: user needs to pick a version above the current
            # highest, so a single "latest" line is what matters.
            Write-Host "Latest release on disk: v$max"
        } else {
            # Check / Deploy: user is picking an existing release, so show
            # the recent ones as a jog to memory.
            $recent = Get-RecentReleaseBases -Count 5
            Write-Host "Recent releases on disk (most recent first):"
            foreach ($r in $recent) { Write-Host "  v$r" }
        }
    } else {
        Write-Host "No releases packaged yet on disk."
    }
    while ($true) {
        $v = Read-Host "Release version (e.g. 22.2.1)"
        if ($v -notmatch '^\d+(\.\d+)*$') {
            Write-Host "Enter a dotted-decimal version like 22.2.1." -ForegroundColor Yellow
            continue
        }
        if ($MustBeGreater -and $max) {
            $req = ConvertTo-PaddedVersion $v
            if ($req -le $max) {
                Write-Host "Version '$v' is not newer than the latest release 'v$max'. Enter a version above 'v$max'." -ForegroundColor Yellow
                continue
            }
        }
        return $v
    }
}

function Prompt-Script {
    $keys = @($SCRIPT_MAP.Keys)
    Write-Host ""
    Write-Host "Which script?"
    for ($i = 0; $i -lt $keys.Length; $i++) {
        Write-Host ("  {0,2}) {1}" -f ($i + 1), $keys[$i])
    }
    while ($true) {
        $raw = Read-Host "Choice"
        if ($raw -match '^\d+$') {
            $n = [int] $raw
            if ($n -ge 1 -and $n -le $keys.Length) { return $keys[$n - 1] }
        }
        Write-Host "Enter a number between 1 and $($keys.Length)." -ForegroundColor Yellow
    }
}

function Prompt-UpdateProject {
    $options = @('InCode only', 'InData only', 'Both InCode and InData')
    $picked = Prompt-Choice -Prompt "Which project's dev DB to capture into schema-model?" -Options $options
    switch -Wildcard ($picked) {
        'InCode only*' { return 'InCode' }
        'InData only*' { return 'InData' }
        'Both*'        { return 'InCode,InData' }
    }
}

# --- Main loop --------------------------------------------------------------
$StartedInteractive = [string]::IsNullOrWhiteSpace($Action)

do {
    if ($StartedInteractive) {
        $Action      = ''
        $Version     = $null
        $Include     = $null
        $Script      = $null
        $Description = $null

        Write-Host ""
        Write-Host "============================================"
        Write-Host " Flyway Release Orchestrator"
        Write-Host "============================================"
        $menuChoice = Prompt-Choice -Prompt "What do you want to do?" -Options @(
            "Update development   (capture dev DB changes into schema-model)",
            "Create release       (package pending changes into V<version>__ files)",
            "Check release        (dry-run report per node)",
            "Deploy release       (flyway migrate per node, targeted to one release)",
            "Run individual script",
            "Quit"
        )
        switch -Wildcard ($menuChoice) {
            'Update development*'      { $Action = 'Update' }
            'Create release*'          { $Action = 'New' }
            'Check release*'           { $Action = 'Check' }
            'Deploy release*'          { $Action = 'Deploy' }
            'Run individual script*'   { $Action = 'Run' }
            'Quit*'                    { $Action = 'Quit' }
        }
        if ($Action -eq 'Quit') { break }

        switch ($Action) {
            'Update' { $Include = Prompt-UpdateProject }
            'New'    {
                $Version = Prompt-Version -MustBeGreater
                $Include = Prompt-Includes
                $desc = Read-Host "Optional description (press Enter to skip)"
                if (-not [string]::IsNullOrWhiteSpace($desc)) { $Description = $desc }
            }
            'Check'  { $Version = Prompt-Version }   # -Include auto-discovered from files
            'Deploy' { $Version = Prompt-Version }   # -Include auto-discovered from files
            'Run'    { $Script = Prompt-Script }
        }
    }

    try {
        switch ($Action) {
            'Update' {
                if ([string]::IsNullOrWhiteSpace($Include)) {
                    throw "-Include is required for Action=Update. Values: InCode, InData, Both."
                }
                $normalized = ($Include -replace '\s','').ToLowerInvariant()
                $projects = if ($normalized -eq 'both') { @('InCode','InData') } else {
                    $Include -split ',' | ForEach-Object {
                        $t = $_.Trim()
                        if ($t -ieq 'InCode') { 'InCode' }
                        elseif ($t -ieq 'InData') { 'InData' }
                        else { throw "Unknown -Include token '$t' for Update. Values: InCode, InData, Both." }
                    } | Select-Object -Unique
                }
                foreach ($proj in $projects) {
                    Invoke-ChildScript -ScriptPath $UPDATE_SCRIPTS[$proj] -Label "Update: $proj (dev -> schema-model)"
                }
            }

            'New' {
                Require-Version
                $buckets = Resolve-IncludedBuckets -IncludeArg $Include
                # Check against EVERY bucket, not just the ones in this
                # release. Otherwise you could create release 6 (NonRepl+
                # InCode) and then release 6.1 (Repl only), and the second
                # one would silently pass because the Repl folder was empty
                # even though V6.1 already exists in NonRepl.
                Assert-VersionGreaterThanExisting -RequestedVersion $Version -BucketNames $BUCKET_ORDER
                Write-Host "Packaging release starting at v$Version across: $($buckets -join ', ')"
                $slot = 0
                foreach ($name in $buckets) {
                    $v = Get-VersionForSlot -Base $Version -Slot $slot
                    Invoke-ChildScript `
                        -ScriptPath $BUCKET_SCRIPTS[$name].Generate `
                        -ReleaseVersion $v `
                        -Label "New: $name at v$v"
                    $slot++
                }
            }

            'Check' {
                Require-Version
                # Auto-discover which bucket owns each slot for this release,
                # from the files on disk. No need for -Include.
                $slots = Find-ReleaseSlots -BaseVersion $Version
                if (-not $slots) {
                    Write-Host "No files found matching V$Version.*__*.sql in any bucket."
                    break
                }
                Write-Host "Found $($slots.Count) file(s) for release v$Version, checking in slot order:"
                foreach ($s in $slots) {
                    Write-Host "  slot $($s.Slot) -> $($s.Bucket) ($($s.File))"
                }

                # Pick client(s) to check against. Same shape as Deploy.
                if ($StartedInteractive) {
                    $clients = Prompt-Clients
                } else {
                    $clients = Get-ConfiguredClients
                    if (-not $clients) {
                        throw "No clients configured in projects/InData/flyway.toml."
                    }
                }
                Write-Host ""
                Write-Host ("Target client(s): {0}" -f ($clients -join ', '))

                foreach ($client in $clients) {
                    Write-Host ""
                    Write-Host "----- Client: $client -----" -ForegroundColor Cyan
                    foreach ($s in $slots) {
                        Invoke-ChildScript `
                            -ScriptPath $BUCKET_SCRIPTS[$s.Bucket].Check `
                            -ReleaseTarget $s.Version `
                            -ReleaseLabel "v$Version" `
                            -ReleaseClient $client `
                            -Label "Check: $($s.Bucket) for $client (target=$($s.Version))"
                    }
                }
            }

            'Deploy' {
                Require-Version
                # Same auto-discovery as Check.
                $slots = Find-ReleaseSlots -BaseVersion $Version
                if (-not $slots) {
                    Write-Host "No files found matching V$Version.*__*.sql in any bucket."
                    break
                }
                Write-Host "Found $($slots.Count) file(s) for release v$Version, deploying in slot order:"
                foreach ($s in $slots) {
                    Write-Host "  slot $($s.Slot) -> $($s.Bucket) ($($s.File))"
                }

                # Pick client(s) to deploy to. Interactive: prompt. Scripted:
                # default to all configured. (No -Client CLI flag yet; add
                # if scripted single-client deploys become a need.)
                if ($StartedInteractive) {
                    $clients = Prompt-Clients
                } else {
                    $clients = Get-ConfiguredClients
                    if (-not $clients) {
                        throw "No clients configured in projects/InData/flyway.toml."
                    }
                }

                # Interactive-only safety confirmation. Scripted callers
                # (CLI -Action Deploy) skip this so automation is unaffected.
                if ($StartedInteractive) {
                    $friendlyNames = @{
                        'InCode'                = 'InCode Schema Changes'
                        'InDataReplication'     = 'InData Replicating Changes'
                        'InDataNonReplication'  = 'InData NonReplicating Changes'
                    }
                    # @(...) wrap forces this to stay an array even when only
                    # one bucket is in the release. Without it $covered would
                    # unwrap to a string, and $covered[0] would return the
                    # first character ("I" instead of "InData NonReplicating
                    # Changes").
                    $covered = @($slots.Bucket | Sort-Object -Unique | ForEach-Object { $friendlyNames[$_] })
                    $summary = if ($covered.Count -eq 1) {
                        $covered[0]
                    } elseif ($covered.Count -eq 2) {
                        "$($covered[0]) and $($covered[1])"
                    } else {
                        "$($covered[0..($covered.Count-2)] -join ', ') and $($covered[-1])"
                    }
                    Write-Host ""
                    Write-Host "This release involves deploying $summary." -ForegroundColor Cyan
                    Write-Host ("Target client(s): {0}" -f ($clients -join ', ')) -ForegroundColor Cyan
                    $confirm = Read-Host "Confirm release v$Version (y/N)"
                    if ($confirm -notmatch '^[Yy]') {
                        Write-Host "Deploy cancelled." -ForegroundColor Yellow
                        break
                    }
                }

                foreach ($client in $clients) {
                    Write-Host ""
                    Write-Host "----- Client: $client -----" -ForegroundColor Cyan
                    foreach ($s in $slots) {
                        # ReleaseClient is used by InData child scripts to
                        # build ${client}Aprod / ${client}Bprod env names.
                        # InCode child ignores it and targets env 'Prod'.
                        Invoke-ChildScript `
                            -ScriptPath $BUCKET_SCRIPTS[$s.Bucket].Deploy `
                            -ReleaseTarget $s.Version `
                            -ReleaseClient $client `
                            -Label "Deploy: $($s.Bucket) for $client (target=$($s.Version))"
                    }
                }
            }

            'List' { List-Releases }
            'Run'  { Invoke-Run }
        }
    }
    catch {
        if ($StartedInteractive) {
            Write-Host ""
            Write-Host "Action failed: $_" -ForegroundColor Red
            Write-Host "(Returning to menu -- the previous action did not complete.)" -ForegroundColor Yellow
        } else {
            throw
        }
    }

    if ($StartedInteractive) {
        Write-Host ""
        Read-Host -Prompt "Press Enter to return to the menu" | Out-Null
    }
} while ($StartedInteractive)

Write-Host ""
Read-Host -Prompt 'Press Enter to close' | Out-Null
