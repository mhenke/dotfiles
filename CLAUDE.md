# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **GNU Stow-managed dotfiles repository** for a Linux Mint/Ubuntu system with dual desktop environment support (Hyprland + XFCE). The system is configured for software development with an emphasis on LLM/AI tools integration.

**System Configuration:**
- Primary WM: Hyprland (Wayland compositor)
- Secondary DE: XFCE (X11 fallback)
- Shell: Zsh with oh-my-zsh
- Terminal: Kitty (Hyprland) / Tilix (XFCE)
- Status Bar: Waybar (Hyprland)
- Editor: VSCode (Flatpak), Zed
- AI Stack: Ollama, Continue.dev, GitHub Copilot, Goose

## Architecture

### GNU Stow Structure

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Each top-level directory (except `scripts/`, `packages/`, `_archived/`) is a **stow package** that mirrors the target home directory structure.

**Package Structure Pattern:**
```
packagename/              # Stow package root
└── .config/             # Mirrors ~/.config/
    └── packagename/     # Application config directory
        └── config files # Actual configuration files
```

When stowed: `stow -t ~ packagename` creates symlinks like:
```
~/.config/packagename → ~/dotfiles/packagename/.config/packagename
```

**26 Stow Packages Managed:**
- **Hyprland ecosystem:** hypr, waybar, swaync, kitty, wlogout, swappy, wallust, cava, fastfetch, ronema, nwg-displays
- **XFCE components:** xed, thunar, kvantum, qt5ct, qt6ct
- **Shell configs:** zsh, bash, fish
- **Development tools:** git, gh (partial), aws (partial)
- **Utilities:** htop, mc, gtk
- **Custom:** applications (desktop files)

### Excluded from Stow

**Security-sensitive (via .gitignore):**
- `~/.aws/credentials` - AWS credentials
- `~/.config/gh/hosts.yml` - GitHub tokens
- Shell history files
- SSH keys

**Special handling required:**
- **tilix:** Uses dconf (binary database) - manual dump/load via `tilix/tilix.dconf`
- **sddm-themes:** System-level (`/usr/share/sddm/themes/`) - uses Git LFS for 37MB of images
- **VSCode:** Uses built-in Settings Sync - don't stow the bloated cache

See `DONT-STOW.md` for complete rationale.

## Common Development Commands

### Stow Operations

```bash
# Navigate to dotfiles directory
cd ~/dotfiles

# Stow a single package (create symlinks)
stow -t ~ hypr

# Restow (update symlinks after changes)
stow -R -t ~ hypr

# Unstow (remove symlinks)
stow -D -t ~ hypr

# Stow all packages at once
stow -t ~ */

# Dry run (test before applying)
stow -n -v -t ~ hypr
```

### System Setup

```bash
# Fresh machine setup (full automated installation)
cd ~/dotfiles
./bootstrap.sh

# Run specific installation steps
./bootstrap.sh   # Interactive menu: choose steps 1-6

# Individual component installation
./scripts/install-packages.sh      # System packages
./scripts/install-dev-tools.sh     # Node, Ruby, Python, AWS CLI
./scripts/install-apps.sh          # VSCode, Discord, etc.
./scripts/setup-stow.sh            # Stow all configs
./scripts/install-themes.sh        # Nordic, Papirus, Bibata
```

### Configuration Management

```bash
# Backup current system state
./scripts/backup-system.sh         # Updates package lists

# Export configs for migration
./scripts/export-configs.sh        # SSH, GPG, AWS (encrypted)
./scripts/export-zen-profile.sh    # Zen Browser profile

# Handle stow conflicts
./scripts/clean-for-stow.sh        # Backup and remove conflicts
./scripts/first-time-stow.sh       # First-time setup helper
```

### Verification

```bash
# Verify repository readiness
./verify-setup.sh

# Check for uncommitted changes, missing files, git status
```

## Development Workflow

### Making Configuration Changes

1. **Edit configs in ~/dotfiles/** (they're symlinked to actual locations)
   ```bash
   # Edit Hyprland config
   vim ~/dotfiles/hypr/.config/hypr/hyprland.conf

   # Changes are immediately active (symlinked!)
   # Reload: Super+Shift+R (Hyprland) or restart service
   ```

2. **Test the changes** in the live environment

3. **Commit and push**
   ```bash
   cd ~/dotfiles
   git add hypr/
   git commit -m "Update Hyprland keybindings"
   git push
   ```

### Adding New Configuration Package

1. **Create package structure**
   ```bash
   cd ~/dotfiles
   mkdir -p newapp/.config
   cp -r ~/.config/newapp newapp/.config/
   ```

2. **Test stowing**
   ```bash
   stow -n -v -t ~ newapp  # Dry run
   stow -t ~ newapp        # Apply
   ```

3. **Update scripts**
   - Add to `PACKAGES` array in `scripts/setup-stow.sh`
   - Update `bootstrap.sh` if needed

4. **Document and commit**
   ```bash
   git add newapp/
   git commit -m "Add newapp configuration"
   git push
   ```

### Handling Conflicts

If stow reports "WARNING: existing target is not owned by stow":

```bash
# Automatic cleanup
./scripts/clean-for-stow.sh

# Manual backup
mv ~/.config/app ~/.config/app.backup
stow -t ~ app

# Adopt (merge existing files into dotfiles)
stow --adopt -t ~ app
git diff  # Review what was adopted
```

## Key System Details

### Ollama Configuration

Ollama runs as a system service with performance optimizations. The service override is **NOT** stowed (requires sudo).

**Setup on new machine:**
```bash
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp ~/dotfiles/ollama/performance.conf /etc/systemd/system/ollama.service.d/
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

See `ollama/README.md` for details.

### SDDM Themes

SDDM theme backgrounds (37MB) are managed with Git LFS. On clone, Git LFS automatically downloads the images.

**Prerequisites:**
```bash
sudo apt install git-lfs
git lfs install
```

**Manual installation:**
```bash
cd ~/dotfiles/sddm-themes
./install-theme.sh  # Copies to /usr/share/sddm/themes/
```

### Tilix Terminal

Tilix uses dconf (binary database) instead of file-based configs.

**Export/Import:**
```bash
# Export (when updating dotfiles)
dconf dump /com/gexperts/Tilix/ > ~/dotfiles/tilix/tilix.dconf

# Import (on new machine)
dconf load /com/gexperts/Tilix/ < ~/dotfiles/tilix/tilix.dconf
```

### Desktop Sessions

Two desktop environments are configured:
- **Hyprland:** Wayland-based tiling compositor (primary)
- **XFCE:** X11-based desktop environment (fallback)

Select at login screen or switch with:
```bash
# Display configuration aliases (in .zshrc)
sceptre  # External monitor only (3440x1440)
laptop   # Laptop screen only
dual     # Both screens
```

## Package Lists

Package manifests are stored in `packages/` for reference:
- `apt.txt` - APT packages
- `flatpak.txt` - Flatpak applications
- `npm-global.txt` - Global npm packages
- `gems.txt` - Ruby gems
- `vscode-extensions.txt` - VSCode extensions
- `ollama-models.txt` - Ollama models

These are generated by `scripts/backup-system.sh` and used by installation scripts.

## Important Files

- **`.stow-local-ignore`** - Files/patterns excluded from stowing
- **`.gitignore`** - Security-sensitive files excluded from git
- **`.gitattributes`** - Git LFS configuration for large files
- **`bootstrap.sh`** - Main setup script (interactive menu)
- **`verify-setup.sh`** - Repository readiness checker

## Development Tools Stack

**Node.js:** Version 22 (via NodeSource repository)
```bash
node --version  # Check version
npm list -g --depth=0  # List global packages
```

**Bun:** Fast JavaScript runtime (7× faster than npm)
```bash
bun install  # 52/54 packages supported
```

**Ruby & Jekyll:**
```bash
bundle install
bundle exec jekyll serve
```

**AWS CLI:** Version 2
```bash
aws configure  # Setup (credentials NOT in repo)
```

**GitHub CLI:**
```bash
gh auth login  # Initial setup
ghpr           # Alias: list PRs
```

**AI Tools:**
- Continue.dev (VSCode extension) - config in `.continue/`
- Zed editor - config in `.config/zed/`
- Goose AI agent - config in `.config/goose/`
- Ollama - local LLM runtime

## Git Workflow

**Branches:**
- `master` - Current Hyprland-based system
- `archive-i3-old-system` - Old i3wm configs (archived)

**Remote:** https://github.com/mhenke/dotfiles

**Common operations:**
```bash
cd ~/dotfiles

# Check status
git status

# Update package lists before committing
./scripts/backup-system.sh

# Commit configuration changes
git add .
git commit -m "Description of changes"
git push

# Pull updates on another machine
git pull
stow -R -t ~ */  # Restow all to update symlinks
```

## Testing Strategy

1. **Always test stow with dry run first:**
   ```bash
   stow -n -v -t ~ package-name
   ```

2. **Check for conflicts** before applying changes

3. **Backup before major changes:**
   ```bash
   cp -r ~/.config/app ~/.config/app.backup
   ```

4. **Verify symlinks after stowing:**
   ```bash
   ls -la ~/.config/app  # Should show symlink
   ```

5. **Test in live environment** before committing

## Troubleshooting

**Stow reports conflicts:**
```bash
./scripts/clean-for-stow.sh  # Automatic cleanup
```

**Symlinks not updating:**
```bash
stow -R -t ~ package  # Restow to refresh
```

**Git LFS files not downloading:**
```bash
git lfs install
git lfs pull
```

**Ollama not using GPU:**
```bash
systemctl status ollama
# Check /etc/systemd/system/ollama.service.d/performance.conf
```

**Waybar not updating:**
```bash
killall waybar
~/.config/waybar/launch.sh  # If launch script exists
```

## Security Notes

- **NEVER commit credentials:** AWS keys, GitHub tokens, SSH keys
- **Check .gitignore** before adding new packages
- **Sensitive configs** are in `.stow-local-ignore` and `.gitignore`
- **Review git status** before committing to avoid leaking secrets
- **Encrypt backups** when exporting sensitive data (see `scripts/export-configs.sh`)

## Migration to New Machine

Complete setup guide:

1. **Install prerequisites:**
   ```bash
   sudo apt update
   sudo apt install -y git git-lfs gh stow
   gh auth login
   ```

2. **Clone repository:**
   ```bash
   gh repo clone mhenke/dotfiles ~/dotfiles
   cd ~/dotfiles
   git lfs install && git lfs pull
   ```

3. **Run bootstrap:**
   ```bash
   ./bootstrap.sh
   # Choose option: 'y' for all steps or select specific steps
   ```

4. **Manual post-install:**
   - Login to: Bitwarden, Discord, Proton VPN
   - Copy SSH keys: `cp -r /backup/.ssh ~/`
   - Setup Ollama: Follow `ollama/README.md`
   - Sync VSCode: Sign in for Settings Sync

See `README.md` for detailed migration instructions.
