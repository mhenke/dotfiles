#!/bin/bash
# Monitor hotplug handler for Hyprland using udev

# Wait a moment for monitors to stabilize
sleep 2

# Run the monitor switch script
"$HOME/.config/hypr/scripts/monitor-switch.sh"
