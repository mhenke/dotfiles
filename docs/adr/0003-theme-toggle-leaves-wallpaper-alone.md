# ADR-0003: The Light/Dark Toggle Leaves the Wallpaper Alone

## Status

Accepted

## Context

Upstream JaKooLit's `DarkLight.sh` treats the mode switch as a full restyle: it
also picks a wallpaper from `Dynamic-Wallpapers/{Dark,Light}` and applies it with
`swww img`. That makes a one-keystroke, frequently pressed toggle mutate the most
visible state on the machine, with no undo.

It already bit once: on 2026-11-10 a single invocation flipped the mode and the
desktop background changed along with it.

Our copy of the script has the wallpaper block removed and replaced by a comment
saying so. The leftovers are visible: lines 7-9 still declare
`wallpaper_base_path`, `dark_wallpapers`, and `light_wallpapers`, and the script
contains zero `swww img` calls.

## Decision

Mode is a color decision only. Wallpaper has exactly one owner — the wallpaper
picker, randomizer, and effect scripts — and the mode toggle never touches it.

## Consequences

- Diffing our `DarkLight.sh` against upstream shows a deleted block; the comment
  is the only marker. Re-syncing from upstream (`KooLsDotsUpdate.sh`, a fresh
  JaKooLit clone) silently reintroduces wallpaper cycling.
- The dead `Dynamic-Wallpapers` variables should be deleted rather than left as
  an invitation to restore the block.
- `Dynamic-Wallpapers/Dark` and `Light` are now only useful to the wallpaper
  scripts, not to the mode switch.

## Alternatives considered

**Keep upstream behaviour.** Rejected: mode is cheap and flipped often;
wallpaper is curated and changing it by accident is a visual surprise across
every monitor with no undo path. The two decisions have different reversibility,
so they should not share a keystroke.

## Revisit when

Mode stops being a casual toggle (e.g. scheduled light/dark), where a coordinated
wallpaper swap would be intentional rather than incidental.
