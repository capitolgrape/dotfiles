#!/usr/bin/env bash
set -euo pipefail

img="${1:-}"
[ -n "$img" ] || exit 1
[ -f "$img" ] || exit 1

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wall"
MATUGEN_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/matugen/config.toml"
mkdir -p "$STATE_DIR"

if ! pgrep -x awww-daemon >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
  sleep 0.3
fi

awww img "$img" \
  --transition-type grow \
  --transition-step 180 \
  --transition-fps 60

if command -v matugen >/dev/null 2>&1 && [ -f "$MATUGEN_CONFIG" ]; then
  matugen image -c "$MATUGEN_CONFIG" --prefer saturation "$img" || \
    printf 'matugen: failed to generate colors\n' >&2
fi

printf '%s\n' "$img" > "$STATE_DIR/current"
