#!/bin/bash
#
# fix-stow-conflicts.sh - Backup existing configs and prepare for Stow
#
# This script backs up existing configuration files that conflict with Stow
# and prepares the system for clean dotfiles symlink management.
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

# Create backup directory
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
log_info "Created backup directory: $BACKUP_DIR"

# Backup and remove conflicting files
log_info "Backing up existing configuration files..."

# .gitconfig
if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
    log_info "Backing up .gitconfig..."
    cp "$HOME/.gitconfig" "$BACKUP_DIR/.gitconfig"
    rm "$HOME/.gitconfig"
    log_success "Backed up and removed .gitconfig"
fi

# i3 config
if [[ -f "$HOME/.config/i3/config" && ! -L "$HOME/.config/i3/config" ]]; then
    log_info "Backing up i3 config..."
    cp "$HOME/.config/i3/config" "$BACKUP_DIR/i3-config"
    rm "$HOME/.config/i3/config"
    log_success "Backed up and removed i3 config"
fi

# .zshrc
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    log_info "Backing up .zshrc..."
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
    rm "$HOME/.zshrc"
    log_success "Backed up and removed .zshrc"
fi

# Check for other potential conflicts
CONFLICTS=()

# Check picom
if [[ -f "$HOME/.config/picom/picom.conf" && ! -L "$HOME/.config/picom/picom.conf" ]]; then
    CONFLICTS+=("picom/picom.conf")
fi

# Check polybar
if [[ -f "$HOME/.config/polybar/config.ini" && ! -L "$HOME/.config/polybar/config.ini" ]]; then
    CONFLICTS+=("polybar/config.ini")
fi

# Check rofi
if [[ -f "$HOME/.config/rofi/config.rasi" && ! -L "$HOME/.config/rofi/config.rasi" ]]; then
    CONFLICTS+=("rofi/config.rasi")
fi

# Check dunst
if [[ -f "$HOME/.config/dunst/dunstrc" && ! -L "$HOME/.config/dunst/dunstrc" ]]; then
    CONFLICTS+=("dunst/dunstrc")
fi

# Backup any additional conflicts found
if [ ${#CONFLICTS[@]} -gt 0 ]; then
    log_warn "Found additional config files that may conflict:"
    for config in "${CONFLICTS[@]}"; do
        echo "  - $HOME/.config/$config"
        mkdir -p "$BACKUP_DIR/$(dirname "$config")"
        cp "$HOME/.config/$config" "$BACKUP_DIR/$config"
        rm "$HOME/.config/$config"
    done
    log_success "Backed up and removed additional configs"
fi

echo ""
log_success "Backup complete! Files saved to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Run: cd ~/dotfiles && bash scripts/setup-stow.sh"
echo "  2. If you need to restore, files are in: $BACKUP_DIR"
echo ""
