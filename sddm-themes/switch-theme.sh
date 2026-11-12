#!/bin/bash
#
# SDDM Theme Switcher
# Switches between custom theme configurations for simple-sddm
#

THEME_DIR="/usr/share/sddm/themes/simple-sddm"
# Get the actual user's home directory (works with sudo)
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi
DOTFILES_DIR="$USER_HOME/dotfiles/sddm-themes/simple-sddm"
CONFIGS_DIR="$DOTFILES_DIR/configs"
BACKGROUNDS_DIR="$DOTFILES_DIR/Backgrounds"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for --list or -l flag (doesn't require sudo)
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    echo -e "${BLUE}Available SDDM Themes:${NC}"
    echo
    i=1
    for config in "$CONFIGS_DIR"/theme-*.conf; do
        if [ -f "$config" ]; then
            theme_basename=$(basename "$config" .conf)
            theme_name=${theme_basename#theme-}
            header=$(grep "^HeaderText=" "$config" | cut -d'"' -f2)
            bg=$(grep "^Background=" "$config" | cut -d'"' -f2 | sed 's|Backgrounds/||')
            accent=$(grep "^AccentColor=" "$config" | cut -d'"' -f2)
            main=$(grep "^MainColor=" "$config" | cut -d'"' -f2)
            echo -e "  ${GREEN}$i${NC}. ${YELLOW}$theme_name${NC}"
            echo "     Header: \"$header\""
            echo "     Background: $bg"
            echo "     Colors: Main=$main, Accent=$accent"
            echo
            ((i++))
        fi
    done
    echo -e "${BLUE}Usage:${NC} sudo ./switch-theme.sh [theme-name]"
    exit 0
fi

# Rofi menu (no sudo): pick a variant, then apply it in a terminal so sudo can prompt.
# Items read "HEADER (slug)": the header is what you recognise, the slug is the identifier.
list_items() {
    local config name header
    for config in "$CONFIGS_DIR"/theme-*.conf; do
        [ -f "$config" ] || continue
        name=$(basename "$config" .conf)
        name=${name#theme-}
        header=$(grep "^HeaderText=" "$config" | cut -d'"' -f2)
        printf '%s (%s)\n' "$header" "$name"
    done
}

if [ "$1" = "--items" ]; then
    list_items
    exit 0
fi

if [ "$1" = "--menu" ]; then
    choice=$(list_items | rofi -dmenu -i -p "SDDM login theme") || exit 0
    [ -n "$choice" ] || exit 0
    theme_name=${choice##*\(}
    theme_name=${theme_name%\)}

    # honour the terminal declared in the Hyprland user defaults, as the upstream menus do
    terminal=$(grep -E '^\$term *=' "$USER_HOME/.config/hypr/UserConfigs/01-UserDefaults.conf" 2>/dev/null | sed 's/.*= *//; s/ *#.*//')
    script=$(readlink -f "$0")
    # the terminal closes when the command returns, so report both outcomes
    exec "${terminal:-ghostty}" -e bash -c "if sudo '$script' '$theme_name'; then '$script' --desktop '$theme_name' && notify-send -i '$HOME/.config/swaync/images/ja.png' SDDM 'Login + desktop: $theme_name' || notify-send -i '$HOME/.config/swaync/images/ja.png' SDDM 'Login screen: $theme_name (no desktop image)'; else notify-send -u critical SDDM 'Login theme switch failed'; fi"
fi

# Desktop side of the same look (no sudo): paint the variant's own image, recolor, repoint the lock screen.
if [ "$1" = "--desktop" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 --desktop <theme-name>"
        exit 1
    fi
    if [ "$EUID" -eq 0 ]; then
        echo "Error: run --desktop as your user, not with sudo (it talks to your swww daemon)"
        exit 1
    fi
    config="$CONFIGS_DIR/theme-$2.conf"
    if [ ! -f "$config" ]; then
        echo "Unknown theme: $2"
        exit 1
    fi
    image=$(grep "^Background=" "$config" | cut -d'"' -f2 | sed 's|Backgrounds/||')
    # prefer the curated copy, fall back to the theme's own background (same picture, LFS-managed)
    wallpaper=$(find "$USER_HOME/Pictures/wallpapers" -maxdepth 2 -name "$image" -print -quit)
    if [ -z "$wallpaper" ]; then
        wallpaper="$BACKGROUNDS_DIR/$image"
    fi
    if [ ! -f "$wallpaper" ]; then
        echo "No image for $image in ~/Pictures/wallpapers or $BACKGROUNDS_DIR — login screen only."
        exit 1
    fi
    monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    swww query > /dev/null 2>&1 || { swww-daemon --format xrgb & sleep 1; }
    swww img -o "$monitor" "$wallpaper" --transition-fps 30 --transition-type any --transition-duration 1 --transition-bezier .43,1.19,1,.4
    "$USER_HOME/.config/hypr/scripts/WallustSwww.sh"
    echo "Desktop wallpaper: $wallpaper"
    exit 0
fi

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: sudo $0 [theme-name]"
    echo "       $0 --list    (view available themes, no sudo required)"
    exit 1
fi

# Function to list available themes
list_themes() {
    echo -e "${BLUE}Available themes:${NC}"
    echo
    local i=1
    for config in "$CONFIGS_DIR"/theme-*.conf; do
        if [ -f "$config" ]; then
            local basename=$(basename "$config" .conf)
            local theme_name=${basename#theme-}
            local header=$(grep "^HeaderText=" "$config" | cut -d'"' -f2)
            local bg=$(grep "^Background=" "$config" | cut -d'"' -f2 | sed 's|Backgrounds/||')
            echo -e "  ${GREEN}$i${NC}. ${YELLOW}$theme_name${NC}"
            echo "     Header: $header"
            echo "     Background: $bg"
            echo
            ((i++))
        fi
    done
}

# Function to apply theme
apply_theme() {
    local theme_name="$1"
    local config_file="$CONFIGS_DIR/theme-${theme_name}.conf"

    if [ ! -f "$config_file" ]; then
        echo -e "${RED}Error: Theme '${theme_name}' not found${NC}"
        echo
        echo -e "${YELLOW}Available themes:${NC}"
        for config in "$CONFIGS_DIR"/theme-*.conf; do
            if [ -f "$config" ]; then
                local basename=$(basename "$config" .conf)
                local name=${basename#theme-}
                echo -e "  - ${GREEN}$name${NC}"
            fi
        done
        echo
        echo -e "${BLUE}Tip:${NC} Run './switch-theme.sh --list' to see all available themes with details"
        exit 1
    fi

    echo -e "${BLUE}Applying theme: ${YELLOW}$theme_name${NC}"

    # Check if background image exists
    local bg_file=$(grep "^Background=" "$config_file" | cut -d'"' -f2)
    local bg_basename=$(basename "$bg_file")

    if [ ! -f "$THEME_DIR/$bg_file" ]; then
        echo -e "${YELLOW}Warning: Background not found in theme directory: $bg_file${NC}"
        if [ -f "$BACKGROUNDS_DIR/$bg_basename" ]; then
            echo -e "${BLUE}Copying background from dotfiles...${NC}"
            cp "$BACKGROUNDS_DIR/$bg_basename" "$THEME_DIR/Backgrounds/"
            chown root:root "$THEME_DIR/Backgrounds/$bg_basename"
            chmod 644 "$THEME_DIR/Backgrounds/$bg_basename"
            echo -e "${GREEN}✓ Background copied${NC}"
        else
            echo -e "${RED}Error: Background not found in dotfiles either!${NC}"
            exit 1
        fi
    fi

    # Backup current theme.conf
    if [ -f "$THEME_DIR/theme.conf" ]; then
        cp "$THEME_DIR/theme.conf" "$THEME_DIR/theme.conf.backup"
        echo -e "${BLUE}Backed up current theme to theme.conf.backup${NC}"
    fi

    # Copy new config
    cp "$config_file" "$THEME_DIR/theme.conf"
    chown root:root "$THEME_DIR/theme.conf"
    chmod 644 "$THEME_DIR/theme.conf"

    # Also update the dotfiles default
    cp "$config_file" "$CONFIGS_DIR/theme.conf"

    echo -e "${GREEN}✓ Theme applied successfully!${NC}"
    echo -e "${BLUE}The new theme will appear on next login/logout${NC}"

    if [ -n "$SUDO_USER" ]; then
        bg_image=$(grep "^Background=" "$config_file" | cut -d'"' -f2 | sed 's|Backgrounds/||')
        if [ -f "$USER_HOME/Pictures/wallpapers/$bg_image" ] || [ -f "$BACKGROUNDS_DIR/$bg_image" ]; then
            echo -e "${YELLOW}Desktop wallpaper unchanged — run as $SUDO_USER:${NC} $0 --desktop ${theme_name}"
        else
            echo -e "${YELLOW}Desktop wallpaper unchanged — no $bg_image to use${NC}"
        fi
    fi
}

# Main script
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     SDDM Theme Switcher              ║${NC}"
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo

# If theme name provided as argument
if [ -n "$1" ]; then
    apply_theme "$1"
    exit 0
fi

# Interactive mode
list_themes

echo -e "${BLUE}Select a theme number or enter theme name:${NC}"
read -r selection

# Check if selection is a number
if [[ "$selection" =~ ^[0-9]+$ ]]; then
    # Get theme name from number
    theme_count=0
    for config in "$CONFIGS_DIR"/theme-*.conf; do
        if [ -f "$config" ]; then
            ((theme_count++))
            if [ "$theme_count" -eq "$selection" ]; then
                basename=$(basename "$config" .conf)
                theme_name=${basename#theme-}
                apply_theme "$theme_name"
                exit 0
            fi
        fi
    done
    echo -e "${RED}Error: Invalid selection number${NC}"
    exit 1
else
    # Assume it's a theme name
    apply_theme "$selection"
fi
