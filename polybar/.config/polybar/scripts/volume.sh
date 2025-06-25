#!/bin/bash
# ~/.config/polybar/scripts/volume.sh
# Volume control script for polybar

# Colors (matching polybar config)
PRIMARY="#88C0D0"
ALERT="#BF616A"
DISABLED="#4C566A"

# Get default sink (speakers/headphones)
get_default_sink() {
    pactl info | grep "Default Sink" | cut -d' ' -f3
}

# Get volume percentage
get_volume() {
    local sink=$(get_default_sink)
    if [[ -n "$sink" ]]; then
        pactl list sinks | grep -A 15 "Name: $sink" | grep "Volume:" | head -1 | awk '{print $5}' | sed 's/%//'
    else
        echo "0"
    fi
}

# Check if volume is muted
is_muted() {
    local sink=$(get_default_sink)
    if [[ -n "$sink" ]]; then
        pactl list sinks | grep -A 15 "Name: $sink" | grep "Mute:" | awk '{print $2}'
    else
        echo "yes"
    fi
}

# Toggle mute
toggle_mute() {
    local sink=$(get_default_sink)
    if [[ -n "$sink" ]]; then
        pactl set-sink-mute "$sink" toggle
    fi
}

# Increase volume
increase_volume() {
    local sink=$(get_default_sink)
    if [[ -n "$sink" ]]; then
        pactl set-sink-volume "$sink" +5%
    fi
}

# Decrease volume
decrease_volume() {
    local sink=$(get_default_sink)
    if [[ -n "$sink" ]]; then
        pactl set-sink-volume "$sink" -5%
    fi
}

# Display volume status
display_status() {
    local volume=$(get_volume)
    local muted=$(is_muted)
    
    if [[ "$muted" == "yes" ]]; then
        echo "%{F$ALERT}MUTED%{F-}"
    else
        if [[ $volume -gt 0 ]]; then
            echo "%{F$PRIMARY}${volume}%%{F-}"
        else
            echo "%{F$DISABLED}0%%{F-}"
        fi
    fi
}

# Handle command line arguments
case "$1" in
    --toggle)
        toggle_mute
        ;;
    --increase)
        increase_volume
        ;;
    --decrease)
        decrease_volume
        ;;
    *)
        display_status
        ;;
esac
