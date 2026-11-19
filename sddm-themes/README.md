# SDDM Theme Customizations

## Overview
Custom SDDM themes with multiple pre-configured theme variants. **All configs and backgrounds are version controlled in this dotfiles repository** for easy backup, restoration, and deployment across machines.

**Everything is in dotfiles:**
- ✓ All 12 theme definitions (`configs/theme-*.conf`) plus the active copy
- ✓ All 12 background images (`Backgrounds/*.png` and `*.jpg`) via Git LFS
- ✓ Theme switcher script (`switch-theme.sh`)
- ✓ Fully documented configs with inline comments

**Current Setup:**
- **simple-sddm** - JaKooLit's theme with 12 custom backgrounds
- **12 pre-configured looks** - One definition per wallpaper, with separate login and lock layouts
- **Theme switcher script** - Easy switching between themes
- **Version controlled** - Track changes, sync across machines, never lose configurations

## Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ YOUR DOTFILES (Source of Truth)                             │
│ ~/dotfiles/sddm-themes/simple-sddm/                         │
│ ├── Backgrounds/          (12 images, Git LFS tracked)      │
│ └── configs/              (12 theme configs + active)      │
│     ├── theme-staircase.conf                                │
│     ├── theme-it-guy.conf                                   │
│     ├── theme-space-nebula.conf                             │
│     ├── theme-lofi-chill-room2.conf                         │
│     ├── theme-northern-lights2.conf                         │
│     ├── theme-city-rainy-night.conf                        │
│     ├── theme-lofi-cafe.conf                                │
│     ├── theme-lofi-computer.conf                            │
│     ├── theme-sunset-horizon.conf                           │
│     ├── theme-linux-user-room.conf                          │
│     ├── theme-game-gta.conf                                │
│     ├── theme-city-rain.conf                               │
│     └── theme.conf        (current active config)           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼ sudo ./switch-theme.sh [name]
┌─────────────────────────────────────────────────────────────┐
│ SYSTEM (Active Theme)                                        │
│ /usr/share/sddm/themes/simple-sddm/                         │
│ ├── Backgrounds/          (copied from dotfiles)            │
│ └── theme.conf            (copied from dotfiles)            │
│                                                              │
│ → SDDM reads this on login                                  │
└─────────────────────────────────────────────────────────────┘
```

**Key Points:**
- Dotfiles = source of truth, version controlled
- System files = working copies, overwritten by switch script
- Edit configs in dotfiles, then switch to apply
- All changes committed to git for history and sync

## Scripts

### 1. switch-theme.sh (Primary Tool)
**Switch between theme variants** - Use this for daily theme switching:
```bash
sudo ./switch-theme.sh [theme-name]
```

Features:
- Interactive menu with theme previews
- Automatic background installation
- Backup of previous theme
- Updates both system files and dotfiles

**Rofi menu** — bound to `SUPER+CTRL+L`, no terminal needed:

```bash
./switch-theme.sh --menu     # pick a variant; opens your default terminal for the sudo prompt
./switch-theme.sh --items    # just print the list, formatted "HEADER (slug)"
./switch-theme.sh --desktop lofi-chill-room2   # paint the same image on the desktop (no sudo)
```

`--menu` does both: it applies the login variant, then calls `--desktop` for the same slug.
`--desktop` uses the variant's `Background=` image from the catalog's `Backgrounds/` directory,
sets it with swww, then runs `WallustSwww.sh` once for the desktop palette, lock-screen image,
and matching lock layout. Approved images are imported into this directory rather than
selected from a second copy in `~/Pictures/wallpapers`. A failed desktop step is reported as incomplete.
Each theme's `[General]` section controls SDDM; its `[Lock]` section controls Hyprlock colors and percentage-based clock/unlock placement. Both screens reuse `[General].HeaderText`: Hyprlock shows it above the username/password area, aligned with `UnlockX`, without changing the clock. A blank header hides that label.

Desktop palettes are saved separately for each image and palette mode in Wallust's native cache.
The wallpaper hook uses FastResize directly, avoiding a repeated Kmeans attempt before loading a
cached FastResize palette. Switching back reapplies the saved colors without extracting them again.
Changing the image or generation settings, switching to an uncached palette mode, or clearing
Wallust's cache requires one new generation. Login and lock colors remain fixed in the catalog.

`--menu` reads the terminal from `$term` in `hypr/.config/hypr/UserConfigs/01-UserDefaults.conf`,
matching the other Hyprland menus, and sends a notification when the switch lands.

**Zsh shortcut** — apply login, desktop, and lock styling with one command:

```zsh
source ~/.zshrc             # once in an already-open terminal
theme northern-lights2     # any slug from --list
```

`theme <name>` prompts for sudo for the login step only, then runs `--desktop` as your user.
If the login step fails or sudo is cancelled, the desktop step is skipped.

### 2. lock-theme.py (Shared Lock Layout)

The wallpaper hook selects a catalog entry by the exact background filename, including spaces.
`lock-theme.py` atomically updates `~/.config/hypr/UserConfigs/hyprlock-theme.conf`; do not edit that generated file.
Unlisted wallpapers use the centered Staircase lock layout. Malformed catalog entries are skipped during lookup; invalid `[Lock]` values in an identified theme leave the last valid include intact.
Hours, minutes, and seconds share one clock widget, keeping their spacing stable.
The wallpaper hook resolves image symlinks before updating the current-image pointers, preserving theme identity across reloads.
Desktop Wallust colors remain independent of the curated login/lock palette.

### 3. install-theme.sh (New System Setup)
**Install theme on a new system** or fresh SDDM installation:
```bash
cd ~/dotfiles/sddm-themes
./install-theme.sh [theme-name]

# Or interactive:
./install-theme.sh
```

This will:
- Install base theme if needed (for simple-sddm)
- Copy all backgrounds and configs from dotfiles
- Set proper permissions
- Configure SDDM to use the theme

### 4. backup-sddm-themes.sh (Backup Tool)
**Backup any manual changes** made directly to `/usr/share/sddm/themes/`:
```bash
cd ~/dotfiles/sddm-themes
./backup-sddm-themes.sh
```

This will:
- Detect custom themes in `/usr/share/sddm/themes/`
- Backup modified backgrounds and configs to dotfiles
- Create/update README for each theme
- Show git status for review

**Then commit changes:**
```bash
cd ~/dotfiles
git add sddm-themes/
git commit -m "Update SDDM theme backups"
git push
```

## Currently Backed Up Themes

### simple-sddm
- **Base**: https://github.com/JaKooLit/simple-sddm
- **Images**: 12 backgrounds via Git LFS
- **Modified**: theme.conf with custom settings

**Backgrounds & Theme Configs:**
| File | Size | Config | Header | Colors | Style |
|------|------|--------|--------|--------|-------|
| Staircase.png | 6.5MB | theme-staircase.conf | "NOTHING TO COMMIT" | Magenta/White | Professional, modern |
| IT_guy.png | 1.8MB | theme-it-guy.conf | "HUMAN + MACHINE" | Green/Ivory | Hacker, cyberpunk |
| Space-Nebula.png | 27MB | theme-space-nebula.conf | "PROMPT TO LAUNCH" | Peach/Ivory | Space exploration |
| Lofi-Chill-Room2.jpg | 3.0MiB | theme-lofi-chill-room2.conf | "VIBE CODE HAVEN" | Warm Orange/Ivory | Cozy, relaxed |
| Northern Lights2.jpg | 1.1MiB | theme-northern-lights2.conf | "NEURAL LIGHTS" | Green/Ivory | Aurora, AI |
| City-Rainy-Night.png | 11MiB | theme-city-rainy-night.conf | "NIGHTLY BUILD" | Pink/Ivory | Neon, rainy night |
| Game-GTA.png | 8.3MiB | theme-game-gta.conf | "GRAND THEFT CODE" | Sky Blue/Ivory | Open-world coding |
| City-Rain.png | 5.7MiB | theme-city-rain.conf | "STREAMING TOKENS" | Ice Blue/Ivory | City, AI |
| Lofi-Cafe2.png | 7.5MiB | theme-lofi-cafe.conf | "COFFEE & COMMITS" | Amber/Cream | Night cafe |
| Lofi-Computer.png | 3.6MiB | theme-lofi-computer.conf | "LOCALHOST AFTER HOURS" | Teal/Lavender | Late-night coding |
| Sun-Setting-Horizon.png | 7.2MiB | theme-sunset-horizon.conf | "PUSH BEFORE SUNSET" | Orange/Cream | Sunset landscape |
| Linux-user-Room.png | 9.6MiB | theme-linux-user-room.conf | "ROOTED IN CODE" | Amber/Lavender | Linux workspace |

All theme configs are stored in `simple-sddm/configs/` with full documentation and comments.

## Customizing Themes

### Edit Existing Theme Variant

All theme configs are in dotfiles with **full documentation**:

```bash
# Edit a theme config in dotfiles
vim ~/dotfiles/sddm-themes/simple-sddm/configs/theme-it-guy.conf

# Key settings you can customize:
# - HeaderText: The greeting message
# - AccentColor: Primary highlight color (#hex)
# - MainColor: Text color
# - BackgroundColor: Form background
# - FormPosition: "left", "center", or "right"
# - HourFormat: "HH:mm" (24h) or "hh:mm AP" (12h)

# Apply the changes
sudo ./switch-theme.sh it-guy

# Commit to version control
cd ~/dotfiles
git add sddm-themes/
git commit -m "Update IT Guy theme colors"
git push
```

### Add New Theme Variant

Create a new config for a different background:

```bash
# 1. Copy an existing config as template
cp ~/dotfiles/sddm-themes/simple-sddm/configs/theme-staircase.conf \
   ~/dotfiles/sddm-themes/simple-sddm/configs/theme-myname.conf

# 2. Edit the new config
vim ~/dotfiles/sddm-themes/simple-sddm/configs/theme-myname.conf
# Change: Background="Backgrounds/myimage.png"
# Customize: Colors, header text, form position
# Customize [Lock]: HourColor, MinuteColor, SecondColor, ClockX, ClockY, UnlockX
# Positions are percentages from the left/top (0..100); clock and login panel are separate.

# 3. Add your background image
cp /path/to/myimage.png ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/

# Generate its desktop palette once without applying colors or changing the wallpaper.
wallust run ./simple-sddm/Backgrounds/myimage.png -s -T -b fastresize

# 4. Switch to it
sudo ./switch-theme.sh myname
./switch-theme.sh --desktop myname

# 5. Commit to version control
cd ~/dotfiles
git add sddm-themes/
git commit -m "Add new theme variant: myname"
git push
```

## Switch Between Theme Variants

**Everything is in your dotfiles** - all 12 theme definitions are version controlled in:
```
~/dotfiles/sddm-themes/simple-sddm/configs/
├── theme-staircase.conf       (magenta, "NOTHING TO COMMIT")
├── theme-it-guy.conf          (green, "HUMAN + MACHINE")
├── theme-space-nebula.conf    (peach, "PROMPT TO LAUNCH")
├── theme-lofi-chill-room2.conf (warm orange, "VIBE CODE HAVEN")
├── theme-northern-lights2.conf ("NEURAL LIGHTS")
├── theme-city-rainy-night.conf ("NIGHTLY BUILD")
├── theme-lofi-cafe.conf       ("COFFEE & COMMITS")
├── theme-lofi-computer.conf   ("LOCALHOST AFTER HOURS")
├── theme-sunset-horizon.conf  ("PUSH BEFORE SUNSET")
├── theme-linux-user-room.conf ("ROOTED IN CODE")
├── theme-game-gta.conf        ("GRAND THEFT CODE")
├── theme-city-rain.conf       ("STREAMING TOKENS")
└── theme.conf                 (symlink/copy of current active theme)
```

### Using the Theme Switcher (Recommended)

**List available themes** - No sudo required:
```bash
cd ~/dotfiles/sddm-themes
./switch-theme.sh --list    # or -l
```

Shows all 12 themes with their headers, backgrounds, and login color schemes.

**Interactive mode** - Select from a menu:
```bash
sudo ./switch-theme.sh
```

**Direct selection** - Switch immediately:
```bash
sudo ./switch-theme.sh staircase
sudo ./switch-theme.sh it-guy
sudo ./switch-theme.sh space-nebula
sudo ./switch-theme.sh lofi-chill-room2
```

The script will:
1. ✓ Copy the theme config from dotfiles to `/usr/share/sddm/themes/simple-sddm/theme.conf`
2. ✓ Ensure the background image is installed
3. ✓ Backup your previous theme automatically
4. ✓ Update the dotfiles default config
5. ✓ Changes appear on next login/logout

### Manual Method

```bash
# Copy desired theme config
sudo cp ~/dotfiles/sddm-themes/simple-sddm/configs/theme-space-nebula.conf \
        /usr/share/sddm/themes/simple-sddm/theme.conf

# If background is missing, copy it
sudo cp ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/Space-Nebula.png \
        /usr/share/sddm/themes/simple-sddm/Backgrounds/
```

## Git LFS Note
Background images use Git LFS. On new machine:
```bash
sudo apt install git-lfs
git lfs install
git clone https://github.com/mhenke/dotfiles.git
# Images download automatically
```

## Troubleshooting

**Can't read themes directory:**
```bash
sudo chmod -R o+rX /usr/share/sddm/themes/
```

**Theme not showing:**
```bash
# Check config
cat /etc/sddm.conf.d/theme.conf.user

# Check theme exists
ls /usr/share/sddm/themes/

# Check logs
journalctl -u sddm -n 50
```

**Backup finds no themes:**
Only backs up themes that are:
- Owned by your user (not root-only), OR
- Contain a .git directory (customized git repos)

Stock themes installed by packages are NOT backed up (reinstall from package manager).

### Safe Regression Checks

```bash
python3 -m unittest discover -s sddm-themes/tests -p 'test_lock_theme.py' -v
```

Run from the dotfiles root. Tests use a temporary home and fake compositor/palette commands; they do not lock the session or change the desktop.
When PyGObject, Cairo, and Pango are available, the suite also measures the generated clock
markup against a 1920×1200 frame to catch clipped text. Without them, only that native-layout
check is skipped.
