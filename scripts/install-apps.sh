#!/bin/bash
#
# install-apps.sh - Install applications
#
# Installs VSCode, Bitwarden, Discord, Kodi, etc.
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

# Install VSCode (with optional purge for clean reinstall)
log_info "Checking Visual Studio Code installation..."

# Ask if user wants to purge existing VSCode installation
if command -v code &> /dev/null; then
    log_warn "VSCode is already installed"
    read -p "Do you want to purge and reinstall VSCode? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Purging existing VSCode installation..."

        # Uninstall all extensions
        log_info "Removing all VSCode extensions..."
        code --list-extensions | xargs -L 1 code --uninstall-extension 2>/dev/null || true

        # Remove VSCode package
        sudo apt remove --purge -y code 2>/dev/null || true

        # Remove VSCode user data and config
        log_info "Removing VSCode user data..."
        rm -rf ~/.config/Code
        rm -rf ~/.vscode

        log_success "VSCode purged successfully"
    else
        log_info "Keeping existing VSCode installation"
    fi
fi

# Install VSCode
if ! command -v code &> /dev/null; then
    log_info "Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt update
    sudo apt install code -y
    log_success "VSCode installed"
fi

# Restore VSCode extensions
PACKAGES_DIR="$(dirname "$0")/../packages"
if [[ -f "$PACKAGES_DIR/vscode-extensions.txt" ]]; then
    log_info "Installing VSCode extensions..."
    while IFS= read -r extension; do
        [[ -z "$extension" || "$extension" =~ ^# ]] && continue
        code --install-extension "$extension" --force 2>/dev/null || log_warn "Failed to install $extension"
    done < "$PACKAGES_DIR/vscode-extensions.txt"
    log_success "VSCode extensions installed"
fi

# Install Bitwarden
log_info "Installing Bitwarden..."
if ! flatpak list | grep -q com.bitwarden.desktop; then
    flatpak install -y flathub com.bitwarden.desktop
    log_success "Bitwarden installed"
else
    log_info "Bitwarden already installed"
fi

# Install Discord
log_info "Installing Discord..."
if ! command -v discord &> /dev/null; then
    wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord.deb
    sudo dpkg -i /tmp/discord.deb || sudo apt install -f -y
    rm /tmp/discord.deb
    log_success "Discord installed"
else
    log_info "Discord already installed"
fi

# Install Kodi
log_info "Installing Kodi..."
if ! command -v kodi &> /dev/null; then
    sudo apt install -y kodi
    log_success "Kodi installed"
else
    log_info "Kodi already installed"
fi

# Install ProtonVPN (CLI version - minimal, no GNOME bloat)
log_info "Installing ProtonVPN CLI..."
if ! command -v protonvpn-cli &> /dev/null; then
    log_info "Installing OpenVPN for ProtonVPN..."
    sudo apt install -y openvpn network-manager-openvpn network-manager-openvpn-gnome

    log_success "OpenVPN installed for ProtonVPN"
    log_warn "ProtonVPN GUI not installed (avoids 350MB GNOME bloat)"
    log_info "To use ProtonVPN:"
    log_info "  1. Download .ovpn files from https://account.protonvpn.com/downloads"
    log_info "  2. Import in Network Manager: nmcli connection import type openvpn file your-config.ovpn"
    log_info "  3. Or use ProtonVPN Flatpak: flatpak install flathub com.protonvpn.www"
else
    log_info "ProtonVPN already configured"
fi

# Install Zen Browser
log_info "Installing Zen Browser..."
if ! flatpak list | grep -q app.zen_browser.zen; then
    flatpak install -y flathub app.zen_browser.zen
    log_success "Zen Browser installed"
    log_info "You can launch Zen from the menu (Internet -> Zen Browser)"
else
    log_info "Zen Browser already installed"
fi

# Install OSCAR (CPAP Analysis Software)
log_info "Installing OSCAR CPAP Analysis Software..."
if ! flatpak list | grep -q com.sleepfiles.OSCAR; then
    flatpak install -y flathub com.sleepfiles.OSCAR
    log_success "OSCAR installed"
    log_info "You can launch OSCAR from the menu (Applications -> OSCAR)"
else
    log_info "OSCAR already installed"
fi

# Install Obsidian (Knowledge Base / Note Taking)
log_info "Installing Obsidian..."
if ! flatpak list | grep -q md.obsidian.Obsidian; then
    flatpak install -y flathub md.obsidian.Obsidian
    log_success "Obsidian installed"
    log_info "You can launch Obsidian from the menu (Office -> Obsidian)"
else
    log_info "Obsidian already installed"
fi

# Install Notion (via Cohesion - unofficial wrapper)
log_info "Installing Notion (Cohesion wrapper)..."
if ! flatpak list | grep -q io.github.brunofin.Cohesion; then
    flatpak install -y flathub io.github.brunofin.Cohesion
    log_success "Notion (Cohesion) installed"
    log_info "You can launch Notion from the menu (Office -> Cohesion)"
    log_warn "Note: Cohesion is an unofficial Notion wrapper, not affiliated with Notion Inc."
else
    log_info "Notion (Cohesion) already installed"
fi

log_success "Applications installed successfully!"
echo ""
echo "Manual setup required (authentication only):"
echo "  - Bitwarden: Sign in to your account"
echo "  - Discord: Sign in to your account"
echo "  - ProtonVPN: Sign in to your ProtonVPN account"
echo "  - VSCode: Sign in to sync settings (Extensions auto-installed)"
echo "  - Zen Browser: Sign in to Firefox Account for sync"
echo "  - Notion (Cohesion): Sign in to your Notion account"
echo "  - Obsidian: Optional - sign in for sync across devices"
echo "  - GitHub CLI: Run 'gh auth login'"
