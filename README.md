# Flyway Deployment Pattern — Reference Implementation

A working Flyway setup that mirrors your Core environment: two databases
(`InCode` and `InData`), two SQL Server nodes kept in sync by merge
replication, and a mix of replicated and non-replicated tables that need
different deploy paths.

The schema in this repo is synthetic. The **pattern** — how the projects
are laid out, how migrations are routed, how a release is packaged —
is what you'd copy onto your real databases.

## The shape

Two Flyway projects, one orchestrator on top:

| Project  | Folder                | Contains                    | Deploys to |
|----------|-----------------------|-----------------------------|------------|
| `incode` | `projects/CoreInCode` | Stored procs / functions    | Both nodes, every release |
| `indata` | `projects/InData`     | Tables (replicated + non)   | Primary only for replicated; both nodes for non-replicated |

Inside `projects/InData/migrations/`:

- **`ReplTables/`** — merge-replicated tables. Each generated migration
  ships with a `.sql.conf` sidecar containing an inclusion-list
  `shouldExecute` expression, so it only runs on the primary node envs
  you've whitelisted. Fail-safe: forget a client and the migration
  skips loudly rather than running unsafely.
- **`NonReplTables/`** — non-replicated tables. Routine cadence,
  deploys directly to both nodes.

Routing is driven by [manifest.yaml](manifest.yaml): every object has an
explicit `replicated: true/false` flag. The generate scripts use two
Redgate Compare filter files (`Filter.ReplTables.scpf`,
`Filter.NonReplTables.scpf`) that mirror the manifest, so the right
object lands in the right bucket automatically.

## How to try it

1. Run the three scripts in [Setup Scripts/](Setup%20Scripts/) against a
   local SQL Server — creates the empty target DBs and populates the
   two dev DBs.
2. Drop a `flyway.user.toml` in each project folder pointing
   `development` and `shadow` at your local instance.
3. Double-click `Release.bat` (or run `Release.ps1`).

`Release.ps1` is the single entry point — interactive menu or CLI. The
five actions cover the full cycle:

- **Update development** — captures dev-DB changes into `schema-model/`.
- **Create release** — packages pending changes as versioned V/U files
  across whichever buckets you choose (InCode, InDataReplication,
  InDataNonReplication, any mix). Slot numbers (`.1`, `.2`, `.3`) keep
  buckets from colliding.
- **Check release** — dry-run report per (bucket, node) at a target
  version.
- **Deploy release** — `flyway migrate -target=<version>` per bucket
  per node, with a confirmation prompt.
- **Run individual script** — one-off launcher for any per-project PS1.

## Adapting this to your environment

The pattern doesn't care about the specific schema. To point it at your
real databases:

1. **Replace the manifest.** Swap `manifest.yaml` for your object list,
   with the `replicated: true/false` flag set correctly per table. This
   is the routing source of truth — everything else follows from it.
2. **Update the filter files.** `Filter.ReplTables.scpf` and
   `Filter.NonReplTables.scpf` in `projects/InData/` list the same
   objects at the Redgate Compare layer. Keep them in sync with the
   manifest.
3. **Baseline from prod.** Use a schema-only `.bak` of your live InCode
   and InData to baseline each project — see
   [Redgate's baseline-from-backup guide](https://documentation.red-gate.com/fd/use-a-sql-server-backup-to-baseline-a-database-273973380.html).
   That makes version 1 exactly match production.
4. **Wire up your environments.** Each Flyway project's `flyway.toml`
   declares environments by client prefix (`<prefix>Aprod`,
   `<prefix>Bprod`, `<prefix>Prod`). Add one set per cluster you deploy
   to. The Repl `.sql.conf` files are inclusion lists — append your new
   `<prefix>Aprod` to each existing sidecar to allow the migration to
   run there. Missing one is loud, not silent.
5. **Point dev + shadow at your servers.** `flyway.user.toml` per
   project. Shadow DBs are auto-provisioned by Flyway on demand.

## Environments reference

| Env             | Project    | Purpose |
|-----------------|------------|---------|
| `development`   | both       | Live dev DB |
| `shadow`        | both       | Throwaway build DB for diff/generate |
| `Check`         | InData     | Throwaway build DB for `check -changes` |
| `<prefix>Prod`  | InCode     | Client's InCode deploy target |
| `<prefix>Aprod` | InData     | Client's primary InData node |
| `<prefix>Bprod` | InData     | Client's secondary InData node (Repl migrations gated off via `.sql.conf`) |

Both `flyway.toml` files carry
`ignoreMigrationPatterns = [ "*:missing", "*:future" ]` so commands
tolerate deleted-from-disk history entries and pending future migrations.

---

For deeper routing rules (what goes in `incode` vs `indata`, how to add
a new client, `shouldExecute` grammar quirks), see [CLAUDE.md](CLAUDE.md).
