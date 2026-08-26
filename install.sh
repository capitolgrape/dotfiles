#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CONFIG_DIR/dotfiles-backup/$TIMESTAMP"

exec > >(tee -i "$SCRIPT_DIR/install-$TIMESTAMP.log") 2>&1

WARNINGS=()

log()  { printf '\033[32m==> %s\033[0m\n' "$*"; }
warn() { WARNINGS+=("$*"); printf '\033[33m!!  %s\033[0m\n' "$*"; }

trap 'warn "Unexpected error at line $LINENO (exit code $?)"' ERR

SUDO_KEEPALIVE_PID=""
sudo -v
(
  set +e
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
  done
) > /dev/null 2>&1 &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

log "Script directory: $SCRIPT_DIR"

copy() {
  local src="$1" dest="$2"
  [[ -e "$src" ]] || { warn "Missing, skipping: $src"; return; }

  if [[ -e "$dest" ]]; then
    if diff -rq "$src" "$dest" &> /dev/null; then
      log "$dest already up to date, skipping"
      return
    fi
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    warn "Backed up existing $dest -> $BACKUP_DIR/$(basename "$dest")"
  fi

  mkdir -p "$dest"
  cp -r "$src/." "$dest/"
  log "Copied $src -> $dest"
}

install_user_file() {
  local src="$1" dest="$2"
  [[ -f "$src" ]] || { warn "Missing, skipping: $src"; return; }

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
      log "$dest already up to date, skipping"
      return
    fi
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    warn "Backed up existing $dest -> $BACKUP_DIR/$(basename "$dest")"
  fi

  install -m 0644 "$src" "$dest"
  log "Installed $src -> $dest"
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

if command -v paru &> /dev/null; then
  log "Syncing repos and upgrading system..."
  paru -Syu --noconfirm --skipreview --noupgrademenu --nopgpfetch --useask < /dev/null || warn "System upgrade failed, continuing anyway..."

  if [[ -f "$SCRIPT_DIR/packages.ini" ]]; then
    mapfile -t PACKAGES < <(sed -E 's/\[[^]]*\]//g' "$SCRIPT_DIR/packages.ini" | tr -s '[:space:]' '\n' | grep -v '^$')
    if ((${#PACKAGES[@]})); then
      log "Installing ${#PACKAGES[@]} packages from packages.ini as a single transaction..."
      if paru -S --needed --noconfirm --skipreview --noupgrademenu --nopgpfetch --useask "${PACKAGES[@]}" < /dev/null; then
        log "Installed all packages"
      else
        warn "Batch install reported an error; verifying which packages are actually missing..."
        FAILED_PACKAGES=()
        for pkg in "${PACKAGES[@]}"; do
          pacman -Qq "$pkg" &> /dev/null || FAILED_PACKAGES+=("$pkg")
        done
        if ((${#FAILED_PACKAGES[@]})); then
          warn "Packages that failed: ${FAILED_PACKAGES[*]}"
        else
          log "All packages present despite reported error"
        fi
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

REQUIRED_COMMANDS=(
  awww matugen grim slurp brightnessctl jq wl-copy notify-send
  vicinae makoctl pw-dump hyprctl
)
for command_name in "${REQUIRED_COMMANDS[@]}"; do
  command -v "$command_name" &> /dev/null || warn "Required command not found: $command_name"
done

if [[ -f "$SCRIPT_DIR/makepkg.conf" ]]; then
  mkdir -p "$CONFIG_DIR/pacman"
  if [[ -e "$CONFIG_DIR/pacman/makepkg.conf" ]] && ! cmp -s "$SCRIPT_DIR/makepkg.conf" "$CONFIG_DIR/pacman/makepkg.conf"; then
    mkdir -p "$BACKUP_DIR"
    mv "$CONFIG_DIR/pacman/makepkg.conf" "$BACKUP_DIR/makepkg.conf"
    warn "Backed up existing $CONFIG_DIR/pacman/makepkg.conf -> $BACKUP_DIR/makepkg.conf"
  fi
  cp "$SCRIPT_DIR/makepkg.conf" "$CONFIG_DIR/pacman/makepkg.conf"
  log "Copied makepkg.conf"
fi

for name in fish vicinae ghostty hypr hyprland-preview-share-picker mako matugen uwsm waybar paru scripts zed mpv fastfetch; do
  copy "$SCRIPT_DIR/$name" "$CONFIG_DIR/$name"
done

install_user_file "$SCRIPT_DIR/systemd/user/mako.service" "$CONFIG_DIR/systemd/user/mako.service"
if [[ -f "$CONFIG_DIR/systemd/user/mako.service" ]] && command -v systemctl &> /dev/null; then
  systemctl --user daemon-reload || warn "Failed to reload the user systemd manager"
fi

PICKER_DIR="$CONFIG_DIR/hyprland-preview-share-picker"
PICKER_STYLE="$PICKER_DIR/style.css"
if [[ -f "$PICKER_STYLE" ]]; then
  sed -i "1c @import url(\"file://${PICKER_DIR}/colors.css\");" "$PICKER_STYLE"
  log "Configured hyprland-preview-share-picker colors path: $PICKER_DIR/colors.css"
fi

if [[ -f "$SCRIPT_DIR/.luarc.json" ]]; then
  if [[ -e "$CONFIG_DIR/.luarc.json" ]] && ! cmp -s "$SCRIPT_DIR/.luarc.json" "$CONFIG_DIR/.luarc.json"; then
    mkdir -p "$BACKUP_DIR"
    mv "$CONFIG_DIR/.luarc.json" "$BACKUP_DIR/.luarc.json"
    warn "Backed up existing $CONFIG_DIR/.luarc.json -> $BACKUP_DIR/.luarc.json"
  fi
  cp "$SCRIPT_DIR/.luarc.json" "$CONFIG_DIR/.luarc.json"
  log "Copied .luarc.json"
fi

mkdir -p "$CONFIG_DIR/ghostty/themes"
mkdir -p "$CONFIG_DIR/zed/themes"

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
  if [[ -e "$CONFIG_DIR/xdg-terminals.list" ]] && ! cmp -s "$SCRIPT_DIR/xdg-terminals.list" "$CONFIG_DIR/xdg-terminals.list"; then
    mkdir -p "$BACKUP_DIR"
    mv "$CONFIG_DIR/xdg-terminals.list" "$BACKUP_DIR/xdg-terminals.list"
    warn "Backed up existing $CONFIG_DIR/xdg-terminals.list -> $BACKUP_DIR/xdg-terminals.list"
  fi
  cp "$SCRIPT_DIR/xdg-terminals.list" "$CONFIG_DIR/xdg-terminals.list"
  log "Copied xdg-terminals.list"
fi

if [[ -f "$SCRIPT_DIR/mimeapps.list" ]]; then
  if [[ -e "$CONFIG_DIR/mimeapps.list" ]] && ! cmp -s "$SCRIPT_DIR/mimeapps.list" "$CONFIG_DIR/mimeapps.list"; then
    mkdir -p "$BACKUP_DIR"
    mv "$CONFIG_DIR/mimeapps.list" "$BACKUP_DIR/mimeapps.list"
    warn "Backed up existing $CONFIG_DIR/mimeapps.list -> $BACKUP_DIR/mimeapps.list"
  fi
  cp "$SCRIPT_DIR/mimeapps.list" "$CONFIG_DIR/mimeapps.list"
  log "Copied mimeapps.list"
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

if command -v git &> /dev/null; then
  if [ ! -d "$CONFIG_DIR/nvim" ]; then
    if git clone https://github.com/nvim-lua/kickstart.nvim "$CONFIG_DIR/nvim"; then
      log "Cloned kickstart.nvim"
    else
      warn "Failed to clone kickstart.nvim"
    fi
  elif [ -d "$CONFIG_DIR/nvim/.git" ]; then
    if git -C "$CONFIG_DIR/nvim" pull --ff-only &> /dev/null; then
      log "Updated kickstart.nvim"
    else
      warn "Failed to update kickstart.nvim (local changes or diverged history?), leaving as-is"
    fi
  else
    warn "$CONFIG_DIR/nvim exists but isn't a git repo, skipping kickstart.nvim update"
  fi
else
  warn "git not found, skipping kickstart.nvim setup"
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

if pacman -Qq greetd &> /dev/null 2>&1; then
  sudo mkdir -p /etc/greetd

  GREETD_CONFIG_NEW="$(cat <<'EOF'
[terminal]
vt = 1
[default_session]
command = "tuigreet --time --remember --remember-session --cmd 'uwsm start -e -D Hyprland hyprland.desktop'"
user = "greeter"
EOF
)"

  if [[ -f /etc/greetd/config.toml ]] && diff -q <(printf '%s' "$GREETD_CONFIG_NEW") /etc/greetd/config.toml &> /dev/null; then
    log "greetd config already up to date, skipping"
  else
    if [[ -f /etc/greetd/config.toml ]]; then
      mkdir -p "$BACKUP_DIR"
      sudo cp /etc/greetd/config.toml "$BACKUP_DIR/greetd-config.toml"
      warn "Backed up existing /etc/greetd/config.toml -> $BACKUP_DIR/greetd-config.toml"
    fi
    printf '%s\n' "$GREETD_CONFIG_NEW" | sudo tee /etc/greetd/config.toml > /dev/null
    log "Wrote greetd config -> /etc/greetd/config.toml"
  fi

  if systemctl list-unit-files --no-legend greetd.service 2>/dev/null | grep -q "^greetd.service"; then
    if sudo systemctl enable greetd.service; then
      log "Enabled greetd.service"
    else
      warn "Failed to enable greetd.service"
    fi
  else
    warn "greetd.service not found, skipping enable"
  fi
else
  warn "greetd not installed, skipping greetd setup"
fi

if command -v virsh &> /dev/null; then
  log "Configuring libvirt/KVM..."

  if [[ ! -e /dev/kvm ]]; then
    warn "KVM is not available. Enable CPU virtualization support in BIOS/UEFI. See https://wiki.archlinux.org/title/KVM"
  else
    sudo usermod "$USER" -aG kvm || warn "Failed to add $USER to kvm group"
  fi

  sudo sed -i 's/^#\?firewall_backend\s*=\s*".*"/firewall_backend = "iptables"/' /etc/libvirt/network.conf \
    || warn "Failed to set libvirt firewall_backend"

  if systemctl is-active --quiet polkit; then
    sudo sed -i 's/^#\?auth_unix_ro\s*=\s*".*"/auth_unix_ro = "polkit"/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/^#\?auth_unix_rw\s*=\s*".*"/auth_unix_rw = "polkit"/' /etc/libvirt/libvirtd.conf
  fi

  sudo usermod "$USER" -aG libvirt || warn "Failed to add $USER to libvirt group"

  for value in libvirt libvirt_guest; do
    if ! grep -wq "$value" /etc/nsswitch.conf; then
      sudo sed -i "/^hosts:/ s/\$/ ${value}/" /etc/nsswitch.conf
    fi
  done

  sudo systemctl enable --now libvirtd.service || warn "Failed to enable libvirtd.service"
  sudo virsh net-autostart default || warn "Failed to autostart default libvirt network"

  log "Libvirt/KVM configuration complete"
else
  warn "virsh not found, skipping libvirt/KVM setup (make sure libvirt is in packages.ini)"
fi

for svc in fstrim.timer paccache.timer bluetooth.service ananicy-cpp.service rtkit-daemon.service; do
  if systemctl list-unit-files --no-legend "$svc" 2>/dev/null | grep -q "^$svc"; then
    if sudo systemctl enable --now "$svc"; then
      log "Enabled $svc"
    else
      warn "Failed to enable $svc"
    fi
  else
    warn "$svc not found, skipping"
  fi
done

for svc in waybar.service vicinae.service hypridle.service mako.service; do
  if systemctl --user list-unit-files --no-legend "$svc" 2>/dev/null | grep -q "^$svc"; then
    if systemctl --user enable --now "$svc"; then
      log "Enabled --user $svc"
    else
      warn "Failed to enable --user $svc"
    fi
  else
    warn "--user $svc not found, skipping"
  fi
done

log "Cleaning up: removing orphaned packages and clearing package cache..."

mapfile -t ORPHANS < <(pacman -Qtdq 2>/dev/null)
if ((${#ORPHANS[@]})); then
  log "Removing ${#ORPHANS[@]} orphaned package(s): ${ORPHANS[*]}"
  sudo pacman -Rns --noconfirm "${ORPHANS[@]}" || warn "Failed to remove some orphaned packages"
else
  log "No orphaned packages to remove"
fi

if command -v paru &> /dev/null; then
  sudo find /var/cache/pacman/pkg -maxdepth 1 -name 'download-*' -exec rm -rf {} + 2>/dev/null || true
  paru -Sc --noconfirm < /dev/null || warn "Failed to clean package cache"
  log "Cleaned package cache"
fi

[[ -d "$BACKUP_DIR" ]] && log "Existing configs backed up to $BACKUP_DIR"

if ((${#WARNINGS[@]})); then
  log "Completed with ${#WARNINGS[@]} warning(s):"
  for w in "${WARNINGS[@]}"; do
    printf '    - %s\n' "$w"
  done
else
  log "Completed with no warnings."
fi

log "Dotfiles setup complete."
