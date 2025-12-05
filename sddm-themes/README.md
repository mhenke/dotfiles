# SDDM Theme Customizations

## Overview
Custom SDDM themes with multiple pre-configured theme variants. **All configs and backgrounds are version controlled in this dotfiles repository** for easy backup, restoration, and deployment across machines.

**Everything is in dotfiles:**
- ✓ All 6 theme configuration files (`configs/*.conf`)
- ✓ All 6 background images (`Backgrounds/*.png`) - 37MB via Git LFS
- ✓ Theme switcher script (`switch-theme.sh`)
- ✓ Fully documented configs with inline comments

**Current Setup:**
- **simple-sddm** - JaKooLit's theme with 6 custom backgrounds
- **6 pre-configured theme variants** - Each optimized for its background with custom colors, headers, and layouts
- **Theme switcher script** - Easy switching between themes
- **Version controlled** - Track changes, sync across machines, never lose configurations

## Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ YOUR DOTFILES (Source of Truth)                             │
│ ~/dotfiles/sddm-themes/simple-sddm/                         │
│ ├── Backgrounds/          (6 PNG files, Git LFS tracked)    │
│ └── configs/              (6 theme configs + active)        │
│     ├── theme-staircase.conf                                │
│     ├── theme-it-guy.conf                                   │
│     ├── theme-mecha-nostalgia.conf                          │
│     ├── theme-space-nebula.conf                             │
│     ├── theme-lofi-cafe.conf                                │
│     ├── theme-path.conf                                     │
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

### 2. install-theme.sh (New System Setup)
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

### 3. backup-sddm-themes.sh (Backup Tool)
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
- **Images**: 5 backgrounds (37MB, Git LFS)
- **Modified**: theme.conf with custom settings

**Backgrounds & Theme Configs:**
| File | Size | Config | Header | Colors | Style |
|------|------|--------|--------|--------|-------|
| Staircase.png | 6.5MB | theme-staircase.conf | "MEMBERS ONLY" | Purple/White | Professional, modern |
| IT_guy.png | 1.8MB | theme-it-guy.conf | "ACCESS TERMINAL" | Bright Green | Hacker, cyberpunk |
| Mecha-Nostalgia.png | 1.7MB | theme-mecha-nostalgia.conf | "PLAYER 1 START" | Pink/Cyan | Retro gaming, 80s |
| Space-Nebula.png | 27MB | theme-space-nebula.conf | "MISSION CONTROL" | Orange/White | Space exploration |
| Lofi-Cafe2.png | 7.5MB | theme-lofi-cafe.conf | "CHILL VIBES ONLY" | Warm Orange/Cream | Cozy, relaxed |
| path.png | 318KB | theme-path.conf | "Welcome" | Blue/White | Simple, minimal |

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

# 3. Add your background image
cp /path/to/myimage.png ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/

# 4. Switch to it
sudo ./switch-theme.sh myname

# 5. Commit to version control
cd ~/dotfiles
git add sddm-themes/
git commit -m "Add new theme variant: myname"
git push
```

## Switch Between Theme Variants

**Everything is in your dotfiles** - all 6 theme configs are version controlled in:
```
~/dotfiles/sddm-themes/simple-sddm/configs/
├── theme-staircase.conf       (purple, "MEMBERS ONLY")
├── theme-it-guy.conf          (green, "ACCESS TERMINAL")
├── theme-mecha-nostalgia.conf (pink/cyan, "PLAYER 1 START")
├── theme-space-nebula.conf    (orange, "MISSION CONTROL")
├── theme-lofi-cafe.conf       (warm orange, "CHILL VIBES ONLY")
├── theme-path.conf            (blue, "Welcome")
└── theme.conf                 (symlink/copy of current active theme)
```

### Using the Theme Switcher (Recommended)

**List available themes** - No sudo required:
```bash
cd ~/dotfiles/sddm-themes
./switch-theme.sh --list    # or -l
```

Shows all 6 themes with their headers, backgrounds, and color schemes.

**Interactive mode** - Select from a menu:
```bash
sudo ./switch-theme.sh
```

**Direct selection** - Switch immediately:
```bash
sudo ./switch-theme.sh staircase
sudo ./switch-theme.sh it-guy
sudo ./switch-theme.sh mecha-nostalgia
sudo ./switch-theme.sh space-nebula
sudo ./switch-theme.sh lofi-cafe
sudo ./switch-theme.sh path
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
