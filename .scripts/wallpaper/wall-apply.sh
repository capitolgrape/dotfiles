#!/usr/bin/env bash
set -euo pipefail

img="${1:-}"
[ -n "$img" ] || exit 1
[ -f "$img" ] || exit 1

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wall"
mkdir -p "$STATE_DIR"

if ! pgrep -x awww-daemon >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
  sleep 0.3
fi

awww img "$img" \
  --transition-type grow \
  --transition-step 180 \
  --transition-fps 60

printf '%s\n' "$img" > "$STATE_DIR/current"
