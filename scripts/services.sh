#!/bin/bash
set -euo pipefail

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

systemctl --user daemon-reload
systemctl --user add-wants niri.service waybar.service
systemctl --user add-wants niri.service swaync.service
systemctl --user add-wants niri.service swayidle.service

sudo systemctl enable --now greetd.service

echo "[INFO] [services] Services enabled and started."
