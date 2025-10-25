#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script to install sddm-sequoia theme with wallpaper support

echo "=== Installing SDDM Sequoia Theme ==="
echo

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script needs sudo privileges."
    echo "Please run: sudo $0"
    exit 1
fi

THEME_DIR="/usr/share/sddm/themes/sddm-sequoia"
SDDM_CONF_DIR="/etc/sddm.conf.d"

# Remove existing theme if present
if [ -d "$THEME_DIR" ]; then
    echo "Removing existing sddm-sequoia theme..."
    rm -rf "$THEME_DIR"
fi

# Clone the theme
echo "Cloning sddm-sequoia theme from Codeberg..."
git clone https://codeberg.org/JaKooLit/sddm-sequoia.git "$THEME_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Failed to clone repository. Check your internet connection."
    exit 1
fi

echo "✓ Theme cloned successfully"
echo

# Create SDDM config directory if it doesn't exist
if [ ! -d "$SDDM_CONF_DIR" ]; then
    echo "Creating $SDDM_CONF_DIR directory..."
    mkdir -p "$SDDM_CONF_DIR"
fi

# Set the theme in SDDM config
echo "Configuring SDDM to use sddm-sequoia theme..."
cat > "$SDDM_CONF_DIR/theme.conf.user" << 'EOF'
[Theme]
Current=sddm-sequoia
EOF

echo "✓ SDDM configuration updated"
echo

# Check if theme has a Backgrounds directory and list wallpapers
if [ -d "$THEME_DIR/Backgrounds" ]; then
    echo "Theme Backgrounds folder found. Contents:"
    ls -lh "$THEME_DIR/Backgrounds/"
    echo
fi

# Check for theme.conf
if [ -f "$THEME_DIR/theme.conf" ]; then
    echo "Theme configuration file found at: $THEME_DIR/theme.conf"
    echo "You can customize the theme by editing this file."
    echo
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ SDDM Sequoia theme installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Theme location: $THEME_DIR"
echo "SDDM config: $SDDM_CONF_DIR/theme.conf.user"
echo
echo "To test without logging out:"
echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DIR"
echo
echo "To see the new login screen, logout with SUPER+SHIFT+E"
echo
