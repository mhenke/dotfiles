#!/bin/bash
#
# install-packages.sh - Install system packages
#
# Installs core system packages including i3, polybar, rofi, etc.
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

log_info "Updating package lists..."
sudo apt update

log_info "Installing system dependencies..."
sudo apt install -y \
    software-properties-common \
    apt-transport-https \
    wget \
    curl \
    git \
    build-essential \
    stow

log_info "Installing i3 and related packages..."
sudo apt install -y \
    i3 \
    i3-wm \
    i3status \
    i3lock \
    polybar \
    rofi \
    picom \
    dunst \
    feh \
    scrot \
    maim \
    xclip \
    xdotool \
    arandr \
    lxappearance

log_info "Installing terminal and shell..."
sudo apt install -y \
    tilix \
    zsh \
    fonts-powerline \
    fonts-font-awesome

log_info "Installing system utilities..."
sudo apt install -y \
    htop \
    neofetch \
    tree \
    jq \
    ripgrep \
    fd-find \
    fzf \
    tmux \
    unzip \
    zip \
    p7zip-full

log_info "Installing development tools..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    ruby \
    ruby-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev

log_info "Installing media and fonts..."
sudo apt install -y \
    pavucontrol \
    pulseaudio \
    playerctl \
    fonts-noto-color-emoji \
    fonts-firacode

# Install packages from apt-manual.txt if it exists
PACKAGES_DIR="$(dirname "$0")/../packages"
if [[ -f "$PACKAGES_DIR/apt-manual.txt" ]]; then
    log_info "Installing packages from apt-manual.txt..."
    # Filter out already installed and non-existent packages
    while IFS= read -r package; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            sudo apt install -y "$package" 2>/dev/null || log_info "Skipping $package (not available)"
        fi
    done < "$PACKAGES_DIR/apt-manual.txt"
fi

log_info "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

log_success "System packages installed successfully!"
