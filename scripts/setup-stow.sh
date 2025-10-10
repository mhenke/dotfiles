#!/bin/bash
#
# setup-stow.sh - Set up dotfiles with GNU Stow
#
# Creates symlinks for all configuration files
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

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DOTFILES_DIR"

log_info "Setting up dotfiles with GNU Stow..."
log_info "Dotfiles directory: $DOTFILES_DIR"

# Packages to stow
PACKAGES=(
    "i3"
    "polybar"
    "picom"
    "dunst"
    "rofi"
    "zsh"
    "git"
    "gtk"
    "xed"
)

# Backup existing configs that would conflict
backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        log_warn "Backing up existing file: $file"
        mv "$file" "${file}.backup-$(date +%Y%m%d-%H%M%S)"
    fi
}

# Backup potential conflicts
log_info "Checking for conflicting files..."
backup_if_exists "$HOME/.config/i3/config"
backup_if_exists "$HOME/.config/polybar/config.ini"
backup_if_exists "$HOME/.config/picom/picom.conf"
backup_if_exists "$HOME/.config/dunst/dunstrc"
backup_if_exists "$HOME/.config/rofi/config.rasi"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.config/gtk-3.0/settings.ini"
backup_if_exists "$HOME/.config/xed/preferences/xed"

# Stow each package
for package in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
        log_info "Stowing $package..."
        stow -t "$HOME" -d "$DOTFILES_DIR" "$package" 2>&1 || log_warn "Failed to stow $package (may already be linked)"
        log_success "$package linked"
    else
        log_warn "Package directory not found: $package"
    fi
done

# Handle tilix separately (uses dconf)
if [[ -f "$DOTFILES_DIR/tilix/tilix.dconf" ]]; then
    log_info "Loading Tilix configuration..."
    dconf load /com/gexperts/Tilix/ < "$DOTFILES_DIR/tilix/tilix.dconf"
    log_success "Tilix configured"
fi

# Make polybar launch script executable
if [[ -f "$HOME/.config/polybar/launch.sh" ]]; then
    chmod +x "$HOME/.config/polybar/launch.sh"
    log_success "Polybar launch script made executable"
fi

# Make polybar scripts executable
if [[ -d "$HOME/.config/polybar/scripts" ]]; then
    chmod +x "$HOME/.config/polybar/scripts/"*.sh 2>/dev/null || true
    log_success "Polybar scripts made executable"
fi

# Make rofi scripts executable
if [[ -d "$HOME/.config/rofi" ]]; then
    chmod +x "$HOME/.config/rofi/"*.sh 2>/dev/null || true
    log_success "Rofi scripts made executable"
fi

log_success "Dotfiles setup complete!"
echo ""
echo "Your config files are now symlinked:"
for package in "${PACKAGES[@]}"; do
    echo "  - $package"
done
echo ""
echo "To update configs in the future:"
echo "  1. Edit files in ~/dotfiles/"
echo "  2. Commit and push changes"
echo "  3. On other machines, pull and run: stow -R -t ~ <package>"
