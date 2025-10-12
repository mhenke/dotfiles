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

# Install VSCode
log_info "Installing Visual Studio Code..."
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    
    sudo apt update
    sudo apt install code -y
    log_success "VSCode installed"
else
    log_info "VSCode already installed"
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

# Install ProtonVPN
log_info "Installing ProtonVPN..."
if ! command -v protonvpn &> /dev/null && ! dpkg -l | grep -q proton-vpn-gnome-desktop; then
    # Clean up any old repository configurations
    sudo rm -f /etc/apt/sources.list.d/protonvpn.list
    sudo rm -f /etc/apt/sources.list.d/protonvpn-stable.list

    # Download the official ProtonVPN repository package (version 1.0.8)
    log_info "Downloading ProtonVPN repository package..."
    wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb -O /tmp/protonvpn-release.deb

    # Install the repository package
    sudo dpkg -i /tmp/protonvpn-release.deb
    rm /tmp/protonvpn-release.deb

    # Update package lists and install ProtonVPN
    sudo apt update
    sudo apt install -y proton-vpn-gnome-desktop

    # Optional: Install system tray support
    sudo apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator 2>/dev/null || true

    log_success "ProtonVPN installed"
else
    log_info "ProtonVPN already installed"
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
if ! dpkg -l | grep -q oscar; then
    # Download OSCAR for Ubuntu 24.04
    log_info "Downloading OSCAR v1.6.1 for Ubuntu 24.04..."
    wget https://www.apneaboard.com/OSCAR/1.6.1/oscar_1.6.1-Ubuntu24_amd64.deb -O /tmp/oscar.deb

    # Install OSCAR
    sudo dpkg -i /tmp/oscar.deb || sudo apt install -f -y
    rm /tmp/oscar.deb

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
