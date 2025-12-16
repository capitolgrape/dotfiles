#!/bin/bash
./scripts/install_paru.sh
sleep 2
clear
paru -S --needed --noconfirm - < pkgs
