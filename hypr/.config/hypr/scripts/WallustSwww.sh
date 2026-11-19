#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Resolve image identity before replacing pointers, including on startup reloads.

current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
cache_file="$HOME/.cache/swww/$current_monitor"
if [ -z "$current_monitor" ] || [ ! -f "$cache_file" ]; then
    echo "No wallpaper cache for the focused monitor" >&2
    exit 1
fi

wallpaper_path=$(grep -v 'Lanczos3' "$cache_file" | head -n 1)
wallpaper_path=$(readlink -f "$wallpaper_path") || exit 1
if [ ! -f "$wallpaper_path" ]; then
    echo "Wallpaper does not exist: $wallpaper_path" >&2
    exit 1
fi

replace_pointer() {
    local pointer="$1" staged
    staged=$(mktemp "$pointer.XXXXXX") || return 1
    if ln -sfn "$wallpaper_path" "$staged" && mv -Tf "$staged" "$pointer"; then
        return 0
    fi
    rm -f "$staged"
    return 1
}

replace_pointer "$HOME/.config/rofi/.current_wallpaper" || exit 1
lock_pointer="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
if [ "$wallpaper_path" != "$lock_pointer" ]; then
    replace_pointer "$lock_pointer" || exit 1
fi

# Curated lock colors must land even if desktop palette generation fails.
python3 "$HOME/dotfiles/sddm-themes/lock-theme.py" "$wallpaper_path" || exit 1
# Use the same backend every time so Wallust can reuse each image's cached palette.
wallust run "$wallpaper_path" -s -b fastresize
