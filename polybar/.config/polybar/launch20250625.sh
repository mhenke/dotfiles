#!/usr/bin/env bash

# Enable debug output
set -x

# Clean up any existing symlinks and ensure we're using the right config
CONFIG_PATH="$HOME/.config/polybar/config.ini"

# Verify config exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: Config file not found at $CONFIG_PATH"
    exit 1
fi

# Display config file content type and path
ls -l "$CONFIG_PATH"
file "$CONFIG_PATH"

# Terminate already running polybar instances
killall -q polybar || true

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do 
    sleep 1
done

# Launch polybar with only config.ini
polybar -c "$CONFIG_PATH" example &

echo "Polybar launched..."
