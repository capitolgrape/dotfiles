#!/bin/bash

exec > >(tee -i install.log) 2>&1

./scripts/install_paru.sh

paru -S --needed --noconfirm - < pkgs

curl -sS https://starship.rs/install.sh | sh

./scripts/code_ext.sh

mkdir -p "$HOME/.config/Code/User"
cp "$PWD/code/settings.json" "$HOME/.config/Code/User/settings.json"


for dir in niri waybar kitty fish hypr; do
    if [ -d "$dir" ]; then
        cp -r "$PWD/$dir" "$HOME/.config/"
    fi
done

starship preset pure-preset -o ~/.config/starship.toml

if command -v fish &> /dev/null; then
    chsh -s $(which fish)
fi

sudo systemctl enable --now bluetooth.service

fc-cache -fv