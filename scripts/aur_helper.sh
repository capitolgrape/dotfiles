#!/bin/bash
set -e

if command -v paru &> /dev/null; then
    echo "paru is already installed."
    exit 0
fi

sudo pacman -S --needed --noconfirm base-devel git

BUILD_DIR=$(mktemp -d)
original_dir=$(pwd)

cleanup() {
    cd "$original_dir" || exit 1
    rm -rf "$BUILD_DIR"
}

trap cleanup EXIT

cd "$BUILD_DIR" || exit 1

git clone https://aur.archlinux.org/paru.git
cd paru || exit 1
makepkg -si --noconfirm

trap - EXIT
cleanup

echo "paru installation completed successfully."
