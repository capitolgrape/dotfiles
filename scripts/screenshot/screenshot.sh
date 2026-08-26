#!/usr/bin/env bash

set -euo pipefail

mode="${1:-full}"
screenshot_dir="${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"
file="$screenshot_dir/$(date +%Y-%m-%d_%H-%M-%S-%N).png"

mkdir -p "$screenshot_dir"

case "$mode" in
    full)
        grim "$file"
        ;;
    area)
        geometry="$(slurp)" || exit 0
        [[ -n "$geometry" ]] || exit 0
        grim -g "$geometry" "$file"
        ;;
    active)
        geometry="$(hyprctl activewindow -j | jq -er '
            select(.at != null and .size != null)
            | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
        ')" || exit 1

        [[ -n "$geometry" ]] || exit 1
        grim -g "$geometry" "$file"
        ;;
    *)
        printf 'Usage: %s [full|area|active]\n' "${0##*/}" >&2
        exit 2
        ;;
esac

if [[ ! -s "$file" ]]; then
    rm -f "$file"
    exit 1
fi

name="${file##*/}"

copied=false
if command -v wl-copy >/dev/null 2>&1 && wl-copy --type image/png < "$file"; then
    copied=true
fi

if command -v notify-send >/dev/null 2>&1; then
    if [[ "$copied" == true ]]; then
        notify-send -a Hyprland -i "$file" -h "string:image-path:$file" \
            "Screenshot saved and copied" "$name"
    else
        notify-send -a Hyprland -i "$file" -h "string:image-path:$file" \
            "Screenshot saved" "$name"
    fi
fi
