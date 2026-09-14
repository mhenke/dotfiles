#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##

# For Hyprlock
#pidof hyprlock || hyprlock -q 

pidof hyprlock || ~/.config/hypr/scripts/hyprlock-guarded.sh   # guarded: sets watchdog marker, reports clean exit