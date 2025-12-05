#!/bin/bash
#
# SDDM Theme Switcher
# Switches between custom theme configurations for simple-sddm
#

THEME_DIR="/usr/share/sddm/themes/simple-sddm"
DOTFILES_DIR="$HOME/dotfiles/sddm-themes/simple-sddm"
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
    CONFIGS_DIR="$HOME/dotfiles/sddm-themes/simple-sddm/configs"
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
