#!/bin/bash
set -Eeuo pipefail

exec > >(tee -i install.log) 2>&1

./scripts/aur_helper.sh

paru -S --needed --noconfirm - < pkgs

if [ -f "$PWD/makepkg.conf" ]; then
    mkdir -p "$HOME/.config/pacman"
    cp "$PWD/makepkg.conf" "$HOME/.config/pacman/makepkg.conf"
fi

if command -v fish &> /dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
    chsh -s "$(command -v fish)"
fi

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

for dir in niri waybar ghostty fish hypr mpv fastfetch zed awww systemd; do
    if [ -d "$dir" ]; then
        target="$HOME/.config/$dir"
        if [ ! -d "$target" ]; then
            mkdir -p "$target"
        fi
        cp -r "$PWD/$dir/." "$target/"
    fi
done

if [ -f "$PWD/mimeapps.list" ]; then
    cp "$PWD/mimeapps.list" "$HOME/.config/mimeapps.list"
fi

mkdir -p "$HOME/Pictures/Wallpapers"
cp -r "$PWD/wallpapers/." "$HOME/Pictures/Wallpapers/"

"$HOME/.config/awww/wall-apply.sh" "$HOME/Pictures/Wallpapers/wallpaper02.png"

fc-cache -fv

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

if command -v starship &> /dev/null; then
    starship preset pure-preset -o ~/.config/starship.toml
fi

./scripts/ufw.sh
./scripts/fisher.sh
./scripts/auto_cpufreq.sh
./scripts/services.sh

echo "[INFO] [install] Dotfiles setup complete."
