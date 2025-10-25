#!/bin/bash
set -e

echo "Installing SDDM Theme Customizations"

if [ "$EUID" -ne 0 ]; then
    echo "Re-running with sudo..."
    exec sudo -E bash "$0" "$@"
fi

THEME_DIR="/usr/share/sddm/themes/simple-sddm"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install base theme if needed
if [ ! -d "$THEME_DIR" ]; then
    echo "Installing base theme..."
    cd /tmp
    git clone https://github.com/JaKooLit/simple-sddm.git
    cp -r simple-sddm "$THEME_DIR"
    rm -rf simple-sddm
fi

echo "Applying customizations..."
cp "$SCRIPT_DIR/simple-sddm/Backgrounds/"*.png "$THEME_DIR/Backgrounds/"
cp "$SCRIPT_DIR/simple-sddm/configs/theme.conf" "$THEME_DIR/"
chown -R $SUDO_USER:$SUDO_USER "$THEME_DIR"

echo "Configuring SDDM..."
mkdir -p /etc/sddm.conf.d/
cp "$SCRIPT_DIR/simple-sddm/configs/sddm.conf.d/theme.conf.user" /etc/sddm.conf.d/

echo "✓ Done! Logout to see changes."
