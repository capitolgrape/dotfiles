#!/usr/bin/env bash
set -euo pipefail

img="${1:-}"
[ -n "$img" ] || exit 1
[ -f "$img" ] || exit 1

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wall"
MATUGEN_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/matugen/config.toml"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$STATE_DIR"

exec 9>"$STATE_DIR/.lock"
flock -x 9

if ! awww query >/dev/null 2>&1; then
  if ! pgrep -x awww-daemon >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
  fi
  for _ in {1..30}; do
    if awww query >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
fi

awww img "$img" \
  --transition-type grow \
  --transition-step 180 \
  --transition-fps 60

if [[ ! -f "$MATUGEN_CONFIG" ]]; then
  printf 'matugen: config not found: %s\n' "$MATUGEN_CONFIG" >&2
  exit 1
fi

if ! command -v matugen >/dev/null 2>&1; then
  printf 'matugen: command not found\n' >&2
  exit 1
fi

if ! matugen image -c "$MATUGEN_CONFIG" --prefer saturation "$img"; then
  printf 'matugen: failed to generate colors\n' >&2
  exit 1
fi

if [[ "$img" == "$WALLPAPER_DIR/"* ]]; then
  stored_img="${img#"$WALLPAPER_DIR/"}"
else
  stored_img="$img"
fi

printf '%s\n' "$stored_img" > "$STATE_DIR/current.tmp.$$"
mv "$STATE_DIR/current.tmp.$$" "$STATE_DIR/current"
