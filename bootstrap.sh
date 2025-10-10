#!/bin/bash
#
# bootstrap.sh - Automated Linux Mint + i3 Setup
# 
# This script sets up a fresh Linux Mint installation with:
# - i3wm, polybar, rofi, picom, dunst
# - Development tools (node, npm, ruby, python, aws)
# - Applications (VSCode, Bitwarden, Discord, Kodi, ProtonVPN)
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

# Confirmation prompt
echo ""
echo "This script will:"
echo "  1. Update system packages"
echo "  2. Install i3, polybar, rofi, picom, dunst, tilix, zsh"
echo "  3. Install development tools (Node.js, Ruby, Python, AWS CLI)"
echo "  4. Install applications (VSCode, Bitwarden, Discord, Kodi, ProtonVPN)"
echo "  5. Set up zsh with oh-my-zsh"
echo "  6. Symlink dotfiles with GNU Stow"
echo "  7. Restore VSCode extensions"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Bootstrap cancelled."
    exit 0
fi

# Run installation scripts
log_info "Step 1/5: Installing system packages..."
bash "$DOTFILES_DIR/scripts/install-packages.sh"
log_success "System packages installed"

log_info "Step 2/5: Installing development tools..."
bash "$DOTFILES_DIR/scripts/install-dev-tools.sh"
log_success "Development tools installed"

log_info "Step 3/5: Installing applications..."
bash "$DOTFILES_DIR/scripts/install-apps.sh"
log_success "Applications installed"

log_info "Step 4/5: Setting up dotfiles with GNU Stow..."
bash "$DOTFILES_DIR/scripts/setup-stow.sh"
log_success "Dotfiles configured"

log_info "Step 5/5: Configuring zsh and shell..."
# Set zsh as default shell if not already
if [[ "$SHELL" != */zsh ]]; then
    log_info "Setting zsh as default shell..."
    chsh -s $(which zsh)
    log_success "Default shell changed to zsh (requires logout to take effect)"
else
    log_info "zsh is already the default shell"
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
