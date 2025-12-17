#!/bin/bash

TEMPLATE_SOURCE="$(pwd)/colors-waybar.css"
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

echo "Done. Colors generated in ~/.cache/wal/colors-waybar.css"
echo "You may need to reload Waybar: 'pkill waybar && waybar &'"
