#!/bin/bash
# ~/.config/polybar/scripts/network.sh (via symlink to dotfiles)
# Auto-detect and display network status

# Colors (matching polybar config)
PRIMARY="#88C0D0"
DISABLED="#4C566A"
ALERT="#BF616A"

# Function to get active network interface
get_active_interface() {
    # Get the interface with a default route
    ip route | grep '^default' | head -n1 | awk '{print $5}'
}

# Function to check if interface is wireless
is_wireless() {
    local interface=$1
    [[ -d "/sys/class/net/$interface/wireless" ]]
}

# Function to get network speed
get_speed() {
    local interface=$1
    if [[ -f "/sys/class/net/$interface/statistics/rx_bytes" ]]; then
        local rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
        local tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
        
        # Store previous values
        local prev_file="/tmp/polybar_net_${interface}"
        local current_time=$(date +%s)
        
        if [[ -f "$prev_file" ]]; then
            local prev_data=$(cat "$prev_file")
            local prev_time=$(echo "$prev_data" | cut -d' ' -f1)
            local prev_rx=$(echo "$prev_data" | cut -d' ' -f2)
            local prev_tx=$(echo "$prev_data" | cut -d' ' -f3)
            
            local time_diff=$((current_time - prev_time))
            if [[ $time_diff -gt 0 ]]; then
                local rx_rate=$(( (rx_bytes - prev_rx) / time_diff ))
                local tx_rate=$(( (tx_bytes - prev_tx) / time_diff ))
                
                # Convert to human readable
                local rx_human=$(numfmt --to=iec-i --suffix=B/s $rx_rate 2>/dev/null || echo "${rx_rate}B/s")
                local tx_human=$(numfmt --to=iec-i --suffix=B/s $tx_rate 2>/dev/null || echo "${tx_rate}B/s")
                
                echo " ↓$rx_human ↑$tx_human"
            fi
        fi
        
        # Store current values
        echo "$current_time $rx_bytes $tx_bytes" > "$prev_file"
    fi
}

# Main logic
INTERFACE=$(get_active_interface)

if [[ -z "$INTERFACE" ]]; then
    echo "%{F$ALERT}OFFLINE%{F-}"
    exit 0
fi

if is_wireless "$INTERFACE"; then
    # Wireless interface
    ESSID=$(iwgetid -r "$INTERFACE" 2>/dev/null)
    if [[ -n "$ESSID" ]]; then
        SIGNAL=$(grep "^\s*$INTERFACE:" /proc/net/wireless | awk '{print int($3 * 100 / 70)}')
        IP=$(ip addr show "$INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        SPEED=$(get_speed "$INTERFACE")
        echo "%{F$PRIMARY}📶%{F-} $ESSID ($SIGNAL%) $IP$SPEED"
    else
        echo "%{F$DISABLED}📶 Disconnected%{F-}"
    fi
else
    # Wired interface
    if [[ $(cat "/sys/class/net/$INTERFACE/operstate" 2>/dev/null) == "up" ]]; then
        IP=$(ip addr show "$INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        SPEED=$(get_speed "$INTERFACE")
        echo "%{F$PRIMARY}🌐%{F-} $IP$SPEED"
    else
        echo "%{F$DISABLED}🌐 Disconnected%{F-}"
    fi
fi
