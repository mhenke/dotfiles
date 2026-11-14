# Claude-Mem Memory Context

<claude-mem-context>
# claude-mem status

This project has no memory yet. The current session will seed it; subsequent sessions will receive auto-injected context for relevant past work.

Memory injection starts on your second session in a project.

`/learn-codebase` is available if the user wants to front-load the entire repo into memory in a single pass (~5 minutes on a typical repo, optional). Otherwise memory builds passively as work happens.

Live activity: http://localhost:37700
How it works: `/how-it-works`

This message disappears once the first observation lands.

</claude-mem-context>

# Graphify knowledge graphs

Graphify maps a repo into `graphify-out/graph.json` (AST, deterministic, offline) so codebase
questions are answered by traversal instead of grep-and-read. Install with
`uv tool install graphifyy`; the CLI is `graphify` (currently 0.9.103). Same file is mirrored at
`~/.config/opencode/AGENTS.md` and `~/.gemini/GEMINI.md`.

## Two storage modes — decide per repo before you run anything

`graphify` reads `GRAPHIFY_OUT` **once at import** (`graphify/paths.py`), and every subsystem derives
from it: `default_graph_json()`, `out_path("cache")`, the AST/stat index. There is no project-identity
check, so whatever that variable names is where an extract writes — regardless of cwd.
`~/.zshrc` no longer exports it (removed 2026-11-07, see the incident below); set it only per call.

1. **In-project (default).** Plain `graphify extract . --code-only` writes `./graphify-out/`.
   `orca` and `herdr-orca` use this. `graphify install --project` adds the skill, `CLAUDE.md`
   section, and hooks; commit those and gitignore `graphify-out/` if the repo should not carry it.
2. **Shared store (repos that must not carry graph junk).** Route every call through the
   `omos-graphify` wrapper (`~/.local/bin/omos-graphify`): it sets
   `GRAPHIFY_OUT="$HOME/.graphify/<git-main-checkout-name>"` for that one call, so linked worktrees
   and lanes resolve to the same graph; `GRAPHIFY_PROJECT=<name>` overrides the target.
   `oh-my-opencode-slim` uses this.

Never export `GRAPHIFY_OUT` in a shell profile, and never run bare `graphify extract` in a repo whose
graph lives in the other mode.

## Query before searching

When the graph exists, before the first grep or file read for a codebase question:

```sh
graphify query "<question>"        # scoped subgraph, honours query_budget/query_depth
graphify path "<A>" "<B>"          # how two things connect
graphify explain "<concept>"       # one node and its neighbours
graphify god-nodes --top 15        # architectural hubs
```

Pass `--graph <path>` when the graph is not at `./graphify-out/graph.json`, or when you are outside
the repo. `affected` ignores `GRAPHIFY_OUT` and breaks outside the repo root — do not use it from a
worktree. Exit codes: `0` answer, `3` ambiguous name (candidates listed), `4` no matching node.

## Keeping it current

`graphify update .` re-extracts changed files (AST only, no API key, no LLM). Code-only builds need
no credentials; the docs/PDF/image semantic pass does and is skipped by `--code-only`.
`graphify cluster-only .` re-clusters and regenerates the report without re-extracting.

Each repo may add `.graphifyrc` (one `key=value` per line) for `query_budget`, `query_depth`,
`viz_node_limit`, and ambiguous extensions (`language.m=objc`, `language.h=cpp`).

## Footguns

- `--out DIR` still writes `<DIR>/graphify-out/`; it is not the same knob as `GRAPHIFY_OUT`.
- A global `graphify install` (no `--project`) writes a **real directory** (not a symlink) into
  `~/.agents/skills/graphify` and `~/.claude/skills/graphify`, colliding with the `npx skills add`
  symlink farm. Remove with `graphify <platform> uninstall`.
- `graphify install --project` defaults to the **claude** platform: it rewrites
  `.claude/settings.json` (reformatting it, adding PreToolUse/SessionStart hooks, leaving a
  `settings.json.graphify-bak` sibling) and creates a root `CLAUDE.md`. Run
  `graphify claude uninstall` before re-running if the repo does not track those.
- A repo that gitignores `.claude/skills/` still gets the hooks that call the skill, so the skill
  never ships but the hooks do.
- `extract` logs nothing between "AST extraction 100%" and completion; minutes of single-threaded
  cross-file symbol resolution look like a hang. Check CPU time advancing before assuming a stall.

## Incident 2026-11-07: shared store clobbered by an in-project extract

Root cause: `GRAPHIFY_OUT` did double duty as "where the graph lives" and "which project the graph
describes", with one global value baked in at shell start.

1. `~/.zshrc:164`: `export GRAPHIFY_OUT="$HOME/.graphify/oh-my-opencode-slim"`.
2. `graphify/paths.py` reads it **once at import**; every subsystem derives from it.
3. So `graphify extract .` in any cwd wrote into the slim store, and a rewrite replaced
   `graph.json` wholesale with the other repo's nodes.

Observed damage:

| Breakage | Evidence |
| --- | --- |
| Slim graph replaced by herdr-orca nodes | store `graph.json` had `built_at_commit 132c3f5`, `source_file` roots `mods/`, `scripts/`; slim HEAD was `9862fdee` |
| Store root marker pointed at the wrong repo | `.graphify_root` = `/home/mhenke/Projects/herdr-orca`, so a later bare `graphify update` re-indexed herdr-orca |
| Cache is shared, not per-project | `cache/stat-index.json` mixed `/home/mhenke/Projects/oh-my-opencode-slim/...` with other roots under one `v0.9.103-s39-...` dir |
| No warning | code-only extraction has no project-identity check, and `.graphifyrc` resolves from the graph's own root rather than cwd, so per-project settings silently followed the store |
| Wrong answers, silently | a bare `graphify query` in `herdr-t3` answered from 7348 nodes of another project instead of its own 874 |

Also: the then-installed 0.8.27 had no `--code-only`, so the documented offline path failed outright;
0.9.103 is the first working version here.

Recovery: slim rebuilt from its own HEAD (7348 nodes / 20740 links); orca built into
`./graphify-out/`. The pre-clobber slim node count is unrecoverable (the 236 reading was taken after
the overwrite). The global export is gone; use `omos-graphify` for shared-store work.

# Harnesses on this machine

| Harness | Global instructions | Global skills |
| --- | --- | --- |
| omp | `~/.omp/agent/AGENTS.md` (sticky: `~/.omp/agent/RULES.md`) | `~/.agents/skills`, `~/.claude/skills`, `~/.config/opencode/skills`, plugins |
| opencode | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skills` |
| Antigravity | `~/.gemini/GEMINI.md`; project `.agents/rules/*.md`, `.agents/workflows/*.md` | `~/.gemini/config/skills` |

`~/.agents` is **not** a universal location. It is the Agent-Skills spec convention honoured by
`npx skills add`, omp's `agents` provider, pi, and Antigravity project rules — but each harness's
user-level *instruction* file lives in its own directory, so a file written only to
`~/.agents/AGENTS.md` reaches no agent at all. Write globally to the per-harness paths above.

Skills are installed with `npx skills add <package>` (or `skills add -g`), which symlinks package
directories into `~/.agents/skills`; harnesses that read that root pick them up, others need their
own `skills/` path. Orca ships its own bundled skills via `orca skills get <name>`.

- Skill source of truth here: `~/.agents/skills` (symlink farm), lock at `~/.agents/.skill-lock.json`.
- Antigravity global workflows: `~/.gemini/antigravity/global_workflows` (symlinks into
  `~/Projects/agents/.antigravity/workflows`).
- Dotfiles stow packages that own these files: `omp` (`~/.omp/agent/*`), `opencode`
  (`~/.config/opencode/*`), `zsh`, `zprofile`. `~/.gemini` is not stowed — edit it in place.
- `~/.omp/agent/AGENTS.md` is currently a hand-made symlink into the `omp` stow package; stow does
  not manage it, so re-stowing will not restore it if deleted.
