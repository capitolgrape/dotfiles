#!/bin/bash
# https://github.com/AdnanHodzic/auto-cpufreq
# https://github.com/ChrisTitusTech/linutil

set -euo pipefail

if ! command -v auto-cpufreq >/dev/null 2>&1; then
    echo "[WARN] [auto_cpufreq] auto-cpufreq is not installed; skipping setup."
    exit 0
fi

if command -v powerprofilesctl >/dev/null 2>&1; then
    sudo systemctl disable --now power-profiles-daemon.service
fi

install_output=$(sudo auto-cpufreq --install 2>&1) || true
if echo "$install_output" | grep -q "running in daemon mode"; then
    echo "[INFO] [auto_cpufreq] auto-cpufreq daemon is already running; skipping install."
else
    echo "$install_output"
fi

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    sudo auto-cpufreq --force powersave
else
    sudo auto-cpufreq --force performance
fi

echo "[INFO] [auto_cpufreq] auto-cpufreq setup complete."
