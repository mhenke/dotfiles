# ADR-0002: Stow `gh` While Leaving Its Config Untracked

## Status

Accepted

## Context

`gh/` is shaped like a Stow package (`gh/.config/gh/config.yml`) and
`DONT-STOW.md` has always said to stow it, but it was never added to `PACKAGES`.

Its two files pull in opposite directions:

- `gh/.config/gh/hosts.yml` holds a live `oauth_token`. Excluded twice over:
  `.gitignore:50` and `gh/.stow-local-ignore`.
- `gh/.config/gh/config.yml` holds only preferences (`version`, `git_protocol`,
  one alias) and is safe to commit — but is **not tracked**, because
  `.gitignore:23` carries a bare `config.yml` rule written for `.gitconfig`
  alongside it.

So `gh/` cannot be an ordinary Linked package. Adding it to `PACKAGES` links a
file that has no committed counterpart.

## Decision

Add `gh` to `PACKAGES`, and leave `gh/.config/gh/config.yml` untracked.

The package is now *Linked* while its principal file is *Untracked* — see
`GLOSSARY.md`. Stowing it links live local state rather than repo content.

## Consequences

- `setup-stow.sh` links `~/.config/gh/config.yml` to a file git does not manage.
  Editing it on the machine edits the "source", which is no longer reversible
  through git.
- A fresh machine gets the repo's `README.md` link but no `config.yml` unless the
  file is created locally first; Stow creates the dangling link, not the content.
- `hosts.yml` is unaffected either way: it is double-ignored and is not a Stow
  target.

## Alternatives considered

**Force-track `config.yml`** with a `!gh/.config/gh/config.yml` negation. Makes
the package conventional and the file restorable. Rejected because it commits a
credential-adjacent file class to permanent history on the strength of a
nine-line contents check performed once — the same pattern that produced the
`.gitconfig` rule in the first place.

**Leave `gh/` unlinked.** Preserves the status quo and avoids a dangling link on
fresh machines. Rejected because it contradicts `DONT-STOW.md` and leaves the
real machine state (`~/.config/gh` linked since 2025-10-25) undocumented.

**Split the rule.** Narrow `.gitignore:23` so `config.yml` is only ignored for
dotfile-root configs. Cleanest end state, but it re-opens `.gitconfig`-adjacent
review for every future `config.yml`. Deferred until a `gh` config actually
needs to be shared across machines.

## Revisit when

`gh config.yml` gains machine-specific state worth sharing, or the fresh-machine
dangling link becomes a problem in practice.