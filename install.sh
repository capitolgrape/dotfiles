#!/bin/bash
set -e

exec > >(tee -i install.log) 2>&1

./scripts/aur_helper.sh

paru -S --needed --noconfirm - < pkgs

if command -v fish &> /dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
    chsh -s "$(command -v fish)"
fi

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

for dir in niri waybar kitty fish hypr mpv fastfetch zed swww; do
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

"$HOME/.config/swww/wall-apply.sh" "$HOME/Pictures/Wallpapers/wallpaper02.png"

fc-cache -fv

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

if command -v starship &> /dev/null; then
    starship preset pure-preset -o ~/.config/starship.toml
fi

./scripts/ufw.sh
./scripts/fisher.sh
./scripts/auto_cpufreq.sh

sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now paccache.timer
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now ananicy-cpp.service
if command -v tuigreet &> /dev/null; then
    sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd niri-session --remember"
user = "greeter"
EOF
fi

sudo systemctl enable --now greetd.service
echo "[INFO] [install] Dotfiles setup complete."
