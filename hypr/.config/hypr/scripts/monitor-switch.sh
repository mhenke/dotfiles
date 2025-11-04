#!/bin/bash
# Automatic monitor configuration switcher for Hyprland

MONITORS_DIR="$HOME/.config/hypr"
DOCKED_MONITORS="$MONITORS_DIR/monitors-docked.conf"
DOCKED_WORKSPACES="$MONITORS_DIR/workspaces-docked.conf"
LAPTOP_MONITORS="$MONITORS_DIR/monitors-laptop.conf"
LAPTOP_WORKSPACES="$MONITORS_DIR/workspaces-laptop.conf"
ACTIVE_MONITORS="$MONITORS_DIR/monitors.conf"
ACTIVE_WORKSPACES="$MONITORS_DIR/workspaces.conf"

# Check if external monitors are connected (count DP- monitors, excluding laptop eDP)
DP_COUNT=$(hyprctl monitors | grep -c "^Monitor DP-")
if [ "$DP_COUNT" -ge 2 ]; then
    # Docked mode: 2+ external monitors connected
    if [ -f "$DOCKED_MONITORS" ] && [ -f "$DOCKED_WORKSPACES" ]; then
        cp "$DOCKED_MONITORS" "$ACTIVE_MONITORS"
        cp "$DOCKED_WORKSPACES" "$ACTIVE_WORKSPACES"
        hyprctl reload
        notify-send "Monitor Setup" "Switched to dual monitor mode" -t 3000
    fi
else
    # Laptop mode: no external monitors
    if [ -f "$LAPTOP_MONITORS" ] && [ -f "$LAPTOP_WORKSPACES" ]; then
        cp "$LAPTOP_MONITORS" "$ACTIVE_MONITORS"
        cp "$LAPTOP_WORKSPACES" "$ACTIVE_WORKSPACES"
        hyprctl reload
        notify-send "Monitor Setup" "Switched to laptop mode" -t 3000
    fi
fi
