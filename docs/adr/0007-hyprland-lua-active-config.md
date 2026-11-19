# ADR-0007: hyprland.lua Is the Active Config; hyprland.conf Is Retired

## Status

Accepted 2026-10-06 (commit 1d68760). Reaffirmed 2026-11-17 after a debug
session spent an hour re-discovering which of the two config files the
session actually parses.

## Decision

Hyprland 0.55+ warns that the `.conf` config format will be removed; 0.57
is the deadline this machine is on. The configuration of record is now
`~/.config/hypr/hyprland.lua`. It re-implements the paths that matter from
the old chain: startup apps (re-reading `UserConfigs/Startup_Apps.conf`),
environment variables, monitor and workspace rules, keybinds, decorations,
animations. `hyprland.conf` parses nothing and is kept only as a readable
record of what used to be sourced; editing it has no effect.

## Considered options

- **Migrate early (chosen).** Migrate to lua while the `.conf` still works,
  so the live session proves the migration on every boot.
- **Wait for removal.** Cheaper now; means migrating under pressure with a
  hard deadline, on a session that cannot start until the port works.
- **Run both.** Not possible: Hyprland parses one config per instance.
  Both files being present is exactly the trap — the dead one still
  *reads* like the config of record because its `source=` lines look
  authoritative.

## Consequences

- User-facing files (`UserConfigs/*.conf`, `Startup_Apps.conf`,
  `workspaces.conf`, `monitors.conf`) keep their format; the lua parses
  them, so workflow is unchanged. Only orchestration moved.
- Both files living side by side is a standing trap: a future edit to
  `hyprland.conf` or to anything it appears to source via `source=` will
  silently do nothing. The [GLOSSARY](../../GLOSSARY.md) names the pair
  **Active config** / **Retired config** for this reason.
- Anything the lua does not re-implement is silently dropped (e.g. the
  empty `WindowRules.conf` rules). Port completeness is proven by live
  session values, not by file presence.
