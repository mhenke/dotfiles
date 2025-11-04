# Complete Stow Package List - All Configurations

**Date**: October 25, 2025
**Based on**: System analysis + usage patterns

---

## Complete Package Inventory

### Analysis Completed
✅ Reviewed ~/.config/ directories
✅ Checked recently modified configs (last 30 days)
✅ Identified largest config directories (frequently used)
✅ Cross-referenced with installed applications

---

## Part 1: Hyprland Ecosystem (10 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **hypr** | 7.5M | ~/.config/hypr/ | ⭐⭐⭐ | Main Hyprland config |
| **waybar** | 556K | ~/.config/waybar/ | ⭐⭐⭐ | Status bar |
| **swaync** | 904K | ~/.config/swaync/ | ⭐⭐⭐ | Notifications |
| **kitty** | 704K | ~/.config/kitty/ | ⭐⭐⭐ | Terminal |
| **rofi** | 236K | ~/.config/rofi/ | ⭐⭐⭐ | App launcher |
| **wlogout** | 388K | ~/.config/wlogout/ | ⭐⭐ | Logout menu |
| **swappy** | small | ~/.config/swappy/ | ⭐⭐ | Screenshot annotation |
| **wallust** | 44K | ~/.config/wallust/ | ⭐⭐ | Wallpaper theming |
| **cava** | 36K | ~/.config/cava/ | ⭐ | Audio visualizer |
| **ronema** | 84K | ~/.config/ronema/ | ⭐⭐ | Rofi network manager |

**Stow command**:
```bash
stow hypr waybar swaync kitty rofi wlogout swappy wallust cava ronema
```

---

## Part 2: System Monitoring & Info (3 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **btop** | 36K | ~/.config/btop/ | ⭐⭐ | System monitor |
| **htop** | small | ~/.config/htop/ | ⭐⭐ | Process viewer |
| **fastfetch** | 160K | ~/.config/fastfetch/ | ⭐ | System info |

**Stow command**:
```bash
stow btop htop fastfetch
```

---

## Part 3: Desktop Environments (2 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **xfce4** | 120K | ~/.config/xfce4/ | ⭐⭐⭐ | XFCE desktop (dual session) |
| **thunar** | small | ~/.config/Thunar/ | ⭐⭐⭐ | File manager |

**Stow command**:
```bash
stow xfce4 thunar
```

---

## Part 4: Theming & Appearance (5 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **gtk** | small | ~/.config/gtk-3.0/ | ⭐⭐⭐ | GTK themes |
| **qt5ct** | small | ~/.config/qt5ct/ | ⭐⭐ | Qt5 themes |
| **qt6ct** | small | ~/.config/qt6ct/ | ⭐⭐ | Qt6 themes |
| **kvantum** | 336K | ~/.config/Kvantum/ | ⭐⭐ | Qt theme engine |
| **nwg-look** | small | ~/.config/nwg-look/ | ⭐ | GTK theme switcher |

**Stow command**:
```bash
stow gtk qt5ct qt6ct kvantum nwg-look
```

**Note**: These configs work together to theme both GTK (GNOME/XFCE) and Qt (KDE) applications

---

## Part 5: LLM/AI Coding Tools (4-7 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **continue** | - | ~/.continue/ | ⭐⭐⭐ | Continue.dev (VS Code AI) |
| **zed** | small | ~/.config/zed/ | ⭐⭐⭐ | Zed editor |
| **goose** | 36K / 4.7M | ~/.config/goose/ | ⭐⭐⭐ | Goose AI agent |
| **ollama** | - | /etc/systemd/... | ⭐⭐⭐ | Docs only (manual install) |
| **cursor** | 33M | ~/.config/Cursor/ | ⭐ | Cursor AI editor (if used) |
| **windsurf** | 28M | ~/.config/Windsurf/ | ⭐ | Windsurf AI editor (if used) |
| **github-copilot** | small | ~/.config/github-copilot/ | ⭐ | Copilot settings |

**Stow command** (core tools):
```bash
stow continue zed goose
```

**Optional** (if you use these AI editors):
```bash
stow cursor windsurf github-copilot
```

**Notes**:
- **Cursor/Windsurf**: Large configs (cache/extensions). Consider if worth tracking.
- **VS Code**: Managed by Flatpak, settings sync handles configs. Don't stow.
- **ollama**: Systemd override documented separately (requires sudo)

---

## Part 6: Development Tools (5 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **git** | small | ~/.config/git/ or ~/.gitconfig | ⭐⭐⭐ | Git configuration |
| **gh** | small | ~/.config/gh/ | ⭐⭐⭐ | GitHub CLI |
| **zsh** | - | ~/.zshrc | ⭐⭐⭐ | Shell config |
| **fish** | small | ~/.config/fish/ | ⭐ | Fish shell (if used) |
| **mc** | small | ~/.config/mc/ | ⭐⭐ | Midnight Commander |

**Stow command**:
```bash
stow git gh zsh mc
```

**Optional**:
```bash
stow fish  # If you use fish shell
```

---

## Part 7: Cloud & Services (2 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **aws** | small | ~/.aws/ | ⭐⭐ | AWS CLI config |
| **netlify** | 40K | ~/.config/netlify/ | ⭐ | Netlify CLI |

**Stow command**:
```bash
stow aws netlify
```

**⚠️ Security**: Don't track AWS credentials! See security section below.

---

## Part 8: Additional Tools (5 packages)

| Package | Size | Config Location | Priority | Notes |
|---------|------|----------------|----------|-------|
| **xed** | small | ~/.config/xed/ | ⭐⭐ | Text editor (XFCE) |
| **ags** | 148K | ~/.config/ags/ | ⭐ | Aylur's GTK Shell (if used) |
| **nwg-displays** | small | ~/.config/nwg-displays/ | ⭐ | Display manager |
| **uv** | small | ~/.config/uv/ | ⭐ | Python package manager |
| **tilix** | - | ~/tilix.dconf | ⭐⭐ | Terminal (dconf-based, special handling) |

**Stow command**:
```bash
stow xed ags nwg-displays uv
```

**Note**: tilix uses dconf dump/load, not stow (keep current setup)

---

## Part 9: Archived (Don't Stow Anymore)

| Package | Reason | Action |
|---------|--------|--------|
| **i3** | Switched to Hyprland | Move to _archived/ |
| **polybar** | Using waybar now | Move to _archived/ |
| **picom** | Wayland doesn't need compositor | Move to _archived/ |
| **dunst** | Using swaync now | Move to _archived/ |

---

## Complete Package Summary

### Essential (Must Stow) - 20 packages
```
hypr waybar swaync kitty rofi wlogout swappy wallust
xfce4 thunar gtk continue zed goose git gh zsh mc
aws xed
```

### Recommended (Should Stow) - 10 packages
```
btop htop fastfetch qt5ct qt6ct kvantum ronema
nwg-displays netlify uv
```

### Optional (If You Use) - 7 packages
```
cava nwg-look ags fish cursor windsurf github-copilot
```

### Special Handling - 3 items
```
tilix      - Use dconf dump/load
ollama     - Manual systemd override install
zen        - Use export/import scripts
```

**Total Stow Packages**: 30-37 (depending on optional choices)

---

## Recommended Makefile

```makefile
.PHONY: stow unstow restow stow-essential stow-all list help

# Essential packages (always stow these)
ESSENTIAL := hypr waybar swaync kitty rofi wlogout swappy wallust \
             xfce4 thunar gtk continue zed goose git gh zsh mc aws xed

# Recommended packages
RECOMMENDED := btop htop fastfetch qt5ct qt6ct kvantum ronema \
               nwg-displays netlify uv

# Optional packages (comment out if not used)
OPTIONAL := cava nwg-look ags fish
# cursor windsurf github-copilot  # Uncomment if you use these

# All packages combined
ALL_PACKAGES := $(ESSENTIAL) $(RECOMMENDED) $(OPTIONAL)

help:
	@echo "Dotfiles Stow Management"
	@echo ""
	@echo "Package counts:"
	@echo "  Essential:    $(words $(ESSENTIAL))"
	@echo "  Recommended:  $(words $(RECOMMENDED))"
	@echo "  Optional:     $(words $(OPTIONAL))"
	@echo "  Total:        $(words $(ALL_PACKAGES))"
	@echo ""
	@echo "Commands:"
	@echo "  make stow-essential  - Stow essential packages only"
	@echo "  make stow-all        - Stow all packages"
	@echo "  make stow            - Stow all packages (alias)"
	@echo "  make unstow          - Remove all symlinks"
	@echo "  make restow          - Update all symlinks"
	@echo "  make list            - List all packages"

stow-essential:
	@echo "Stowing essential packages..."
	@stow --verbose --target=$$HOME --restow $(ESSENTIAL)
	@echo ""
	@echo "✓ Essential packages stowed!"

stow-all stow:
	@echo "Stowing all packages..."
	@stow --verbose --target=$$HOME --restow $(ALL_PACKAGES)
	@echo ""
	@echo "✓ All packages stowed!"
	@echo ""
	@echo "⚠️  Manual steps still required:"
	@echo "  - Tilix: dconf load /com/gexperts/Tilix/ < tilix.dconf"
	@echo "  - Ollama: See ollama/README.md for systemd override"
	@echo "  - AWS credentials: Must be configured separately"

unstow:
	@echo "Unstowing all packages..."
	@stow --verbose --target=$$HOME --delete $(ALL_PACKAGES)
	@echo "✓ All packages unstowed!"

restow:
	@echo "Restowing all packages..."
	@stow --verbose --target=$$HOME --restow $(ALL_PACKAGES)
	@echo "✓ All packages restowed!"

list:
	@echo "Essential packages:"
	@echo "$(ESSENTIAL)" | tr ' ' '\n' | sort
	@echo ""
	@echo "Recommended packages:"
	@echo "$(RECOMMENDED)" | tr ' ' '\n' | sort
	@echo ""
	@echo "Optional packages:"
	@echo "$(OPTIONAL)" | tr ' ' '\n' | sort
	@echo ""
	@echo "Manually managed:"
	@echo "  - tilix (dconf)"
	@echo "  - ollama (systemd)"
	@echo "  - zen-browser (export/import)"
```

---

## Updated .stow-local-ignore

```
# Version control
\.git
\.gitignore
\.gitmodules

# Documentation
README.*
\.md$
LICENSE
CONTRIBUTING.*

# Scripts and automation
bootstrap\.sh
Makefile
^scripts
^packages

# Archived configs
^_archived

# Backup files
\.backup$
\.backup-.*
\.bck$
\.old$
~$

# System files
\.DS_Store
\.directory
Thumbs\.db

# Temporary files
.*\.tmp
.*\.temp
.*\.cache

# Python
__pycache__
\.pyc$
\.pyo$

# Node
node_modules
package-lock\.json

# Cache directories (don't stow cache!)
[Cc]ache/
\.cache/
cache2/

# Build artifacts
dist/
build/
target/

# Editor specific
\.vscode/
\.idea/
\.*.swp
\.*.swo

# Large AI editor caches (if stowing cursor/windsurf)
Cursor/.*[Cc]ache.*
Cursor/CachedData
Windsurf/.*[Cc]ache.*
Windsurf/CachedData
Code/.*[Cc]ache.*
Code/CachedData
```

---

## Security Considerations

### Never Commit These Files

Add to `.gitignore`:
```bash
# Credentials and sensitive data
.aws/credentials
.aws/sso/
.ssh/id_*
.ssh/*.pem
.ssh/*.key
*.pem
*.key

# Authentication tokens
.config/gh/hosts.yml      # Contains GitHub token
.config/netlify/*.json    # May contain API keys

# History files (personal)
.zsh_history
.bash_history
.python_history
.*_history

# AI editor personal data
Cursor/User/globalStorage/
Windsurf/User/globalStorage/
.continue/index/          # Personal code embeddings

# Cache (large, unnecessary)
**/Cache/
**/cache/
**/CachedData/
```

### Encrypted Credentials Template

For AWS credentials:
```bash
# In aws/.aws/README.md:
```

**AWS Credentials Setup**

Credentials are NOT tracked in git for security.

On new machine:
```bash
# Option 1: Run AWS configure
aws configure
# Enter your credentials interactively

# Option 2: Restore from encrypted backup
gpg --decrypt credentials.gpg > ~/.aws/credentials
chmod 600 ~/.aws/credentials
```

To backup credentials (encrypted):
```bash
gpg --encrypt --recipient your@email.com ~/.aws/credentials
# Save credentials.gpg somewhere safe (password manager, encrypted backup)
```
```

---

## Cursor/Windsurf Consideration

**Problem**: These configs are LARGE (33M, 28M) and contain:
- Cache files
- Downloaded extensions
- Temporary data

**Recommendation**: DON'T stow these by default

**Alternative Approach**:
```
cursor/
├── README.md              # Manual setup instructions
├── settings.json          # Just the settings file
└── keybindings.json       # Just the keybindings
```

Then manually copy on new machine:
```bash
cp ~/dotfiles/cursor/settings.json ~/.config/Cursor/User/
cp ~/dotfiles/cursor/keybindings.json ~/.config/Cursor/User/
```

Same for Windsurf.

---

## Quick Setup Script

Create `scripts/stow-all.sh`:
```bash
#!/bin/bash
# Comprehensive stow script

cd "$(dirname "$0")/.."

echo "🔗 Stowing all dotfiles..."
echo ""

# Essential packages
echo "📦 Essential packages..."
stow --target=$HOME hypr waybar swaync kitty rofi wlogout swappy wallust \
     xfce4 thunar gtk continue zed goose git gh zsh mc aws xed

# Recommended packages
echo "📦 Recommended packages..."
stow --target=$HOME btop htop fastfetch qt5ct qt6ct kvantum ronema \
     nwg-displays netlify uv

# Optional (comment out if not needed)
echo "📦 Optional packages..."
stow --target=$HOME cava nwg-look ags fish 2>/dev/null || true

echo ""
echo "✅ Stowing complete!"
echo ""
echo "⚠️  Manual steps required:"
echo "1. Tilix:"
echo "   dconf load /com/gexperts/Tilix/ < tilix.dconf"
echo ""
echo "2. Ollama:"
echo "   cd ollama && cat README.md"
echo ""
echo "3. AWS credentials:"
echo "   aws configure"
echo ""
echo "4. Zen browser:"
echo "   cd zen-browser && ./import-profile.sh"
```

---

## Final Checklist

### Before Stowing
- [ ] Backup current configs: `tar -czf config-backup.tar.gz ~/.config`
- [ ] Review package list above
- [ ] Decide which optional packages to include
- [ ] Create .stow-local-ignore
- [ ] Update .gitignore for security

### Create Packages
- [ ] Create directory for each package
- [ ] Copy configs to package/.config/
- [ ] Test with `stow --simulate`
- [ ] Handle special cases (tilix, ollama, aws)

### Stow Everything
- [ ] Run `make stow-essential` first
- [ ] Verify symlinks: `ls -la ~/.config/`
- [ ] Test applications work
- [ ] Run `make stow-all` for remaining packages

### Finalize
- [ ] Create README.md with full documentation
- [ ] Create Makefile with automation
- [ ] Git commit all packages
- [ ] Push to remote repository

### Manual Steps
- [ ] Install tilix config: `dconf load ...`
- [ ] Install Ollama systemd override (sudo)
- [ ] Configure AWS credentials separately
- [ ] Export/import Zen browser profile

---

## Total Count

**Packages to create**: ~30-37
**Manual configs**: 3 (tilix, ollama, zen)
**Security-sensitive**: 2 (aws credentials, gh token)

**Estimated time**:
- Setup: 2-3 hours
- Testing: 1 hour
- Documentation: 1 hour
- **Total**: 4-5 hours for complete migration

---

**See STOW-MIGRATION-PLAN.md for detailed implementation steps!**
