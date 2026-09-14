#!/bin/bash
# session-watchdog.sh - guards the two things that died on 2026-09-11:
# 1. hyprlock crashing while holding the session lock -> Hyprland "Oopsie daisy"
#    dead-end screen (upstream: omarchy #5521/#5935, hyprlock #76).
#    Marker protocol: hyprlock-guarded.sh sets $RUNDIR/.watchdog-locked on lock,
#    clears it only on clean unlock (exit 0). Marker + no hyprlock = crashed.
#    Respawn requires misc:allow_session_lock_restore=1 in Hyprland.
# 2. hypridle dying -> no idle events, no lock/DPMS/hibernate.
# State lives under $XDG_RUNTIME_DIR (0700, per-user) — never world-writable.
# No unlock escape hatch: maintenance unlocks by killing this script + hyprlock
# from your own session.
ME="$(id -u)"
RUNDIR="${XDG_RUNTIME_DIR:-/tmp/hypr-watchdog-$ME}"
if ! mkdir -p "$RUNDIR" 2>/dev/null || ! chmod 700 "$RUNDIR" || [ ! -O "$RUNDIR" ]; then
    echo "session-watchdog: unsafe RUNDIR $RUNDIR, refusing to run" >&2
    exit 1
fi
exec 9>"$RUNDIR/watchdog.lock"
flock -n 9 || exit 0  # already running (e.g. Hyprland re-exec re-ran Startup_Apps)
MARKER="$RUNDIR/.watchdog-locked"
LOG="$RUNDIR/session-watchdog.log"
CRASHES=0

while :; do
    if [ -f "$MARKER" ] && [ -O "$MARKER" ] && ! pgrep -x -U "$ME" hyprlock >/dev/null; then
        CRASHES=$((CRASHES + 1))
        if [ "$CRASHES" -gt 5 ]; then
            echo "$(date -Is) hyprlock crash-looping ($CRASHES) -> backing off 5min" >> "$LOG"
            sleep 300
            CRASHES=0
            continue
        fi
        echo "$(date -Is) lock marker but hyprlock dead -> respawning" >> "$LOG"
        setsid nohup "$HOME/.config/hypr/scripts/hyprlock-guarded.sh" >/dev/null 2>&1 < /dev/null 9>&- &
    else
        CRASHES=0
    fi

    if ! pgrep -x -U "$ME" hypridle >/dev/null; then
        echo "$(date -Is) hypridle dead -> restarting via manager" >> "$LOG"
        setsid nohup "$HOME/.config/hypr/scripts/hypridle_manager.sh" >/dev/null 2>&1 < /dev/null 9>&- &
    fi

    sleep 15
done
