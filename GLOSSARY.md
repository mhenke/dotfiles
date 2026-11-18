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
header text, form position — selected by slug such as `lofi-chill-room2` or
`staircase`. The slug is the name; the header text is content, so
"VIBE CODE HAVEN" is `lofi-chill-room2`, not a variant called *vibe coding haven*.
_Avoid_: theme, login theme, preset, skin

**Header text**:
The greeting or slogan shared by a look's login and lock screens. It is display
copy, never an identifier.
_Avoid_: title, name

**Look**:
A coordinated appearance spanning the login screen, lock screen, and desktop,
with a matching image and complementary colors. Applying a look selects these
appearances together without making the display surfaces interchangeable.
_Avoid_: theme, preset, mode

### Startup & placement

**Autostart entry**:
One line in `Startup_Apps.conf` that launches something at session start.
It runs once per boot; a window rule in the entry applies to the **first**
window the app maps, and later launches of the same app join the running
instance instead, landing on whatever workspace is focused.
_Avoid_: startup command, startup app

**Workspace placement**:
The bracket prefix on an autostart entry — `[workspace N silent]` — that
decides which workspace a first window opens on, without focusing it. It
binds at window-map time; it does not follow later launches of the same app.
_Avoid_: workspace rule (that means the `workspace =` lines), assignment

**Monitor-bound workspace**:
A workspace whose `workspaces.conf` entry pins it to a named monitor. When
that monitor is absent the workspace still exists — it falls back to a
connected display, which is how autostart keeps working across dock states.
_Avoid_: workspace rule, monitor assignment

**Monitor profile**:
One saved monitor-and-workspace arrangement — `laptop-only`, `docked-dual`,
`default` — that can be applied wholesale. Applying a profile rewrites the
live monitor and workspace files and reloads Hyprland.
_Avoid_: layout, mode, display setup

**Active config**:
The one file Hyprland actually parses at session start — currently
`hyprland.lua`, chosen because the `.conf` format is being removed. There is
exactly one; the other candidate config is dead. Editing the dead one has no
effect and is a real trap, since both still live side by side.
_Avoid_: main config, primary config, config file (unqualified)

**Retired config**:
`hyprland.conf`: parses nothing anymore. It still reads like the config of
record — its `source=` lines list every user file — but the active config
duplicates the paths that matter (startup apps, environment, monitors,
workspaces, keybinds). Kept for reference during the lua migration; do not
edit it expecting change.
_Avoid_: old config, backup config

**Palette**:
The desktop and application color set associated with a wallpaper and mode.
Each wallpaper has its own palette, which can be reused; login- and lock-screen
colors are separate choices.
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
team; `balanced` is the older default. The word covers two independent selections:
a preset chooses the **roles**, and a **council preset** chooses the **seats**.
They are chosen separately and can name different presets at once, so the seats do
not follow the roles.
_Avoid_: profile, config, team

**Role**:
One agent's slot in a **preset** — orchestrator, oracle, designer. A role is
configuration; the **agent** of the same name is the thing that runs. The same
name can be both, and a role can stay in use while its agent is off the
**roster**, reached only because it is **invoked**.
_Avoid_: agent (when the slot is meant), persona

**Seat**:
A councillor's slot in a **council preset** — alpha, beta, gamma. A seat is the
council's counterpart of a **role**, and the two are kept in step by convention
rather than by configuration: alpha mirrors oracle, beta mirrors skeptic, gamma
mirrors observer. Nothing enforces it, so a change to a role's **chain** has to
be mirrored in its seat or the two silently disagree.
_Avoid_: councillor (when the slot is meant), member

**Council preset**:
A named set of **seats**, selected independently of the **preset** that supplies
the **roles**. `subscription` exists as both, and picking one without the other
leaves the council running another preset's seats while the roles run the new
one.
_Avoid_: preset (when the seats are meant), council config

**Chain**:
One agent's ordered model list. It advances when the current entry fails in a way
another entry could survive — the model is spent, unavailable, or refusing work it
could do elsewhere. A failure every entry would reproduce, such as a malformed
request, stops the chain instead. What the list *is* depends on the agent: for a
**subagent** it is a head plus fallbacks, because the first entry becomes that
agent's launch model; for the **orchestrator** it is a fallback list only, because
its live session model leads instead.
_Avoid_: fallback list, cascade, stack (unqualified)

**Model setting**:
A value an agent sends with every request — `temperature`, `variant` — not a
property of the chain. The same value goes to whichever model runs, and models
treat it one of three ways: they **honour** it, they ignore it silently, or they
**reject** it. Configuration cannot express the difference, so a chain is only as
permissive as its strictest model, and a setting must satisfy every entry it may
reach.
_Avoid_: parameter, option, config

**Rejected setting**:
A model refusing a **model setting** the agent always sends, answered as a
validation error. This is a hard error rather than a **chain** failure: no provider
is excluded and no fallback runs, because the next entry would refuse the same
request. The remedy is to send the setting only where it is honoured. Distinct from
an *inert* setting, which the model accepts and ignores, and from a **spent
allowance**, which advances the chain.
_Avoid_: config error, invalid request

**Head**:
The first model in a **chain**, and it binds only when the agent's model is set
from the chain — which is true of subagents and never of the orchestrator, whose
**session model** leads and whose chain is consulted on failure. An orchestrator
entry is therefore never a head, whatever position it occupies. Calling the first
one a head is what makes its array look like a running model.
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
