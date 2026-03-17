# dotfiles

> opinionated niri setup for arch linux

![desktop](preview/desktop.jpg)

## warning

highly **opinionated**. modifies system settings, changes default shell, enables services. best for fresh arch/cachyos installs. run at your own risk.

## quick start

```bash
git clone https://github.com/dumbovita/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## components

| component | tool | link |
|-----------|------|------|
| compositor | niri | [github.com/YaLTeR/niri](https://github.com/YaLTeR/niri) |
| bar | waybar | [github.com/Alexays/Waybar](https://github.com/Alexays/Waybar) |
| terminal | kitty | [sw.kovidgoyal.net/kitty](https://sw.kovidgoyal.net/kitty/) |
| shell | fish + starship | [fishshell.com](https://fishshell.com/) / [starship.rs](https://starship.rs/) |
| editor | zed | [zed.dev](https://zed.dev/) |
| launcher | vicinae | [github.com/vicinaehq/vicinae](https://github.com/vicinaehq/vicinae) |
| lock | hyprlock | [github.com/hyprwm/hyprlock](https://github.com/hyprwm/hyprlock) |
| wallpaper | awww | [codeberg.org/LGFae/awww](https://codeberg.org/LGFae/awww) |
| notifications | swaync | [github.com/ErikReider/SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter) |

## keybinds

| key | action |
|-----|--------|
| `mod+return` | open terminal |
| `mod+space` | launch vicinae |
| `mod+v` | clipboard history |
| `mod+e` | file manager |
| `mod+o` | toggle overview |
| `mod+q` | close window |
| `mod+f` | maximize column |
| `mod+shift+f` | fullscreen window |
| `mod+shift+l` | lock screen |
| `mod+shift+w` | change wallpaper |
| `mod+r` | restart waybar |
| `mod+arrows` | focus windows |
| `mod+pgup/pgdn` | switch workspace |
| `mod+1-9` | focus workspace 1-9 |
| `mod+shift+1-9` | move to workspace 1-9 |
| `print` | screenshot |
| `ctrl+print` | screenshot screen |
| `alt+print` | screenshot window |
| `mod+shift+e` | quit niri |

## structure

```
.
├── fastfetch/          # system info display
├── fish/               # shell config
├── hypr/               # lock screen
├── kitty/              # terminal config
├── mpv/                # media player
├── niri/               # window manager
├── scripts/            # install helpers
├── awww/               # wallpaper scripts
├── systemd/user/       # user services
├── wallpapers/         # background images
├── waybar/             # status bar
└── zed/                # editor settings
```

<!--
## screenshots

| desktop | terminal | monitor |
|---------|----------|---------|
| ![desktop](preview/desktop.jpg) | ![terminal](preview/terminal.jpg) | ![monitor](preview/monitor.jpg) |
-->
