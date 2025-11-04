# Additional Packages for Stow Migration

**Date**: October 25, 2025
**Addendum to**: STOW-MIGRATION-PLAN.md

---

## Additional Tools to Add to Dotfiles

Based on your regular usage, add these packages to the dotfiles structure:

### 1. AWS CLI Configuration
```
dotfiles/
└── aws/
    └── .aws/
        ├── config          # AWS CLI configuration
        └── credentials     # ⚠️ ENCRYPTED or .gitignore!
```

**IMPORTANT - Security**:
```bash
# Option A: Don't track credentials (recommended)
echo ".aws/credentials" >> ~/dotfiles/.gitignore
echo ".aws/sso/" >> ~/dotfiles/.gitignore

# Option B: Encrypt credentials with GPG
cd ~/dotfiles
gpg --encrypt --recipient your@email.com aws/.aws/credentials
# Then .gitignore the unencrypted version
```

**Stow setup**:
```bash
cd ~/dotfiles
mkdir -p aws/.aws
cp ~/.aws/config aws/.aws/
# DON'T copy credentials directly - handle separately

stow --target=$HOME aws
```

---

### 2. Thunar File Manager
```
dotfiles/
└── thunar/
    └── .config/
        └── Thunar/
            ├── accels.scm    # Keyboard shortcuts
            └── uca.xml       # Custom actions
```

**Stow setup**:
```bash
cd ~/dotfiles
mkdir -p thunar/.config
cp -r ~/.config/Thunar thunar/.config/

stow --target=$HOME thunar
```

---

### 3. Zen Browser Configuration

**Challenge**: Zen is a Flatpak, configs are in different location:
```
~/.var/app/app.zen_browser.zen/
```

**Solutions**:

#### Option A: Document Profile Export/Import (Recommended)
```
dotfiles/
└── zen-browser/
    ├── README.md              # Export/import instructions
    ├── export-profile.sh      # Script to backup profile
    └── import-profile.sh      # Script to restore profile
```

#### Option B: Symlink Flatpak Data (Advanced)
```
dotfiles/
└── zen-browser/
    └── .var/
        └── app/
            └── app.zen_browser.zen/
                └── config/       # Zen preferences
```

**Recommendation**: Use Option A because:
- Zen browser profiles are large
- Contain cache and temp files
- Better to export/import bookmarks & settings
- Less brittle than symlinking Flatpak internals

---

### 4. Tilix Terminal (You Already Have This!)

Looking at your existing dotfiles, you have:
```
dotfiles/tilix/
└── tilix.dconf
```

**Keep this!** Even though you're using kitty in Hyprland, you might want tilix for XFCE sessions.

**Note**: The existing structure uses dconf dump/load:
```bash
# Export (already done)
dconf dump /com/gexperts/Tilix/ > tilix.dconf

# Import on new machine
dconf load /com/gexperts/Tilix/ < tilix.dconf
```

This is **NOT managed by Stow** (dconf doesn't use files). Keep the current setup!

---

### 5. Git + Zsh (You Already Have These!)

Your existing dotfiles already include:
```
dotfiles/
├── git/
│   └── .gitconfig
└── zsh/
    ├── .zshrc
    ├── .zsh_aliases (if you have it)
    └── plugins/ (if tracked)
```

**Zsh Plugins** - Two approaches:

#### Current Approach (Keep):
If you use oh-my-zsh, plugins are installed in:
```
~/.oh-my-zsh/custom/plugins/
```

These are typically Git submodules or cloned separately. Don't stow them - instead:

```bash
# Document in README how to install plugins
# Example:
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

#### Alternative (If You Want):
```
dotfiles/
└── zsh/
    ├── .zshrc
    └── .oh-my-zsh/
        └── custom/
            └── plugins/    # Custom plugins
```

But this gets large! Better to document installation in bootstrap.sh

---

## Updated Dotfiles Structure

```
dotfiles/
├── .git/
├── .gitignore                      # UPDATE: Add AWS credentials
├── .stow-local-ignore
├── README.md                       # UPDATE: Document all tools
├── bootstrap.sh                    # UPDATE: Add new tools
├── Makefile
│
├── _archived/                      # i3 ecosystem (not using anymore)
│   ├── i3/
│   ├── polybar/
│   ├── picom/
│   └── dunst/
│
├── # ========== KEEP & UPDATE ==========
├── git/                            # ✅ Already have
│   └── .gitconfig
├── zsh/                            # ✅ Already have
│   └── .zshrc
├── gtk/                            # ✅ Already have
├── htop/                           # ✅ Already have
├── mc/                             # ✅ Already have
├── rofi/                           # ✅ Already have (works in Hyprland!)
├── xed/                            # ✅ Already have
├── tilix/                          # ✅ Already have (keep for XFCE)
│   └── tilix.dconf                 # Special: dconf dump/load
│
├── # ========== NEW: Hyprland ==========
├── hypr/
├── waybar/
├── swaync/
├── kitty/
├── swappy/
├── wlogout/
├── wallust/
├── cava/
├── btop/
├── fastfetch/
│
├── # ========== NEW: XFCE ==========
├── xfce4/
├── thunar/                         # 🆕 ADD THIS
│
├── # ========== NEW: LLM Tools ==========
├── continue/
├── zed/
├── goose/
├── ollama/
│
├── # ========== NEW: Cloud & Apps ==========
├── aws/                            # 🆕 ADD THIS
│   └── .aws/
│       ├── config
│       └── credentials.gpg         # Encrypted!
└── zen-browser/                    # 🆕 ADD THIS
    ├── README.md                   # Export/import docs
    ├── export-profile.sh
    └── import-profile.sh
```

---

## Updated .gitignore

Add to `~/dotfiles/.gitignore`:

```bash
# AWS credentials (security!)
.aws/credentials
.aws/sso/
.aws/**/*.json

# Zen browser cache/temp
zen-browser/.var/**/Cache/
zen-browser/.var/**/cache*/
zen-browser/.var/**/tmp/

# Zsh history (personal)
.zsh_history
.zhistory

# SSH keys (never commit!)
.ssh/id_*
.ssh/*.pem
```

---

## Updated Makefile

```makefile
.PHONY: stow unstow restow list help

# All packages (alphabetical)
PACKAGES := aws btop cava continue fastfetch git goose gtk htop \
            hypr kitty mc rofi swappy swaync thunar wallust \
            waybar wlogout xed xfce4 zed zsh

# Note: tilix uses dconf, not stowed

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Packages managed: $(words $(PACKAGES))"
	@echo ""
	@echo "Usage:"
	@echo "  make stow      - Stow all packages"
	@echo "  make unstow    - Unstow all packages"
	@echo "  make restow    - Restow all packages"
	@echo "  make list      - List all packages"

stow:
	@echo "Stowing all packages..."
	@stow --verbose --target=$$HOME --restow $(PACKAGES)
	@echo ""
	@echo "⚠️  Remember to handle separately:"
	@echo "  - AWS credentials (encrypted)"
	@echo "  - Tilix (dconf load)"
	@echo "  - Ollama (systemd override)"

unstow:
	@stow --verbose --target=$$HOME --delete $(PACKAGES)

restow:
	@stow --verbose --target=$$HOME --restow $(PACKAGES)

list:
	@echo "Stow-managed packages:"
	@echo "$(PACKAGES)" | tr ' ' '\n' | sort
	@echo ""
	@echo "Manually managed:"
	@echo "  - tilix (dconf)"
	@echo "  - ollama (systemd)"
	@echo "  - aws credentials (encrypted)"
```

---

## Security Best Practices

### AWS Credentials

**Never commit unencrypted credentials!**

Option 1: GPG Encryption
```bash
cd ~/dotfiles/aws/.aws
gpg --encrypt --recipient your@email.com credentials
# Creates credentials.gpg

# Add to .gitignore
echo "credentials" >> ~/dotfiles/.gitignore

# On new machine:
gpg --decrypt credentials.gpg > ~/.aws/credentials
chmod 600 ~/.aws/credentials
```

Option 2: Don't Track (Recommended)
```bash
# Add to .gitignore
echo ".aws/credentials" >> ~/dotfiles/.gitignore
echo ".aws/sso/" >> ~/dotfiles/.gitignore

# Document in README how to set up AWS CLI
# Users run: aws configure
```

### SSH Keys

Same approach - NEVER commit:
```bash
# .gitignore
.ssh/id_*
.ssh/*.pem
.ssh/*.key
```

---

## Setup Commands

### Add New Packages to Dotfiles

```bash
cd ~/dotfiles

# Add Thunar
mkdir -p thunar/.config
cp -r ~/.config/Thunar thunar/.config/
stow --target=$HOME thunar

# Add AWS (config only, not credentials!)
mkdir -p aws/.aws
cp ~/.aws/config aws/.aws/
# Handle credentials separately (see Security section)

# Add Zen browser export scripts
mkdir zen-browser
cat > zen-browser/export-profile.sh << 'EOF'
#!/bin/bash
# Export Zen browser profile
PROFILE_DIR=~/.var/app/app.zen_browser.zen/.zen/

if [ ! -d "$PROFILE_DIR" ]; then
  echo "Zen profile not found!"
  exit 1
fi

# Find default profile
PROFILE=$(find $PROFILE_DIR -maxdepth 1 -name "*.default*" -type d | head -n 1)

if [ -z "$PROFILE" ]; then
  echo "No default profile found!"
  exit 1
fi

echo "Exporting from: $PROFILE"

# Backup important files
mkdir -p zen-profile-backup
cp "$PROFILE/places.sqlite" zen-profile-backup/  # Bookmarks & history
cp "$PROFILE/prefs.js" zen-profile-backup/       # Preferences
cp -r "$PROFILE/extensions" zen-profile-backup/  # Extensions (if not synced)

tar -czf zen-profile-$(date +%Y%m%d).tar.gz zen-profile-backup/
rm -rf zen-profile-backup/

echo "✓ Exported to: zen-profile-$(date +%Y%m%d).tar.gz"
EOF

chmod +x zen-browser/export-profile.sh

# Commit everything
git add .
git commit -m "Add Thunar, AWS, and Zen browser configs"
git push
```

---

## Summary of Changes

### ✅ Already in Your Dotfiles (Keep)
- git
- zsh
- rofi
- gtk
- htop
- mc
- xed
- tilix (dconf-based)

### 🆕 Need to Add
- thunar (file manager)
- aws (AWS CLI config - handle credentials securely!)
- zen-browser (export/import scripts)

### ♻️ Archive (Not Using Anymore)
- i3
- polybar
- picom
- dunst

### 🚀 Already Planned in Main Document
- Hyprland ecosystem
- LLM tools
- XFCE
- systemd/ollama

---

## Final Package Count

**Total Stow Packages**: ~25
- Hyprland: 9 packages
- LLM/AI: 4 packages
- Desktop: 2 packages (XFCE, Thunar)
- Base tools: 8 packages (git, zsh, gtk, htop, mc, rofi, xed, aws)

**Manually Managed**: 3
- Tilix (dconf)
- Ollama (systemd)
- AWS credentials (encrypted/manual)

**Archived**: 4
- i3, polybar, picom, dunst (i3 ecosystem)

---

## Next Steps

1. ✅ Read main plan: `~/STOW-MIGRATION-PLAN.md`
2. 🆕 Add packages from this addendum
3. 🔒 Handle AWS credentials securely
4. 📦 Follow migration steps from main plan
5. 🎯 Enjoy organized, portable dotfiles!

---

**See STOW-MIGRATION-PLAN.md for complete implementation guide!**
