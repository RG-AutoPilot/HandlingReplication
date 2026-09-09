# Flyway Deployment Pattern Simulation

## What this is

This is a Redgate solution engineering repo, built to simulate a Flyway
deployment pattern for a client currently evaluating Flyway for their Core
OLTP environment. It is a proof-of-concept, not a copy of their real
schema, built so we can prove the deployment pattern works before we ask
the client for their real table list and manifest.

If you're an AI assistant working in this repo, read this file fully
before doing anything. Tactical routing rules (which project a given
change belongs in) live in `CLAUDE.md`, read that too before writing any
migration.

## The client's real environment

The client runs a fifteen-year-old SQL Server monolith. Two SQL Server
nodes, kept in sync with SQL Server merge replication. There are two
databases in scope, confirmed directly with the client:

`InCode`, containing stored procedures and functions only, no tables.
Deployed identically to both nodes on every release, because it isn't
part of merge replication.

`InData`, containing tables, triggers, and constraints. Some of its
tables are part of the merge-replicated pool (deploy to primary, SQL
Server propagates to secondary). The rest are non-replicated — deployed
directly and identically to both nodes on every release, same cadence
as InCode.

`InDialerData` is a third database, confirmed to exist and be
merge-replicated, but its internal structure hasn't been investigated.
Out of scope for this repo — see the "Known gaps" section below.

A note on "A" and "B": these aren't fixed, global labels in the client's
real environment. Which physical node is active versus passive can differ
per database, and can even flip by cluster parity (even-numbered clusters
one way, odd-numbered the other). In this repo, `Aprod` and `Bprod` are
relative roles for a single simulated cluster, not a stable global
identity. Worth remembering before this goes anywhere near real
replication modelling.

## Repo structure: two Flyway projects, bucket split inside InData

| Project  | Folder                | Contains                                                    | Deploys to |
|----------|------------------------|--------------------------------------------------------------|------------|
| `incode` | `projects/CoreInCode`  | Stored procedures / functions                                | Both nodes, directly, every release |
| `indata` | `projects/InData`      | All InData tables, replicated pool AND non-replicated        | Primary only for the replicated pool (replication handles the rest); both nodes directly for non-replicated |

Inside `projects/InData/migrations/` there are two subfolders:

- `ReplTables/` — migrations touching objects in the merge-replicated pool.
  Twice-yearly, high-risk changes in production because they trigger a full
  replication rebuild. Each generated V/U migration in here gets a
  `<migration>.sql.conf` sibling with
  `shouldExecute=${flyway:environment}!=Bprod` so it never runs against
  the secondary directly.
- `NonReplTables/` — migrations touching non-replicated objects. Routine
  cadence, deploys directly to both nodes, no `.conf` sibling.

Every object in either project carries an explicit `replicated: true/false`
flag in [manifest.yaml](manifest.yaml). That flag drives which
subfolder a generated script lands in — via a Redgate Compare filter
file per bucket. Never trust a table name (`ActiveNode…` / `PassiveNode…`
etc.) as a routing signal, the client has confirmed their naming
convention is inconsistent.

## What we're actually solving for here

Not the replication problem, not yet. This repo exists to prove out the
deployment pattern in isolation: a repeatable, versioned, auditable way
to capture and deploy changes across InCode and InData, using Flyway,
before we layer the harder problem of simulating the A/B replication
topology itself on top.

## Repo layout

```
.
├── README.md                     # this file
├── CLAUDE.md                     # tactical routing rules for an AI assistant
├── manifest.yaml                 # object -> project + replicated flag
├── Release.ps1                   # cross-project orchestrator (interactive menu + CLI)
├── Release.bat                   # double-click launcher for Release.ps1
├── Setup Scripts/
│   ├── 1-Create-Empty-Databases.sql       # empty CoreInCode / CoreInData_A/B / CoreInCheck
│   ├── 2-Populate-CoreInCode-Dev.sql      # creates CoreInCode_Dev with sample procs
│   └── 3-Populate-CoreInData-Dev.sql      # creates CoreInData_Dev with all 30 tables
└── projects/
    ├── CoreInCode/
    │   ├── flyway.toml           # project config, Prod environment, shadow build
    │   ├── flyway.user.toml      # per-user dev + shadow URLs (gitignored)
    │   ├── CreateDevDatabase.sql # canonical dev DB bootstrap
    │   ├── schema-model/         # authoritative desired state
    │   ├── migrations/           # V/U files created by Release.ps1
    │   └── scripts/
    │       ├── Update-SchemaModel-FromDev.ps1
    │       ├── Generate-Migration.ps1
    │       ├── Check.ps1
    │       └── Deploy.ps1
    └── InData/
        ├── flyway.toml           # project config, Aprod/Bprod/Check environments
        ├── flyway.user.toml      # per-user dev + shadow URLs (gitignored)
        ├── CreateDevDatabase.sql
        ├── Filter.ReplTables.scpf     # bucket filter for the replicated pool
        ├── Filter.NonReplTables.scpf  # bucket filter for the non-replicated tables
        ├── schema-model/
        ├── migrations/
        │   ├── ReplTables/       # V/U + .sql.conf (Bprod-blocking deploy rule)
        │   └── NonReplTables/
        └── scripts/
            ├── Update-SchemaModel-FromDev.ps1
            ├── Generate-ReplTables-Migration.ps1
            ├── Generate-NonReplTables-Migration.ps1
            ├── Check-ReplTables.ps1
            ├── Check-NonReplTables.ps1
            ├── Deploy-ReplTables.ps1
            └── Deploy-NonReplTables.ps1
```

## Environments

Defined across each project's `flyway.toml` (shared) and
`flyway.user.toml` (per-machine, gitignored):

| Env           | Project    | Purpose                                                                 |
|---------------|------------|-------------------------------------------------------------------------|
| `development` | both       | Live dev DB the developer edits (`CoreInCode_Dev`, `CoreInData_Dev`)    |
| `shadow`      | both       | Throwaway build DB for `diff`/`generate` (provisioner=create-database)  |
| `Check`       | InData     | Throwaway build DB for `check -changes` (provisioner=create-database)   |
| `Prod`        | InCode     | InCode's single deployment target (both nodes for InCode)               |
| `Aprod`       | InData     | Primary InData node                                                     |
| `Bprod`       | InData     | Secondary InData node (Repl migrations blocked via `.sql.conf` gate)    |

Both `flyway.toml` files carry
`ignoreMigrationPatterns = [ "*:missing", "*:future" ]` at the `[flyway]`
level so every command tolerates missing history entries (from cleanups)
and future entries (before a Deploy).

## Getting started

1. **Run the SQL setup scripts** in [Setup Scripts/](Setup%20Scripts/), in
   order, against your dev SQL Server instance. `1-Create-Empty-Databases.sql`
   makes the four target/check DBs empty; `2-` and `3-` create and
   populate the two dev DBs. Windows auth, `localhost` by default.
2. **Copy `flyway.user.toml`** in each project folder if it isn't there
   already, pointing `development` and `shadow` at your local server. The
   shadow DBs are created on demand by Flyway itself.
3. **Run `Release.bat`** (or `Release.ps1` directly) at the repo root.
   That's the main entry point.

## Day-to-day workflow

Everything routes through `Release.ps1`. It has an interactive menu (just
double-click `Release.bat`, or run with no args) and matching CLI flags
for scripting.

The full cycle for a normal sprint:

1. **Update development** — captures changes you've made in your dev DB
   into the checked-in `schema-model/` folder. Pick InCode, InData, or
   Both. Commit the schema-model changes to git.
2. **Create release** — packages pending schema-model changes into
   versioned migration files. You pick a base version (e.g. `7`) and
   which buckets to include (InCode, InDataReplication,
   InDataNonReplication, or any mix). Slot numbering appends `.1`, `.2`,
   `.3` per included bucket, so `-Version 7 -Include A,B,C` gives you
   `V7.1__…`, `V7.2__…`, `V7.3__…`. The base version must be strictly
   greater than the highest existing V-file across every bucket — the
   prompt tells you the current max upfront.
3. **Check release** — dry-run report per (bucket, node), scoped with
   `-target=<version>` so you only see what that release would do.
   Reports land in `projects/*/reports/` (gitignored).
4. **Deploy release** — same auto-discovery as Check, prompts you to
   confirm ("This release involves deploying Non-Replicated, Replicated
   and InCode changes. Confirm release v7 (y/N)"), then runs
   `flyway migrate -target=<version>` per bucket per node.

Check and Deploy don't ask you to remember the include order you used at
New time — they scan the folders for files matching `V<version>.<slot>__`
and process them in slot order regardless of which bucket owns each slot.

For one-off runs (e.g. only run `Deploy-ReplTables.ps1`), the menu's "Run
individual script" option launches any single per-project PS1 by
shortname.

## Key decisions already made, and why

**Migrations-based, not state-based.** Flyway offers two deployment
styles: state-based (`prepare` / `deploy`, diffs a schema model against a
live target every time) and migrations-based (`migrate` / `undo`, applies
a sequence of versioned, checksummed scripts, only running what's
pending). We chose migrations-based because it maps directly onto what
the client asked for: resumable deploys, a single-command rollback, and a
per-script audit trail. Developers still author changes against a schema
model using `diff` / `model`, then Release.ps1's Generate step turns
that into a versioned migration for PR review.

**Two Flyway projects, not three.** An earlier design had `incode`,
`nodea`, and `nodeb`, one per physical database. The client's most recent
answer collapsed that: there is no InData content unique to a single
node, so `nodea` + `nodeb` merged into one `indata` project. The A/B
production split is now expressed via the ReplTables/NonReplTables
subfolder split, per-migration `.sql.conf` deploy rules, and Flyway
environments — not by separate projects. That answer contradicts an
earlier client statement and is still pending final confirmation. See
`CLAUDE.md` for the "flag anything that looks single-node-scoped" rule
kept in place because of this.

**Cross-project release orchestration via `Release.ps1`.** The client
releases version-numbered bundles that can contain any mix of InCode,
Replication, and Non-Replication changes. `Release.ps1` mirrors that
shape at the tooling layer: one release version, one action, fanning out
across whichever buckets the developer chose. Each generated migration's
filename carries the release version, so Flyway's own history is the
release audit trail — no parallel manifest file.

**Version-slot assignment.** `-Version <base>` appends `.<slot+1>` per
included bucket, so slots don't collide across buckets even when they
share a database. `[version]` comparison (not string comparison) means
`22.2.10 > 22.2.9`.

## Known gaps and out-of-scope items

The schema in this repo is synthetic. It is not the client's real table
list. The client has agreed to share a sample of their real manifest
file. Swap these entries out once it arrives, the two-project structure
and the routing files don't need to change shape to accommodate that.

`InDialerData` is confirmed to be a real, separate, merge-replicated
database, distinct from InData. Its internal structure hasn't been
investigated. Explicitly out of scope for this repo until that's
answered. See `manifest.yaml`'s `out_of_scope` section.

The data warehouse side of the client's environment (separate from Core,
runs on Always On availability groups, no A/B replication complexity) is
out of scope entirely. If it comes into scope later, it would likely
follow the same pattern, simpler than Core since Always On replicates
automatically.

Replication itself is not modelled here. This repo proves the deployment
pattern works. Simulating the actual merge replication topology on top of
it — including the fact that "A" and "B" are relative, not global,
labels — is a separate, later piece of work. The `.sql.conf`
Bprod-blocking gate is defensive against a pipeline misconfiguration;
it's not a substitute for real replication modelling.

Not every cluster in production is identical. A consulting / professional
services division customizes stored procedures per customer, so "one
script fits every cluster" is an approximation, not a guarantee. Not
modelled here, worth remembering when this moves past the deployment
pattern into real pipeline design.
