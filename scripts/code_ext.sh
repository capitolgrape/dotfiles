#!/bin/bash
set -e


extensions=(
    "github.github-vscode-theme"
    "ritwickdey.liveserver"
    "esbenp.prettier-vscode"
    "ms-python.vscode-pylance"
    "pkief.material-icon-theme"
    "ms-python.black-formatter"
    "ms-vscode.cpptools"
    "ms-python.vscode-python-envs"
    "kdl-org.kdl"
    "kdl-org.kdl-v1"
    "ms-python.debugpy"
    "ms-python.python"
)

for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force
done
