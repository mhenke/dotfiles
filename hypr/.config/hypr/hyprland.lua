-- Hyprland Lua Configuration
-- Migrated from legacy .conf format for Hyprland 0.55+ (future-proofed for 0.57+)
-- Resolves deprecation warning: ".conf config format will be removed in Hyprland 0.57"

local home = os.getenv("HOME") or ""
local hyprDir = home .. "/.config/hypr"
local scriptsDir = hyprDir .. "/scripts"
local userScriptsDir = hyprDir .. "/UserScripts"
local userConfigsDir = hyprDir .. "/UserConfigs"

-- ============================================================================
-- 1. Helper Functions to Load Sub-Configs & Dynamic Theming
-- ============================================================================

local function load_wallust_colors(file_path)
    local colors = {}
    local f = io.open(file_path, "r")
    if not f then return colors end
    for line in f:lines() do
        local var, val = line:match("^%$([%w_]+)%s*=%s*(.+)$")
        if var and val then
            val = val:gsub("#.*$", ""):match("^%s*(.-)%s*$")
            colors[var] = val
        end
    end
    f:close()
    return colors
end

local function load_user_defaults(file_path)
    local defaults = {
        term = "ghostty",
        files = home .. "/.local/bin/yazi-wrapper",
        browser = "flatpak run app.zen_browser.zen",
        search_engine = "https://www.google.com/search?q={}",
    }
    local f = io.open(file_path, "r")
    if not f then return defaults end
    for line in f:lines() do
        local var, val = line:match("^%$([%w_]+)%s*=%s*(.+)$")
        if var and val then
            val = val:gsub("#.*$", ""):match("^%s*(.-)%s*$")
            val = val:match('^"(.*)"$') or val:match("^'(.*)'$") or val
            defaults[var:lower()] = val
        end
    end
    f:close()
    return defaults
end

local function load_env_variables(file_path)
    local f = io.open(file_path, "r")
    if not f then return end
    for line in f:lines() do
        line = line:gsub("#.*$", ""):match("^%s*(.-)%s*$")
        if line and line:match("^env%s*=%s*") then
            local rest = line:match("^env%s*=%s*(.+)$")
            if rest then
                local k, v = rest:match("^([^,]+)%s*,%s*(.+)$")
                if k and v then
                    k = k:match("^%s*(.-)%s*$")
                    v = v:match("^%s*(.-)%s*$"):gsub("%$HOME", home)
                    hl.env(k, v)
                end
            end
        end
    end
    f:close()
end

local function load_workspaces_and_monitors(file_path)
    local f = io.open(file_path, "r")
    if not f then return end
    for line in f:lines() do
        line = line:gsub("#.*$", ""):match("^%s*(.-)%s*$")
        if line and line ~= "" then
            local mon_str = line:match("^monitor%s*=%s*(.+)$")
            if mon_str then
                local parts = {}
                for p in mon_str:gmatch("[^,]+") do
                    table.insert(parts, p:match("^%s*(.-)%s*$"))
                end
                if #parts >= 4 then
                    hl.monitor({
                        output = parts[1],
                        mode = parts[2],
                        position = parts[3],
                        scale = tonumber(parts[4]) or 1,
                    })
                end
            end
            local ws_str = line:match("^workspace%s*=%s*(.+)$")
            if ws_str then
                local ws_id = ws_str:match("^(%w+)")
                local mon = ws_str:match("monitor:([%w%-%_]+)")
                local is_def = ws_str:find("default:true") ~= nil
                local rule = { workspace = ws_id }
                if mon then rule.monitor = mon end
                if is_def then rule.default = true end
                hl.workspace_rule(rule)
            end
        end
    end
    f:close()
end

local function get_startup_apps(file_path)
    local cmds = {}
    local f = io.open(file_path, "r")
    if not f then return cmds end
    for line in f:lines() do
        line = line:match("^%s*(.-)%s*$")
        if line and not line:match("^#") and line:match("^exec%-once%s*=%s*") then
            local cmd = line:match("^exec%-once%s*=%s*(.+)$")
            if cmd then
                cmd = cmd:gsub("%$HOME", home)
                cmd = cmd:gsub("%$scriptsDir", scriptsDir)
                cmd = cmd:gsub("%$UserScripts", userScriptsDir)
                table.insert(cmds, cmd)
            end
        end
    end
    f:close()
    return cmds
end

-- ============================================================================
-- 2. Environment Variables & Defaults
-- ============================================================================

load_env_variables(userConfigsDir .. "/ENVariables.conf")
local userDefaults = load_user_defaults(userConfigsDir .. "/01-UserDefaults.conf")
local wallustColors = load_wallust_colors(hyprDir .. "/wallust/wallust-hyprland.conf")

-- ============================================================================
-- 3. Core Settings (UserSettings.conf)
-- ============================================================================

hl.config({
    dwindle = {
        preserve_split = true,
        split_width_multiplier = 1.0,
        force_split = 0,
        smart_split = false,
        smart_resizing = true,
    },
    master = {
        new_on_top = true,
        mfact = 0.5,
    },
    general = {
        resize_on_border = true,
        layout = "dwindle",
        border_size = 2,
        gaps_in = 0,
        gaps_out = 0,
        ["col.active_border"] = wallustColors["color12"] or "rgb(2D7183)",
        ["col.inactive_border"] = wallustColors["color10"] or "rgb(3B444D)",
    },
    input = {
        kb_layout = "us",
        repeat_rate = 50,
        repeat_delay = 300,
        numlock_by_default = true,
        left_handed = false,
        follow_mouse = 0,
        sensitivity = 0.25,
        float_switch_override_focus = false,
        touchpad = {
            disable_while_typing = true,
            natural_scroll = true,
            clickfinger_behavior = false,
            middle_button_emulation = true,
            tap_to_click = true,
            drag_lock = false,
        },
    },
    gestures = {
        workspace_swipe_distance = 400,
        workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = true,
        workspace_swipe_forever = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        enable_swallow = false,
        focus_on_activate = false,
        swallow_regex = "^(kitty)$",
        disable_watchdog_warning = true,
        allow_session_lock_restore = true,
    },
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        dim_inactive = false,
        dim_strength = 0.0,
        dim_special = 0.8,
        shadow = {
            enabled = false,
            range = 6,
            render_power = 1,
            color = wallustColors["color12"] or "rgb(2D7183)",
            color_inactive = wallustColors["color2"] or "rgb(2C333A)",
        },
        blur = {
            enabled = false,
            size = 6,
            passes = 2,
            ignore_opacity = true,
            special = true,
        },
    },
    group = {
        ["col.border_active"] = wallustColors["color15"] or "rgb(DFC2A3)",
        groupbar = {
            ["col.active"] = wallustColors["color0"] or "rgb(514A49)",
        },
    },
    animations = {
        enabled = true,
    },
})

-- ============================================================================
-- 4. Animations & Curves (UserAnimations.conf)
-- ============================================================================

hl.curve("wind",      { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn",     { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut",    { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner",     { type = "bezier", points = { {1, 1}, {1, 1} } })
hl.curve("overshot",  { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.5, 0}, {0.99, 0.99} } })
hl.curve("smoothIn",  { type = "bezier", points = { {0.5, -0.5}, {0.68, 1.5} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "smoothOut" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "overshot" })

-- Device config (Laptops.conf)
hl.device({
    name = "asue1209:00-04f3:319f-touchpad",
    enabled = true,
})

-- ============================================================================
-- 5. Monitors & Workspaces (workspaces.conf + fallback)
-- ============================================================================

load_workspaces_and_monitors(hyprDir .. "/workspaces.conf")

-- Safe laptop fallback (mirrors eDP-1 for meeting displays)
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
    mirror = "eDP-1",
})

-- ============================================================================
-- 6. Keybindings
-- ============================================================================

local mainMod = "SUPER"

-- Core System & Window Management
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("hyprctl dispatch exit 0"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(scriptsDir .. "/KillActiveProcess.sh"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(scriptsDir .. "/Wlogout.sh"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- Master Layout Binds
hl.bind(mainMod .. " + CTRL + D", hl.dsp.layout("removemaster"))
hl.bind(mainMod .. " + I", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + K", hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.layout("swapwithmaster"))

-- Dwindle Layout Binds
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3"))

-- Groups
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + tab", hl.dsp.group.next())

-- Window Cycling & Floating
hl.bind("ALT + tab", hl.dsp.window.cycle_next())
hl.bind("ALT + tab", hl.dsp.window.bring_to_top())
hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + space", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CTRL + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 1"))

-- Focus Movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Window Movement
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "down" }))

-- Window Swapping
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Window Resizing (continuous with repeating)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -50 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 50 }), { repeating = true })

-- Mouse Dragging / Resizing
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces Navigation (tab, mouse, period/comma)
hl.bind(mainMod .. " + tab",         hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_down",  hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",    hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + period",      hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma",       hl.dsp.focus({ workspace = "e-1" }))

-- Special Workspace
hl.bind(mainMod .. " + U",         hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special" }))

-- Workspaces [1-10] via keycodes
for i = 1, 10 do
    local code = "code:" .. (9 + i)
    hl.bind(mainMod .. " + " .. code,                  hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. code,          hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. code,           hl.dsp.window.move({ workspace = i, silent = true }))
end

hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + CTRL + bracketleft",   hl.dsp.window.move({ workspace = "-1", silent = true }))
hl.bind(mainMod .. " + CTRL + bracketright",  hl.dsp.window.move({ workspace = "+1", silent = true }))

-- Multimedia & Hotkeys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --inc"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --dec"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle-mic"), { locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle"), { locked = true })
hl.bind("XF86Sleep",            hl.dsp.exec_cmd("systemctl hibernate"), { locked = true })
hl.bind("XF86Rfkill",           hl.dsp.exec_cmd(scriptsDir .. "/AirplaneMode.sh"), { locked = true })

hl.bind("XF86AudioPause",     hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true })
hl.bind("XF86AudioPlay",      hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true })
hl.bind("XF86AudioNext",      hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --nxt"), { locked = true })
hl.bind("XF86AudioPrev",      hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --prv"), { locked = true })
hl.bind("XF86AudioStop",      hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --stop"), { locked = true })

-- Screenshots
hl.bind(mainMod .. " + Print",                hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"))
hl.bind(mainMod .. " + SHIFT + Print",        hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"))
hl.bind(mainMod .. " + CTRL + Print",         hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"))
hl.bind(mainMod .. " + CTRL + SHIFT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"))
hl.bind("ALT + Print",                        hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"))
hl.bind(mainMod .. " + SHIFT + S",            hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --swappy"))

-- Laptop Specific Keys
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --dec"))
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --inc"))
hl.bind("XF86Launch1",           hl.dsp.exec_cmd("rog-control-center"))
hl.bind("XF86Launch3",           hl.dsp.exec_cmd("asusctl led-mode -n"))
hl.bind("XF86Launch4",           hl.dsp.exec_cmd("asusctl profile -n"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --dec"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --inc"))
hl.bind("XF86TouchpadToggle",    hl.dsp.exec_cmd(scriptsDir .. "/TouchPad.sh"))

hl.bind(mainMod .. " + F6",         hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"))
hl.bind(mainMod .. " + SHIFT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"))
hl.bind(mainMod .. " + CTRL + F6",  hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"))
hl.bind(mainMod .. " + ALT + F6",   hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"))
hl.bind("ALT + F6",                 hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"))

-- User Applications (UserKeybinds.conf)
hl.bind(mainMod .. " + D",       hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window -icon-theme Flat-Remix-Blue-Dark"))
hl.bind(mainMod .. " + B",       hl.dsp.exec_cmd(userDefaults.browser or "flatpak run app.zen_browser.zen"))
hl.bind(mainMod .. " + C",       hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("zed"))
hl.bind(mainMod .. " + T",       hl.dsp.exec_cmd("xed"))
hl.bind(mainMod .. " + A",       hl.dsp.exec_cmd("pkill rofi || true && ags -t 'overview'"))
hl.bind(mainMod .. " + Return",  hl.dsp.exec_cmd(userDefaults.term or "ghostty"))
hl.bind(mainMod .. " + E",       hl.dsp.exec_cmd(userDefaults.files or (home .. "/.local/bin/yazi-wrapper")))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("[float; move 15% 5%; size 70% 60%] " .. (userDefaults.term or "ghostty")))

-- Features / Extras Keybinds
hl.bind(mainMod .. " + H",             hl.dsp.exec_cmd(userScriptsDir .. "/KeyHints_Updated.sh"))
hl.bind(mainMod .. " + ALT + R",       hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"))
hl.bind(mainMod .. " + ALT + E",       hl.dsp.exec_cmd(scriptsDir .. "/RofiEmoji.sh"))
hl.bind(mainMod .. " + S",             hl.dsp.exec_cmd(scriptsDir .. "/RofiSearch.sh"))
hl.bind(mainMod .. " + ALT + O",       hl.dsp.exec_cmd(scriptsDir .. "/ChangeBlur.sh"))
hl.bind(mainMod .. " + SHIFT + G",     hl.dsp.exec_cmd(scriptsDir .. "/GameMode.sh"))
hl.bind(mainMod .. " + ALT + L",       hl.dsp.exec_cmd(scriptsDir .. "/ChangeLayout.sh"))
hl.bind(mainMod .. " + ALT + V",       hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"))
hl.bind(mainMod .. " + CTRL + R",      hl.dsp.exec_cmd(scriptsDir .. "/RofiThemeSelector.sh"))
hl.bind(mainMod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("pkill rofi || true && " .. scriptsDir .. "/RofiThemeSelector-modified.sh"))

hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')\""))
hl.bind(mainMod .. " + ALT + mouse_up",   hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')\""))

hl.bind(mainMod .. " + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + CTRL + B",       hl.dsp.exec_cmd(scriptsDir .. "/WaybarStyles.sh"))
hl.bind(mainMod .. " + ALT + B",        hl.dsp.exec_cmd(scriptsDir .. "/WaybarLayout.sh"))

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(userScriptsDir .. "/RofiBeats.sh"))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(userScriptsDir .. "/WallpaperSelect.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(userScriptsDir .. "/WallpaperEffects.sh"))
hl.bind("CTRL + ALT + W",          hl.dsp.exec_cmd(userScriptsDir .. "/WallpaperRandom.sh"))
hl.bind(mainMod .. " + CTRL + O",  hl.dsp.exec_cmd("hyprctl setprop active opaque toggle"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd(scriptsDir .. "/KeyBinds.sh"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(scriptsDir .. "/Animations.sh"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(userScriptsDir .. "/ZshChangeTheme.sh"))
hl.bind("ALT_L + SHIFT_L",         hl.dsp.exec_cmd(scriptsDir .. "/SwitchKeyboardLayout.sh"), { locked = true })
hl.bind(mainMod .. " + ALT + C",   hl.dsp.exec_cmd(userScriptsDir .. "/RofiCalc.sh"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("ronema"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(scriptsDir .. "/AudioSwitcher.sh"))
hl.bind(mainMod .. " + ALT + M",   hl.dsp.exec_cmd(userScriptsDir .. "/MirrorDisplay.sh"))

hl.bind(mainMod .. " + V",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(scriptsDir .. "/Wlogout.sh"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(scriptsDir .. "/Kool_Quick_Settings.sh"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("xfce4-settings-manager"))

-- ============================================================================
-- 7. Autostart Applications (Startup_Apps.conf + initial-boot.sh)
-- ============================================================================

local startupCmds = get_startup_apps(userConfigsDir .. "/Startup_Apps.conf")

hl.on("hyprland.start", function()
    hl.exec_cmd(hyprDir .. "/initial-boot.sh")
    for _, cmd in ipairs(startupCmds) do
        hl.exec_cmd(cmd)
    end
end)
