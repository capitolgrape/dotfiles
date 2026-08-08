hl.monitor({
    output   = "DP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local ok, colors = pcall(dofile, config_home .. "/hypr/colors.lua")

if not ok then
    colors = {
        primary         = "rgba(33ccffdd)",
        secondary       = "rgba(00ff99dd)",
        surface_variant = "rgba(595959aa)",
        shadow          = "rgba(1a1a1aee)",
    }
end

local screenshot = config_home .. "/scripts/screenshot/screenshot.sh"

local function uwsm(command)
    return function()
        hl.exec_cmd("uwsm app -- " .. command)
    end
end

hl.on("hyprland.start", function()
    uwsm(config_home .. "/scripts/wallpaper/wall-restore.sh")()
    uwsm("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")()
end)

hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 9,
        border_size      = 1,

        col              = {
            active_border   = { colors = { colors.primary, colors.secondary }, angle = 45 },
            inactive_border = colors.surface_variant,
        },

        resize_on_border = false,
        allow_tearing    = true,
        layout           = "dwindle",

        snap             = {
            enabled      = true,
            window_gap   = 8,
            monitor_gap  = 12,
            respect_gaps = true,
        },
    },

    decoration = {
        rounding         = 6,
        rounding_power   = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow           = {
            enabled      = true,
            range        = 3,
            render_power = 3,
            color        = colors.shadow,
        },

        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
            xray     = false,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    input = {
        kb_layout              = "tr",

        follow_mouse           = 1,
        follow_mouse_threshold = 2,
        follow_mouse_shrink    = 2,
        focus_on_close         = 1,

        repeat_rate            = 35,
        repeat_delay           = 200,
        sensitivity            = 0,
    },

    cursor = {
        no_hardware_cursors = 2,
        inactive_timeout    = 0,
        hide_on_key_press   = true,
    },

    misc = {
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,

        enable_swallow           = true,
        swallow_regex            = "^(ghostty|com\\.mitchellh\\.ghostty)$",

        force_default_wallpaper  = -1,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    render = {
        direct_scanout = 2,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", uwsm("ghostty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", uwsm("nautilus"))
hl.bind(mainMod .. " + V", uwsm("vicinae 'vicinae://launch/clipboard/history?toggle=true'"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + W", uwsm(config_home .. "/scripts/wallpaper/wall-select.sh"))
hl.bind(mainMod .. " + SPACE", uwsm("vicinae toggle"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload && systemctl --user restart waybar.service"))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
    { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("PRINT", hl.dsp.exec_cmd(screenshot .. " area"))
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd(screenshot .. " full"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd(screenshot .. " active"))

hl.layer_rule({
    match        = { namespace = "vicinae" },
    blur         = true,
    ignore_alpha = 0,
    no_anim      = true,
})

hl.layer_rule({
    match        = { namespace = "^mako$" },
    blur         = true,
    ignore_alpha = 0.3,
    no_anim      = true,
})

hl.window_rule({
    match          = { class = ".*" },
    suppress_event = "maximize",
    idle_inhibit   = "fullscreen",
})

hl.window_rule({
    match  = { modal = true },
    float  = true,
    center = true,
})

hl.window_rule({
    match  = { class = "^xdg-desktop-portal-gtk$" },
    float  = true,
    size   = { 1440, 810 },
    center = true,
})

hl.window_rule({
    match             = {
        class = "^firefox$",
        title = "^Picture-in-Picture$",
    },

    float             = true,
    pin               = true,
    size              = { 480, 270 },
    move              = { "monitor_w-480-24", "monitor_h-270-24" },
    keep_aspect_ratio = true,
    no_initial_focus  = true,
})

hl.window_rule({
    match             = {
        initial_class = "^$",
        initial_title = "^Picture in picture$",
    },

    float             = true,
    pin               = true,
    size              = { 480, 270 },
    move              = { "monitor_w-480-24", "monitor_h-270-24" },
    keep_aspect_ratio = true,
    no_initial_focus  = true,
})

hl.window_rule({
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    match           = { class = "^(steam_app_.*|gamescope|cs2)$" },
    immediate       = true,
    confine_pointer = true,
    content         = "game",
})

hl.window_rule({
    match            = { class = "^xwaylandvideobridge$" },
    no_initial_focus = true,
    no_focus         = true,
    no_anim          = true,
    no_blur          = true,
    no_shadow        = true,
    max_size         = { 1, 1 },
    opacity          = "0.0 override",
})

hl.window_rule({
    match           = { class = "^(Bitwarden|chrome-nngceckbapebfimnlniiiahkandclblb-Default)$" },
    float           = true,
    center          = true,
    pin             = true,
    no_screen_share = true,
})

hl.window_rule({
    match  = { class = "^(org\\.pulseaudio\\.pavucontrol|blueman-manager)$" },
    float  = true,
    center = true,
    size   = { 1600, 900 },
    pin    = true,
})

hl.window_rule({
    match  = {
        class = "^com\\.mitchellh\\.ghostty$",
        title = "^btm$",
    },

    float  = true,
    center = true,
    size   = { 1600, 900 },
    pin    = true,
})

hl.window_rule({
    match           = {
        class = "^(polkit-gnome-authentication-agent-1|pinentry|pinentry-.*|org\\.gnupg\\.pinentry.*)$",
    },

    float           = true,
    center          = true,
    pin             = true,
    stay_focused    = true,
    dim_around      = true,
    no_screen_share = true,
})

hl.window_rule({
    match      = { class = "^(mpv|imv)$" },
    fullscreen = true,
})
