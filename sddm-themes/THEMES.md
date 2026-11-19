# Wallpaper Theme Catalog

## Overview
The twelve `simple-sddm/configs/theme-*.conf` files are the single source of truth for both SDDM login themes and Hyprlock looks. Each complete entry pairs an original image in `simple-sddm/Backgrounds/` with `[General]` login settings and `[Lock]` clock colors and positions. `configs/theme.conf` is the active login source copy, initially Staircase, not another selectable entry.

## Available Themes

The config filename is `theme-<slug>.conf`. Background filenames, including spaces and case, are significant.

| Theme / slug | Background | Welcome header | Login form |
| --- | --- | --- | --- |
| Staircase (default) / `staircase` | `Staircase.png` | NOTHING TO COMMIT | Left |
| Northern Lights2 / `northern-lights2` | `Northern Lights2.jpg` | NEURAL LIGHTS | Left |
| City-Rainy-Night / `city-rainy-night` | `City-Rainy-Night.png` | NIGHTLY BUILD | Left |
| Game-GTA / `game-gta` | `Game-GTA.png` | GRAND THEFT CODE | Right |
| City-Rain / `city-rain` | `City-Rain.png` | STREAMING TOKENS | Right |
| IT Guy / `it-guy` | `IT_guy.png` | HUMAN + MACHINE | Right |
| Space Nebula / `space-nebula` | `Space-Nebula.png` | PROMPT TO LAUNCH | Right |
| Lofi Chill Room2 / `lofi-chill-room2` | `Lofi-Chill-Room2.jpg` | VIBE CODE HAVEN | Left |
| Lofi Cafe 2 / `lofi-cafe` | `Lofi-Cafe2.png` | COFFEE & COMMITS | Right |
| Lofi Computer / `lofi-computer` | `Lofi-Computer.png` | LOCALHOST AFTER HOURS | Left |
| Sunset Horizon / `sunset-horizon` | `Sun-Setting-Horizon.png` | PUSH BEFORE SUNSET | Right |
| Linux User Room / `linux-user-room` | `Linux-user-Room.png` | ROOTED IN CODE | Left |

### Login versus lock screen

- SDDM reads `[General]`: `HeaderText`, `Background`, `BackgroundColor`, `DimBackgroundImage`, `FormPosition`, and its other existing settings. `MainColor` is `#FFF6ED` except Staircase's `#FFFFFF`; `AccentColor` matches the lock's minutes color.
- Hyprlock uses `[Lock]`: `HourColor`, `MinuteColor`, `SecondColor`, `ClockX`, `ClockY`, and `UnlockX`. It also reuses `[General].HeaderText` above the username/password area, aligned with `UnlockX`, 300 pixels above the bottom. A blank header hides that label. The wallpaper hook selects the catalog entry by the exact background basename and renders `~/.config/hypr/UserConfigs/hyprlock-theme.conf`; this generated include is not a second catalog.
- Login panel side, backdrop, dimming, and `HourFormat` do not control the lock layout. The lock always displays hours, minutes, and seconds; Space Nebula retains its existing 12-hour login clock, while the other entries use `HH:mm`.
- **Unlisted images use the centered Staircase lock layout, colors, and welcome header**, never the previously selected image's placement. They do not change the installed login theme.

## Switching Themes

### Using the Theme Switcher Script

From `~/dotfiles/sddm-themes`, inspect the catalog without sudo:
```bash
./switch-theme.sh --list
./switch-theme.sh --items
```

**Login/boot theme only (requires sudo):**
```bash
sudo ./switch-theme.sh                 # interactive selection
sudo ./switch-theme.sh northern-lights2
```

This backs up `/usr/share/sddm/themes/simple-sddm/theme.conf`, installs the selected config and any missing background, and updates `configs/theme.conf`. It does not change the running desktop or lock wallpaper. The installed theme appears at the next normal login.

**Desktop and lock look only (run as your user, never with sudo):**
```bash
./switch-theme.sh --desktop northern-lights2
```

This changes the desktop wallpaper, refreshes its palette, and updates the lock wallpaper and generated lock include through the shared wallpaper hook. It does not write the privileged SDDM installation.

`./switch-theme.sh --menu` provides the existing Rofi picker and applies both parts, prompting for sudo in a terminal for the login installation.

### Manual Method

```bash
# Copy desired theme config
sudo cp ~/dotfiles/sddm-themes/simple-sddm/configs/theme-space-nebula.conf \
        /usr/share/sddm/themes/simple-sddm/theme.conf

# If background is missing, copy it too
sudo cp ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/Space-Nebula.png \
        /usr/share/sddm/themes/simple-sddm/Backgrounds/
```

## Design and Lock Coordinates

Each entry's palette and geometry complement its original image. Edit the catalog entry, not the generated Hyprlock include.

Use quiet image regions for the clock and date, with visible margins and separation from the
bottom unlock controls. Assess positions on the cropped 1920×1200 viewport, not the source
image's pixel dimensions. The approved grouped clock measures about 648×264 pixels there.
Login backdrops should pick up the image's darker hues; declared foreground/background and
button text/accent pairs must retain at least 4.5:1 contrast. Preserve approved headers and
Staircase's gold/magenta/tan clock rather than recoloring every variant for uniformity.

- `[Lock]` colors are quoted six-digit hex values.
- `ClockX` and `ClockY` are the clock's center as percentages of screen width and height, measured from the top-left. For example, normalized `(0.25, 0.20)` is `ClockX="25"` and `ClockY="20"`.
- `UnlockX` is the horizontal center for the username and password area; it is independent of the clock and the SDDM form side.
- The lock date follows the clock. Shared metadata keeps its existing layout, with text shadows for readability rather than new panels.

## Common Theme Settings

All SDDM entries share:
- **Font**: JetBrainsMono Nerd Font
- **Blur**: Partial blur (radius: 50)
- **Round Corners**: 20px radius
- **Last User**: Preselected; password authentication is still required
- **Password Focus**: Automatic
- **Resolution**: Optimized for 1920x1200

## Customization

To modify a theme:

1. Edit the config file in dotfiles:
   ```bash
   vim ~/dotfiles/sddm-themes/simple-sddm/configs/theme-it-guy.conf
   ```

2. Key settings to customize:
   - `HeaderText`: The main greeting text
   - `AccentColor`: Primary highlight color
   - `MainColor`: Text color
   - `BackgroundColor`: Form background
   - `FormPosition`: "left", "center", or "right"
   - `HourFormat`: "HH:mm" (24h) or "hh:mm AP" (12h)
   - `[Lock]` `HourColor`, `MinuteColor`, `SecondColor`: Lock clock palette; keep `AccentColor` equal to `MinuteColor`
   - `[Lock]` `ClockX`, `ClockY`, `UnlockX`: Screen percentages from 0 to 100

3. Apply login and desktop changes separately:
   ```bash
   sudo ./switch-theme.sh it-guy
   ./switch-theme.sh --desktop it-guy
   ```

## Backup & Restore

The login switch automatically creates a backup:
- Current theme saved to: `/usr/share/sddm/themes/simple-sddm/theme.conf.backup`

To restore previous theme:
```bash
sudo cp /usr/share/sddm/themes/simple-sddm/theme.conf.backup \
        /usr/share/sddm/themes/simple-sddm/theme.conf
```

## Troubleshooting

**Theme not appearing after switch:**
- The installed login theme appears at the next normal login; do not restart SDDM just to preview it.
- The running desktop and lock look require the separate `--desktop` command without sudo.

**Missing background image:**
The switch script automatically copies missing backgrounds from dotfiles.
If manual install needed:
```bash
sudo cp ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/*.{png,jpg} \
        /usr/share/sddm/themes/simple-sddm/Backgrounds/
```

**Colors look wrong:**
SDDM uses Qt color names and hex codes; catalog palette values use quoted hex codes. Edit the source entry and apply the appropriate login or desktop command.

## Adding New Themes

1. Create a new config file:
   ```bash
   cp ~/dotfiles/sddm-themes/simple-sddm/configs/theme-staircase.conf \
      ~/dotfiles/sddm-themes/simple-sddm/configs/theme-myname.conf
   ```

2. Edit the new config:
   - Change `[General]` `Background=` to the exact image filename under `Backgrounds/`
   - Customize login colors, header text, and form position
   - Set all six `[Lock]` keys, using quoted hex colors and percentage positions
   - Keep `[General]` `AccentColor` equal to `[Lock]` `MinuteColor`; login form side and lock positions remain independent

3. Add the background image to:
   ```
   ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/
   ```

4. Apply it as needed:
   ```bash
   sudo ./switch-theme.sh myname             # login/boot only
   ./switch-theme.sh --desktop myname        # desktop and lock only
   ```

## Git LFS Note

PNG and JPG background images use Git LFS, including the original `Northern Lights2.jpg` (not other Northern Lights variants). The switch script copies these source assets from dotfiles, so ensure:
```bash
git lfs pull
```

has been run to download all images.
