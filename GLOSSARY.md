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
shortcut across two of them, using the variant's own background image when the
wallpaper folder holds no copy.
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
### Agent routing

**Preset**:
A named set of per-agent **chains**. `subscription` is the synthesized-subscription
team; `balanced` is the older default.
_Avoid_: profile, config, team

**Chain**:
One agent's ordered model list. It advances only on failure. What the list *is*
depends on the agent: for a **subagent** it is a head plus fallbacks, because the
first entry becomes that agent's launch model; for the **orchestrator** it is a
fallback list only, because its live session model leads instead.
_Avoid_: fallback list, cascade, stack (unqualified)

**Head**:
The first model in a **chain**, and it binds only when the agent's model is set
from the chain — which is true of subagents and never of the orchestrator, whose
session model leads and whose chain is consulted on failure. A "head" chosen for
the orchestrator in a preset therefore changes nothing until something fails.
_Avoid_: primary, default model

**Session model**:
The model a live conversation is actually running, chosen by `/model`, by the
global default, or inherited by a delegated agent. It outranks any **head**, and
is the only thing that decides what the orchestrator spends.
_Avoid_: current model, runtime model

**Roster**:
The orchestrator's list of agents it may delegate to. An agent registers and runs
without being on it; the orchestrator simply never chooses it. Being reachable is
a separate fact from existing.
_Avoid_: registry, agent list, catalog

**Invoked**:
An agent reached on purpose with `@name` rather than delegated to by the
orchestrator. Keeping an agent invoked-only is a choice about who spends it, not
a limitation: the escalation tier and the skeptic are paid for when the user
decides a decision is worth the price.
_Avoid_: manual, direct, ad-hoc

**Escalation**:
Reaching for the most expensive model on purpose, for a decision the cheaper
agents could not settle. An escalation is invoked, never left running: the same
model idling as a session default spends the pool on ordinary turns.
_Avoid_: upgrade, fallback, promotion

**Anchor**:
The single metered entry at a chain's end, paid per token — Zen `opencode/<paid-id>`
or `deepseek/<id>`. It keeps the chain alive after every pooled tier is spent.
_Avoid_: last resort, paygo fallback, backup

**Pool**:
One provider's shared allowance: Copilot's monthly AI credits, OpenAI's 5-hour
and weekly windows, CommandCode's credit balance. Every model on it spends the
same pool at once — a per-model allowance is a **ceiling on that model's draw**,
never a separate budget, so three $20 allowances do not make $60.
_Avoid_: quota, budget, plan (unqualified); per-model budget

**Allowance**:
A per-model ceiling on how much of a **pool** that one model may consume. Sized
per model (CommandCode ranges $10–$100), it constrains a model rather than
funding it: the pool remains the only budget, which is why a cheaper model
stretches a month and a larger allowance on an expensive one does not.
_Avoid_: per-model budget, sub-quota, separate pool

**Subscription provider**:
A provider whose models draw on a finite **pool** that resets on a window —
Copilot monthly, OpenAI's 5-hour and weekly, CommandCode's credit balance.
Spending it excludes the provider for the rest of a **descent**, which is why it
earns one entry per **chain**: a second entry from the same pool is unreachable.
_Avoid_: paid provider, paid pool, quota provider

**Metered provider**:
A provider billed per token with no pool to exhaust — Zen paygo and DeepSeek.
It never excludes itself, so it is what an **Anchor** is made of. Cost per call
is the only constraint; there is no allowance to spend.
_Avoid_: paygo, paid provider, per-token provider

**Free tier**:
Models billed to nobody. Their exhaustion is classified as a billing failure,
not a spent allowance: it fails over and excludes nothing, so free entries
repeat freely in one chain. Free tier is a **cost shield**, and where it sits
says which cost it shields: before the metered anchor it protects real money;
in a head position it protects the subscription pools as well, at the price of
a weaker answer.
_Avoid_: free provider, free plan
