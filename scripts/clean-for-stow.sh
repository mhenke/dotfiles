#!/bin/bash
#
# clean-for-stow.sh - Remove existing config directories not owned by Stow
#
# This backs up and removes directories that conflict with Stow,
# allowing a clean stow setup.
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_warn "This script will backup and remove existing config directories"
log_warn "that conflict with GNU Stow."
echo ""
log_info "Files and directories that will be backed up and removed:"
echo "  - ~/.zshrc"
echo "  - ~/.gitconfig"
echo "  - ~/.config/i3"
echo "  - ~/.config/polybar"
echo "  - ~/.config/picom"
echo "  - ~/.config/dunst"
echo "  - ~/.config/rofi"
echo "  - ~/.config/gtk-3.0"
echo "  - ~/.config/gtk-4.0"
echo "  - ~/.config/xed"
echo "  - ~/.config/htop"
echo "  - ~/.config/mc"
echo "  - ~/.config/tilix"
echo ""
log_warn "Backups will be created with timestamp: .backup-YYYYMMDD-HHMMSS"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled"
    exit 0
fi

BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Function to backup and remove
backup_and_remove() {
    local path="$1"
    local name=$(basename "$path")

    if [[ -e "$path" && ! -L "$path" ]]; then
        log_info "Backing up: $path"
        mv "$path" "${path}.backup-${BACKUP_TIMESTAMP}"
        log_success "Backed up: $name"
    elif [[ -L "$path" ]]; then
        log_info "Skipping $name (already a symlink - owned by Stow)"
    else
        log_info "Skipping $name (does not exist)"
    fi
}

log_info "Backing up and removing conflicting files and directories..."
echo ""

# Backup individual files in home directory
backup_and_remove "$HOME/.zshrc"
backup_and_remove "$HOME/.gitconfig"

# Backup config directories
backup_and_remove "$HOME/.config/i3"
backup_and_remove "$HOME/.config/polybar"
backup_and_remove "$HOME/.config/picom"
backup_and_remove "$HOME/.config/dunst"
backup_and_remove "$HOME/.config/rofi"
backup_and_remove "$HOME/.config/gtk-3.0"
backup_and_remove "$HOME/.config/gtk-4.0"
backup_and_remove "$HOME/.config/xed"
backup_and_remove "$HOME/.config/htop"
backup_and_remove "$HOME/.config/mc"
backup_and_remove "$HOME/.config/tilix"

echo ""
log_success "Cleanup complete!"
echo ""
log_info "Backups created with timestamp: $BACKUP_TIMESTAMP"
log_info "You can now run: ./scripts/setup-stow.sh"
echo ""
log_warn "To restore backups if needed:"
echo "  mv ~/.config/i3.backup-$BACKUP_TIMESTAMP ~/.config/i3"
echo "  (repeat for other directories)"
