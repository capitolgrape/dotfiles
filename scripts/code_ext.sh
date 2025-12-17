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

echo "Installing extensions..."

install_extension() {
    local ext=$1
    local retries=3
    local count=0

    until code --install-extension "$ext" --force; do
        exit_code=$?
        count=$((count + 1))
        if [ $count -lt $retries ]; then
            echo "Failed to install $ext. Retrying ($count/$retries)..."
            sleep 2
        else
            echo "Failed to install $ext after $retries attempts."
            return $exit_code
        fi
    done
}

for ext in "${extensions[@]}"; do
    install_extension "$ext" || echo "Warning: Could not install $ext"
done
