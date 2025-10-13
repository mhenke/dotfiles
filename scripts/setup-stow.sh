#!/bin/bash
#
# setup-stow.sh - Set up dotfiles with GNU Stow
#
# Creates symlinks for all configuration files
#

# Note: Not using 'set -e' because we handle errors explicitly
# and want to continue stowing all packages even if some fail

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
    "htop"
    "mc"
)

# Backup existing configs that would conflict
backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        log_warn "Backing up existing file: $file"
        mv "$file" "${file}.backup-$(date +%Y%m%d-%H%M%S)"
    fi
}

# Backup entire directory if it exists and is not a symlink
backup_dir_if_exists() {
    local dir="$1"
    if [[ -d "$dir" && ! -L "$dir" ]]; then
        # Check if directory has any content
        if [[ -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
            log_warn "Backing up existing directory: $dir"
            mv "$dir" "${dir}.backup-$(date +%Y%m%d-%H%M%S)"
        else
            # Empty directory, just remove it
            rmdir "$dir" 2>/dev/null || true
        fi
    fi
}

# Backup potential conflicts
log_info "Checking for conflicting files and directories..."

# Check if there are conflicts
CONFLICTS_FOUND=false
CONFLICTING_DIRS=()

check_conflict() {
    local path="$1"
    if [[ -e "$path" && ! -L "$path" ]]; then
        CONFLICTS_FOUND=true
        CONFLICTING_DIRS+=("$path")
    fi
}

# Check for conflicts
check_conflict "$HOME/.zshrc"
check_conflict "$HOME/.gitconfig"
check_conflict "$HOME/.config/i3"
check_conflict "$HOME/.config/polybar"
check_conflict "$HOME/.config/picom"
check_conflict "$HOME/.config/dunst"
check_conflict "$HOME/.config/rofi"
check_conflict "$HOME/.config/gtk-3.0"
check_conflict "$HOME/.config/gtk-4.0"
check_conflict "$HOME/.config/xed"
check_conflict "$HOME/.config/htop"
check_conflict "$HOME/.config/mc"
check_conflict "$HOME/.config/tilix"

if [[ "$CONFLICTS_FOUND" == true ]]; then
    log_warn "Found ${#CONFLICTING_DIRS[@]} conflicting directories/files:"
    for dir in "${CONFLICTING_DIRS[@]}"; do
        echo "  - $dir"
    done
    echo ""
    log_warn "These need to be backed up and removed before Stow can create symlinks"
    echo ""
    read -p "Automatically backup and remove these? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Backing up and removing conflicts..."
        bash "$DOTFILES_DIR/scripts/clean-for-stow.sh" <<< "y"
    else
        log_error "Cannot proceed with conflicting directories"
        log_info "Run manually: ./scripts/clean-for-stow.sh"
        exit 1
    fi
else
    log_success "No conflicts found"
fi

# Stow each package
log_info "Stowing packages..."
echo ""

ALREADY_LINKED=0
NEWLY_LINKED=0
FAILED=0

for package in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
        # Try to stow, capture output (use -R to restow if already linked)
        if stow_output=$(stow -R -v -t "$HOME" -d "$DOTFILES_DIR" "$package" 2>&1); then
            # Check if output indicates it was already stowed
            if echo "$stow_output" | grep -q "UNLINK:\|LINK:"; then
                # Something was changed (restowed)
                log_success "✓ $package"
                ((NEWLY_LINKED++))
            else
                # Nothing changed - already perfectly stowed
                log_info "⊙ $package (already linked)"
                ((ALREADY_LINKED++))
            fi
        else
            # Real error occurred
            log_warn "✗ $package (failed)"
            ((FAILED++))
            echo "$stow_output" | sed 's/^/    /' | head -5

            # Check for common errors
            if echo "$stow_output" | grep -q "existing target is"; then
                echo "    → Conflict: existing files not owned by stow"
                echo "    → Run: ./scripts/clean-for-stow.sh"
            fi
        fi
    else
        log_warn "Package directory not found: $package"
        ((FAILED++))
    fi
done

echo ""
echo "Summary:"
echo "  ✓ Linked:   $NEWLY_LINKED"
echo "  ⊙ Skipped:  $ALREADY_LINKED (already linked)"
echo "  ✗ Failed:   $FAILED"
echo ""

if [[ $FAILED -gt 0 ]]; then
    log_warn "Some packages failed to stow"
    log_info "Check conflicts and re-run if needed"
fi

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

if [[ $FAILED -eq 0 ]]; then
    log_success "Dotfiles setup complete!"
else
    log_warn "Dotfiles setup completed with errors"
fi

echo ""
echo "Stowed packages:"
for package in "${PACKAGES[@]}"; do
    echo "  - $package"
done
echo ""
log_info "To update configs in the future:"
echo "  1. Edit files in ~/dotfiles/"
echo "  2. Commit and push changes"
echo "  3. On other machines: git pull && stow -R -t ~ <package>"
