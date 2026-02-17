#!/bin/bash
set -e

exec > >(tee -i install.log) 2>&1

./scripts/aur_helper.sh

paru -S --needed --noconfirm - < pkgs

if command -v fish &> /dev/null; then
    chsh -s $(which fish)
fi

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

starship preset pure-preset -o ~/.config/starship.toml

./scripts/code_ext.sh

mkdir -p "$HOME/.config/Code/User"
cp "$PWD/code/settings.json" "$HOME/.config/Code/User/settings.json"

for dir in niri waybar kitty fish hypr mpv; do
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

mkdir -p "$HOME/.wallpapers"
cp -r "$PWD/wallpapers/." "$HOME/.wallpapers/"

./scripts/wal-update.sh "$HOME/.wallpapers/mononoke036.jpg"

cp "$PWD/scripts/wal-update.sh" "$HOME/wal-update.sh"
chmod +x "$HOME/wal-update.sh"

fc-cache -fv

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now paccache.timer
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now greetd.service

sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
