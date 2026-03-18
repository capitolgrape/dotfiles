#!/bin/bash
set -euo pipefail

if ! command -v fish &> /dev/null; then
    echo "[WARN] [fisher] fish shell is not installed; skipping fisher installation."
    exit 0
fi

if ! fish -c "functions -q fisher" 2>/dev/null; then
    echo "[INFO] [fisher] Installing fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
else
    echo "[INFO] [fisher] fisher is already installed."
fi

echo "[INFO] [fisher] Installing plugins..."
fish -c "fisher install franciscolourenco/done jorgebucaran/autopair.fish PatrickF1/fzf.fish nickeb96/puffer-fish"

echo "[INFO] [fisher] fisher and plugins installation complete."
