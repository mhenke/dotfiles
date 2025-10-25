# SDDM Theme Customizations

## Overview
Custom backgrounds and settings for JaKooLit's simple-sddm theme.

- **Location**: `/usr/share/sddm/themes/simple-sddm/`
- **Base Theme**: https://github.com/JaKooLit/simple-sddm
- **Images**: 5 backgrounds (37MB total, tracked via Git LFS)

## Installation on New Machine

### Quick Install
```bash
cd ~/dotfiles/sddm-themes
./install-theme.sh
```

### Manual Install

1. **Clone base theme**
```bash
cd /tmp
git clone https://github.com/JaKooLit/simple-sddm.git
sudo cp -r simple-sddm /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/simple-sddm
```

2. **Apply customizations**
```bash
cd ~/dotfiles/sddm-themes/simple-sddm

# Copy backgrounds
sudo cp Backgrounds/*.png /usr/share/sddm/themes/simple-sddm/Backgrounds/

# Copy theme config
sudo cp configs/theme.conf /usr/share/sddm/themes/simple-sddm/

# Set permissions
sudo chown -R $USER:$USER /usr/share/sddm/themes/simple-sddm
```

3. **Configure SDDM**
```bash
sudo mkdir -p /etc/sddm.conf.d/
sudo cp configs/sddm.conf.d/theme.conf.user /etc/sddm.conf.d/
```

## Backgrounds

| File | Size | Description |
|------|------|-------------|
| Staircase.png | 6.5MB | Current default |
| Space-Nebula.png | 27MB | Space scene (large!) |
| IT_guy.png | 1.8MB | Tech workspace |
| Mecha-Nostalgia.png | 1.7MB | Retro cyberpunk |
| path.png | 318KB | Original theme |

## Switch Background

**Method 1: Edit theme.conf**
```bash
sudo nano /usr/share/sddm/themes/simple-sddm/theme.conf
```
Change: `Background="Backgrounds/Staircase.png"`

**Method 2: Use script**
```bash
cd ~/dotfiles/sddm-themes
./switch-background.sh
```

Logout to see changes.

## Update Backup

After modifying theme in `/usr/share/sddm/themes/simple-sddm/`:

```bash
cd /usr/share/sddm/themes/simple-sddm
cp Backgrounds/*.png ~/dotfiles/sddm-themes/simple-sddm/Backgrounds/
cp theme.conf ~/dotfiles/sddm-themes/simple-sddm/configs/

cd ~/dotfiles
git add sddm-themes/
git commit -m "Update SDDM theme"
git push
```

## Git LFS Note

Background images are tracked with Git LFS. When cloning dotfiles on new machine:
```bash
git lfs install
git clone https://github.com/mhenke/dotfiles.git
# Images download automatically
```
