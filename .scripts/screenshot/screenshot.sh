#!/usr/bin/env bash

set -euo pipefail

mode="${1:-full}"
screenshot_dir="$HOME/Pictures/Screenshots"
file="$screenshot_dir/$(date +%Y-%m-%d_%H-%M-%S).png"

mkdir -p "$screenshot_dir"

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
    *)
        printf 'Usage: %s [full|area]\n' "${0##*/}" >&2
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
