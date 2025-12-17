#!/bin/bash
set -e


if command -v yay &> /dev/null; then
    echo "Yay is already installed."
    exit 0
fi

# if command -v paru &> /dev/null; then
#     echo "Paru is already installed."
#     exit 0
# fi

sudo pacman -S --needed --noconfirm base-devel git

BUILD_DIR=$(mktemp -d)
original_dir=$(pwd)

cd "$BUILD_DIR" || exit 1

# git clone https://aur.archlinux.org/paru.git
# cd paru || exit 1
#
# makepkg -si --noconfirm

git clone https://aur.archlinux.org/yay.git
cd yay || exit 1
makepkg -si --noconfirm

cd "$original_dir"
rm -rf "$BUILD_DIR"

echo "Yay installation completed successfully."
