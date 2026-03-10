#!/bin/bash
# https://github.com/AdnanHodzic/auto-cpufreq
# https://github.com/ChrisTitusTech/linutil

set -eu

AUTO_CPUFREQ_PATH="$HOME/.local/share/auto-cpufreq"

if ! command -v auto-cpufreq >/dev/null 2>&1; then
    if command -v powerprofilesctl >/dev/null 2>&1; then
        sudo systemctl disable --now power-profiles-daemon
    fi

    mkdir -p "$HOME/.local/share"

    if [ -d "$AUTO_CPUFREQ_PATH" ]; then
        rm -rf "$AUTO_CPUFREQ_PATH"
    fi

    git clone --depth=1 https://github.com/AdnanHodzic/auto-cpufreq.git "$AUTO_CPUFREQ_PATH"
    cd "$AUTO_CPUFREQ_PATH"
    sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
fi

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    sudo auto-cpufreq --force powersave
else
    sudo auto-cpufreq --force performance
fi

echo "auto-cpufreq setup complete."
