#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec > >(tee -i "$SCRIPT_DIR/install.log") 2>&1
echo "[INFO] Script directory: $SCRIPT_DIR"

"$SCRIPT_DIR/scripts/aur_helper.sh"

if [ -f "$SCRIPT_DIR/makepkg.conf" ]; then
    mkdir -p "$HOME/.config/pacman"
    cp "$SCRIPT_DIR/makepkg.conf" "$HOME/.config/pacman/makepkg.conf"
fi

paru -S --needed --noconfirm - < "$SCRIPT_DIR/pkgs"

if command -v fish &> /dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
    chsh -s "$(command -v fish)"
fi

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/nvim-lua/kickstart.nvim ~/.config/nvim
fi

for dir in niri waybar ghostty fish hypr mpv fastfetch zed awww systemd paru; do
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

xdg-user-dirs-update

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'date_modified']"
    gsettings set org.gnome.nautilus.preferences click-policy 'double'
    gsettings set org.gtk.Settings.FileChooser sort-directories-first true
    gsettings set org.gnome.nautilus.preferences recursive-search 'always'
    gsettings set org.gnome.nautilus.preferences thumbnail-limit 100
    gsettings set org.gtk.Settings.FileChooser startup-mode 'recent'
fi

if command -v starship &> /dev/null; then
    starship preset pure-preset -o ~/.config/starship.toml
fi

"$SCRIPT_DIR/scripts/ufw.sh"
"$SCRIPT_DIR/scripts/fisher.sh"
"$SCRIPT_DIR/scripts/auto_cpufreq.sh"
"$SCRIPT_DIR/scripts/services.sh"

echo "[INFO] [install] Dotfiles setup complete."
