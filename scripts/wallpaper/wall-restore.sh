#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/wall/current"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/wallpaper"

[ -f "$STATE_FILE" ] || exit 0

stored_img="$(<"$STATE_FILE")"
if [[ "$stored_img" = /* ]]; then
  img="$stored_img"
else
  img="$HOME/Pictures/Wallpapers/$stored_img"
fi

[ -f "$img" ] || exit 0

exec "$CONFIG_DIR/wall-apply.sh" "$img"
