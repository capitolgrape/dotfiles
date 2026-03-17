#!/usr/bin/env bash
set -euo pipefail

img="${1:-}"
[ -n "$img" ] || exit 1
[ -f "$img" ] || exit 1

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wall"
TEMPLATE_SOURCE="$HOME/.config/waybar/colors-waybar.css"
TEMPLATE_DIR="$HOME/.config/wal/templates"
TEMPLATE_DEST="$TEMPLATE_DIR/colors-waybar.css"

mkdir -p "$STATE_DIR"
mkdir -p "$TEMPLATE_DIR"

if ! pgrep -x awww-daemon >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
  sleep 0.3
fi

awww img "$img" \
  --transition-type grow \
  --transition-step 180 \
  --transition-fps 60

ln -sf "$TEMPLATE_SOURCE" "$TEMPLATE_DEST"
wal -i "$img" >/dev/null 2>&1 || true

printf '%s\n' "$img" > "$STATE_DIR/current"

pkill -x waybar 2>/dev/null || true
nohup waybar >/dev/null 2>&1 &
