#!/bin/bash
set -e


TEMPLATE_SOURCE="$HOME/.config/waybar/colors-waybar.css"
TEMPLATE_DIR="$HOME/.config/wal/templates"
TEMPLATE_DEST="$TEMPLATE_DIR/colors-waybar.css"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Creating directory: $TEMPLATE_DIR"
    mkdir -p "$TEMPLATE_DIR"
fi

echo "Linking template to $TEMPLATE_DEST..."
ln -sf "$TEMPLATE_SOURCE" "$TEMPLATE_DEST"

if [ -z "$1" ]; then
    echo "No image provided. Running wal -R to restore last colors..."
    wal -R
else
    echo "Generating colors from image: $1"
    wal -i "$1"
fi