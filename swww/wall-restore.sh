#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swww"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/wall/current"

if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  swww-daemon >/dev/null 2>&1 &
  sleep 0.3
fi

[ -f "$STATE_FILE" ] || exit 0
img="$(<"$STATE_FILE")"
[ -f "$img" ] || exit 0

exec "$CONFIG_DIR/wall-apply.sh" "$img"
