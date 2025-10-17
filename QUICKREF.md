# Quick Reference Guide

## Most Used Commands (Based on History Analysis)

| Command | Count | Purpose |
|---------|-------|---------|
| git | 342 | Version control |
| cd | 203 | Change directory |
| npm | 161 | Node package manager |
| ls | 116 | List files |
| npx | 104 | Execute npm packages |
| gh | 98 | GitHub CLI |
| bundle | 85 | Ruby dependency manager |
| grep | 56 | Search text |
| rm | 48 | Remove files |
| sudo | 46 | Run as superuser |
| find | 39 | Find files |
| cat | 33 | Display file contents |
| python3 | 25 | Python interpreter |
| cp | 23 | Copy files |
| aws | 17 | AWS CLI |

## Custom Aliases

### Config Editing
```bash
zshconfig          # Edit ~/.zshrc
i3config           # Edit i3 config
picomconfig        # Edit picom config
```

### GitHub CLI
```bash
ghpr               # List pull requests: gh pr list
ghco               # GitHub Copilot
ghce               # GitHub Copilot explain
ghcs               # GitHub Copilot suggest
ghci               # GitHub Copilot interactive
ghcopilot          # GitHub Copilot
```

### Display Configuration
```bash
sceptre            # External monitor only (3440x1440@50Hz)
laptop             # Laptop screen only (1366x768)
dual               # Both screens (external above laptop)
```

### System Maintenance
```bash
update             # Full system update:
                   # sudo dpkg --configure -a &&
                   # sudo apt update -y &&
                   # sudo apt upgrade -y &&
                   # sudo apt autoremove -y
```

### Better Defaults (if installed)
```bash
ls                 # exa with icons (if exa installed)
la                 # exa -la with icons
tree               # exa --tree with icons
cat                # bat (syntax highlighting, if bat installed)
top                # htop (if htop installed)
```

## i3 Keybindings

### Essential
| Keybinding | Action |
|------------|--------|
| `Mod+Enter` | Open terminal (tilix) |
| `Mod+d` | Application launcher (rofi) |
| `Mod+Shift+q` | Close focused window |
| `Mod+Shift+e` | Exit i3 (power menu) |
| `Mod+Shift+r` | Reload i3 config |
| `Mod+Shift+c` | Restart i3 |

### Navigation
| Keybinding | Action |
|------------|--------|
| `Mod+j/k/l/;` | Focus left/down/up/right |
| `Mod+1-9` | Switch to workspace 1-9 |
| `Mod+Shift+1-9` | Move window to workspace 1-9 |
| `Mod+Space` | Toggle focus between tiling/floating |

### Layout
| Keybinding | Action |
|------------|--------|
| `Mod+h` | Horizontal split |
| `Mod+v` | Vertical split |
| `Mod+f` | Toggle fullscreen |
| `Mod+Shift+Space` | Toggle floating mode |
| `Mod+s` | Stacking layout |
| `Mod+w` | Tabbed layout |
| `Mod+e` | Toggle split layout |

### Window Management
| Keybinding | Action |
|------------|--------|
| `Mod+Shift+j/k/l/;` | Move window left/down/up/right |
| `Mod+r` | Enter resize mode |
| (in resize) `j/k/l/;` | Resize window |
| (in resize) `Esc/Enter` | Exit resize mode |

### Scratchpad
| Keybinding | Action |
|------------|--------|
| `Mod+Shift+minus` | Move window to scratchpad |
| `Mod+minus` | Show/hide scratchpad |

## Polybar

### Restart Polybar
```bash
~/.config/polybar/launch.sh
# or
killall polybar && ~/.config/polybar/launch.sh
```

### Modules Available
- Workspaces (i3)
- Window title
- CPU usage
- Memory usage
- Network status
- Volume control
- Microphone status
- Battery (laptop)
- Date and time

### Scripts Location
```bash
~/.config/polybar/scripts/
  ├── volume.sh       # Volume control
  ├── network.sh      # Network status
  └── microphone.sh   # Mic status
```

## Rofi

### Launch Modes
```bash
rofi -show drun      # Application launcher
rofi -show run       # Command runner
rofi -show window    # Window switcher
```

### Custom Scripts
```bash
~/.config/rofi/launcher.sh     # App launcher
~/.config/rofi/powermenu.sh    # Power menu
~/.config/rofi/emoji.sh        # Emoji picker
```

## Tilix

### Shortcuts
| Keybinding | Action |
|------------|--------|
| `Ctrl+Shift+t` | New tab |
| `Ctrl+Shift+w` | Close tab |
| `Ctrl+Shift+d` | Split horizontally |
| `Ctrl+Shift+r` | Split vertically |
| `Ctrl+Shift+e` | Close split |
| `Alt+Arrow` | Navigate splits |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |

### Load Config
```bash
dconf load /com/gexperts/Tilix/ < ~/dotfiles/tilix/tilix.dconf
```

## ZSH

### oh-my-zsh Commands
```bash
omz update           # Update oh-my-zsh
omz reload           # Reload zsh config
omz plugin list      # List enabled plugins
```

### Active Plugins
1. **git** - Git aliases and info
2. **aliases** - Enhanced git shortcuts (ga, gco, grhh, etc.)
3. **z** - Smart directory jumping
4. **zsh-autosuggestions** - Command suggestions from history
5. **zsh-syntax-highlighting** - Syntax coloring
6. **npm** - npm shortcuts and completion
7. **docker-compose** - Docker compose shortcuts
8. **aws** - AWS CLI completion
9. **fzf** - Fuzzy finder integration
10. **you-should-use** - Suggests aliases for commands

### Z (Directory Jumping)
```bash
z Projects         # Jump to ~/Projects (fuzzy match)
z proj             # Also works
z -l              # List all directories in db
```

### FZF Shortcuts
| Keybinding | Action |
|------------|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy search files |
| `Alt+C` | Fuzzy search directories (cd) |

## Git Aliases (from oh-my-zsh)

### Common
```bash
ga                 # git add
gaa                # git add --all
gc                 # git commit -v
gc!                # git commit -v --amend
gca                # git commit -v -a
gca!               # git commit -v -a --amend
gco                # git checkout
gcb                # git checkout -b
gd                 # git diff
gst                # git status
gp                 # git push
gpl                # git pull
gl                 # git pull
glog               # git log --oneline --decorate --graph
grh                # git reset
grhh               # git reset --hard
gru                # git reset --
```

## Development Tools

### Node.js 22 (via NodeSource)
```bash
# Node.js 22 is automatically installed via NodeSource repository
# during bootstrap (install-dev-tools.sh)
node --version           # Check version (should show v22.x.x)
npm --version            # Check npm version
```

### Global npm Packages
```bash
npm list -g --depth=0    # List global packages
npm update -g            # Update all global packages
npm install -g <pkg>     # Install global package
```

### Ruby & Jekyll
```bash
bundle install           # Install dependencies
bundle exec jekyll serve # Run Jekyll site
gem list                 # List installed gems
```

### Python
```bash
python3 --version        # Check version
pip3 install <package>   # Install package
pip3 list                # List packages
```

### AWS CLI
```bash
aws configure            # Configure credentials
aws s3 ls                # List S3 buckets
aws --version            # Check version
```

### GitHub CLI
```bash
gh auth login            # Authenticate
gh pr list               # List pull requests
gh pr create             # Create PR
gh pr checkout <num>     # Checkout PR
gh repo view             # View repo in browser
```

## Dotfiles Management

### Using Stow
```bash
cd ~/dotfiles

# Install package (create symlinks)
stow -t ~ i3

# Remove package (remove symlinks)
stow -D -t ~ i3

# Restow package (update symlinks)
stow -R -t ~ i3

# Install all packages
stow -t ~ */

# Dry run (see what would happen)
stow -n -v -t ~ i3
```

### Update Workflow
```bash
# Edit config
vim ~/.config/i3/config

# Config is actually in ~/dotfiles/i3/.config/i3/config (symlinked)

# Commit changes
cd ~/dotfiles
git add i3/.config/i3/config
git commit -m "Update i3 config"
git push

# On other machine
cd ~/dotfiles
git pull
# Changes automatically applied via symlinks
```

## System Information

### Hardware
```bash
neofetch             # System overview with logo
htop                 # Process viewer
lscpu                # CPU info
free -h              # Memory usage
df -h                # Disk space
lsblk                # Block devices
```

### Display
```bash
xrandr               # List displays and resolutions
arandr               # GUI display configuration
```

### Audio
```bash
pavucontrol          # GUI volume control
playerctl play       # Play media
playerctl pause      # Pause media
playerctl next       # Next track
```

## Backup & Restore

### Generate Package Lists
```bash
cd ~/dotfiles
./scripts/backup-system.sh
```

### Bootstrap New System
```bash
cd ~/dotfiles
./bootstrap.sh
```

### Individual Components
```bash
cd ~/dotfiles
./scripts/install-packages.sh      # System packages
./scripts/install-dev-tools.sh     # Dev tools
./scripts/install-apps.sh          # Applications
./scripts/setup-stow.sh            # Dotfiles
```

## Troubleshooting

### Restart Services
```bash
# i3
Mod+Shift+r                      # Reload config
Mod+Shift+c                      # Restart i3

# Polybar
killall polybar
~/.config/polybar/launch.sh

# Picom
killall picom
picom &

# Dunst
killall dunst
dunst &

# All at once
i3-msg restart
```

### Check Logs
```bash
# i3 log
cat ~/.local/share/xorg/Xorg.0.log

# Polybar log
cat ~/.config/polybar/polybar.log

# Picom log
cat ~/.picom.log

# System log
journalctl -xe
```

### Reset Config
```bash
# Backup current
cp ~/.config/i3/config ~/.config/i3/config.backup

# Restore from dotfiles
cd ~/dotfiles
stow -R -t ~ i3
```

## Performance

### ZSH Startup Time
```bash
# Test startup time
time zsh -i -c exit

# Profile startup
zsh -xv 2>&1 | ts -i '%.s' > /tmp/zsh-profile.log
```

### Resource Usage
```bash
# Top processes
htop

# i3 tree (window hierarchy)
i3-msg -t get_tree

# Polybar debug
polybar --log=info example
```
