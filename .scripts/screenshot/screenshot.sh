#!/usr/bin/env bash

set -euo pipefail

mode="${1:-full}"
screenshot_dir="$HOME/Pictures/Screenshots"
file="$screenshot_dir/$(date +%Y-%m-%d_%H-%M-%S).png"

mkdir -p "$screenshot_dir"

if command -v swaync-client >/dev/null 2>&1; then
    swaync-client --skip-wait --close-panel >/dev/null 2>&1 || true
    swaync-client --skip-wait --hide-all >/dev/null 2>&1 || true
    sleep 0.1
fi

case "$mode" in
    full)
        if ! grim "$file"; then
            rm -f "$file"
            exit 1
        fi
        ;;
    area)
        if ! geometry="$(slurp)" || [[ -z "$geometry" ]]; then
            exit 0
        fi

        if ! grim -g "$geometry" "$file"; then
            rm -f "$file"
            exit 1
        fi
        ;;
    active)
        if ! geometry="$(hyprctl activewindow -j | jq -r '.at as $at | .size as $size | "\($at[0]),\($at[1]) \($size[0])x\($size[1])"')" || [[ -z "$geometry" ]]; then
            exit 1
        fi

        if ! grim -g "$geometry" "$file"; then
            rm -f "$file"
            exit 1
        fi
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
notify=(notify-send -a Hyprland -i "$file" -h "string:image-path:$file")

if command -v wl-copy >/dev/null 2>&1 && wl-copy --type image/png < "$file"; then
    "${notify[@]}" "Screenshot copied" "$name"
else
    "${notify[@]}" "Screenshot saved" "$name"
fi
