#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script to set SDDM login screen wallpaper
# Best practice: Copy to theme Backgrounds folder + use theme.conf.user

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THEME_DIR="/usr/share/sddm/themes/simple-sddm"
THEME_BG_DIR="$THEME_DIR/Backgrounds"
THEME_CONF_USER="$THEME_DIR/theme.conf.user"

echo "=== SDDM Wallpaper Setter ==="
echo

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script needs sudo privileges."
    echo "Please run: sudo $0"
    exit 1
fi

# Get the real user (when running with sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo ~$REAL_USER)
WALLPAPER_DIR="$REAL_HOME/Pictures/wallpapers"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "❌ Error: Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Get a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

if [ -z "$RANDOM_WALLPAPER" ]; then
    echo "❌ Error: No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

WALLPAPER_NAME=$(basename "$RANDOM_WALLPAPER")
WALLPAPER_EXT="${WALLPAPER_NAME##*.}"

echo "✓ Selected wallpaper: $WALLPAPER_NAME"
echo

# Copy wallpaper to theme Backgrounds directory (accessible to SDDM)
echo "Copying wallpaper to SDDM theme directory..."
cp "$RANDOM_WALLPAPER" "$THEME_BG_DIR/custom-wallpaper.$WALLPAPER_EXT"
chmod 644 "$THEME_BG_DIR/custom-wallpaper.$WALLPAPER_EXT"

echo "✓ Wallpaper copied to theme directory"
echo

# Create/update theme.conf.user to use the custom wallpaper
# Using relative path as per simple-sddm documentation
echo "Updating theme configuration..."
cat > "$THEME_CONF_USER" << EOF
[General]
Background="Backgrounds/custom-wallpaper.$WALLPAPER_EXT"
EOF

chmod 644 "$THEME_CONF_USER"

echo "✓ Theme configuration updated"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ SDDM wallpaper configured successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Wallpaper: $WALLPAPER_NAME"
echo "Location: $THEME_BG_DIR/custom-wallpaper.$WALLPAPER_EXT"
echo "Config: theme.conf.user (upgrade-safe)"
echo
echo "The new login screen will appear on your next logout/reboot."
echo "To test: Press SUPER+SHIFT+E and logout"
echo
echo "To change wallpaper again, run: sudo $0"
echo
