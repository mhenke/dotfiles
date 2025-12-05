# SDDM Theme Configurations

## Overview
Custom theme configurations for each background image in the simple-sddm theme. Each config has unique colors, header text, and form positioning to match the aesthetic of its background.

## Available Themes

### 1. Staircase (Default)
- **Config**: `theme-staircase.conf`
- **Background**: `Staircase.png` (6.5MB)
- **Header**: "MEMBERS ONLY"
- **Colors**: Purple accent (#7287fd), white text
- **Form Position**: Left
- **Style**: Professional, modern

### 2. IT Guy / Hacker
- **Config**: `theme-it-guy.conf`
- **Background**: `IT_guy.png` (1.8MB)
- **Header**: "ACCESS TERMINAL"
- **Colors**: Bright green (#00ff88) - terminal/hacker aesthetic
- **Form Position**: Right
- **Style**: Cyberpunk, tech-focused

### 3. Mecha Nostalgia
- **Config**: `theme-mecha-nostalgia.conf`
- **Background**: `Mecha-Nostalgia.png` (1.7MB)
- **Header**: "PLAYER 1 START"
- **Colors**: Pink/magenta (#ff66cc) with cyan accent (#00d9ff)
- **Form Position**: Right
- **Time Format**: 12-hour (AM/PM)
- **Style**: Retro gaming, 80s nostalgia

### 4. Space Nebula
- **Config**: `theme-space-nebula.conf`
- **Background**: `Space-Nebula.png` (27MB)
- **Header**: "MISSION CONTROL"
- **Colors**: Orange accent (#ff8844), white text
- **Form Position**: Right
- **Time Format**: 12-hour (AM/PM)
- **Style**: Space exploration, epic

### 5. Lofi Cafe
- **Config**: `theme-lofi-cafe.conf`
- **Background**: `Lofi-Cafe2.png` (7.5MB)
- **Header**: "CHILL VIBES ONLY"
- **Colors**: Warm orange (#ff9966), cream text (#ffeedd)
- **Form Position**: Left
- **Style**: Cozy, relaxed, lofi aesthetic

### 6. Path (Minimal)
- **Config**: `theme-path.conf`
- **Background**: `path.png` (318KB)
- **Header**: "Welcome"
- **Colors**: Blue accent (#5599ff), white text
- **Form Position**: Center
- **Style**: Simple, clean, minimal

## Switching Themes

### Using the Theme Switcher Script

**Interactive mode:**
```bash
cd ~/dotfiles/sddm-themes
sudo ./switch-theme.sh
```

**Direct theme selection:**
```bash
sudo ./switch-theme.sh staircase
sudo ./switch-theme.sh it-guy
sudo ./switch-theme.sh mecha-nostalgia
sudo ./switch-theme.sh space-nebula
sudo ./switch-theme.sh lofi-cafe
sudo ./switch-theme.sh path
```

The script will:
1. Copy the selected theme config to `/usr/share/sddm/themes/simple-sddm/theme.conf`
2. Ensure the background image is installed
3. Backup your previous theme
4. Update the dotfiles default config

### Manual Method

```bash
# Copy desired theme config
sudo cp ~/dotfiles/sddm-themes/simple-sddm/configs/theme-space-nebula.conf \
        /usr/share/sddm/themes/simple-sddm/theme.conf

# If background is missing, copy it too
sudo cp ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/Space-Nebula.png \
        /usr/share/sddm/themes/simple-sddm/Backgrounds/
```

## Design Philosophy

Each theme is customized to complement its background:

- **Form Position**: Placed to avoid obscuring key visual elements
- **Colors**: Match the dominant/accent colors in the background
- **Header Text**: Reflects the mood/theme of the image
- **Shadow Opacity**: Adjusted based on background brightness

## Common Theme Settings

All themes share:
- **Font**: JetBrainsMono Nerd Font
- **Blur**: Partial blur (radius: 50)
- **Round Corners**: 20px radius
- **Auto-login Last User**: Enabled
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

3. Apply the changes:
   ```bash
   sudo ./switch-theme.sh it-guy
   ```

## Backup & Restore

The switch script automatically creates backups:
- Current theme saved to: `/usr/share/sddm/themes/simple-sddm/theme.conf.backup`

To restore previous theme:
```bash
sudo cp /usr/share/sddm/themes/simple-sddm/theme.conf.backup \
        /usr/share/sddm/themes/simple-sddm/theme.conf
```

## Troubleshooting

**Theme not appearing after switch:**
- Log out and log back in to see changes
- Or restart SDDM: `sudo systemctl restart sddm` (will log you out)

**Missing background image:**
The switch script automatically copies missing backgrounds from dotfiles.
If manual install needed:
```bash
sudo cp ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/*.png \
        /usr/share/sddm/themes/simple-sddm/Backgrounds/
```

**Colors look wrong:**
SDDM uses Qt color names and hex codes. Test changes in the config file and reload.

## Adding New Themes

1. Create a new config file:
   ```bash
   cp ~/dotfiles/sddm-themes/simple-sddm/configs/theme-staircase.conf \
      ~/dotfiles/sddm-themes/simple-sddm/configs/theme-myname.conf
   ```

2. Edit the new config:
   - Change `Background=` to your image filename
   - Customize colors, header text, and form position

3. Add the background image to:
   ```
   ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/
   ```

4. Switch to it:
   ```bash
   sudo ./switch-theme.sh myname
   ```

## Git LFS Note

Background images use Git LFS (37MB total). The switch script handles copying from dotfiles, so ensure:
```bash
git lfs pull
```

has been run to download all images.
