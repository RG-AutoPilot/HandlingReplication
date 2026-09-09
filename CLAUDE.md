# CLAUDE.md

Tactical routing rules for an AI assistant working in this repo. The
strategic story (client's real environment, why the deployment pattern
looks like this) lives in [README.md](README.md), read that first if you
haven't.

## Structure at a glance

Two Flyway projects:

| Project  | Folder                | Contains                                                    | Deploys to |
|----------|------------------------|--------------------------------------------------------------|------------|
| `incode` | `projects/CoreInCode`  | Stored procedures / functions                                | Both nodes (env: `Prod`), every release |
| `indata` | `projects/InData`      | All InData tables, replicated AND non-replicated             | Primary (`Aprod`) for replicated; both (`Aprod` + `Bprod`) for non-replicated |

Inside `projects/InData/migrations/` there are two subfolders:

- `ReplTables/` — merge-replicated pool. High-risk (twice-yearly in
  production, triggers a full replication rebuild). Every V/U file here
  ships with a `<migration>.sql.conf` sibling carrying an
  **inclusion-list** `shouldExecute` expression enumerating every env
  the migration is allowed to run in
  (`${flyway:environment}==CL1Aprod||${flyway:environment}==RGAprod||${flyway:environment}==Check||${flyway:environment}==shadow`
  today). Flyway skips the migration on any env not in the list,
  including every B-node env. This is the same shape Flyway Desktop
  generates for a deploy rule, so regenerating from Desktop won't drift.
  Fail-safe: an env you forget to add just skips the migration (loud —
  developer sees it skipped) rather than silently executing it. See the
  "Adding a new client" note below.
- `NonReplTables/` — non-replicated tables. Routine cadence, deploys to
  both nodes directly. No `.sql.conf`.

Client-side, the current answer is that **no InData content is unique to
one node** — every object is either replicated or dual-deploy. That
answer contradicts an earlier client answer and is still pending final
confirmation. **If you see anything in this codebase or in a developer's
request that looks like it's scoped to only one specific node outside of
replication, stop and flag it explicitly rather than filing it away.**
That would be evidence the "no unique content" assumption is wrong.

Each project folder is a **complete, standalone Flyway project** with
its own `flyway.toml`, `schema-model/`, `migrations/`, and `.mcp.json`.
Someone can `cd` into either project folder and run plain `flyway` CLI
commands with no AI involved.

## How to route a change

Full object-to-project mapping lives in [manifest.yaml](manifest.yaml).
Read it before answering "which project owns X?".

1. Look the object up in `manifest.yaml`.
2. If it isn't listed:
   - **Stored procs / functions** → belong in `incode`.
   - **Tables** → **ask the developer directly**: "Is this part of the
     merge-replicated pool, or is it non-replicated (deployed directly
     to both nodes)?" Do not guess from the table name. The client's
     naming convention (`ActiveNode…` / `PassiveNode…`) is inconsistent
     and unreliable. Once you have an answer, add the object to
     `manifest.yaml` under `indata` with an explicit `replicated:
     true/false` flag before writing any migration.
3. For an `indata` change, the `replicated` flag also decides which
   migrations subfolder the generated script lands in: `ReplTables/` for
   `replicated: true`, `NonReplTables/` for `replicated: false`. The
   generate wrappers use per-bucket Redgate Compare filter files
   (`Filter.ReplTables.scpf`, `Filter.NonReplTables.scpf`) that mirror
   the manifest's `replicated` flag at the tooling layer. **If you add
   or rename a table in `manifest.yaml`, update the matching filter
   file too.**
4. If the change touches a `replicated: true` object, **flag this
   explicitly to the developer** — in production these ship twice-yearly
   because they trigger a full replication rebuild. Don't let a
   replicated-table change get treated the same as a routine one.
5. Never split one logical change across two projects silently. If a
   change genuinely touches objects in two different projects (e.g. a
   new proc that reads a new table), that's two separate migrations,
   both called out explicitly to the developer. Same applies inside
   `indata` if one change touches both a replicated and a non-replicated
   table (rare, but flag it).

## Day-to-day workflow: use Release.ps1

`Release.ps1` at the repo root is the main entry point. Interactive menu
(no args) or CLI (`-Action New|Check|Deploy|Update|List|Run`). The five
main actions:

1. **Update development** — captures dev-DB changes into `schema-model/`.
   Choose InCode, InData, or Both. This is the equivalent of Flyway
   Desktop's "save changes" action; no migration scripts are produced.
2. **Create release** — packages pending schema-model changes as
   versioned V/U files. You pick a base version (e.g. `7`) and buckets
   (`InCode,InDataReplication,InDataNonReplication` — any mix, any
   order). Slots append `.1`, `.2`, `.3` per included bucket in
   `-Include` order, so `-Version 7 -Include A,B,C` produces
   `V7.1__…`, `V7.2__…`, `V7.3__…`. Base version must be strictly
   greater than the highest existing V-file across every bucket.
3. **Check release** — dry-run report per (bucket, node) with
   `-target=<version>`, HTML output to `projects/*/reports/`
   (gitignored).
4. **Deploy release** — `flyway migrate -target=<version>` per bucket
   per node. Interactive Deploy prompts for confirmation and lists the
   buckets that will be touched. Check/Deploy don't need `-Include`;
   they scan the folders for files matching `V<version>.<slot>__` and
   process in slot order, so the developer never has to remember the
   original `-Include` order.
5. **Run individual script** — launcher for any single per-project PS1
   by shortname, useful for one-off runs.

The per-project scripts (`Update-SchemaModel-FromDev.ps1`,
`Generate-*-Migration.ps1`, `Check-*.ps1`, `Deploy-*.ps1`) live under
each project's `scripts/` folder. Release.ps1 invokes them with
`$env:RELEASE_VERSION` (Generate) or `$env:RELEASE_TARGET` (Check/Deploy)
set — the scripts read those env vars and add the matching flyway
flags. When run standalone (double-click), the scripts fall back to
timestamp-based version numbering and unscoped migrate, so they still
work outside the orchestrator.

## Environments

Environments are **client-prefixed**: each client cluster has its own
A/B pair for InData and a Prod env for InCode. The prefix identifies the
client; `<prefix>Aprod` / `<prefix>Bprod` / `<prefix>Prod` are the three
envs per client. Naming is free-form (any `[A-Za-z0-9]+` prefix works)
so long as the prefix is used consistently across all three envs — the
client-selection code in `Release.ps1` builds env names from the prefix.

Currently configured clients (on Huxley's dev box):

| Prefix | Cluster                                                     | Notes |
|--------|--------------------------------------------------------------|-------|
| `CL1`  | `CoreInData_A` / `CoreInData_B` / `CoreInCode`               | **Replicated** — merge repl publisher/subscriber configured manually on `HuxRG`. Repl migrations run on Aprod, merge agent propagates to Bprod. |
| `RG`   | `Redgate_CoreInData_NodeA` / `Redgate_CoreInData_NodeB` / `Redgate_CoreInCode` | **Non-replicated** — plain dual-deploy for the NonRepl bucket; Repl migrations run on Aprod only, never reach Bprod (no merge agent to propagate). Useful for testing routing behaviour without merge-repl side effects. |

| Env             | Project    | Purpose |
|-----------------|------------|---------|
| `development`   | both       | Live dev DB (`CoreInCode_Dev`, `CoreInData_Dev`) |
| `shadow`        | both       | Throwaway build DB for diff/generate, provisioner=create-database |
| `Check`         | InData     | Throwaway build DB for check -changes, provisioner=create-database |
| `Prod`          | InCode     | Standalone fallback env (single CoreInCode DB), used only when a script is run standalone with no client selected |
| `<prefix>Aprod` | InData     | Client's primary InData node |
| `<prefix>Bprod` | InData     | Client's secondary InData node (Repl migrations blocked via `.sql.conf`) |
| `<prefix>Prod`  | InCode     | Client's InCode deploy target |

Both `flyway.toml` files carry
`ignoreMigrationPatterns = [ "*:missing", "*:future" ]` at `[flyway]`
level so every command tolerates deleted-from-disk history entries and
future migrations pending deploy.

### Replication status per client

- **CL1** has real SQL Server merge replication configured on `HuxRG`:
  `CoreInData_A` is the publisher of publication `CoreInData_Merge`,
  `CoreInData_B` is the push subscriber, 11 articles matching
  `manifest.yaml`'s `replicated: true` entries. Setup was manual (not
  scripted into this repo — the script lives on Huxley's box only).
- **RG** has no replication. `Redgate_CoreInData_NodeA` and
  `Redgate_CoreInData_NodeB` are plain databases. The `.sql.conf`
  gating still blocks Repl migrations from hitting `RGBprod` directly;
  they land only on `RGAprod`, and B will drift because there's no
  merge agent to propagate. That's the intended behaviour for the
  non-replicated mode — it lets you test routing gates without merge
  repl's side effects (rowguid columns, triggers, restricted DDL).

### Adding a new client — Repl gating fanout

The Repl safety gate in `projects/InData/migrations/ReplTables/*.sql.conf`
is an inclusion list of allowed envs:
`shouldExecute=${flyway:environment}==CL1Aprod||${flyway:environment}==RGAprod||${flyway:environment}==Check||${flyway:environment}==shadow`.
This is the shape Flyway Desktop generates for a deploy rule — keep it
so regenerating a rule from Desktop won't drift.

Flyway's `shouldExecute` parser (as of Enterprise 13.4) accepts only
`==`, `!=`, `&&`, `||` — `IN (...)`, `NOT IN (...)`, and the word forms
`AND`/`OR` all fail with "no viable alternative". Environment names on
the RHS are bare identifiers (no quotes). There is no wildcard/regex.
(Attempted `\bAprod\b` regex support empirically fails: the string is
treated as a literal, matching nothing, so every migration silently
skips. Verified 2026-09-08 — an engineer is looking at whether Java
regex hooks are exposed elsewhere in the expression.)

**When adding a new client (e.g. prefix `ACME`), three edits are mandatory:**

1. Add `[environments.ACMEAprod]` and `[environments.ACMEBprod]` to
   `projects/InData/flyway.toml`.
2. Add `[environments.ACMEProd]` to `projects/CoreInCode/flyway.toml`.
   Prefix **must** match across both files — the client-selection code
   in `Release.ps1` builds env names as `${prefix}Aprod`/`Bprod`/`Prod`.
3. Update **every** `.sql.conf` under `projects/InData/migrations/ReplTables/`
   to append `||${flyway:environment}==ACMEAprod` to the expression.
   Missing one file causes that Repl migration to be skipped on the new
   client's A node — a **loud** failure (visible in migrate output),
   not a silent unsafe one. That's the point of using an inclusion list
   instead of an exclusion list: omission fails safe.

Note: `Generate-ReplTables-Migration.ps1` already discovers `*Aprod`
envs dynamically from `flyway.toml`, so future generated migrations
pick up new clients automatically. Only existing sidecar files need
the manual `||` append.

If the per-file fanout ever gets unwieldy, switch to a per-env
`placeholders.nodeRole = "A"|"B"` and change the gate to
`${nodeRole}==A` (constant across clients). Not done yet — this note
exists to make that trade-off visible.

## Setup

Fresh clone bootstrap:

1. Run `Setup Scripts/1-Create-Empty-Databases.sql` — creates
   `CoreInCode`, `CoreInData_A`, `CoreInData_B`, `CoreInCheck` empty.
2. Run `Setup Scripts/2-Populate-CoreInCode-Dev.sql` — creates
   `CoreInCode_Dev` with sample procs.
3. Run `Setup Scripts/3-Populate-CoreInData-Dev.sql` — creates
   `CoreInData_Dev` with all 30 tables.
4. Ensure each project's `flyway.user.toml` points `development` and
   `shadow` at your local server.

Shadow DBs are provisioned by Flyway on demand (`create-database`
provisioner), so they don't need to be pre-created.

## Naming convention is NOT a routing signal

The client's own table names include historical prefixes like
`ActiveNode…` and `PassiveNode…`. These names do **NOT** reliably
indicate whether a table is node-scoped or which node it belongs to —
the client has confirmed their naming convention on this is
inconsistent. Trust the `replicated` flag in `manifest.yaml` and the
`-- Replicated:` comment at the top of each schema-model file, not the
name. If a name suggests one thing and the flag says another, the flag
wins, and raise the mismatch with the developer.

## `undo` is not a true rollback

`flyway undo` reverses the structural delta (drops what a migration
created, doesn't restore lost data), it does not reconstruct prior
state. Fine for a quick revert in QA. For a production incident, the
client's own stated approach is fix-forward via a hotfix pipeline, not
`undo`. Don't suggest `undo` as a production rollback mechanism without
flagging this distinction.

## What this repo intentionally does not do yet

- **Repo does not ship replication setup.** Merge replication IS
  configured on Huxley's local box for the CL1 client, but the setup
  script is local, not committed. Dev databases (CoreInData_Dev,
  CoreInCode_Dev) remain plain, standalone — replication only affects
  the prod node DBs of the CL1 cluster. See the Environments section
  above for the current state per client. Don't add replication
  configuration for the RG client unless explicitly asked to — the RG
  cluster is deliberately non-replicated so the two setups can be
  compared side by side.
- **InDialerData is out of scope.** Confirmed to exist as a separate,
  merge-replicated database, but its internal structure hasn't been
  investigated. See `manifest.yaml`'s `out_of_scope` section. Don't
  build a project for it unprompted.
- **No data warehouse projects.** Out of scope, see `manifest.yaml`.
- **No production credentials anywhere.** Anything beyond `development`
  and `shadow` should use Flyway's secrets management, never a plaintext
  value in `flyway.toml`.

## Flyway MCP Server notes

Each project's `.mcp.json` launches the Flyway MCP Server (Enterprise,
public preview) with `-mcp.toolsets=develop_migrations`. Tool names and
behaviour may change without notice per Redgate's own documentation. If
an expected tool isn't available, check the current toolsets rather than
assuming the file is wrong.
