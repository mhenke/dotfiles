# Themes & Customization Transfer Guide
## Nordic Dark Theme Setup Across All Applications

**Theme**: Nordic (Nord color palette - arctic blue/dark gray)
**Style**: Dark mode everywhere
**Icons**: Papirus-Dark
**Cursor**: Bibata-Modern-Classic
**Font**: FiraCode Nerd Font

---

## 🎨 Complete Theme Ecosystem

Your setup uses a **consistent Nordic/Nord theme** across all applications:

- **GTK Apps** (Thunar, xed, etc.): Nordic GTK theme
- **i3**: Nord colors (custom config)
- **polybar**: Nord colors (custom config)
- **picom**: Nord shadow colors
- **rofi**: Nord theme (nord.rasi)
- **dunst**: Nord colors
- **tilix**: Nord color scheme (nord.json)
- **VSCode**: Cobalt2 theme (blue/dark with Nord-like colors)
- **Zen Browser**: Dark mode + custom themes
- **Icons**: Papirus-Dark (system-wide)
- **Cursor**: Bibata-Modern-Classic

---

## 📁 Theme Files in Dotfiles (Managed by Stow)

### ✅ Already in Dotfiles

These are **already tracked** and will be transferred automatically via `stow`:

```
~/dotfiles/
├── i3/.config/i3/config                    # Nord color scheme built-in
├── polybar/.config/polybar/config.ini       # Nord colors defined
├── picom/.config/picom/picom.conf          # Nord shadow colors
├── rofi/.config/rofi/theme/nord.rasi       # Nord theme for rofi
├── tilix/.config/tilix/schemes/nord.json   # Nord terminal colors
├── dunst/.config/dunst/dunstrc             # Nord notification colors
├── gtk/.config/gtk-3.0/settings.ini        # Theme preferences
│   ├── gtk-theme-name=Nordic
│   ├── gtk-icon-theme-name=Papirus-Dark
│   └── gtk-cursor-theme-name=Bibata-Modern-Classic
└── zsh/.zshrc                               # Shell appearance
```

### ⚠️ NOT in Dotfiles (Need Manual Installation)

These **cannot be managed by Stow** (they're binary themes, not configs):

1. **Nordic GTK Theme** (`~/.themes/Nordic/`)
   - Full GTK2/GTK3/GTK4 theme with assets
   - Must be installed separately on new machine

2. **Papirus Icon Theme** (system package)
   - Available via apt: `papirus-icon-theme`

3. **Bibata Cursor Theme** (`~/.icons/Bibata-Modern-Classic/`)
   - Must be downloaded/installed separately

4. **VSCode Theme** (Cobalt2)
   - Installed via VSCode extensions
   - Auto-syncs if signed into VSCode

5. **Zen Browser Themes**
   - Stored in browser profile
   - Need to backup/restore browser profile

6. **FiraCode Nerd Font**
   - Available via apt: `fonts-firacode`

---

## 🚀 Installation Guide for New Machine

### Step 1: Install Base Packages (Bootstrap Handles This)

```bash
# These are in apt-ultra-minimal.txt:
sudo apt install -y \
    fonts-firacode \
    fonts-font-awesome \
    fonts-powerline \
    fonts-noto-color-emoji \
    papirus-icon-theme \
    lxappearance
```

### Step 2: Install Nordic GTK Theme

**Option A: From GitHub (Recommended)**
```bash
cd /tmp
git clone https://github.com/EliverLara/Nordic.git
sudo cp -r Nordic /usr/share/themes/
# OR for user-only:
mkdir -p ~/.themes
cp -r Nordic ~/.themes/
```

**Option B: From Package (if available)**
```bash
# Check if available in repos
apt search nordic-theme
```

### Step 3: Install Bibata Cursor Theme

```bash
cd /tmp
wget -qO Bibata.tar.gz https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.gz
tar -xzf Bibata.tar.gz
mkdir -p ~/.icons
mv Bibata-Modern-Classic ~/.icons/
```

### Step 4: Apply Dotfiles with Stow

```bash
cd ~/dotfiles
./scripts/setup-stow.sh
# This automatically applies:
# - gtk settings (Nordic theme preference)
# - tilix Nord color scheme
# - rofi Nord theme
# - i3/polybar/picom Nord colors
# - dunst Nord colors
```

### Step 5: Verify GTK Theme with lxappearance

```bash
lxappearance
# Select:
# - Widget: Nordic
# - Icon Theme: Papirus-Dark
# - Mouse Cursor: Bibata-Modern-Classic
# - Default Font: Sans 10
```

**Note:** Your `gtk/.config/gtk-3.0/settings.ini` already has these preferences, but lxappearance ensures they're applied correctly.

### Step 6: Install VSCode Theme (Auto-Synced)

If you sign into VSCode with your Microsoft/GitHub account:
- Cobalt2 theme will auto-install via Settings Sync
- All extensions in `packages/vscode-extensions.txt` will install

**Manual installation (if needed):**
```bash
code --install-extension wesbos.theme-cobalt2
```

### Step 7: Zen Browser Theme

Zen Browser themes are stored in the browser profile. To transfer:

**Option A: Sync Account (Easiest)**
- Sign into Zen Browser with your account
- Themes should sync automatically

**Option B: Manual Profile Transfer**
```bash
# On old machine - backup:
cp -r ~/.zen ~/dotfiles-backup/zen-profile

# On new machine - restore:
cp -r ~/dotfiles-backup/zen-profile ~/.zen
```

---

## 🎨 Theme Color Reference (Nord Palette)

All your configs use these **Nord colors** consistently:

```bash
# Polar Night (Dark)
nord0  = #2E3440  # Background
nord1  = #3B4252  # Background lighter
nord2  = #434C5E  # Selection background
nord3  = #4C566A  # Comments, borders

# Snow Storm (Light)
nord4  = #D8DEE9  # Foreground dim
nord5  = #E5E9F0  # Foreground
nord6  = #ECEFF4  # Foreground bright

# Frost (Blue/Cyan)
nord7  = #8FBCBB  # Frost cyan
nord8  = #88C0D0  # Frost blue (primary accent)
nord9  = #81A1C1  # Frost darker blue
nord10 = #5E81AC  # Frost darkest blue (secondary accent)

# Aurora (Colors)
nord11 = #BF616A  # Red (errors, alerts)
nord12 = #D08770  # Orange
nord13 = #EBCB8B  # Yellow
nord14 = #A3BE8C  # Green (success)
nord15 = #B48EAD  # Purple
```

These colors are used in:
- i3 (window borders, workspace indicators)
- polybar (modules, separators)
- picom (shadow colors)
- rofi (background, selection, text)
- dunst (notification colors)
- tilix (terminal palette)

---

## 📦 What Stow Manages vs. Manual Installation

### ✅ Stow Manages (Symlinked from ~/dotfiles)

**Configuration files only:**
- i3 config with Nord colors
- polybar config with Nord colors
- picom config with Nord shadow
- rofi Nord theme (nord.rasi)
- tilix Nord color scheme (nord.json)
- dunst Nord colors
- gtk settings.ini (theme PREFERENCES, not the theme itself)
- zsh config

**How it works:**
Stow creates symlinks like:
```
~/.config/i3/config → ~/dotfiles/i3/.config/i3/config
~/.config/tilix/schemes/nord.json → ~/dotfiles/tilix/.config/tilix/schemes/nord.json
```

### ❌ Stow Does NOT Manage (Manual Installation Required)

**Binary theme files and assets:**
- Nordic GTK theme (`/usr/share/themes/Nordic/` or `~/.themes/Nordic/`)
  - Contains gtk-2.0/, gtk-3.0/, gtk-4.0/, assets/, etc.
  - Too large and not user-specific config

- Papirus icons (`/usr/share/icons/Papirus-Dark/`)
  - System-wide icon theme
  - Installed via apt package

- Bibata cursor (`~/.icons/Bibata-Modern-Classic/`)
  - Binary cursor theme files
  - Not a text config

- FiraCode fonts (`/usr/share/fonts/`)
  - System-wide fonts
  - Installed via apt

**Why not in dotfiles?**
1. **Large binary files** (GTK themes have images, icons have thousands of SVGs)
2. **System-wide** (not user-specific)
3. **Available via package managers** (easier to install via apt/download)
4. **License issues** (some themes can't be redistributed in your repo)

---

## 🔧 Application-Specific Theme Details

### GTK Apps (Thunar, xed, etc.)

**Theme**: Nordic GTK theme
**Managed by**: `~/.config/gtk-3.0/settings.ini` (in dotfiles)
**Applied by**: lxappearance or manual edit

Your gtk settings.ini specifies:
```ini
gtk-theme-name=Nordic
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-application-prefer-dark-theme=1
```

This tells all GTK apps to use Nordic theme if it's installed.

### Tilix Terminal

**Theme**: Nord color scheme
**File**: `~/dotfiles/tilix/.config/tilix/schemes/nord.json`
**Managed by**: Stow ✅

Colors:
- Background: #2E3440 (nord0)
- Foreground: #D8DEE9 (nord4)
- 16-color palette matching Nord

### Rofi Launcher

**Theme**: Nord (custom)
**File**: `~/dotfiles/rofi/.config/rofi/theme/nord.rasi`
**Managed by**: Stow ✅

Applied in i3 config:
```bash
rofi -show drun -icon-theme "Papirus-Dark"
```

### i3 Window Manager

**Theme**: Nord colors (built into config)
**File**: `~/dotfiles/i3/.config/i3/config`
**Managed by**: Stow ✅

Window border colors defined:
```bash
client.focused          #5E81AC (nord10)
client.focused_inactive #4C566A (nord3)
client.unfocused        #3B4252 (nord1)
client.urgent           #BF616A (nord11)
```

### Polybar

**Theme**: Nord colors
**File**: `~/dotfiles/polybar/.config/polybar/config.ini`
**Managed by**: Stow ✅

Color definitions match i3 and Nord palette.

### VSCode

**Theme**: Cobalt2 (blue/dark, Nord-like)
**Installation**: VSCode extension
**Managed by**: VSCode Settings Sync

To install manually:
```bash
code --install-extension wesbos.theme-cobalt2
```

Settings in `~/.config/Code/User/settings.json`:
```json
"workbench.colorTheme": "Cobalt2"
"workbench.iconTheme": "material-icon-theme"
```

**Note:** VSCode settings can be added to dotfiles if desired.

### Zen Browser

**Theme**: Custom dark themes + mods
**Location**: `~/.zen/<profile>/zen-themes.json`
**Managed by**: Browser profile backup

**Transfer method:**
1. Sign into Zen account (syncs themes)
2. Or backup/restore `~/.zen/` directory

---

## 📝 Dotfiles Structure - What to Add

Based on best practices, here's what **should** and **shouldn't** be in your dotfiles:

### ✅ Should Be in Dotfiles (Text Configs)

```
~/dotfiles/
├── tilix/
│   └── .config/tilix/schemes/nord.json     ✅ Added
├── rofi/
│   └── .config/rofi/theme/nord.rasi        ✅ Already there
├── gtk/
│   └── .config/gtk-3.0/settings.ini        ✅ Already there
├── dunst/
│   └── .config/dunst/dunstrc               ✅ Already there
├── i3/
│   └── .config/i3/config                   ✅ Already there
├── polybar/
│   └── .config/polybar/config.ini          ✅ Already there
├── picom/
│   └── .config/picom/picom.conf            ✅ Already there
├── zsh/
│   └── .zshrc                               ✅ Already there
└── xed/
    └── .config/xed/...                      ✅ Already there
```

### ❌ Should NOT Be in Dotfiles (Install Separately)

```
# These are too large, binary, or available via package managers:
~/.themes/Nordic/                            ❌ Install from GitHub
~/.icons/Bibata-Modern-Classic/              ❌ Download separately
/usr/share/icons/Papirus-Dark/               ❌ Install via apt
/usr/share/fonts/truetype/firacode/          ❌ Install via apt
~/.zen/                                      ❌ Backup separately
~/.config/Code/                               ❌ Use Settings Sync
```

### 🤔 Optional (Can Be in Dotfiles)

```
# Small, text-based VSCode settings:
vscode/
└── .config/Code/User/
    ├── settings.json                        🤔 Optional
    ├── keybindings.json                     🤔 Optional
    └── snippets/                            🤔 Optional

# Browser user.js (if you customize Firefox/Zen):
browsers/
└── .mozilla/firefox/profile/user.js        🤔 Optional

# Custom scripts:
scripts/
└── .local/bin/                              🤔 Optional
```

---

## 🎯 Final Checklist for New Machine

### After running `./bootstrap.sh`:

- [ ] **GTK Theme**: Install Nordic from GitHub → /usr/share/themes/
- [ ] **Icons**: Verify papirus-icon-theme installed via apt
- [ ] **Cursor**: Download Bibata-Modern-Classic → ~/.icons/
- [ ] **Fonts**: Verify fonts-firacode installed via apt
- [ ] **Stow**: Run `./scripts/setup-stow.sh` (applies all configs)
- [ ] **lxappearance**: Open and verify Nordic/Papirus/Bibata selected
- [ ] **VSCode**: Sign in → Cobalt2 theme auto-installs
- [ ] **Zen Browser**: Sign in → themes sync OR restore profile backup
- [ ] **i3**: Restart i3 (Mod+Shift+r) → verify Nord colors
- [ ] **polybar**: Check top bar → Nord colors applied
- [ ] **rofi**: Launch (Mod+d) → Nord theme visible
- [ ] **tilix**: Open terminal → Nord color scheme active
- [ ] **Verify dark mode**: All apps should use dark theme

---

## 🛠️ Troubleshooting

### GTK apps not using Nordic theme
```bash
# Check if theme is installed:
ls /usr/share/themes/ | grep Nordic
ls ~/.themes/ | grep Nordic

# If not found, install from GitHub:
git clone https://github.com/EliverLara/Nordic.git
sudo cp -r Nordic /usr/share/themes/

# Apply with lxappearance:
lxappearance
```

### Tilix not using Nord colors
```bash
# Verify scheme file exists:
ls ~/.config/tilix/schemes/nord.json

# If not, stow didn't work - manually create:
mkdir -p ~/.config/tilix/schemes
stow -d ~/dotfiles -t ~ tilix

# Then in Tilix: Preferences → Profiles → Colors → Nord
```

### Icons not showing in rofi
```bash
# Install Papirus:
sudo apt install papirus-icon-theme

# Verify:
ls /usr/share/icons/ | grep Papirus
```

### VSCode theme not applying
```bash
# Install Cobalt2 manually:
code --install-extension wesbos.theme-cobalt2

# Set in settings:
# Ctrl+Shift+P → "Preferences: Color Theme" → Cobalt2
```

---

## 📚 Additional Resources

- **Nordic GTK Theme**: https://github.com/EliverLara/Nordic
- **Nord Color Palette**: https://www.nordtheme.com/
- **Papirus Icons**: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
- **Bibata Cursor**: https://github.com/ful1e5/Bibata_Cursor
- **GNU Stow Guide**: https://www.gnu.org/software/stow/manual/stow.html

---

## ✨ Summary

**Your theme setup is:**
- ✅ **Consistent**: Nord/Nordic colors across all apps
- ✅ **Minimal**: Only essential theming, no bloat
- ✅ **Automated**: Most configs managed by stow
- ✅ **Documented**: This guide covers everything

**On new machine, you need to:**
1. Run `./bootstrap.sh` (installs apt packages)
2. Install Nordic GTK theme (from GitHub)
3. Install Bibata cursor (download)
4. Run stow (applies all text configs)
5. Sign into VSCode/Zen (themes sync automatically)

**That's it! Your Nordic dark theme will be identical to your old laptop.** 🎨
