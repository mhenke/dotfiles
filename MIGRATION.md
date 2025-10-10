# Migration Checklist: Old Laptop → New Laptop

## Phase 1: Preparation (On Old Laptop)

### 1.1 Update Dotfiles Repository
- [ ] Run backup script: `cd ~/dotfiles && ./scripts/backup-system.sh`
- [ ] Review generated package lists in `packages/` directory
- [ ] Commit and push changes:
  ```bash
  cd ~/dotfiles
  git add .
  git commit -m "Pre-migration backup $(date +%Y-%m-%d)"
  git push
  ```

### 1.2 Backup Critical Data
- [ ] Export Bitwarden vault (emergency backup)
- [ ] Backup SSH keys: `cp -r ~/.ssh ~/backup-ssh`
- [ ] Backup AWS credentials: `cp -r ~/.aws ~/backup-aws`
- [ ] Export browser bookmarks and passwords
- [ ] Backup ~/Projects and important files
- [ ] Save zsh history: Already backed up in `dotfiles-backup-*/`

### 1.3 Document Custom Configurations
- [ ] List installed PPAs: `ls /etc/apt/sources.list.d/`
- [ ] Document any system modifications
- [ ] Note ProtonVPN login credentials (in Bitwarden)
- [ ] List cron jobs: `crontab -l > ~/cron-backup.txt`

### 1.4 Export Application Data
- [ ] VSCode settings (should auto-sync)
- [ ] Discord: Note servers/settings
- [ ] Kodi: Export library if needed
- [ ] Note any custom keybindings or shortcuts

---

## Phase 2: Fresh Installation (New Laptop)

### 2.1 Install Linux Mint XFCE
- [ ] Download Linux Mint XFCE ISO (latest stable)
- [ ] Create bootable USB drive
- [ ] Boot and install Linux Mint
- [ ] Complete initial setup wizard
- [ ] Connect to WiFi/Ethernet
- [ ] Run initial system update:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

### 2.2 Set Up User Account
- [ ] Use same username as old laptop (recommended: mhenke)
- [ ] Configure basic settings (timezone, language, etc.)
- [ ] Install essential tools:
  ```bash
  sudo apt install -y git curl wget
  ```

---

## Phase 3: Automated Setup (New Laptop)

### 3.1 Clone Dotfiles
```bash
cd ~
git clone https://github.com/YOUR-USERNAME/dotfiles.git
cd dotfiles
```

### 3.2 Run Bootstrap Script
```bash
./bootstrap.sh
```

This will:
- Install all system packages (i3, polybar, rofi, etc.)
- Install development tools (Node.js, Ruby, Python, AWS CLI)
- Install applications (VSCode, Bitwarden, Discord, etc.)
- Set up zsh with oh-my-zsh and plugins
- Symlink all dotfiles with GNU Stow
- Restore VSCode extensions

**Duration:** 20-30 minutes depending on internet speed

### 3.3 Reboot
```bash
sudo reboot
```

---

## Phase 4: Post-Installation (New Laptop)

### 4.1 Select i3 Session
- [ ] At login screen, click session selector
- [ ] Choose "i3"
- [ ] Login

### 4.2 Configure Git
```bash
git config --global user.name "Michael Henke"
git config --global user.email "henke.mike@gmail.com"
```

### 4.3 Authenticate Services

**GitHub CLI:**
```bash
gh auth login
# Select: GitHub.com → HTTPS → Authenticate via browser
```

**Bitwarden:**
- [ ] Launch Bitwarden
- [ ] Login with master password
- [ ] Enable browser integration

**Discord:**
- [ ] Launch Discord
- [ ] Login with credentials

**ProtonVPN:**
- [ ] Download from: https://protonvpn.com/download
- [ ] Install: `sudo dpkg -i protonvpn*.deb`
- [ ] Login with credentials

**VSCode:**
- [ ] Launch VSCode
- [ ] Sign in with GitHub/Microsoft
- [ ] Settings Sync should automatically restore settings

### 4.4 Restore SSH Keys
```bash
# Copy from backup drive or old laptop
cp -r /path/to/backup/.ssh ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

### 4.5 Restore AWS Credentials
```bash
# Copy from backup
cp -r /path/to/backup/.aws ~/
chmod 600 ~/.aws/credentials
```

### 4.6 Configure Displays
If using external monitor:
```bash
# External only (3440x1440)
sceptre

# Laptop only
laptop

# Both screens (dual setup)
dual
```

To make permanent:
- Run arandr: `arandr`
- Configure displays graphically
- Save as `~/.screenlayout/default.sh`
- Add to i3 config: `exec_always ~/.screenlayout/default.sh`

---

## Phase 5: Verification & Testing

### 5.1 Test i3 Functionality
- [ ] Test keybindings (Mod+Enter for terminal, Mod+d for rofi)
- [ ] Check polybar displays correctly
- [ ] Test workspace switching (Mod+1-9)
- [ ] Verify window tiling works
- [ ] Test rofi launcher and power menu

### 5.2 Test Applications
- [ ] Terminal (tilix): Open and test
- [ ] VSCode: Open project, verify extensions
- [ ] Browser: Check bookmarks restored
- [ ] Bitwarden: Verify vault accessible
- [ ] Discord: Check messages load

### 5.3 Test Development Environment
```bash
# Node.js
node --version
npm --version

# Ruby
ruby --version
bundle --version
jekyll --version

# Python
python3 --version
pip3 --version

# AWS
aws --version

# GitHub
gh --version

# Git
git --version
```

### 5.4 Test Shell Configuration
- [ ] Open new terminal - should be zsh with af-magic theme
- [ ] Test aliases: `ghpr`, `update`, `sceptre`
- [ ] Test zsh plugins (autosuggestions, syntax highlighting)
- [ ] Test fzf: `Ctrl+R` for history search
- [ ] Test z: `z Downloads` (may need to build history)

---

## Phase 6: Data Migration

### 6.1 Transfer Projects
```bash
# From old laptop, compress projects
tar -czf projects-backup.tar.gz ~/Projects

# Transfer via USB, scp, or rsync
# On new laptop:
tar -xzf projects-backup.tar.gz -C ~/
```

### 6.2 Browser Data
- [ ] Import bookmarks
- [ ] Sign into browser sync
- [ ] Install extensions (uBlock Origin, etc.)

### 6.3 Application-Specific Data
- [ ] Kodi: Import library if backed up
- [ ] Any game saves or configs

---

## Phase 7: Customization & Fine-Tuning

### 7.1 i3 Customization
Edit `~/.config/i3/config`:
- [ ] Adjust keybindings if needed
- [ ] Configure startup applications
- [ ] Set wallpaper: Add `exec_always feh --bg-scale /path/to/wallpaper`

### 7.2 Polybar Customization
Edit `~/.config/polybar/config.ini`:
- [ ] Adjust modules shown
- [ ] Change colors/theme
- [ ] Restart polybar: `~/.config/polybar/launch.sh`

### 7.3 Rofi Theme
- [ ] Test different themes: `rofi-theme-selector`
- [ ] Current configs in `~/.config/rofi/`

### 7.4 Terminal Theme
- [ ] Tilix: Right-click → Preferences → Colors
- [ ] Choose color scheme

---

## Troubleshooting

### Issue: Polybar not appearing
**Solution:**
```bash
killall polybar
~/.config/polybar/launch.sh
```

### Issue: i3 keybindings not working
**Solution:**
- Check Mod key is set correctly (usually Mod4 = Super/Windows key)
- Reload i3: `Mod+Shift+r`

### Issue: Rofi not launching
**Solution:**
```bash
# Test rofi directly
rofi -show drun

# Check if rofi is installed
which rofi
```

### Issue: ZSH plugins not working
**Solution:**
```bash
# Reinstall plugins
rm -rf ~/.oh-my-zsh/custom/plugins/*
cd ~/dotfiles
./scripts/install-dev-tools.sh
```

### Issue: VSCode extensions not restored
**Solution:**
```bash
cd ~/dotfiles
cat packages/vscode-extensions.txt | xargs -L 1 code --install-extension
```

### Issue: Display configuration not saved
**Solution:**
```bash
# Use arandr to configure, then save
arandr
# Layout → Save As → ~/.screenlayout/default.sh

# Add to i3 config
echo "exec_always ~/.screenlayout/default.sh" >> ~/.config/i3/config
```

---

## Post-Migration Cleanup (Old Laptop)

- [ ] Verify all important data transferred
- [ ] Securely wipe sensitive data if donating/selling
- [ ] Keep as backup machine or repurpose

---

## Time Estimates

| Phase | Duration |
|-------|----------|
| Phase 1: Preparation | 30 min |
| Phase 2: Fresh Install | 30 min |
| Phase 3: Automated Setup | 30 min |
| Phase 4: Post-Install | 45 min |
| Phase 5: Verification | 20 min |
| Phase 6: Data Migration | Varies (30min - 2hrs) |
| Phase 7: Customization | 30 min |
| **Total** | **~4 hours** |

---

## Quick Reference Commands

```bash
# Update system
update

# Monitor configurations
sceptre    # External only
laptop     # Laptop only
dual       # Both screens

# GitHub
gh auth login
gh pr list
ghco       # GitHub Copilot

# Restart i3 services
mod+shift+r                    # Reload i3
~/.config/polybar/launch.sh    # Restart polybar
killall picom && picom &       # Restart compositor

# Dotfiles management
cd ~/dotfiles
stow -t ~ <package>     # Install package
stow -D -t ~ <package>  # Remove package
stow -R -t ~ <package>  # Restow package
git pull && stow -R -t ~ */    # Update all
```

---

## Success Criteria

Migration is complete when:
- ✅ i3 session loads and functions correctly
- ✅ All applications launch successfully
- ✅ Development environment works (node, npm, ruby, python, aws, gh)
- ✅ Shell has all customizations (zsh, theme, plugins, aliases)
- ✅ Can access all services (GitHub, Bitwarden, Discord, ProtonVPN)
- ✅ Projects are accessible and working
- ✅ Display configuration is saved and loads on boot
- ✅ All keybindings and shortcuts work as expected
