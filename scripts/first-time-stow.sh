#!/bin/bash
#
# first-time-stow.sh - First-time Stow setup for new machines
#
# This script is designed for clean installs where you want to replace
# default system configs with your dotfiles.
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

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DOTFILES_DIR"

log_info "First-time Stow setup for new machine"
echo ""
log_warn "This will REPLACE existing config files with dotfiles from this repo"
echo ""
log_info "Current dotfiles directory: $DOTFILES_DIR"
echo ""

# Detect what conflicts exist by doing a dry run
log_info "Checking for conflicts..."
CONFLICTS=$(stow --no-folding -n -v -t "$HOME" -d "$DOTFILES_DIR" */ 2>&1 | grep "existing target" | wc -l)

if [[ $CONFLICTS -gt 0 ]]; then
    log_warn "Found $CONFLICTS conflicting files/directories:"
    stow --no-folding -n -v -t "$HOME" -d "$DOTFILES_DIR" */ 2>&1 | grep "existing target" | sed 's/^/  /'
    echo ""
else
    log_success "No conflicts found - ready to stow!"
fi

echo ""
read -p "Backup and replace all conflicting files? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled - no changes made"
    exit 0
fi

# Create single backup directory for all conflicts
BACKUP_DIR="$HOME/dotfiles-conflicts-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
log_info "Backing up conflicts to: $BACKUP_DIR"

# Function to backup a file/directory
backup_item() {
    local item="$1"
    local full_path="$HOME/$item"

    if [[ -e "$full_path" && ! -L "$full_path" ]]; then
        # Create parent directory in backup if needed
        local parent_dir=$(dirname "$BACKUP_DIR/$item")
        mkdir -p "$parent_dir"

        # Move the file/directory to backup
        mv "$full_path" "$BACKUP_DIR/$item"
        log_info "  Backed up: $item"
        return 0
    fi
    return 1
}

# Extract list of conflicting items from stow dry-run
log_info "Backing up conflicting items..."
BACKED_UP=0

while IFS= read -r line; do
    if [[ "$line" =~ "existing target is".*:\ (.*) ]]; then
        item="${BASH_REMATCH[1]}"
        if backup_item "$item"; then
            ((BACKED_UP++))
        fi
    fi
done < <(stow --no-folding -n -v -t "$HOME" -d "$DOTFILES_DIR" */ 2>&1)

if [[ $BACKED_UP -gt 0 ]]; then
    log_success "Backed up $BACKED_UP items to: $BACKUP_DIR"
else
    log_info "No items needed backup"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# Now stow everything
echo ""
log_info "Stowing all packages..."
echo ""

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
    "htop"
    "mc"
)

SUCCESS=0
FAILED=0

for package in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
        # --no-folding: Only symlink files, not directories (fixes i3 config issues)
        if stow --no-folding -v -t "$HOME" -d "$DOTFILES_DIR" "$package" 2>/dev/null; then
            log_success "✓ $package"
            ((SUCCESS++))
        else
            log_warn "✗ $package (failed)"
            ((FAILED++))
        fi
    fi
done

# Handle tilix separately (uses dconf)
if [[ -f "$DOTFILES_DIR/tilix/tilix.dconf" ]]; then
    log_info "Loading Tilix configuration..."
    dconf load /com/gexperts/Tilix/ < "$DOTFILES_DIR/tilix/tilix.dconf" 2>/dev/null || log_warn "Tilix dconf failed (may not be installed)"
fi

# Make scripts executable
if [[ -f "$HOME/.config/polybar/launch.sh" ]]; then
    chmod +x "$HOME/.config/polybar/launch.sh"
fi

if [[ -d "$HOME/.config/polybar/scripts" ]]; then
    chmod +x "$HOME/.config/polybar/scripts/"*.sh 2>/dev/null || true
fi

if [[ -d "$HOME/.config/rofi" ]]; then
    chmod +x "$HOME/.config/rofi/"*.sh 2>/dev/null || true
fi

# Summary
echo ""
echo "═══════════════════════════════════════════"
echo "Summary:"
echo "  ✓ Stowed:   $SUCCESS packages"
echo "  ✗ Failed:   $FAILED packages"
if [[ $BACKED_UP -gt 0 ]]; then
    echo "  ⊙ Backed up: $BACKED_UP items"
fi
echo "═══════════════════════════════════════════"
echo ""

if [[ $FAILED -eq 0 ]]; then
    log_success "First-time stow complete!"
else
    log_warn "Completed with $FAILED failures"
fi

if [[ $BACKED_UP -gt 0 ]]; then
    echo ""
    log_info "Your original configs are backed up in:"
    echo "  $BACKUP_DIR"
    echo ""
    log_info "To restore a backup:"
    echo "  cp $BACKUP_DIR/.gitconfig ~/"
fi

echo ""
log_info "Next steps:"
echo "  1. Restart your shell: exec zsh"
echo "  2. Reload i3: Mod+Shift+R"
echo "  3. Check that configs work as expected"
