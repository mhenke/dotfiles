# mhenke/dotfiles

Config-as-code for a Hyprland workstation. One Git repo holds every app's
configuration; GNU Stow links it into `$HOME` so edits happen in exactly one
place.

## Language

### Packaging

**Package**:
A top-level directory shaped like a slice of the home tree — e.g.
`hypr/.config/hypr/` mirrors `~/.config/hypr/`. Mirrors `$HOME` from the top, so
a package may contain `.config/`, `.gitconfig`, `.omp/`, or any mix.
_Avoid_: config dir, directory, folder

**Linked package**:
A package named in `scripts/setup-stow.sh` `PACKAGES`, and therefore the only
kind `setup-stow.sh` will link into `$HOME`. Being present in the repo and being
linked are different facts; a tracked top-level directory is not automatically
a linked package.
_Avoid_: stowed package, active package, installed package

**Stray**:
A live file under `$HOME` where Stow expects a symlink — a regular file sitting
where the package's symlink belongs. Strays block `stow` for the whole package
regardless of whether their contents match the repo. Proven this session:
identical bytes still conflict; only the symlink-vs-regular-file distinction
matters.
_Avoid_: conflict, dirty file, drift, stale copy

**Conflict**:
The condition where `stow` refuses to run because a target under `$HOME` exists
and is neither a symlink nor a directory. The usual cause is a Stray. A conflict
is a per-package property, not a per-file one — one stray aborts every operation
on that package.
_Avoid_: error, failure, clash

### Configuration state

**Tracked**:
Under version control. Stowing a tracked file means a symlink points at repo
content, so the live file and the repo file are the same bytes by construction.

**Untracked**:
Present on disk but excluded by `.gitignore`, so stowing it links *live local
state* rather than repo content. `gh/.config/gh/config.yml` is the live example:
it is a Linked package member that is deliberately Untracked, because the
identical-looking ignore rule for `.gitconfig` is treated as credential-adjacent.
_Avoid_: ignored, local-only, unversioned

**Double-ignored**:
Excluded by both `.gitignore` and a package's `.stow-local-ignore`. The two
protect different things — git history and the filesystem — so a credential path
guarded by both survives either one being removed.
_Avoid_: protected, safely ignored

### Verification

**Stow-clean**:
A package for which `stow -n -v -t ~ <pkg>` reports no conflict. This is a
statement about symlink topology under `$HOME` only; it says nothing about
whether the contents are current.
_Avoid_: validated, verified, clean

**Gate**:
`./verify-setup.sh`, the repo's own readiness check. Its warnings are advisory
and its exit status is what matters.
_Avoid_: verifier, readiness check, preflight

### Display surfaces

**Display surface**:
One of the places the workstation paints a full-screen image: desktop, lock
screen, login screen, logout screen. Each surface is configured independently;
changing one never implies another, except when a look is applied.
_Avoid_: screen, wallpaper screen, monitor

**Desktop**:
The Hyprland session after login. The only surface on which wallpaper and
palette are live.
_Avoid_: screen, workspace

**Lock screen**:
The hyprlock overlay in front of a running session, dismissed by re-entering
credentials. It paints a copy of the last applied wallpaper, so it ignores
wallpaper effects and lags behind video wallpapers.
_Avoid_: login screen, screensaver

**Login screen**:
The SDDM greeter that appears before any session exists; it authenticates the
user and selects the session type.
_Avoid_: lock screen, boot screen, desktop

### Appearance

**Wallpaper**:
The image painted on one display surface. Unqualified it is ambiguous, so name
the surface: desktop wallpaper and login screen wallpaper are switched by
different tools and drift apart.
_Avoid_: background, bg, theme

**SDDM theme variant**:
One complete login-screen appearance — background image, main and accent colors,
header text, form position — selected by slug such as `lofi-cafe` or
`mecha-nostalgia`. The slug is the name; the header text is content, so
"VIBE CODE HAVEN" is `lofi-cafe`, not a variant called *vibe coding haven*.
_Avoid_: theme, login theme, preset, skin

**Header text**:
The greeting line a login-screen variant draws. It is display copy, never an
identifier.
_Avoid_: title, name

**Look**:
A login-screen variant plus the same image on the desktop, applied by one
command. The surfaces stay independent underneath; a look is a deliberate
shortcut across two of them, and it only exists when the wallpaper folder holds
a file matching the variant's background name.
_Avoid_: theme, preset, mode

**Palette**:
The color set derived from the current desktop wallpaper and pushed into
terminal, bar, launcher, and notification styling. Regenerated when the wallpaper
is applied; independent of any SDDM theme variant.
_Avoid_: theme, colorscheme, wallpaper colors

**Mode**:
Light or Dark — the workstation-wide brightness posture that swaps palette
variant, GTK and icon appearance, and bar/launcher styling. It changes neither
the desktop wallpaper nor the login screen.
_Avoid_: theme, color mode, appearance profile

**Theme**:
Unusable unqualified here: it names at least five independent things — SDDM
theme variant, palette, mode, GTK/Qt appearance, terminal/launcher styling. Say
which.
_Avoid_: theme (bare)