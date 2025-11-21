#!/bin/bash

# Kill any existing hypridle processes
killall hypridle 2>/dev/null

# Check if on battery or AC power
if cat /sys/class/power_supply/ADP0/online 2>/dev/null | grep -q "1"; then
    # Plugged in
    hypridle -c ~/.config/hypr/hypridle_ac.conf &
else
    # On battery
    hypridle -c ~/.config/hypr/hypridle_battery.conf &
fi
