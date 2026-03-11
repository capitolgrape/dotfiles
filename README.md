# dotfiles

personal linux dotfiles for my `niri` setup. you can use the configs here in your own setup.

## preview

<table>
  <tr>
    <td><img src="preview/desktop.jpg" alt="desktop" width="420"></td>
    <td><img src="preview/terminal.jpg" alt="terminal" width="420"></td>
  </tr>
  <tr>
    <td><img src="preview/zed.jpg" alt="zed" width="420"></td>
    <td><img src="preview/monitor.jpg" alt="monitor" width="420"></td>
  </tr>
</table>

## what's included

### core desktop

- `niri/` - main compositor config
- `waybar/` - bar config and style
- `hypr/` - used for `hyprlock`
- `mimeapps.list` - default app associations
- `wallpapers/` - wallpapers copied during setup

### terminal and shell

- `kitty/` - terminal config
- `fish/` - shell config and abbreviations
- `fastfetch/` - system info output

### media and apps

- `mpv/` - player config, scripts, profiles, and fonts. grabbed it from somewhere and changed it a bit
- `zed/` - `zed` settings

### scripts

- `scripts/aur_helper.sh` - installs `paru` if it is not installed
- `scripts/wal-update.sh` - runs `pywal`
  - usage: `./wal-update.sh wallpaper.png`
- `scripts/ufw.sh` - sets up the firewall
- `scripts/auto_cpufreq.sh` - enables and applies `auto-cpufreq` if it is installed. taken from [linutil](https://github.com/ChrisTitusTech/linutil)

## install script warning

do not treat `install.sh` as a safe universal installer.

it is highly opinionated and is **not recommended for use on an existing system**. it installs packages, copies configs directly into `~/.config`, changes the default shell, applies mime associations, enables system services, runs firewall and cpu tuning scripts, and assumes an arch-based system with `paru`.

if you want to reuse this repo, it is safer to copy the parts you need manually instead of running `install.sh` as-is.

## what `install.sh` does

right now, `install.sh` does this:

1. installs `paru` and the packages listed in `pkgs`
2. changes the default shell to `fish` and installs `bun` if needed
3. copies these config directories into `~/.config`:
    - `niri`
    - `waybar`
    - `kitty`
    - `fish`
    - `hypr`
    - `mpv`
    - `fastfetch`
    - `zed`
4. copies `mimeapps.list` into `~/.config`
5. copies wallpapers into `~/.wallpapers`, generates wallpaper-based colors, and adds `~/wal-update.sh`
6. rebuilds the font cache and sets the gnome color scheme preference to dark
7. enables and starts these services and timers:
    - `fstrim.timer`
    - `paccache.timer`
    - `bluetooth.service`
    - `greetd.service`
    - `ananicy-cpp.service`
8. applies the firewall setup, cpu power tuning setup, and the `starship` pure preset if `starship` is installed

## known issues

- steam popup notifications can be annoying when they show up. still didn't figure out a proper fix.
- possible fix: disable steam notifications from `steam -> settings -> notifications -> show notification toasts` and set it to `never`.
