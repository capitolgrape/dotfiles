#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$CONFIG_DIR/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

exec > >(tee -i "$SCRIPT_DIR/install.log") 2>&1

log()  { printf '\033[32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33m!!  %s\033[0m\n' "$*"; }

log "Script directory: $SCRIPT_DIR"

copy() {
  local src="$1" dest="$2"
  [[ -e "$src" ]] || { warn "Missing, skipping: $src"; return; }

  if [[ -e "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    warn "Backed up existing $dest -> $BACKUP_DIR/$(basename "$dest")"
  fi

  mkdir -p "$dest"
  cp -r "$src/." "$dest/"
  log "Copied $src -> $dest"
}

if ! command -v paru &> /dev/null; then
  log "paru not found, building it from the AUR..."
  sudo pacman -S --needed --noconfirm base-devel git || warn "Failed to install base-devel/git"

  PARU_BUILD_DIR="$(mktemp -d)"
  git clone https://aur.archlinux.org/paru.git "$PARU_BUILD_DIR" || warn "Failed to clone paru AUR repo"
  (cd "$PARU_BUILD_DIR" && makepkg -si --noconfirm) || warn "paru build failed"
  rm -rf "$PARU_BUILD_DIR"

  if command -v paru &> /dev/null; then
    log "paru installed successfully"
  else
    warn "paru installation failed"
  fi
fi

if [[ -f "$SCRIPT_DIR/makepkg.conf" ]]; then
  mkdir -p "$CONFIG_DIR/pacman"
  cp "$SCRIPT_DIR/makepkg.conf" "$CONFIG_DIR/pacman/makepkg.conf"
  log "Copied makepkg.conf"
fi


if command -v paru &> /dev/null; then
  log "Syncing repos and upgrading system (avoids partial-upgrade conflicts)..."
  paru -Syu --noconfirm || warn "System upgrade failed, continuing anyway..."

  if [[ -f "$SCRIPT_DIR/packages.ini" ]]; then
    mapfile -t PACKAGES < <(grep -vE '^\s*($|\[)' "$SCRIPT_DIR/packages.ini")
    if ((${#PACKAGES[@]})); then
      log "Installing ${#PACKAGES[@]} packages from packages.ini as a single transaction..."
      if paru -S --needed --noconfirm "${PACKAGES[@]}"; then
        log "Installed all packages"
      else
        warn "Batch install reported an error; verifying which packages are actually missing..."
        FAILED_PACKAGES=()
        for pkg in "${PACKAGES[@]}"; do
          pacman -Qq "$pkg" &> /dev/null || FAILED_PACKAGES+=("$pkg")
        done
        ((${#FAILED_PACKAGES[@]})) && warn "Packages that failed: ${FAILED_PACKAGES[*]}" || log "All packages present despite reported error"
      fi
    else
      warn "packages.ini has no packages listed, skipping"
    fi
  else
    warn "packages.ini not found, skipping package install"
  fi
else
  warn "paru not found, skipping package install"
fi

for name in fish ghostty hypr hyprland-preview-share-picker mako matugen uwsm waybar paru scripts; do
  copy "$SCRIPT_DIR/$name" "$CONFIG_DIR/$name"
done

[[ -d "$CONFIG_DIR/scripts" ]] && find "$CONFIG_DIR/scripts" -type f -name '*.sh' -exec chmod +x {} +

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
if [[ -d "$SCRIPT_DIR/wallpapers" ]]; then
  mkdir -p "$WALLPAPER_DIR"
  cp -r "$SCRIPT_DIR/wallpapers/." "$WALLPAPER_DIR/"
  log "Copied wallpapers -> $WALLPAPER_DIR"

  WALL_APPLY="$CONFIG_DIR/scripts/wallpaper/wall-apply.sh"
  if [[ -x "$WALL_APPLY" ]]; then
    mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \))
    if ((${#WALLPAPERS[@]})); then
      RANDOM_WALLPAPER="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"
      if "$WALL_APPLY" "$RANDOM_WALLPAPER"; then
        log "Applied random wallpaper: $(basename "$RANDOM_WALLPAPER")"
      else
        warn "wall-apply.sh failed to apply $RANDOM_WALLPAPER"
      fi
    else
      warn "No wallpapers found in $WALLPAPER_DIR, skipping apply"
    fi
  else
    warn "$WALL_APPLY not found or not executable, skipping wallpaper apply"
  fi
else
  warn "$SCRIPT_DIR/wallpapers not found, skipping wallpaper setup"
fi

if [[ -f "$SCRIPT_DIR/xdg-terminals.list" ]]; then
  cp "$SCRIPT_DIR/xdg-terminals.list" "$CONFIG_DIR/xdg-terminals.list"
  log "Copied xdg-terminals.list"
fi

if command -v fish &> /dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
  FISH_PATH="$(command -v fish)"
  if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    log "Added $FISH_PATH to /etc/shells"
  fi
  if chsh -s "$FISH_PATH"; then
    log "Default shell set to fish (log out/in to take effect)"
  else
    warn "Failed to set fish as default shell"
  fi
fi

if [ ! -d "$CONFIG_DIR/nvim" ]; then
  if git clone https://github.com/nvim-lua/kickstart.nvim "$CONFIG_DIR/nvim"; then
    log "Cloned kickstart.nvim"
  else
    warn "Failed to clone kickstart.nvim"
  fi
fi

if command -v gsettings &> /dev/null; then
  {
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'date_modified']"
    gsettings set org.gnome.nautilus.preferences click-policy 'double'
    gsettings set org.gtk.Settings.FileChooser sort-directories-first true
    gsettings set org.gnome.nautilus.preferences recursive-search 'always'
    gsettings set org.gnome.nautilus.preferences thumbnail-limit 100
    gsettings set org.gtk.Settings.FileChooser startup-mode 'recent'
    gsettings set org.gnome.desktop.privacy remember-recent-files false
  } || warn "Some gsettings tweaks failed (e.g. schema not installed)"
  log "Applied gsettings tweaks"
fi

if command -v starship &> /dev/null; then
  if starship preset pure-preset --force -o "$CONFIG_DIR/starship.toml"; then
    log "Wrote starship preset"
  else
    warn "Failed to write starship preset"
  fi
fi

command -v fc-cache &> /dev/null && fc-cache -fv
command -v xdg-user-dirs-update &> /dev/null && xdg-user-dirs-update

if command -v fish &> /dev/null; then
  if ! fish -c "functions -q fisher" 2>/dev/null; then
    log "Installing fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" || warn "fisher install failed"
  else
    log "fisher already installed"
  fi
  log "Installing fisher plugins..."
  fish -c "fisher install franciscolourenco/done jorgebucaran/autopair.fish PatrickF1/fzf.fish nickeb96/puffer-fish" || warn "fisher plugin install failed"
else
  warn "fish not installed, skipping fisher"
fi

if command -v auto-cpufreq &> /dev/null; then
  if command -v powerprofilesctl &> /dev/null; then
    sudo systemctl disable --now power-profiles-daemon.service || warn "Failed to disable power-profiles-daemon"
  fi

  install_output=$(sudo auto-cpufreq --install 2>&1) || true
  if echo "$install_output" | grep -q "running in daemon mode"; then
    log "auto-cpufreq daemon already running, skipping install"
  else
    echo "$install_output"
  fi

  if ls /sys/class/power_supply/BAT* &> /dev/null; then
    sudo auto-cpufreq --force powersave || warn "Failed to set auto-cpufreq powersave mode"
  else
    sudo auto-cpufreq --force performance || warn "Failed to set auto-cpufreq performance mode"
  fi
  log "auto-cpufreq setup complete"
else
  warn "auto-cpufreq not installed, skipping"
fi

for svc in fstrim.timer paccache.timer bluetooth.service ananicy-cpp.service; do
  if systemctl list-unit-files --no-legend "$svc" 2>/dev/null | grep -q "^$svc"; then
    sudo systemctl enable --now "$svc"
    log "Enabled $svc"
  else
    warn "$svc not found, skipping"
  fi
done

[[ -d "$BACKUP_DIR" ]] && log "Existing configs backed up to $BACKUP_DIR"

log "Dotfiles setup complete."