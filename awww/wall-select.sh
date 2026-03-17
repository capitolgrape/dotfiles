#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/awww"
dir="$HOME/Pictures/Wallpapers"

img="$(
  find "$dir" -type f \( \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.png' -o \
    -iname '*.webp' \
  \) | sort | vicinae dmenu -p 'Pick wallpaper...'
)"

[ -n "${img:-}" ] || exit 0
exec "$CONFIG_DIR/wall-apply.sh" "$img"
