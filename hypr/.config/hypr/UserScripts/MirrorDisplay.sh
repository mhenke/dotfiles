#!/bin/bash
# Script to toggle mirroring for presentations in Hyprland

# Get the name of the laptop display
LAPTOP_DISPLAY=$(hyprctl monitors | grep "Monitor" | awk '{print $2}' | grep "eDP")

if [ -z "$LAPTOP_DISPLAY" ]; then
    LAPTOP_DISPLAY="eDP-1" # Fallback if not detected
fi

# Get all connected monitors (even if not currently active in Hyprland layout)
# We use hyprctl monitors all to see everything
EXTERNAL_MONITOR=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}' | grep -v "$LAPTOP_DISPLAY" | head -n 1)

if [ -z "$EXTERNAL_MONITOR" ]; then
    notify-send "Mirror Toggle" "No external monitor detected." -i dialog-warning
    exit 1
fi

# Check if mirroring is currently active
# We check if the external monitor's config contains "mirror"
IS_MIRRORED=$(hyprctl monitors | grep -A 2 "$EXTERNAL_MONITOR" | grep "mirror")

if [ -n "$IS_MIRRORED" ]; then
    # Currently mirroring, switch to extended (preferred, auto position)
    hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, auto, 1"
    notify-send "Mirror Toggle" "Switched to Extended Mode ($EXTERNAL_MONITOR)" -i display
else
    # Currently extended, switch to mirroring
    hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, auto, 1, mirror, $LAPTOP_DISPLAY"
    notify-send "Mirror Toggle" "Switched to Mirror Mode ($EXTERNAL_MONITOR -> $LAPTOP_DISPLAY)" -i display
fi
