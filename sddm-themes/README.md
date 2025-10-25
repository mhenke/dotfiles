# SDDM Theme Customizations

## Overview
Custom SDDM themes backed up from `/usr/share/sddm/themes/`.

Currently backed up:
- **simple-sddm** - JaKooLit's theme with custom backgrounds (37MB via Git LFS)

## Scripts

### Backup Custom Themes
Backs up any custom SDDM themes (owned by you or with .git directory):
```bash
cd ~/dotfiles/sddm-themes
./backup-sddm-themes.sh
```

This will:
- Detect custom themes in `/usr/share/sddm/themes/`
- Backup modified backgrounds and configs
- Create/update README for each theme
- Show git status for review

**Then commit changes:**
```bash
cd ~/dotfiles
git add sddm-themes/
git commit -m "Update SDDM theme backups"
git push
```

### Install Themes
Install backed up theme to new system:
```bash
cd ~/dotfiles/sddm-themes
./install-theme.sh [theme-name]

# Or interactive:
./install-theme.sh
```

This will:
- Install base theme if needed (for simple-sddm)
- Copy backgrounds and configs from dotfiles
- Set proper permissions
- Configure SDDM to use the theme

## Currently Backed Up Themes

### simple-sddm
- **Base**: https://github.com/JaKooLit/simple-sddm
- **Images**: 5 backgrounds (37MB, Git LFS)
- **Modified**: theme.conf with custom settings

**Backgrounds:**
| File | Size | Description |
|------|------|-------------|
| Staircase.png | 6.5MB | Current default |
| Space-Nebula.png | 27MB | Space scene |
| IT_guy.png | 1.8MB | Tech workspace |
| Mecha-Nostalgia.png | 1.7MB | Retro cyberpunk |
| path.png | 318KB | Original |

## Add New Theme

If you customize another SDDM theme:

1. Make changes in `/usr/share/sddm/themes/your-theme/`
2. Run backup script:
   ```bash
   cd ~/dotfiles/sddm-themes
   ./backup-sddm-themes.sh
   ```
3. Commit to git:
   ```bash
   git add sddm-themes/
   git commit -m "Add new SDDM theme: your-theme"
   git push
   ```

## Switch Active Theme

**Method 1: Use install script**
```bash
cd ~/dotfiles/sddm-themes
./install-theme.sh your-theme-name
```

**Method 2: Manual**
```bash
sudo nano /etc/sddm.conf.d/theme.conf.user
# Change: Current=simple-sddm
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
