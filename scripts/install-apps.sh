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
if ! command -v bitwarden &> /dev/null; then
    wget "https://vault.bitwarden.com/download/?app=desktop&platform=linux" -O /tmp/bitwarden.deb
    sudo dpkg -i /tmp/bitwarden.deb || sudo apt install -f -y
    rm /tmp/bitwarden.deb
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
if ! command -v protonvpn &> /dev/null && ! dpkg -l | grep -q proton-vpn-gtk-app; then
    # Add ProtonVPN repository (updated method)
    wget https://repo2.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb -O /tmp/protonvpn-release.deb
    sudo dpkg -i /tmp/protonvpn-release.deb || sudo apt install -f -y
    rm /tmp/protonvpn-release.deb

    sudo apt update
    sudo apt install -y proton-vpn-gnome-desktop
    log_success "ProtonVPN installed"
else
    log_info "ProtonVPN already installed"
fi

# Install Zen Browser
log_info "Installing Zen Browser..."
if ! command -v zen &> /dev/null; then
    # Create directories
    sudo mkdir -p /opt/AppImages
    mkdir -p ~/.local/share/applications

    # Download latest Zen Browser AppImage
    log_info "Downloading Zen Browser AppImage..."
    wget --show-progress https://github.com/zen-browser/desktop/releases/latest/download/zen-specific.AppImage -O /tmp/zen-specific.AppImage

    # Move to /opt and make executable
    sudo mv /tmp/zen-specific.AppImage /opt/AppImages/zen-specific.AppImage
    sudo chmod +x /opt/AppImages/zen-specific.AppImage

    # Create symlink for easy command-line access
    sudo ln -sf /opt/AppImages/zen-specific.AppImage /usr/local/bin/zen

    # Download icon (optional, but good for menu)
    wget -q https://raw.githubusercontent.com/zen-browser/desktop/main/src/browser/branding/official/default256.png -O /tmp/zen-icon.png 2>/dev/null || true
    if [ -f /tmp/zen-icon.png ]; then
        sudo mv /tmp/zen-icon.png /opt/AppImages/zen-browser-icon.png
    fi

    # Create desktop entry for application menu
    cat > ~/.local/share/applications/zen-browser.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Zen Browser
Comment=Experience tranquillity while browsing the web
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;
Exec=/opt/AppImages/zen-specific.AppImage
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/AppImages/zen-browser-icon.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

    log_success "Zen Browser installed"
    log_info "You can launch Zen from the menu (Internet -> Zen Browser) or run 'zen' in terminal"
else
    log_info "Zen Browser already installed"
fi

log_success "Applications installed successfully!"
echo ""
echo "Manual setup required (authentication only):"
echo "  - Bitwarden: Sign in to your account"
echo "  - Discord: Sign in to your account"
echo "  - ProtonVPN: Sign in to your ProtonVPN account"
echo "  - VSCode: Sign in to sync settings (Extensions auto-installed)"
echo "  - Zen Browser: Sign in to Firefox Account for sync"
echo "  - GitHub CLI: Run 'gh auth login'"
