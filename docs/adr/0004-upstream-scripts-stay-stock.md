# ADR-0004: Upstream Hyprland Scripts Stay Stock; Local Changes Live in `sddm-themes`

## Status

Accepted

## Context

The Hyprland layer is JaKooLit's system: `~/.config/hypr/scripts/` and
`~/.config/hypr/UserScripts/` are upstream files, refreshed by
`KooLsDotsUpdate.sh`. Only `~/dotfiles/sddm-themes/` is ours.

A data-loss incident crossed that line. `WallustSwww.sh` (upstream) refreshes
`.wallpaper_effects/.wallpaper_current` with `cp -r`. That is correct for
upstream's expected layout: a pointer to a throwaway copy. Here the pointer
resolved through `~/Pictures/wallpaper.png` — itself a symlink to
`wallpapers/Red_Eclipse.png` — so `cp` wrote into a curated wallpaper and
destroyed it.

The first fix edited the upstream script (`ln -sfn` instead of `cp`, plus a guard
against the effects output). It worked, and it was wrong: the next
`KooLsDotsUpdate.sh` would silently revert it, and a reader diffing against
upstream would have to re-derive why.

## Decision

Upstream scripts are not edited. Local behaviour is shaped by the layout they
read and write:

- `.wallpaper_effects/.wallpaper_current` is a pointer to
  `~/Pictures/wallpaper.png`.
- `~/Pictures/wallpaper.png` is always a **regular file** — a copy of the last
  applied wallpaper — and never a symlink to an image in `wallpapers/`.

Our own scripts live in `~/dotfiles/sddm-themes/`.

## Consequences

- Upstream stays mergeable and updates cannot revert the protection.
- The lock screen paints a copy, so it ignores wallpaper effects and lags behind
  video wallpapers. That is upstream behaviour, not a defect to fix in place.
- Re-pointing `.wallpaper_current` at a real image — or re-symlinking
  `Pictures/wallpaper.png` — silently re-arms the clobber. Nothing enforces the
  invariant but this note.
- Each wallpaper apply rewrites `Pictures/wallpaper.png` and leaves the dotfiles
  repo clean, because the pointer is untracked.

## Alternatives considered

**Patch `WallustSwww.sh`** (link instead of copy, skip the effects output).
Correct, and it made the lock screen track the desktop exactly. Rejected: a
local patch to an update-managed file is exactly what reverts silently, and the
data loss lived in the layout, not in `cp`.

## Revisit when

Upstream changes the pointer mechanism, or the dotfiles stop tracking JaKooLit
at all and every script becomes ours.
