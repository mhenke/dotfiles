#!/bin/bash
#
# backup-app-configs.sh - Backup application configs not in dotfiles
#
# Backs up configs for:
# - Zen Browser
# - Tilix
# - Thunar (if you use it)
# - VSCode settings (if not synced)
# - Discord
# - Kodi
# - Any other app configs in ~/.config, ~/.local, ~/.cache
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Backup directory
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

log_info "Creating backup in: $BACKUP_DIR"

# =============================================================================
# BROWSER CONFIGS
# =============================================================================
log_info "Backing up browser configurations..."

# Zen Browser (if exists)
if [ -d "$HOME/.zen" ]; then
    log_info "Found Zen Browser config"
    cp -r "$HOME/.zen" "$BACKUP_DIR/"
    log_success "Zen Browser backed up"
fi

# Firefox profiles (if you use Firefox)
if [ -d "$HOME/.mozilla/firefox" ]; then
    log_info "Found Firefox profiles"
    cp -r "$HOME/.mozilla/firefox" "$BACKUP_DIR/firefox-profiles"
    log_success "Firefox profiles backed up"
fi

# =============================================================================
# TERMINAL CONFIGS
# =============================================================================
log_info "Backing up terminal configurations..."

# Tilix (dconf settings)
if command -v dconf >/dev/null 2>&1; then
    log_info "Exporting Tilix dconf settings"
    dconf dump /com/gexperts/Tilix/ > "$BACKUP_DIR/tilix-settings.dconf"
    log_success "Tilix settings backed up"
fi

# Terminator (if you use it)
if [ -d "$HOME/.config/terminator" ]; then
    cp -r "$HOME/.config/terminator" "$BACKUP_DIR/"
    log_success "Terminator config backed up"
fi

# =============================================================================
# FILE MANAGER
# =============================================================================
log_info "Backing up file manager configurations..."

# Thunar
if [ -d "$HOME/.config/Thunar" ]; then
    cp -r "$HOME/.config/Thunar" "$BACKUP_DIR/"
    log_success "Thunar config backed up"
fi

# Thunar custom actions
if [ -d "$HOME/.config/xfce4" ]; then
    mkdir -p "$BACKUP_DIR/xfce4"
    if [ -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ]; then
        cp "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" "$BACKUP_DIR/xfce4/"
        log_success "Thunar XML settings backed up"
    fi
fi

# =============================================================================
# VSCODE
# =============================================================================
log_info "Backing up VSCode settings (if not cloud synced)..."

if [ -d "$HOME/.config/Code/User" ]; then
    mkdir -p "$BACKUP_DIR/vscode"
    cp "$HOME/.config/Code/User/settings.json" "$BACKUP_DIR/vscode/" 2>/dev/null || log_warn "VSCode settings.json not found"
    cp "$HOME/.config/Code/User/keybindings.json" "$BACKUP_DIR/vscode/" 2>/dev/null || log_warn "VSCode keybindings.json not found"
    cp "$HOME/.config/Code/User/snippets/"* "$BACKUP_DIR/vscode/" 2>/dev/null || log_warn "VSCode snippets not found"
    log_success "VSCode settings backed up (if exists)"
fi

# =============================================================================
# DISCORD
# =============================================================================
log_info "Backing up Discord settings..."

if [ -d "$HOME/.config/discord" ]; then
    # Only backup settings, not cache
    mkdir -p "$BACKUP_DIR/discord"
    find "$HOME/.config/discord" -name "*.json" -not -path "*/Cache/*" -exec cp --parents {} "$BACKUP_DIR/" \; 2>/dev/null
    log_success "Discord settings backed up"
fi

# =============================================================================
# KODI
# =============================================================================
log_info "Backing up Kodi configuration..."

if [ -d "$HOME/.kodi" ]; then
    mkdir -p "$BACKUP_DIR/kodi"
    # Backup userdata (settings, sources, favorites, etc.)
    if [ -d "$HOME/.kodi/userdata" ]; then
        cp -r "$HOME/.kodi/userdata" "$BACKUP_DIR/kodi/"
        # Remove cache to save space
        rm -rf "$BACKUP_DIR/kodi/userdata/Thumbnails" 2>/dev/null
        log_success "Kodi settings backed up"
    fi
fi

# =============================================================================
# THEME/GTK SETTINGS
# =============================================================================
log_info "Backing up theme and GTK settings..."

# GTK bookmarks
if [ -f "$HOME/.config/gtk-3.0/bookmarks" ]; then
    mkdir -p "$BACKUP_DIR/gtk-3.0"
    cp "$HOME/.config/gtk-3.0/bookmarks" "$BACKUP_DIR/gtk-3.0/"
    log_success "GTK bookmarks backed up"
fi

# GTK theme settings (if not in dotfiles)
if [ -f "$HOME/.gtkrc-2.0" ]; then
    cp "$HOME/.gtkrc-2.0" "$BACKUP_DIR/"
fi

# Icon theme settings
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    cp "$HOME/.config/gtk-3.0/settings.ini" "$BACKUP_DIR/gtk-3.0/"
fi

# =============================================================================
# APPLICATION CACHE & DATA
# =============================================================================
log_info "Backing up application data..."

# Bitwarden (local data)
if [ -d "$HOME/.config/Bitwarden" ]; then
    mkdir -p "$BACKUP_DIR/Bitwarden"
    cp -r "$HOME/.config/Bitwarden" "$BACKUP_DIR/"
    log_success "Bitwarden data backed up"
fi

# Fonts (custom fonts you installed)
if [ -d "$HOME/.local/share/fonts" ]; then
    cp -r "$HOME/.local/share/fonts" "$BACKUP_DIR/"
    log_success "Custom fonts backed up"
fi

# Desktop entries (custom .desktop files)
if [ -d "$HOME/.local/share/applications" ]; then
    cp -r "$HOME/.local/share/applications" "$BACKUP_DIR/"
    log_success "Custom .desktop files backed up"
fi

# =============================================================================
# MISC CONFIGS
# =============================================================================
log_info "Backing up miscellaneous configs..."

# All ~/.config directories not already in dotfiles
log_info "Scanning ~/.config for additional configs..."
for dir in "$HOME/.config/"*/; do
    dirname=$(basename "$dir")
    # Skip if already in dotfiles
    if [ ! -d "$HOME/dotfiles/$dirname" ]; then
        # Skip large cache directories
        if [[ ! "$dirname" =~ ^(chromium|google-chrome|Code|BraveSoftware|Slack|teams)$ ]]; then
            cp -r "$dir" "$BACKUP_DIR/additional-configs/" 2>/dev/null || true
        fi
    fi
done

# =============================================================================
# DCONF DUMP (FULL SYSTEM SETTINGS)
# =============================================================================
log_info "Dumping full dconf settings..."
if command -v dconf >/dev/null 2>&1; then
    dconf dump / > "$BACKUP_DIR/full-dconf-settings.conf"
    log_success "Full dconf settings backed up"
fi

# =============================================================================
# CREATE RESTORE SCRIPT
# =============================================================================
log_info "Creating restore script..."

cat > "$BACKUP_DIR/restore.sh" << 'RESTORE_EOF'
#!/bin/bash
# Auto-generated restore script
# Run this on the new machine to restore backed up configs

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Restoring application configs..."

# Zen Browser
if [ -d ".zen" ]; then
    log_info "Restoring Zen Browser..."
    cp -r .zen "$HOME/"
    log_success "Zen Browser restored"
fi

# Firefox
if [ -d "firefox-profiles" ]; then
    log_info "Restoring Firefox..."
    mkdir -p "$HOME/.mozilla"
    cp -r firefox-profiles "$HOME/.mozilla/firefox"
    log_success "Firefox restored"
fi

# Tilix
if [ -f "tilix-settings.dconf" ]; then
    log_info "Restoring Tilix settings..."
    dconf load /com/gexperts/Tilix/ < tilix-settings.dconf
    log_success "Tilix restored"
fi

# Thunar
if [ -d "Thunar" ]; then
    log_info "Restoring Thunar..."
    cp -r Thunar "$HOME/.config/"
    log_success "Thunar restored"
fi

# VSCode
if [ -d "vscode" ]; then
    log_info "Restoring VSCode settings..."
    mkdir -p "$HOME/.config/Code/User"
    cp vscode/* "$HOME/.config/Code/User/" 2>/dev/null || true
    log_success "VSCode settings restored"
fi

# Discord
if [ -d "discord" ]; then
    log_info "Restoring Discord settings..."
    cp -r discord "$HOME/.config/"
    log_success "Discord settings restored"
fi

# Kodi
if [ -d "kodi" ]; then
    log_info "Restoring Kodi..."
    mkdir -p "$HOME/.kodi"
    cp -r kodi/userdata "$HOME/.kodi/"
    log_success "Kodi restored"
fi

# GTK
if [ -d "gtk-3.0" ]; then
    log_info "Restoring GTK settings..."
    mkdir -p "$HOME/.config/gtk-3.0"
    cp gtk-3.0/* "$HOME/.config/gtk-3.0/"
    log_success "GTK settings restored"
fi

# Bitwarden
if [ -d "Bitwarden" ]; then
    log_info "Restoring Bitwarden..."
    cp -r Bitwarden "$HOME/.config/"
    log_success "Bitwarden restored"
fi

# Custom fonts
if [ -d "fonts" ]; then
    log_info "Restoring custom fonts..."
    mkdir -p "$HOME/.local/share"
    cp -r fonts "$HOME/.local/share/"
    fc-cache -f -v
    log_success "Fonts restored"
fi

# Custom .desktop files
if [ -d "applications" ]; then
    log_info "Restoring .desktop files..."
    mkdir -p "$HOME/.local/share"
    cp -r applications "$HOME/.local/share/"
    log_success ".desktop files restored"
fi

# Additional configs
if [ -d "additional-configs" ]; then
    log_info "Restoring additional configs..."
    cp -r additional-configs/* "$HOME/.config/" 2>/dev/null || true
    log_success "Additional configs restored"
fi

echo ""
log_success "Restore complete!"
echo ""
log_info "You may need to:"
echo "  1. Restart applications"
echo "  2. Logout/login for some changes to take effect"
echo ""
RESTORE_EOF

chmod +x "$BACKUP_DIR/restore.sh"

# =============================================================================
# CREATE README
# =============================================================================
cat > "$BACKUP_DIR/README.md" << 'README_EOF'
# Application Configs Backup

This backup contains application configurations that aren't tracked in dotfiles.

## What's Backed Up

- **Zen Browser** - Profile, extensions, settings
- **Tilix** - Terminal settings (dconf)
- **Thunar** - File manager settings
- **VSCode** - Settings, keybindings, snippets (if not cloud synced)
- **Discord** - Settings and configuration
- **Kodi** - Media center settings, sources, favorites
- **GTK** - Theme settings, bookmarks
- **Bitwarden** - Local data
- **Custom fonts** - User-installed fonts
- **Desktop entries** - Custom .desktop files
- **Full dconf dump** - All system settings

## How to Restore

### Option 1: Automatic Restore
```bash
cd /path/to/this/backup
./restore.sh
```

### Option 2: Manual Restore
Copy specific directories:
```bash
# Zen Browser
cp -r .zen ~/

# Tilix
dconf load /com/gexperts/Tilix/ < tilix-settings.dconf

# Thunar
cp -r Thunar ~/.config/

# Kodi
cp -r kodi/userdata ~/.kodi/
```

## Full System dconf Restore

To restore ALL dconf settings (use with caution):
```bash
dconf load / < full-dconf-settings.conf
```

## Notes

- Some apps may need to be installed before restoring configs
- Logout/login after restoring for changes to take effect
- Browser profiles may need extension re-installation
README_EOF

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "================================================================"
log_success "Backup complete!"
echo "================================================================"
echo ""
log_info "Backed up to: $BACKUP_DIR"
echo ""
log_info "What was backed up:"
echo "  - Browser configs (Zen, Firefox if exists)"
echo "  - Terminal settings (Tilix dconf)"
echo "  - File manager (Thunar)"
echo "  - VSCode settings"
echo "  - Discord settings"
echo "  - Kodi configuration"
echo "  - GTK themes/bookmarks"
echo "  - Bitwarden local data"
echo "  - Custom fonts"
echo "  - Custom .desktop files"
echo "  - Additional ~/.config directories"
echo "  - Full dconf dump"
echo ""
log_info "To restore on new machine:"
echo "  1. Copy this folder to new machine"
echo "  2. cd $BACKUP_DIR"
echo "  3. ./restore.sh"
echo ""
log_info "Or copy to a USB drive:"
echo "  cp -r $BACKUP_DIR /media/your-usb-drive/"
echo ""
