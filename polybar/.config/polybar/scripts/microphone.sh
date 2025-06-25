#!/bin/bash
# ~/.config/polybar/scripts/microphone.sh
# Microphone control script for polybar

# Colors (matching polybar config)
PRIMARY="#88C0D0"
ALERT="#BF616A"
DISABLED="#4C566A"

# Get default source (microphone)
get_default_source() {
    pactl info | grep "Default Source" | cut -d' ' -f3
}

# Get microphone volume
get_mic_volume() {
    local source=$(get_default_source)
    if [[ -n "$source" ]]; then
        pactl list sources | grep -A 10 "Name: $source" | grep "Volume:" | head -1 | awk '{print $5}' | sed 's/%//'
    else
        echo "0"
    fi
}

# Check if microphone is muted
is_mic_muted() {
    local source=$(get_default_source)
    if [[ -n "$source" ]]; then
        pactl list sources | grep -A 10 "Name: $source" | grep "Mute:" | awk '{print $2}'
    else
        echo "yes"
    fi
}

# Toggle microphone mute
toggle_mic() {
    local source=$(get_default_source)
    if [[ -n "$source" ]]; then
        pactl set-source-mute "$source" toggle
    fi
}

# Increase microphone volume
increase_volume() {
    local source=$(get_default_source)
    if [[ -n "$source" ]]; then
        pactl set-source-volume "$source" +5%
    fi
}

# Decrease microphone volume
decrease_volume() {
    local source=$(get_default_source)
    if [[ -n "$source" ]]; then
        pactl set-source-volume "$source" -5%
    fi
}

# Display microphone status
display_status() {
    local volume=$(get_mic_volume)
    local muted=$(is_mic_muted)
    
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
        toggle_mic
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
