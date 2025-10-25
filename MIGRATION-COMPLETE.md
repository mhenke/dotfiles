# Dotfiles Migration Complete

**Date:** October 25, 2024
**From:** i3 + X11 setup
**To:** Hyprland + Wayland setup

## What Was Done

### 1. Archived Old System
- Created `archive-i3-old-system` branch with old configs
- Removed: i3, polybar, dunst, picom
- Branch available at: https://github.com/mhenke/dotfiles/tree/archive-i3-old-system

### 2. Added New Hyprland Packages (15 new)
**Core WM:**
- hypr (572K - wallpapers excluded via .stow-local-ignore)
- waybar (560K)
- swaync (904K)
- wlogout (388K)

**Terminal & Shell:**
- kitty (704K)
- fish (shell configs)

**Utilities:**
- swappy (screenshot annotation)
- wallust (color scheme generator)
- cava (audio visualizer)
- fastfetch (system info)
- ronema (file manager addon)
- nwg-displays (display manager)

**Theming:**
- thunar (file manager)
- kvantum (Qt theme engine)
- qt5ct (Qt5 config)
- qt6ct (Qt6 config)

**Special Cases:**
- tilix (dconf-based, not stowed - see tilix/README.md)

### 3. Updated Existing Packages (7)
- xed, git, gtk, htop, mc, zsh - adopted with stow

## Stow Verification

All configs verified with GNU Stow and properly symlinked:

```bash
~/.config/hypr/hyprland.conf -> ~/dotfiles/hypr/.config/hypr/hyprland.conf
~/.config/waybar -> ~/dotfiles/waybar/.config/waybar (directory symlink)
~/.config/kitty/kitty.conf -> ~/dotfiles/kitty/.config/kitty/kitty.conf
~/.zshrc -> ~/dotfiles/zsh/.zshrc
... (22 packages total)
```

## Excluded from Git

### Via .stow-local-ignore
- `hypr/wallpaper_effects/` (6.9MB wallpaper images)

### Via .gitignore
- History files (*_history, .zsh_history)
- Cache directories (cache/, Cache/)
- Log files (*.log)
- Fish variables
- Temporary files (*.tmp, *.swp)

## File Statistics
- **491 files changed**
- **36,428 insertions, 2,546 deletions**
- **Total size:** ~4MB (excluding wallpapers)

## Usage on New Machine

```bash
# Clone repo
git clone https://github.com/mhenke/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Stow packages (all or selective)
stow --target=$HOME hypr waybar kitty zsh
# or stow all:
stow --target=$HOME */

# For tilix (dconf-based):
dconf load /com/gexperts/Tilix/ < tilix/tilix.dconf
```

## Branches
- `master` - Current Hyprland setup
- `archive-i3-old-system` - Old i3 configs (reference only)

## GitHub Repo
https://github.com/mhenke/dotfiles

---
*Migration completed successfully. All configs are now version controlled and portable.*
