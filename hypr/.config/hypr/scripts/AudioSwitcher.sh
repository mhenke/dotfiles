#!/bin/bash
# /* ---- 💫 Audio Output Switcher with Rofi 💫 ---- */
# Simple script to switch audio output devices using rofi

# Get list of audio sinks (output devices)
get_sinks() {
    wpctl status | awk '/Sinks:/,/Sources:/' | grep -E "^\s+[0-9]+\." | sed 's/^[[:space:]]*//'
}

# Get current default sink ID
get_default_sink() {
    wpctl status | awk '/Sinks:/,/Sources:/' | grep -E "^\s+[0-9]+\." | grep "\*" | sed 's/^[[:space:]]*//' | awk '{print $1}' | tr -d '.*'
}

# Format sink list for rofi
format_sinks() {
    while read -r line; do
        # Extract ID and name
        id=$(echo "$line" | awk '{print $1}' | tr -d '.*')
        name=$(echo "$line" | sed 's/^[0-9]*\.\s*//' | sed 's/\[.*\]//')

        # Check if this is the default sink
        if echo "$line" | grep -q "\*"; then
            echo "✓ $name|$id"
        else
            echo "  $name|$id"
        fi
    done
}

# Main
main() {
    # Get formatted sink list
    sink_list=$(get_sinks | format_sinks)

    # Show rofi menu
    selected=$(echo "$sink_list" | awk -F'|' '{print $1}' | rofi -dmenu -i -p "Audio Output" -theme-str 'window {width: 400px;}')

    # Exit if nothing selected
    [[ -z "$selected" ]] && exit 0

    # Get the ID of selected sink
    sink_id=$(echo "$sink_list" | grep -F "$selected" | awk -F'|' '{print $2}')

    # Set as default sink
    if [[ -n "$sink_id" ]]; then
        wpctl set-default "$sink_id"

        # Send notification
        device_name=$(echo "$selected" | sed 's/^[[:space:]]*✓//' | sed 's/^[[:space:]]*//')
        notify-send -i audio-card "Audio Output" "Switched to: $device_name"
    fi
}

main
