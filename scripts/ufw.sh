#!/bin/bash
set -euo pipefail

if ! command -v ufw >/dev/null 2>&1; then
    echo "[ERROR] [ufw] ufw is not installed; firewall setup aborted."
    exit 1
fi

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

echo "[INFO] [ufw] Firewall setup complete."
