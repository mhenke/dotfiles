#!/bin/bash
#
# bootstrap.sh - Automated Linux Mint + i3 Setup
# 
# This script sets up a fresh Linux Mint installation with:
# - i3wm, polybar, rofi, picom, dunst
# - Development tools (node, npm, ruby, python, aws)
# - Applications (VSCode, Bitwarden, Discord, Kodi, ProtonVPN, Zen Browser, OSCAR, Obsidian, Notion)
# - Dotfiles via GNU Stow
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should NOT be run as root. Run as your normal user."
   exit 1
fi

# Get script directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"

log_info "Starting bootstrap process..."
log_info "Dotfiles directory: $DOTFILES_DIR"

# Display installation steps
echo ""
echo "Available installation steps:"
echo "  1. Install system packages (i3, polybar, rofi, picom, dunst, tilix, zsh)"
echo "  2. Install development tools (Node.js, Ruby, Python, AWS CLI, GitHub CLI)"
echo "  3. Install applications (VSCode, Bitwarden, Discord, Kodi, ProtonVPN, Zen Browser, OSCAR, Obsidian, Notion)"
echo "  4. Setup dotfiles with GNU Stow"
echo "  5. Install themes and apply dark mode (Nordic, Papirus icons, Bibata cursor)"
echo "  6. Configure zsh as default shell"
echo ""
echo "Options:"
echo "  y/Y     - Run all steps"
echo "  n/N     - Cancel"
echo "  1-6     - Start from specific step"
echo "  1,3,5   - Run specific steps only"
echo ""
read -p "Choose option (y/n/1-6): " REPLY
echo

# Parse user input
START_STEP=1
RUN_ALL=true
SPECIFIC_STEPS=()

case "$REPLY" in
    [Yy]*)
        log_info "Running all steps..."
        START_STEP=1
        RUN_ALL=true
        ;;
    [Nn]*)
        log_info "Bootstrap cancelled."
        exit 0
        ;;
    *,*)
        # Comma-separated specific steps (e.g., "1,3,5")
        IFS=',' read -ra SPECIFIC_STEPS <<< "$REPLY"
        RUN_ALL=false
        log_info "Running specific steps: ${SPECIFIC_STEPS[*]}"
        ;;
    [1-6])
        # Single number - start from that step
        START_STEP=$REPLY
        RUN_ALL=true
        log_info "Starting from step $START_STEP..."
        ;;
    *)
        log_error "Invalid option. Please use y/n or 1-6"
        exit 1
        ;;
esac

# Function to check if step should run
should_run_step() {
    local step=$1
    if [[ "$RUN_ALL" = true && $step -ge $START_STEP ]]; then
        return 0
    elif [[ " ${SPECIFIC_STEPS[@]} " =~ " $step " ]]; then
        return 0
    else
        return 1
    fi
}

# Run installation scripts
if should_run_step 1; then
    log_info "Step 1/6: Installing system packages..."
    bash "$DOTFILES_DIR/scripts/install-packages.sh"
    log_success "System packages installed"
fi

if should_run_step 2; then
    log_info "Step 2/6: Installing development tools..."
    bash "$DOTFILES_DIR/scripts/install-dev-tools.sh"
    log_success "Development tools installed"
fi

if should_run_step 3; then
    log_info "Step 3/6: Installing applications..."
    bash "$DOTFILES_DIR/scripts/install-apps.sh"
    log_success "Applications installed"
fi

if should_run_step 4; then
    log_info "Step 4/6: Setting up dotfiles with GNU Stow..."
    bash "$DOTFILES_DIR/scripts/setup-stow.sh"
    log_success "Dotfiles configured"
fi

if should_run_step 5; then
    log_info "Step 5/6: Installing themes..."
    bash "$DOTFILES_DIR/scripts/install-themes.sh"
    log_success "Themes installed"

    # Apply dark mode settings
    log_info "Applying dark mode settings..."
    bash "$DOTFILES_DIR/scripts/apply-dark-mode.sh"
    log_success "Dark mode applied"
fi

if should_run_step 6; then
    log_info "Step 6/6: Configuring zsh and shell..."
    # Set zsh as default shell if not already
    if [[ "$SHELL" != */zsh ]]; then
        log_info "Setting zsh as default shell..."
        chsh -s $(which zsh)
        log_success "Default shell changed to zsh (requires logout to take effect)"
    else
        log_info "zsh is already the default shell"
    fi
fi

# Final messages
echo ""
log_success "Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  1. Logout and log back in (to apply shell changes)"
echo "  2. Select 'i3' session at login screen"
echo "  3. Login to services:"
echo "     - GitHub: gh auth login"
echo "     - Bitwarden"
echo "     - Discord"
echo "     - Proton VPN"
echo "  4. Copy SSH keys: cp -r /backup/.ssh ~/ && chmod 700 ~/.ssh"
echo "  5. Sync VSCode settings (should auto-sync if signed in)"
echo ""
echo "Monitor aliases: 'sceptre', 'laptop', 'dual'"
echo ""
log_info "Enjoy your new system! 🚀"
