#!/bin/bash
# hyprlock-guarded.sh - hyprlock wrapper with crash marker for session-watchdog.sh.
# Marker $RUNDIR/.watchdog-locked exists while the session SHOULD be locked.
# Cleared ONLY on clean unlock (hyprlock exit 0). Crash/kill leaves it set ->
# watchdog respawns the lock screen (screen stays locked = intended).
# If RUNDIR is unsafe, lock WITHOUT a marker (fail toward locked; watchdog
# just won't respawn this instance).
ME="$(id -u)"
RUNDIR="${XDG_RUNTIME_DIR:-/tmp/hypr-watchdog-$ME}"
MARKER=""
if mkdir -p "$RUNDIR" 2>/dev/null && chmod 700 "$RUNDIR" && [ -O "$RUNDIR" ]; then
    MARKER="$RUNDIR/.watchdog-locked"
    touch "$MARKER"
fi
hyprlock
rc=$?
[ "$rc" -eq 0 ] && [ -n "$MARKER" ] && rm -f "$MARKER"
exit "$rc"
