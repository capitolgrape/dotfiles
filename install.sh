#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec > >(tee -i "$SCRIPT_DIR/install.log") 2>&1
echo "[INFO] Script directory: $SCRIPT_DIR"

"$SCRIPT_DIR/scripts/aur_helper.sh"

paru -S --needed --noconfirm - < "$SCRIPT_DIR/pkgs"

if [ -f "$SCRIPT_DIR/makepkg.conf" ]; then
    mkdir -p "$HOME/.config/pacman"
    cp "$SCRIPT_DIR/makepkg.conf" "$HOME/.config/pacman/makepkg.conf"
fi

if command -v fish &> /dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
    chsh -s "$(command -v fish)"
fi

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

for dir in niri waybar ghostty fish hypr mpv fastfetch zed awww systemd; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        target="$HOME/.config/$dir"
        if [ ! -d "$target" ]; then
            mkdir -p "$target"
        fi
        cp -r "$SCRIPT_DIR/$dir/." "$target/"
    fi
done

if [ -f "$SCRIPT_DIR/mimeapps.list" ]; then
    cp "$SCRIPT_DIR/mimeapps.list" "$HOME/.config/mimeapps.list"
fi

mkdir -p "$HOME/Pictures/Wallpapers"
cp -r "$SCRIPT_DIR/wallpapers/." "$HOME/Pictures/Wallpapers/"

"$HOME/.config/awww/wall-apply.sh" "$HOME/Pictures/Wallpapers/wallpaper02.png"

fc-cache -fv

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

if command -v starship &> /dev/null; then
    starship preset pure-preset -o ~/.config/starship.toml
fi

"$SCRIPT_DIR/scripts/ufw.sh"
"$SCRIPT_DIR/scripts/fisher.sh"
"$SCRIPT_DIR/scripts/auto_cpufreq.sh"
"$SCRIPT_DIR/scripts/services.sh"

echo "[INFO] [install] Dotfiles setup complete."
