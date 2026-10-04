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