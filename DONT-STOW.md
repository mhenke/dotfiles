# Configs NOT Managed by Stow

## Large Cache/Bloat (Excluded via .gitignore)

### VS Code (226MB - 225MB is cached extensions)
- Location: `~/.config/Code/`
- Why: Flatpak with Settings Sync, 99% cache
- Actual configs: `~/.config/Code/User/` (4KB)
- **Decision:** Don't stow. Use VS Code Settings Sync feature

### Cursor (33MB - mostly cache)
- Location: `~/.config/Cursor/`
- Why: 99% cache, updates frequently
- Actual configs: `~/.config/Cursor/User/{settings.json,keybindings.json}`
- **Decision:** Don't stow. Manual export/import if needed

### Windsurf (28MB - mostly cache)
- Location: `~/.config/Windsurf/`
- Why: 99% cache, updates frequently
- **Decision:** Don't stow. Not used daily

### Goose GUI (4.7MB)
- Location: `~/.config/Goose/`
- Why: Large cache for GUI version
- **Decision:** Don't stow. Not used daily

## dconf-Based (No Files to Stow)

### Tilix
- Location: dconf database `/com/gexperts/Tilix/`
- Why: Binary database, not files
- **Solution:** Manual dump/load (see `tilix/README.md`)

```bash
# Export
dconf dump /com/gexperts/Tilix/ > ~/dotfiles/tilix/tilix.dconf

# Import
dconf load /com/gexperts/Tilix/ < ~/dotfiles/tilix/tilix.dconf
```

## System-Level (Requires sudo)

### SDDM Themes
- Location: `/usr/share/sddm/themes/`
- Why: System-wide, requires root
- **Decision:** Document separately if custom

### Ollama Service
- Location: `/etc/systemd/system/ollama.service.d/`
- Why: System service override
- **Decision:** Document separately

## Application-Specific Export/Import

### Zen Browser
- Use built-in profile export/import
- Location: `~/.zen/` (not suitable for stow)

### AWS CLI
- Location: `~/.aws/`
- Why: Contains credentials
- **Decision:** Don't stow. Use AWS SSO or environment variables

### GitHub CLI
- Location: `~/.config/gh/`
- Why: `hosts.yml` holds a live `oauth_token`
- **Decision:** Stowed as a package (in `PACKAGES`) — `config.yml` only. `hosts.yml` is excluded twice over: `.gitignore:50` and `gh/.stow-local-ignore`. Note `config.yml` itself is untracked (bare `config.yml` rule at `.gitignore:23`), so stowing links live local state.

### OpenCode CLI
- Location: `~/.config/opencode/opencode.json`
- Why: Machine-specific absolute paths (`/home/<user>/...` in instructions, skills, plugin URLs); live-edited by the CLI; provider auth lives outside the file (`~/.local/share/opencode/auth.json`)
- **Decision:** Don't stow. Edit live; port intentional changes here only as a sanitized template if cross-machine sync is ever needed

---

**Summary:** 21 stowed packages + these excluded = complete coverage
