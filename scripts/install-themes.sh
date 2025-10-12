#!/bin/bash
#
# install-themes.sh - Install Nordic theme, Papirus icons, and Bibata cursor
#
# Installs the visual themes and customizations for consistent look across apps
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

# Install Nordic theme
log_info "Installing Nordic GTK theme..."
if [[ ! -d "$HOME/.themes/Nordic" ]]; then
    # Download and install Nordic theme
    cd /tmp
    wget -q https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz
    tar -xf Nordic.tar.xz
    mkdir -p ~/.themes
    mv Nordic ~/.themes/
    rm Nordic.tar.xz
    log_success "Nordic theme installed"
else
    log_info "Nordic theme already installed"
fi

# Install Papirus icon theme
log_info "Installing Papirus icon theme..."
if ! dpkg -l | grep -q papirus-icon-theme; then
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update
    sudo apt install -y papirus-icon-theme
    log_success "Papirus icon theme installed"
else
    log_info "Papirus already installed"
fi

# Install Bibata cursor theme
log_info "Installing Bibata Modern Classic cursor theme..."
if [[ ! -d "$HOME/.icons/Bibata-Modern-Classic" ]]; then
    cd /tmp
    wget -q https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
    tar -xf Bibata-Modern-Classic.tar.xz
    mkdir -p ~/.icons
    mv Bibata-Modern-Classic ~/.icons/
    rm Bibata-Modern-Classic.tar.xz
    log_success "Bibata Modern Classic cursor installed"
else
    log_info "Bibata cursor already installed"
fi

# Apply theme settings via gsettings (for GTK apps)
log_info "Applying theme settings..."
gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic"
gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Classic"

# Also set for GNOME/GTK (in case not using Cinnamon)
gsettings set org.gnome.desktop.interface gtk-theme "Nordic" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic" 2>/dev/null || true

log_success "Theme settings applied"

echo ""
log_success "Themes installed successfully!"
echo ""
echo "Installed themes:"
echo "  - Nordic GTK theme (dark blue/gray)"
echo "  - Papirus-Dark icon theme"
echo "  - Bibata Modern Classic cursor"
echo ""
echo "Theme settings have been applied via gsettings."
echo "You may need to logout/login or restart apps to see changes."
echo ""
echo "To manually apply in other applications:"
echo "  - xed: Preferences -> Theme -> Nordic"
echo "  - VSCode: Already using Nordic via extensions"
echo "  - Tilix: Already using Nord color scheme"
