#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/wallpaper"
dir="$HOME/Pictures/Wallpapers"

[ -d "$dir" ] || exit 0
command -v vicinae >/dev/null 2>&1 || exit 1

img="$(
  while IFS= read -r -d '' path; do
    [[ "$path" == *$'\n'* ]] || printf '%s\n' "$path"
  done < <(find "$dir" -type f \( \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.gif' -o \
    -iname '*.png' -o \
    -iname '*.webp' \
  \) -print0 | sort -z) | vicinae dmenu -p 'Pick wallpaper...'
)"

[ -n "${img:-}" ] || exit 0
exec "$CONFIG_DIR/wall-apply.sh" "$img"
