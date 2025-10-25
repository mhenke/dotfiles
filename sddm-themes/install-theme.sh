#!/bin/bash
set -e

echo "=== Installing SDDM Theme Customizations ==="
echo

if [ "$EUID" -ne 0 ]; then
    echo "Re-running with sudo..."
    exec sudo -E bash "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="/usr/share/sddm/themes"

# Determine which theme to install
if [ -n "$1" ]; then
    THEME_NAME="$1"
else
    # List available backed up themes
    echo "Available themes in dotfiles:"
    for dir in "$SCRIPT_DIR"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/configs/theme.conf" ]; then
            basename "$dir"
        fi
    done
    echo
    read -p "Enter theme name (or press Enter for 'simple-sddm'): " THEME_NAME
    THEME_NAME=${THEME_NAME:-simple-sddm}
fi

BACKUP_PATH="$SCRIPT_DIR/$THEME_NAME"
THEME_PATH="$THEMES_DIR/$THEME_NAME"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Error: Theme '$THEME_NAME' not found in dotfiles"
    echo "Available: $(ls -d "$SCRIPT_DIR"/*/ | xargs -n1 basename | tr '\n' ' ')"
    exit 1
fi

# Install base theme if it's simple-sddm and doesn't exist
if [ "$THEME_NAME" = "simple-sddm" ] && [ ! -d "$THEME_PATH" ]; then
    echo "Installing base simple-sddm theme..."
    cd /tmp
    git clone https://github.com/JaKooLit/simple-sddm.git
    cp -r simple-sddm "$THEME_PATH"
    rm -rf simple-sddm
fi

# Create theme directory if needed
if [ ! -d "$THEME_PATH" ]; then
    echo "Creating theme directory: $THEME_PATH"
    mkdir -p "$THEME_PATH"
fi

# Install customizations
echo "Installing $THEME_NAME customizations..."

if [ -d "$BACKUP_PATH/Backgrounds" ]; then
    echo "  - Copying backgrounds..."
    mkdir -p "$THEME_PATH/Backgrounds"
    cp "$BACKUP_PATH/Backgrounds/"*.{png,jpg} "$THEME_PATH/Backgrounds/" 2>/dev/null || true
fi

if [ -d "$BACKUP_PATH/configs" ]; then
    echo "  - Copying theme config..."
    cp "$BACKUP_PATH/configs/"*.conf "$THEME_PATH/" 2>/dev/null || true
fi

echo "  - Setting permissions..."
chown -R $SUDO_USER:$SUDO_USER "$THEME_PATH"

# Configure SDDM to use this theme
echo "  - Configuring SDDM..."
mkdir -p /etc/sddm.conf.d/

if [ -f "$BACKUP_PATH/configs/sddm.conf.d/theme.conf.user" ]; then
    cp "$BACKUP_PATH/configs/sddm.conf.d/theme.conf.user" /etc/sddm.conf.d/
else
    echo "[Theme]
Current=$THEME_NAME" > /etc/sddm.conf.d/theme.conf.user
fi

echo
echo "✓ Theme '$THEME_NAME' installed!"
echo "  Location: $THEME_PATH"
echo "  Config: /etc/sddm.conf.d/theme.conf.user"
echo
echo "Logout to see changes."
