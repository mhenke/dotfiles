# First-Time Setup Guide

This guide helps you set up your dotfiles on a fresh system or resolve configuration conflicts.

## Issues You're Seeing

1. **ProtonVPN 404 Error** - Old repository URL no longer works
2. **Stow Conflicts** - Existing config files conflict with symlinks
3. **Tilix VTE Warning** - Terminal configuration needed
4. **i3 First-Run Prompt** - i3 wants to create default config

## Step-by-Step Resolution

### Step 1: Clean Up ProtonVPN Repository

```bash
# Remove corrupted ProtonVPN files
sudo rm -f /etc/apt/sources.list.d/protonvpn.list
sudo rm -f /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg

# Update apt to clear errors
sudo apt update
```

### Step 2: Fix Stow Conflicts

**Option A: Automated (Recommended)**
```bash
cd ~/dotfiles
bash scripts/fix-stow-conflicts.sh
```

This will:
- Create a timestamped backup directory
- Back up your existing `.gitconfig`, `i3/config`, `.zshrc`
- Remove the conflicting files
- Check for other potential conflicts

**Option B: Manual**
```bash
# Create backup directory
mkdir -p ~/dotfiles-backup

# Backup and remove conflicts
cp ~/.gitconfig ~/dotfiles-backup/ && rm ~/.gitconfig
cp ~/.config/i3/config ~/dotfiles-backup/ && rm ~/.config/i3/config
cp ~/.zshrc ~/dotfiles-backup/ && rm ~/.zshrc
```

### Step 3: Run Stow Setup

```bash
cd ~/dotfiles
bash scripts/setup-stow.sh
```

This will symlink all your dotfiles from the repo to your home directory.

### Step 4: Fix Tilix VTE Configuration

The Tilix warning is because your shell doesn't have the VTE configuration. Add this to your shell:

**For zsh (already in our .zshrc, just needs activation):**
```bash
# After Stow, start a new zsh shell
zsh

# Or logout and login again
```

**Manual fix if needed:**
```bash
echo 'if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    source /etc/profile.d/vte.sh
fi' >> ~/.zshrc

# Reload
source ~/.zshrc
```

### Step 5: Verify i3 Configuration

After Stow completes, your i3 config should be properly symlinked:

```bash
ls -la ~/.config/i3/config
# Should show: .config/i3/config -> ../../dotfiles/i3/.config/i3/config
```

When you press **Enter** at the i3 first-run prompt:
- **Press ESC** to skip i3's default config generation
- Your dotfiles config will already be in place via Stow

Or just log out and log back into i3 - it will use the existing config.

### Step 6: Install ProtonVPN (If Needed)

If ProtonVPN isn't installed yet, re-run the app installation:

```bash
cd ~/dotfiles

# Option 1: Run just step 3 (applications)
bash bootstrap.sh
# Then choose: 3

# Option 2: Manual ProtonVPN only
wget https://repo2.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb -O /tmp/protonvpn-release.deb
sudo dpkg -i /tmp/protonvpn-release.deb
rm /tmp/protonvpn-release.deb
sudo apt update
sudo apt install -y proton-vpn-gnome-desktop
```

## Complete Fresh System Setup

If you're setting up a completely new system, use the bootstrap:

```bash
cd ~/dotfiles
bash bootstrap.sh
```

Choose:
- `y` - Run all steps (full setup)
- `1-5` - Start from specific step
- `1,3,5` - Run specific steps only

## Verification Checklist

After setup, verify everything is working:

- [ ] `git status` in ~/dotfiles shows clean working tree
- [ ] `ls -la ~/.zshrc` shows symlink to dotfiles repo
- [ ] `ls -la ~/.config/i3/config` shows symlink to dotfiles repo
- [ ] Open new terminal - no Tilix VTE warning
- [ ] i3 loads with your custom config (Nord colors, polybar, etc.)
- [ ] `sudo apt update` - no ProtonVPN errors

## Troubleshooting

### Stow still shows conflicts
```bash
# Check what's conflicting
stow -t ~ --verbose=2 -n git i3 zsh

# Remove the specific file and try again
rm ~/.config/path/to/conflicting/file
bash scripts/setup-stow.sh
```

### i3 keeps showing first-run prompt
```bash
# Force remove i3's first-run flag
rm -f ~/.config/i3/config

# Re-run Stow
cd ~/dotfiles
stow -t ~ i3
```

### Tilix warning persists
```bash
# Check if VTE script exists
ls -la /etc/profile.d/vte*.sh

# If it exists, manually source it
echo 'if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    [[ -f /etc/profile.d/vte.sh ]] && source /etc/profile.d/vte.sh
fi' >> ~/.zshrc
```

## Backup Location

Your original configs are backed up to:
```
~/dotfiles-backup-YYYYMMDD-HHMMSS/
```

Keep this directory until you verify everything works correctly.

## Next Steps After Setup

1. Logout and login (to apply zsh as default shell)
2. Select "i3" session at login screen
3. Login to services:
   - GitHub: `gh auth login`
   - Bitwarden
   - Discord
   - Proton VPN
   - Zen Browser (Firefox sync)
4. Copy SSH keys if needed:
   ```bash
   cp -r /backup/.ssh ~/
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/*
   ```
5. VSCode should auto-sync if signed in

## Monitor Configuration

Use these aliases to switch monitor setups:
- `sceptre` - External monitor only (3440x1440)
- `laptop` - Laptop screen only
- `dual` - Both screens (external above/left of laptop)
