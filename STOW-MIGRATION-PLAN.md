# GNU Stow Migration Plan: Hyprland + LLM Optimizations

> **Historical planning doc (2025-10-25).** Commands below predate the lua
> config migration — `hyprland.lua` is the active config, `hyprland.conf` is
> retired (see `docs/adr/0007-hyprland-lua-active-config.md`).

**Date**: October 25, 2025
**System**: Linux Mint 22.1 / Ubuntu 24.04
**Migration**: i3wm → Hyprland + XFCE + LLM Stack

---

## Executive Summary

Based on research of GNU Stow best practices and analysis of your existing dotfiles setup, here's the comprehensive plan to manage your new Hyprland + LLM configurations with Stow.

**Key Findings from Research**:
1. ✅ Your existing ~/dotfiles structure follows Stow best practices perfectly
2. ✅ JaKooLit's Hyprland dotfiles can be adapted to Stow structure
3. ✅ Multiple users successfully manage Hyprland + Waybar + Rofi with Stow
4. ⚠️ Systemd service overrides need special handling (user vs system services)
5. ✅ LLM tool configs (.continue, zed, goose) fit standard Stow patterns

---

## Part 1: Your Existing Dotfiles Structure (Analysis)

### Current Setup
```
~/dotfiles/
├── .git/                  # Git repo (good!)
├── .gitignore            # Proper ignores configured
├── bootstrap.sh          # Automated setup script
├── README.md            # Documentation
├── packages/            # Package lists
└── [stow packages]/     # i3 ecosystem configs
    ├── i3/              # i3wm (OLD - to be replaced)
    ├── polybar/         # Status bar (OLD - replaced by waybar)
    ├── picom/           # Compositor (OLD - not needed in Wayland)
    ├── rofi/            # Already have! (Compatible with Hyprland)
    ├── dunst/           # Notifications (replaced by swaync in Hyprland)
    ├── git/             # Git config (KEEP)
    ├── gtk/             # GTK themes (KEEP)
    ├── htop/            # HTOP config (KEEP)
    ├── mc/              # Midnight Commander (KEEP)
    ├── tilix/           # Terminal (replaced by kitty in Hyprland)
    ├── xed/             # Text editor (KEEP for XFCE)
    └── zsh/             # Shell config (KEEP)
```

**Structure Pattern** (each package):
```
packagename/
└── .config/
    └── packagename/
        └── config files
```

This correctly mirrors `~/.config/packagename/` → perfect for Stow!

---

## Part 2: New Configurations to Add

### Hyprland Ecosystem (from JaKooLit)
```
New packages to create:
├── hypr/              # Hyprland window manager
├── waybar/            # Status bar (replaces polybar)
├── swaync/            # Notifications (replaces dunst)
├── kitty/             # Terminal (replaces tilix)
├── swappy/            # Screenshot annotation
├── wlogout/           # Logout menu
├── wallust/           # Wallpaper theming
├── cava/              # Audio visualizer
├── btop/              # System monitor
└── fastfetch/         # System info
```

### LLM/AI Configurations
```
New AI tool packages:
├── continue/          # Continue.dev for VS Code
├── zed/               # Zed editor
├── goose/             # Goose AI agent
└── ollama/            # Ollama service config (special handling!)
```

### XFCE Configurations
```
Keep XFCE for dual session support:
└── xfce4/             # XFCE desktop environment
```

---

## Part 3: Directory Structure (Complete Plan)

### Recommended ~/dotfiles/ Layout

```
dotfiles/
├── .git/
├── .gitignore
├── .stow-local-ignore          # NEW: Stow-specific ignores
├── README.md                   # UPDATE: Document Hyprland + LLM setup
├── bootstrap.sh                # UPDATE: Hyprland + LLM installation
├── Makefile                    # NEW: Automate stow/unstow operations
│
├── packages/                   # Package manager lists
│   ├── apt.txt                 # UPDATE: Add Hyprland packages
│   ├── flatpak.txt             # NEW: Flatpak apps (VS Code, Zen)
│   ├── npm-global.txt          # Keep as-is
│   ├── gems.txt                # Keep as-is
│   └── ollama-models.txt       # NEW: Ollama models to install
│
├── scripts/                    # Helper scripts
│   ├── stow-all.sh             # NEW: Stow all packages
│   ├── unstow-old.sh           # NEW: Remove i3 ecosystem
│   ├── install-hyprland.sh     # NEW: Hyprland setup
│   └── install-llm-stack.sh    # NEW: LLM tools setup
│
├── systemd/                    # NEW: Systemd user services
│   └── .config/
│       └── systemd/
│           └── user/
│               ├── ollama-local.service    # User service wrapper
│               └── README.md               # Systemd override docs
│
│ # ========== KEEP (Update for Hyprland) ==========
├── git/
│   └── .gitconfig
├── gtk/
│   └── .config/
│       └── gtk-3.0/
│           └── settings.ini
├── htop/
│   └── .config/
│       └── htop/
│           └── htoprc
├── mc/
│   └── .config/
│       └── mc/
│           └── ini
├── rofi/                       # UPDATE: Compatible with Hyprland
│   └── .config/
│       └── rofi/
│           ├── config.rasi
│           └── themes/
├── xed/
│   └── .config/
│       └── xed/
│           └── preferences
├── zsh/
│   ├── .zshrc
│   ├── .zsh_aliases
│   └── .zsh_functions
│
│ # ========== ARCHIVE (i3 ecosystem - keep for reference) ==========
├── _archived/                  # NEW: Move old configs here
│   ├── i3/
│   ├── polybar/
│   ├── picom/
│   ├── dunst/
│   └── tilix/
│
│ # ========== NEW: Hyprland Ecosystem ==========
├── hypr/
│   └── .config/
│       └── hypr/
│           ├── hyprland.conf
│           ├── hyprpaper.conf
│           ├── hypridle.conf
│           ├── hyprlock.conf
│           ├── scripts/
│           ├── UserScripts/
│           └── UserConfigs/      # User customizations
│
├── waybar/
│   └── .config/
│       └── waybar/
│           ├── config.jsonc
│           ├── style.css
│           └── modules
│
├── swaync/
│   └── .config/
│       └── swaync/
│           ├── config.json
│           └── style.css
│
├── kitty/
│   └── .config/
│       └── kitty/
│           ├── kitty.conf
│           └── themes/
│
├── swappy/
│   └── .config/
│       └── swappy/
│           └── config
│
├── wlogout/
│   └── .config/
│       └── wlogout/
│           ├── layout
│           └── style.css
│
├── wallust/
│   └── .config/
│       └── wallust/
│           └── wallust.toml
│
├── cava/
│   └── .config/
│       └── cava/
│           └── config
│
├── btop/
│   └── .config/
│       └── btop/
│           └── btop.conf
│
├── fastfetch/
│   └── .config/
│       └── fastfetch/
│           └── config.jsonc
│
│ # ========== NEW: XFCE (for dual session) ==========
├── xfce4/
│   └── .config/
│       └── xfce4/
│           ├── xfconf/
│           └── panel/
│
│ # ========== NEW: LLM/AI Tools ==========
├── continue/
│   └── .continue/
│       ├── config.yaml
│       └── .continuerc.json
│
├── zed/
│   └── .config/
│       └── zed/
│           ├── settings.json
│           └── keymap.json
│
├── goose/
│   └── .config/
│       └── goose/
│           └── config.yaml
│
└── ollama/
    ├── ollama-override.conf    # Template for manual install
    └── README.md               # Instructions for systemd override
```

---

## Part 4: Special Considerations

### 1. Ollama Systemd Service Override

**Problem**: Ollama service override is in `/etc/systemd/system/ollama.service.d/performance.conf` (system-level, requires sudo)

**Solutions** (choose one):

#### Option A: Document Manual Install (Recommended)
```bash
# In dotfiles/ollama/
ollama/
├── performance.conf        # Template file
└── README.md              # Installation instructions
```

In README.md:
```markdown
# Ollama Service Override

This config must be installed manually (requires sudo):

sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp performance.conf /etc/systemd/system/ollama.service.d/
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

#### Option B: User Service Alternative
```bash
# Create user service in systemd/ package
systemd/
└── .config/
    └── systemd/
        └── user/
            └── ollama.service   # Full user service definition
```

Then use: `systemctl --user enable ollama`

**Recommendation**: Use Option A (document manual install) because:
- Ollama is already installed as system service
- Keeps existing setup working
- Simple one-time manual step documented in dotfiles

### 2. JaKooLit Hyprland Configs

**Challenge**: JaKooLit's configs use a custom update system (`upgrade.sh`) that manages `UserConfigs/`

**Solution**:
1. **Initial migration**: Copy current JaKooLit configs to `~/dotfiles/hypr/`
2. **Going forward**:
   - Edit files in `~/dotfiles/hypr/.config/hypr/`
   - Symlinks mean changes auto-apply to `~/.config/hypr/`
   - Don't use JaKooLit's `upgrade.sh` (conflicts with Stow)
   - Manually merge JaKooLit updates if needed

### 3. Continue.dev Location

**Issue**: Continue config is at `~/.continue/` (not in `~/.config/`)

**Solution**: Use this structure:
```
continue/
└── .continue/       # Mirrors ~/.continue/
    ├── config.yaml
    └── .continuerc.json
```

Stow will create `~/.continue/` symlink correctly!

### 4. Files to NOT Stow

Create `.stow-local-ignore` in `~/dotfiles/`:
```
# Ignore version control
\.git
\.gitignore
\.gitmodules

# Ignore documentation
README.*
\.md$
LICENSE
CONTRIBUTING

# Ignore scripts
bootstrap\.sh
Makefile
^scripts

# Ignore package lists
^packages

# Ignore archived configs
^_archived

# Ignore backup files
\.backup$
\.bck$
\.old$
~$

# Ignore system-specific
\.DS_Store
\.directory
```

---

## Part 5: Migration Steps

### Step 1: Backup Current Setup

```bash
cd ~
# Backup existing dotfiles repo
cp -r dotfiles dotfiles-backup-$(date +%Y%m%d)

# Backup current live configs (in case of issues)
tar -czf ~/config-backup-$(date +%Y%m%d).tar.gz \
  ~/.config/hypr \
  ~/.config/waybar \
  ~/.config/kitty \
  ~/.config/zed \
  ~/.continue \
  ~/.config/goose \
  ~/.zshrc
```

### Step 2: Prepare Dotfiles Repository

```bash
cd ~/dotfiles

# Create _archived directory and move old i3 stuff
mkdir _archived
mv i3 polybar picom dunst tilix _archived/

# Create .stow-local-ignore
cat > .stow-local-ignore << 'EOF'
\.git
\.gitignore
README.*
\.md$
LICENSE
bootstrap\.sh
Makefile
^scripts
^packages
^_archived
\.backup$
\.old$
~$
\.DS_Store
EOF

# Commit the restructuring
git add .
git commit -m "Archive i3 ecosystem, prepare for Hyprland migration"
```

### Step 3: Create New Stow Packages

```bash
cd ~/dotfiles

# Create Hyprland package structure
mkdir -p hypr/.config
cp -r ~/.config/hypr hypr/.config/

# Create Waybar package
mkdir -p waybar/.config
cp -r ~/.config/waybar waybar/.config/

# Create other Hyprland ecosystem packages
for pkg in swaync kitty swappy wlogout wallust cava btop fastfetch; do
  mkdir -p $pkg/.config
  cp -r ~/.config/$pkg $pkg/.config/
done

# Create XFCE package
mkdir -p xfce4/.config
cp -r ~/.config/xfce4 xfce4/.config/

# Create LLM tool packages
mkdir -p zed/.config
cp -r ~/.config/zed zed/.config/

mkdir -p goose/.config
cp -r ~/.config/goose goose/.config/

mkdir -p continue
cp -r ~/.continue continue/

# Create Ollama package (documentation only)
mkdir -p ollama
cp /etc/systemd/system/ollama.service.d/performance.conf ollama/
cat > ollama/README.md << 'EOF'
# Ollama Service Override

Manual installation required (one-time setup):

\`\`\`bash
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp performance.conf /etc/systemd/system/ollama.service.d/
sudo systemctl daemon-reload
sudo systemctl restart ollama
\`\`\`

Verify:
\`\`\`bash
systemctl status ollama
\`\`\`
EOF
```

### Step 4: Test Stow (Dry Run)

```bash
cd ~/dotfiles

# Test WITHOUT making changes (--simulate)
stow --simulate --verbose --target=$HOME hypr
stow --simulate --verbose --target=$HOME waybar
stow --simulate --verbose --target=$HOME zed

# Check for conflicts
# If you see "WARNING: existing target is not owned by stow"
# You'll need to move those files first
```

### Step 5: Handle Conflicts

If Stow reports conflicts:

```bash
# Option A: Backup existing files
mv ~/.config/hypr ~/.config/hypr.pre-stow

# Option B: Adopt existing files (merges them into stow)
stow --adopt --target=$HOME hypr
# WARNING: This overwrites files in ~/dotfiles/hypr with your current configs
# Review changes with: git diff
```

### Step 6: Stow All Packages

```bash
cd ~/dotfiles

# Stow Hyprland ecosystem
stow --target=$HOME hypr waybar swaync kitty swappy wlogout wallust cava btop fastfetch

# Stow LLM tools
stow --target=$HOME zed goose continue

# Stow XFCE
stow --target=$HOME xfce4

# Stow existing packages (if not already stowed)
stow --target=$HOME git gtk htop mc rofi xed zsh

# Verify symlinks
ls -la ~/.config/hypr  # Should show: .config/hypr -> ../dotfiles/hypr/.config/hypr
ls -la ~/.zshrc        # Should show: .zshrc -> dotfiles/zsh/.zshrc
```

### Step 7: Create Automation Scripts

```bash
cd ~/dotfiles/scripts

# Create stow-all.sh
cat > stow-all.sh << 'EOF'
#!/bin/bash
# Stow all configuration packages

cd "$(dirname "$0")/.."

HYPR_PKGS="hypr waybar swaync kitty swappy wlogout wallust cava btop fastfetch"
LLM_PKGS="zed goose continue"
XFCE_PKGS="xfce4"
BASE_PKGS="git gtk htop mc rofi xed zsh"

echo "Stowing Hyprland packages..."
stow --target=$HOME $HYPR_PKGS

echo "Stowing LLM tools..."
stow --target=$HOME $LLM_PKGS

echo "Stowing XFCE..."
stow --target=$HOME $XFCE_PKGS

echo "Stowing base packages..."
stow --target=$HOME $BASE_PKGS

echo "✓ All packages stowed!"
EOF

chmod +x stow-all.sh

# Create unstow-all.sh
cat > unstow-all.sh << 'EOF'
#!/bin/bash
# Unstow all configuration packages

cd "$(dirname "$0")/.."

HYPR_PKGS="hypr waybar swaync kitty swappy wlogout wallust cava btop fastfetch"
LLM_PKGS="zed goose continue"
XFCE_PKGS="xfce4"
BASE_PKGS="git gtk htop mc rofi xed zsh"

stow --delete --target=$HOME $HYPR_PKGS $LLM_PKGS $XFCE_PKGS $BASE_PKGS

echo "✓ All packages unstowed!"
EOF

chmod +x unstow-all.sh
```

### Step 8: Create Makefile (Optional)

```bash
cd ~/dotfiles

cat > Makefile << 'EOF'
.PHONY: stow unstow restow list help

PACKAGES := hypr waybar swaync kitty swappy wlogout wallust cava btop fastfetch \
            zed goose continue xfce4 git gtk htop mc rofi xed zsh

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make stow      - Stow all packages"
	@echo "  make unstow    - Unstow all packages"
	@echo "  make restow    - Restow all packages (update symlinks)"
	@echo "  make list      - List all packages"

stow:
	@echo "Stowing all packages..."
	@stow --verbose --target=$$HOME --restow $(PACKAGES)

unstow:
	@echo "Unstowing all packages..."
	@stow --verbose --target=$$HOME --delete $(PACKAGES)

restow:
	@echo "Restowing all packages..."
	@stow --verbose --target=$$HOME --restow $(PACKAGES)

list:
	@echo "Available packages:"
	@echo "$(PACKAGES)" | tr ' ' '\n'
EOF
```

### Step 9: Update README.md

```bash
cd ~/dotfiles

# Add sections for:
# - Hyprland setup
# - LLM tools (Ollama, Continue, Zed, Goose)
# - XFCE dual session
# - Updated package lists
# - New stow automation
```

### Step 10: Commit Everything

```bash
cd ~/dotfiles

git add .
git commit -m "Migrate to Hyprland + LLM stack

- Add Hyprland ecosystem (waybar, swaync, kitty, etc.)
- Add LLM tools (Zed, Goose, Continue, Ollama docs)
- Add XFCE for dual session support
- Archive i3 ecosystem to _archived/
- Add .stow-local-ignore for proper file exclusions
- Add automation scripts (stow-all.sh, Makefile)
- Update documentation for new setup"

git push
```

---

## Part 6: Daily Workflow

### Making Config Changes

```bash
# Edit configs in ~/dotfiles/ (they're symlinked to ~/.config/)
vim ~/dotfiles/hypr/.config/hypr/hyprland.conf

# Changes are immediately active (symlinked!)
# Just reload Hyprland: Super+Shift+R

# Commit changes
cd ~/dotfiles
git add hypr/
git commit -m "Update Hyprland keybindings"
git push
```

### Adding New Package

```bash
cd ~/dotfiles

# Create package structure
mkdir -p newapp/.config
cp -r ~/.config/newapp newapp/.config/

# Stow it
stow --target=$HOME newapp

# Add to automation
# Edit Makefile and add 'newapp' to PACKAGES list

# Commit
git add newapp/
git add Makefile
git commit -m "Add newapp configuration"
```

### New Machine Setup

```bash
# 1. Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# 2. Install Stow
sudo apt install stow

# 3. Stow everything
cd ~/dotfiles
make stow

# OR use script:
./scripts/stow-all.sh

# 4. Install Ollama override manually
cd ~/dotfiles/ollama
cat README.md  # Follow instructions

# Done! All configs are now symlinked
```

---

## Part 7: Best Practices Learned from Research

### ✅ DO

1. **Mirror directory structure exactly**
   - `~/dotfiles/package/.config/app/` → `~/.config/app/`
   - Stow automatically creates parent directories

2. **One package per application**
   - Easier to manage
   - Can selectively install/uninstall
   - Clear organization

3. **Use .stow-local-ignore**
   - Ignore documentation
   - Ignore git files
   - Ignore build artifacts

4. **Version control everything**
   - Git repo with regular commits
   - Push to GitHub/GitLab
   - Easy to sync across machines

5. **Document special cases**
   - Ollama systemd override
   - Manual setup steps
   - Dependencies

6. **Test with --simulate first**
   - Catch conflicts before applying
   - Safer migrations

### ❌ DON'T

1. **Don't include sensitive data**
   - No SSH keys
   - No AWS credentials
   - No passwords
   - Use .gitignore

2. **Don't mix package files with docs**
   - Keep README.md at repo root
   - Don't put docs inside package directories (they'd get stowed)

3. **Don't manually edit symlinked files**
   - Always edit in `~/dotfiles/`
   - Symlinks make this transparent anyway

4. **Don't forget to commit**
   - Easy to lose changes
   - Commit after each logical change

5. **Don't stow everything blindly**
   - Some configs are machine-specific
   - Use different branches for different machines if needed

---

## Part 8: Advanced Patterns

### Machine-Specific Configs

**Option 1: Branches**
```bash
# Main branch: common configs
git checkout main

# Machine-specific branch
git checkout -b laptop-thinkpad
# Edit machine-specific configs
git commit -m "Laptop-specific display settings"
```

**Option 2: Separate packages**
```
dotfiles/
├── hypr-desktop/
├── hypr-laptop/
└── hypr-common/

# On desktop: stow hypr-common hypr-desktop
# On laptop: stow hypr-common hypr-laptop
```

### Conditional Stowing

Create `scripts/smart-stow.sh`:
```bash
#!/bin/bash

# Detect desktop environment
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  stow hypr waybar swaync
elif [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]; then
  stow xfce4
fi

# Always stow base packages
stow git zsh gtk
```

---

## Part 9: Troubleshooting

### Issue: "WARNING: existing target is not owned by stow"

**Cause**: Files exist in `~/.config/` that aren't symlinks

**Solution**:
```bash
# Option 1: Backup and remove
mv ~/.config/hypr ~/.config/hypr.backup
stow hypr

# Option 2: Adopt (merge into dotfiles)
stow --adopt hypr
git status  # Check what changed
git diff    # Review changes
```

### Issue: Stow creates wrong directory structure

**Cause**: Package structure doesn't mirror target

**Solution**:
```bash
# WRONG:
package/
└── config.ini   # Would create ~/config.ini

# RIGHT:
package/
└── .config/
    └── package/
        └── config.ini   # Creates ~/.config/package/config.ini
```

### Issue: Changes in dotfiles don't apply

**Cause**: Not actually symlinked

**Solution**:
```bash
# Check if symlinked
ls -la ~/.config/hypr

# Should show: hypr -> ../../dotfiles/hypr/.config/hypr
# If not symlinked, need to stow:
cd ~/dotfiles
stow --restow hypr
```

### Issue: Git shows untracked files after stow --adopt

**Cause**: --adopt moved files from ~/ into ~/dotfiles/

**Solution**:
```bash
cd ~/dotfiles
git status        # Review what was adopted
git diff         # Check changes
git add .
git commit -m "Adopt existing configs"
```

---

## Part 10: Summary & Next Steps

### What You'll Have

✅ **Organized dotfiles** - All configs in one place
✅ **Version controlled** - Git tracking all changes
✅ **Portable** - Easy setup on new machines
✅ **Modular** - Install only what you need
✅ **Documented** - Clear README and inline docs
✅ **Automated** - Scripts for common operations
✅ **Safe** - Backups and dry-run testing

### Your Dotfiles Will Manage

**Hyprland Ecosystem**:
- hypr, waybar, swaync, kitty, rofi, wlogout, wallust, cava, btop, fastfetch

**LLM/AI Tools**:
- continue, zed, goose, ollama (docs)

**Desktop Environments**:
- XFCE (dual session support)

**Base Tools**:
- git, zsh, gtk, htop, mc, xed

### Immediate Next Steps

1. ✅ **Review this plan** - Understand the structure
2. 📦 **Backup current setup** - Run backup commands
3. 🗂️ **Restructure dotfiles** - Create new package directories
4. 🔗 **Test stow --simulate** - Dry run before applying
5. ✅ **Stow packages** - Apply symlinks
6. 📝 **Update README** - Document new setup
7. 💾 **Git commit & push** - Save everything

### Long-term Workflow

**On this machine**:
```bash
# Edit configs
vim ~/dotfiles/hypr/.config/hypr/hyprland.conf

# Commit changes
cd ~/dotfiles
git add .
git commit -m "Update whatever"
git push
```

**On new machine**:
```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
make stow  # or ./scripts/stow-all.sh
```

---

## Resources

### Documentation
- GNU Stow manual: https://www.gnu.org/software/stow/manual/
- JaKooLit Hyprland-Dots: https://github.com/JaKooLit/Hyprland-Dots
- Hyprland wiki: https://wiki.hyprland.org/

### Example Dotfiles with Stow + Hyprland
- https://github.com/Deivis44/dotfiles
- https://github.com/AbyssWalker240/hyprland-dotfiles-v2
- https://github.com/rrakesh28/hyprland-dotfiles

### Best Practices Articles
- System Crafters: Using GNU Stow to Manage Dotfiles
- Arch Wiki: Dotfiles management
- Various blog posts (referenced in research)

---

**Ready to proceed with migration? Follow Step 1 (Backup) first!**
