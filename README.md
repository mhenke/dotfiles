# Linux Mint XFCE + i3 Dotfiles

Automated setup for migrating Linux Mint XFCE with i3wm to a new machine.

## Quick Start (New Machine)

```bash
# 0. Prerequisites (required first!)
sudo apt update
sudo apt install -y git gh

# Authenticate with GitHub
gh auth login

# 1. Clone this repo
git clone https://github.com/mhenke/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run bootstrap script (installs everything)
./bootstrap.sh

# 3. Reboot and select i3 session at login
```

## What's Included

### Window Manager & UI
- **i3** - Tiling window manager with custom keybindings
- **polybar** - Status bar with custom modules (volume, network, microphone)
- **picom** - Compositor for transparency and effects
- **rofi** - Application launcher and power menu
- **dunst** - Notification daemon

### Terminal & Shell
- **tilix** - Terminal emulator
- **zsh** with oh-my-zsh - Shell with custom theme (af-magic)
- **zsh plugins** - autosuggestions, syntax highlighting, z, fzf, etc.

### Development Tools
- **VSCode** - Code editor with automated extension installation
- **git** + **gh** - Version control and GitHub CLI
- **Node.js** + **npm** - JavaScript runtime and package manager
- **Bun** - Fast JavaScript runtime (7× faster than npm)
- **Claude Code** + **GitHub Copilot** - AI coding assistants
- **Python3** + pip
- **Ruby** + Jekyll
- **AWS CLI v2**

### Applications
- **Bitwarden** - Password manager
- **Discord** - Communication
- **Kodi** - Media center
- **Proton VPN** - VPN client (CLI, no GNOME bloat)
- **Zen Browser** - Firefox-based browser (Flatpak)
- **OSCAR** - CPAP analysis software
- **Obsidian** - Note-taking and knowledge base
- **Notion** (via Cohesion) - Productivity workspace
- **xed** - Text editor

### Themes & Appearance
- **Nordic** - Dark GTK theme (blue/gray palette)
- **Papirus-Dark** - Icon theme
- **Bibata-Modern-Classic** - Cursor theme
- **Nord** - Terminal color scheme
- **Auto dark mode** - System-wide dark theme application (XFCE/Cinnamon/MATE support)

## Recent Improvements

### New Features (2025-10)
- ✨ **Automated VSCode extension management** - 37 extensions auto-installed
- ✨ **Bun integration** - 7× faster package installation for 52/54 packages
- ✨ **First-time stow helper** - Automatic conflict detection and backup
- ✨ **Dark mode automation** - Desktop environment detection (XFCE/Cinnamon/MATE)
- ✨ **Backup/export scripts** - Configs, Zen Browser profile, personal data
- ✨ **Import scripts** - Automated restoration on new laptop
- ✨ **Bootstrap order fix** - Stow runs before themes to avoid conflicts

### Migration Tools
- `export-configs.sh` - Backup SSH, GPG, AWS credentials (GPG encrypted)
- `export-zen-profile.sh` - Export Zen Browser (detects Flatpak/AppImage/deb)
- `export-personal-data.sh` - Backup Documents, Desktop, Kodi, themes
- `export-vscode-extensions.sh` - Export VSCode extension list
- `first-time-stow.sh` - Clean first-time setup for new machines
- `clean-for-stow.sh` - Fix "existing target not owned by stow" errors

## Manual Setup Steps

### 1. Backup Current System (Old Laptop)

```bash
cd ~/dotfiles
./scripts/backup-system.sh
```

This creates:
- `packages-apt.txt` - All installed apt packages
- `packages-npm-global.txt` - Global npm packages
- `packages-gem.txt` - Ruby gems
- `vscode-extensions.txt` - VSCode extensions
- Backups of any configs not yet in dotfiles

### 2. Fresh Install on New Laptop

1. Install **Linux Mint XFCE** (latest version)
2. Complete initial setup (username: mhenke recommended)
3. Connect to internet
4. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

### 3. Automated Installation

```bash
./bootstrap.sh
```

The script will:
- Install system packages (i3, polybar, rofi, etc.)
- Install development tools (Node.js, Ruby, Python packages)
- Set up zsh with oh-my-zsh
- Install applications (VSCode, Bitwarden, Discord, etc.)
- Use GNU Stow to symlink all dotfiles
- Restore VSCode extensions
- Configure git

### 4. Manual Post-Install

After bootstrap completes:

1. **Login to services:**
   - Bitwarden
   - GitHub: `gh auth login`
   - Discord
   - Proton VPN
   - VSCode settings sync

2. **Configure monitors** (if using external displays):
   - Use aliases: `sceptre`, `laptop`, or `dual`

3. **Select i3 at login:**
   - Logout → Select i3 session → Login

4. **Restore SSH keys:**
   ```bash
   # Copy from old laptop or backup
   cp -r /path/to/backup/.ssh ~/
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/*
   ```

## Repository Structure

```
dotfiles/
├── bootstrap.sh              # Main setup script
├── scripts/
│   ├── backup-system.sh      # Backup current system state
│   ├── install-packages.sh   # Install system packages
│   ├── install-dev-tools.sh  # Install development tools
│   ├── install-apps.sh       # Install applications
│   └── setup-stow.sh         # Symlink configs with stow
├── packages/
│   ├── apt.txt               # APT packages
│   ├── npm-global.txt        # Global npm packages
│   ├── gems.txt              # Ruby gems
│   └── vscode-extensions.txt # VSCode extensions
├── i3/
│   └── .config/i3/config     # i3 configuration
├── polybar/
│   └── .config/polybar/      # Polybar configs and scripts
├── picom/
│   └── .config/picom/        # Picom configuration
├── rofi/
│   └── .config/rofi/         # Rofi themes and configs
├── dunst/
│   └── .config/dunst/        # Dunst notification config
├── tilix/
│   └── tilix.dconf           # Tilix terminal config
├── zsh/
│   └── .zshrc                # Zsh configuration
├── git/
│   └── .gitconfig            # Git configuration
├── gtk/
│   └── .config/gtk-3.0/      # GTK theme settings
└── xed/
    └── .config/xed/          # Xed text editor preferences
```

## Using GNU Stow

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for managing symlinks.

```bash
# Install a package (creates symlinks)
stow -t ~ i3

# Remove a package (removes symlinks)
stow -D -t ~ i3

# Restow a package (update symlinks)
stow -R -t ~ i3

# Install all packages
stow -t ~ */
```

## Customization

### Display Configuration

Three monitor setup aliases in `.zshrc`:
- `sceptre` - External monitor only (3440x1440)
- `laptop` - Laptop screen only (1366x768)
- `dual` - Both screens (external above laptop)

### i3 Keybindings

See `.config/i3/config` for full list. Key highlights:
- `Mod+Enter` - Open terminal (tilix)
- `Mod+d` - Application launcher (rofi)
- `Mod+Shift+e` - Power menu
- `Mod+[1-9]` - Switch workspaces

### Custom Aliases

See `.zshrc` for all aliases including:
- `ghpr` - List GitHub pull requests
- `update` - Full system update
- Development shortcuts from oh-my-zsh plugins

## Most Used Commands

Based on shell history analysis:
1. `git` (341 uses)
2. `cd` (202 uses)
3. `npm` (161 uses)
4. `ls` (116 uses)
5. `npx` (104 uses)
6. `gh` (98 uses)
7. `bundle` (85 uses)
8. `grep` (56 uses)

## Troubleshooting

### Stow conflicts
If stow reports conflicts, backup the conflicting files:
```bash
mv ~/.config/i3/config ~/.config/i3/config.backup
stow -t ~ i3
```

### Polybar not starting
```bash
~/.config/polybar/launch.sh
```

### Tilix terminal not found
```bash
sudo apt install tilix
```

### ZSH plugins not working
```bash
# Reinstall oh-my-zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Updates

To update dotfiles from the old machine:

```bash
cd ~/dotfiles
# Make changes to configs
git add .
git commit -m "Update configs"
git push
```

On the new machine:
```bash
cd ~/dotfiles
git pull
stow -R -t ~ */  # Restow all packages
```

## License

Personal dotfiles - use at your own risk!
