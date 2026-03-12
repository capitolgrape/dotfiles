#!/bin/bash
# https://github.com/AdnanHodzic/auto-cpufreq
# https://github.com/ChrisTitusTech/linutil

set -eu

if ! command -v auto-cpufreq >/dev/null 2>&1; then
    echo "auto-cpufreq is not installed, skipping."
    exit 0
fi

if command -v powerprofilesctl >/dev/null 2>&1; then
    sudo systemctl disable --now power-profiles-daemon.service
fi

sudo auto-cpufreq --install

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    sudo auto-cpufreq --force powersave
else
    sudo auto-cpufreq --force performance
fi

echo "auto-cpufreq setup complete."
