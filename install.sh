#!/bin/bash

exec > >(tee -i install.log) 2>&1

./scripts/install_paru.sh

paru -S --needed --noconfirm - < pkgs

if command -v fish &> /dev/null; then
    chsh -s $(which fish)
fi

curl -sS https://starship.rs/install.sh | sh

starship preset pure-preset -o ~/.config/starship.toml

./scripts/code_ext.sh

mkdir -p "$HOME/.config/Code/User"
cp "$PWD/code/settings.json" "$HOME/.config/Code/User/settings.json"


for dir in niri waybar kitty fish hypr; do
    if [ -d "$dir" ]; then
        cp -r "$PWD/$dir" "$HOME/.config/"
    fi
done

fc-cache -fv

sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now ly.service