#!/usr/bin/env bash
# ~/.config/polybar/launch.sh (via symlink to dotfiles)
# Improved polybar launch script with better error handling

# Exit on any error
set -e

# Configuration - Works with symlinks to dotfiles
CONFIG_PATH="$HOME/.config/polybar/config.ini"
LOG_FILE="$HOME/.config/polybar/polybar.log"
SCRIPTS_DIR="$HOME/.config/polybar/scripts"

# Create necessary directories
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$SCRIPTS_DIR"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    for cmd in polybar xrandr; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "ERROR: Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Function to verify config file
verify_config() {
    if [[ ! -f "$CONFIG_PATH" ]]; then
        log "ERROR: Config file not found at $CONFIG_PATH"
        exit 1
    fi
    
    # Test polybar config syntax
    if ! polybar -c "$CONFIG_PATH" -l error &>/dev/null; then
        log "ERROR: Invalid polybar configuration"
        exit 1
    fi
    
    log "Config file verified: $CONFIG_PATH"
}

# Function to create network script if it doesn't exist
create_network_script() {
    local script_path="$SCRIPTS_DIR/network.sh"
    
    if [[ ! -f "$script_path" ]]; then
        log "Creating network script at $script_path"
        
        # You would put the network script content here or copy it
        cat > "$script_path" << 'EOF'
#!/bin/bash
# Basic network status - replace with the full script from the artifact above
INTERFACE=$(ip route | grep '^default' | head -n1 | awk '{print $5}')
if [[ -n "$INTERFACE" ]]; then
    IP=$(ip addr show "$INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    echo "$INTERFACE: $IP"
else
    echo "OFFLINE"
fi
EOF
        chmod +x "$script_path"
    fi
}

# Function to terminate existing polybar instances
terminate_polybar() {
    log "Terminating existing polybar instances..."
    
    # Kill all polybar instances for current user
    pkill -u "$USER" polybar 2>/dev/null || true
    
    # Wait for processes to terminate gracefully
    local timeout=5
    while pgrep -u "$USER" -x polybar >/dev/null && [[ $timeout -gt 0 ]]; do
        sleep 0.5
        ((timeout--))
    done
    
    # Force kill if still running
    if pgrep -u "$USER" -x polybar >/dev/null; then
        log "WARNING: Force killing remaining polybar processes"
        pkill -9 -u "$USER" polybar 2>/dev/null || true
        sleep 1
    fi
    
    log "Polybar instances terminated"
}

# Function to detect monitors
detect_monitors() {
    # Get list of connected monitors
    xrandr --query | grep " connected" | cut -d" " -f1
}

# Function to launch polybar
launch_polybar() {
    local monitors
    mapfile -t monitors < <(detect_monitors)
    
    if [[ ${#monitors[@]} -eq 0 ]]; then
        log "ERROR: No monitors detected"
        exit 1
    fi
    
    log "Detected monitors: ${monitors[*]}"
    
    # Launch polybar on each monitor
    for monitor in "${monitors[@]}"; do
        log "Launching polybar on monitor: $monitor"
        MONITOR="$monitor" polybar -c "$CONFIG_PATH" example >>"$LOG_FILE" 2>&1 &
        
        # Small delay between launches
        sleep 0.1
    done
    
    log "Polybar launched on ${#monitors[@]} monitor(s)"
}

# Function to verify polybar is running
verify_launch() {
    sleep 2
    
    if pgrep -u "$USER" -x polybar >/dev/null; then
        log "SUCCESS: Polybar is running"
        return 0
    else
        log "ERROR: Polybar failed to start"
        return 1
    fi
}

# Main execution
main() {
    log "Starting polybar launch sequence..."
    
    # Run checks
    check_dependencies
    verify_config
    create_network_script
    
    # Launch sequence
    terminate_polybar
    launch_polybar
    
    if verify_launch; then
        log "Polybar launch completed successfully"
    else
        log "Polybar launch failed - check log file: $LOG_FILE"
        exit 1
    fi
}

# Handle script interruption
trap 'log "Launch script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
