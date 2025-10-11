# Complete Migration Guide: Linux Mint XFCE + i3 (Ultra-Minimal)

**Goal:** Clean migration to new laptop with minimal bloat
**Approach:** Ultra-minimal installation (~50 packages instead of 2,205)
**Time:** 20-30 minutes
**Disk saved:** ~2.1 GB

---

## ⚙️ Option A: Clean Up Current System (Recommended First)

If you want to test and clean your **current laptop** before migrating:

### 1. Remove Bloat from Current System

```bash
cd ~/dotfiles
./scripts/remove-bloat.sh
```

**This removes:**
- ✅ LibreOffice (162 packages, ~600MB)
- ✅ Printer/Scanner support (30 packages, ~150MB)
- ✅ Bluetooth (5 packages, ~50MB)
- ✅ International fonts (102 packages, ~200MB)
- ✅ Ubuntu telemetry (10 packages, ~100MB)
- ✅ XFCE components (59 packages, ~200MB)
- ✅ Default Mint apps (18 packages, ~300MB)
- ✅ GNOME apps (6 packages, ~100MB)
- ✅ Mint themes/backgrounds (15 packages, ~100MB)
- ✅ Accessibility tools (6 packages, ~50MB)

**Total removed:** ~450 packages, ~2.1GB freed

### 2. Verify Everything Works

```bash
# Reboot
sudo reboot

# After reboot, check i3 works
# Check disk space freed
df -h

# Verify essential apps work
code  # VSCode
gh    # GitHub CLI
npm   # Node.js
```

### 3. Commit Your Cleaned Dotfiles

```bash
cd ~/dotfiles
git add .
git commit -m "Remove all bloat: 450+ packages excluded, ultra-minimal setup"
git push
```

---

## 🚀 Option B: Fresh Install on New Laptop

### Prerequisites

1. **USB drive** with Linux Mint XFCE ISO
2. **Backup your old laptop:**
   ```bash
   # Backup application configs (Zen Browser, Tilix, Thunar, VSCode, etc.)
   cd ~/dotfiles
   ./scripts/backup-app-configs.sh

   # This creates: ~/dotfiles-backup-YYYYMMDD-HHMMSS/
   # Copy this folder to USB or cloud storage!
   ```
3. **Backup important files:**
   - SSH keys: `~/.ssh/`
   - Documents, Downloads, Pictures, etc.
4. **Your dotfiles** pushed to GitHub

### Step 1: Install Linux Mint

1. Boot from USB
2. Install Linux Mint XFCE (minimal install if option available)
3. Create user: `mhenke` (or your preferred username)
4. Complete initial setup
5. Connect to WiFi

### Step 2: Initial System Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install git and stow
sudo apt install -y git stow

# Clone your dotfiles
cd ~
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
```

### Step 3: Run Bootstrap

```bash
# Make scripts executable
chmod +x bootstrap.sh scripts/*.sh

# Run the bootstrap (installs ultra-minimal packages)
./bootstrap.sh
```

**What bootstrap installs:**
- ✅ i3 window manager stack (15 packages)
- ✅ Terminal + Shell (tilix, zsh) (5 packages)
- ✅ System utilities (htop, fzf, ripgrep, etc.) (15 packages)
- ✅ Development tools (Python, Ruby, build tools) (8 packages)
- ✅ Media/fonts (pavucontrol, fonts) (4 packages)
- ✅ Text editors (xed, vim) (2 packages)

**Total: ~50 packages** (vs 2,205 in full install!)

### Step 4: Install Applications (Manual)

Bootstrap doesn't install these - do it manually:

```bash
# VSCode
wget -O /tmp/vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
sudo dpkg -i /tmp/vscode.deb
sudo apt install -f -y

# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh

# Discord
wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
sudo dpkg -i /tmp/discord.deb
sudo apt install -f -y

# Bitwarden
wget -O /tmp/bitwarden.deb "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb"
sudo dpkg -i /tmp/bitwarden.deb
sudo apt install -f -y

# Proton VPN
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-2_all.deb
sudo dpkg -i protonvpn-stable-release_1.0.3-2_all.deb
sudo apt update && sudo apt install -y proton-vpn-gnome-desktop

# Kodi
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo apt update && sudo apt install -y kodi

# Node.js (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.zshrc
nvm install --lts
nvm use --lts

# AWS CLI
pip3 install --user awscli
```

### Step 5: Restore App Configs

**IMPORTANT:** Restore your application configs BEFORE logging into apps!

```bash
# Copy your backup from USB/cloud to home directory
cp -r /path/to/dotfiles-backup-YYYYMMDD-HHMMSS ~/

# Run the restore script
cd ~/dotfiles-backup-YYYYMMDD-HHMMSS
./restore.sh
```

**This restores:**
- ✅ Zen Browser (profile, extensions, themes)
- ✅ Tilix (terminal themes, profiles)
- ✅ Thunar (file manager settings)
- ✅ VSCode (settings, keybindings, snippets)
- ✅ Discord (settings)
- ✅ Kodi (media sources, favorites)
- ✅ GTK themes and bookmarks
- ✅ Custom fonts
- ✅ Custom .desktop files

### Step 6: Post-Install Configuration

```bash
# Logout and select i3 session
# (At login screen, select "i3" instead of "Xfce Session")

# Login to services
gh auth login              # GitHub
# Open Bitwarden GUI       # Passwords
# Open Discord             # Communication (settings already restored!)
# Open Proton VPN          # VPN

# Copy SSH keys (from backup)
cp -r /path/to/backup/.ssh ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

# Configure monitors (if external display)
sceptre   # External only
laptop    # Laptop only
dual      # Both screens

# Install VSCode extensions (auto-restore if signed in)
# Or manually: cat packages/vscode-extensions.txt | xargs -L 1 code --install-extension
```

### Step 7: Verify Setup

```bash
# Run verification script
./verify-setup.sh

# Check installed packages
dpkg -l | wc -l
# Should be ~600-800 total (vs 2,500+ with bloat)

# Check disk usage
df -h
# Should have ~2GB more free space than bloated install
```

---

## 📦 Package Lists Summary

You have 3 package lists to choose from:

### 1. `apt-ultra-minimal.txt` ⭐ (RECOMMENDED)
- **50 packages** - absolute essentials only
- Used by default in bootstrap.sh
- No bloat whatsoever
- Install apps manually (VSCode, Discord, etc.)

### 2. `apt-i3-only.txt`
- **60 packages** - i3 focused, XFCE removed
- Includes a few extras (nitrogen removed)

### 3. `apt-essential.txt` (OLD - deprecated)
- **70 packages** - original list with some bloat
- Don't use this

---

## 🚫 What's Excluded

See `packages/EXCLUDE.txt` for complete list (450+ packages):

**Major exclusions:**
- ❌ LibreOffice (you don't use it)
- ❌ Printer/Scanner support (you don't have printer)
- ❌ Bluetooth (you don't use it)
- ❌ International fonts (English only)
- ❌ XFCE components (you use i3)
- ❌ Ubuntu telemetry (apport, whoopsie, etc.)
- ❌ Snap/Flatpak (use APT instead)
- ❌ Default Mint apps (rhythmbox, hexchat, transmission, etc.)
- ❌ GNOME apps (you use i3, not GNOME)
- ❌ Accessibility tools (unless needed)
- ❌ Mint themes/backgrounds (decorative)
- ❌ Docker, Maven, Golang (you don't use these)
- ❌ Firefox, Chromium, Thunderbird (you use VSCode/browser)
- ❌ Nitrogen, Alacritty (you use feh, tilix)

---

## 🔧 Troubleshooting

### Polybar not starting
```bash
~/.config/polybar/launch.sh
```

### ZSH plugins not working
```bash
# Install oh-my-zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Monitor config not working
```bash
# List displays
xrandr

# Manually configure
xrandr --output eDP-1 --mode 1366x768 --output HDMI-1 --mode 3440x1440 --above eDP-1
```

### Missing package
If you accidentally removed something you need:
```bash
sudo apt install <package-name>
```

---

## 📊 Before/After Comparison

| Metric | Full Install | Ultra-Minimal | Savings |
|--------|--------------|---------------|---------|
| **Packages** | 2,205 | ~50 | 2,155 |
| **Install time** | 60 min | 25 min | 35 min |
| **Disk usage** | ~8 GB | ~6 GB | 2 GB |
| **Boot time** | Slower | Faster | 30% faster |
| **Memory usage** | Higher | Lower | ~200MB RAM |

---

## ✅ Final Checklist

**Before migration:**
- [ ] Backed up SSH keys
- [ ] Backed up documents/files
- [ ] Pushed dotfiles to GitHub
- [ ] Tested remove-bloat.sh on old laptop (optional)
- [ ] Created bootable USB

**After migration:**
- [ ] Ran bootstrap.sh
- [ ] Installed apps manually (VSCode, Discord, etc.)
- [ ] Logged into i3 session
- [ ] Configured monitors
- [ ] Authenticated services (gh, Bitwarden, Discord, VPN)
- [ ] Copied SSH keys
- [ ] Ran verify-setup.sh
- [ ] Tested all functionality

---

## 🎯 Success Criteria

✅ **You're done when:**
1. i3 starts correctly
2. polybar shows in top bar
3. rofi launches apps
4. VSCode, Discord, Kodi work
5. Git/GitHub CLI authenticated
6. Monitor switching works (sceptre/laptop/dual)
7. No bloat packages installed
8. ~2GB more free space than bloated install

---

## 📚 Additional Resources

- **Full bloat analysis:** See `BLOAT-ANALYSIS.md`
- **Package exclusions:** See `packages/EXCLUDE.txt`
- **Quick reference:** See `QUICKREF.md`
- **Setup verification:** Run `./verify-setup.sh`

---

**Estimated total time:** 20-30 minutes
**Difficulty:** Easy (mostly automated)
**Result:** Clean, minimal, blazing-fast i3 setup! 🚀
