#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/wallpaper"
dir="$HOME/Pictures/Wallpapers"

[ -d "$dir" ] || exit 0

img="$(
  find "$dir" -type f \( \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.gif' -o \
    -iname '*.png' -o \
    -iname '*.webp' \
  \) | sort | vicinae dmenu -p 'Pick wallpaper...'
)"

[ -n "${img:-}" ] || exit 0
exec "$CONFIG_DIR/wall-apply.sh" "$img"
