#!/bin/bash
# not using rn
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

echo "[INFO] [code_ext] Installing VS Code extensions..."

install_extension() {
    local ext=$1
    local retries=3
    local count=0

    until code --install-extension "$ext" --force; do
        exit_code=$?
        count=$((count + 1))
        if [ $count -lt $retries ]; then
            echo "[WARN] [code_ext] Failed to install $ext; retrying (attempt $((count + 1)) of $retries)..."
            sleep 2
        else
            echo "[ERROR] [code_ext] Failed to install $ext after $retries attempts."
            return $exit_code
        fi
    done
}

for ext in "${extensions[@]}"; do
    install_extension "$ext" || echo "[WARN] [code_ext] Continuing after failed install: $ext."
done
