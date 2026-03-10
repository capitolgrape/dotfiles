#!/bin/bash

set -e

if ! command -v ufw >/dev/null 2>&1; then
    echo "ufw is not installed. Exiting."
    exit 1
fi

sudo ufw limit 22/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

echo "ufw setup complete."
