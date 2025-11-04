# Stow Guidelines: What TO and NOT TO Include

**Date**: October 25, 2025
**Purpose**: Research-based guidelines for selective Stow management

---

## Research Summary

Based on analysis of GNU Stow best practices and dotfiles management, here are comprehensive guidelines for what should and should NOT be managed with Stow.

---

## Part 1: General Principles

### ✅ STOW These Types of Files

1. **Configuration files** - Settings you want across machines
2. **Keybindings** - Keyboard shortcuts
3. **Themes/Colors** - Visual preferences
4. **Scripts** - Custom automation you wrote
5. **Application settings** - App preferences

### ❌ DON'T STOW These Types

1. **Cache directories** - Temporary, machine-specific
2. **Log files** - Session-specific data
3. **Credentials/Secrets** - Security risk
4. **History files** - Personal, machine-specific
5. **Large binary data** - Database caches, downloads
6. **Machine-specific configs** - Display setups, hardware configs

---

## Part 2: Category-by-Category Analysis

### Hyprland Ecosystem

#### ✅ STOW: Core Configs
```
hypr/
├── hyprland.conf         ✅ Main config - YES
├── hyprpaper.conf        ✅ Wallpaper config - YES
├── hypridle.conf         ✅ Idle management - YES
├── hyprlock.conf         ✅ Lock screen - YES
├── scripts/              ✅ Custom scripts - YES
└── UserConfigs/          ✅ User settings - YES
```

#### ❌ DON'T STOW: Generated/Cache
```
hypr/
├── hyprland.log          ❌ Log file - NO
├── .cache/               ❌ Cache directory - NO
└── socket/               ❌ Runtime socket - NO
```

**Verdict**: ✅ **STOW hypr** (config files only)

---

#### ✅ STOW: Waybar
```
waybar/
├── config.jsonc          ✅ Main config - YES
├── style.css             ✅ Styling - YES
├── modules               ✅ Module configs - YES
└── scripts/              ✅ Custom scripts - YES
```

**Verdict**: ✅ **STOW waybar** (all configs)

---

#### ✅ STOW: kitty, rofi, swaync, etc.
All these are pure configuration - no cache/runtime data mixed in.

**Verdict**: ✅ **STOW these** (safe, all configs)

---

### LLM/AI Tools

#### ⚠️ PARTIAL: Continue.dev
```
.continue/
├── config.yaml           ✅ Settings - YES
├── .continuerc.json      ✅ RC file - YES
├── .continueignore       ✅ Ignore patterns - YES
├── index/                ❌ Code embeddings - NO (personal, large)
├── .utils/               ❌ Temp utilities - NO
└── dev_data/             ❌ Development cache - NO
```

**Recommendation**: Create custom package structure
```
continue/
└── .continue/
    ├── config.yaml       # Include only config files
    ├── .continuerc.json
    ├── .continueignore
    └── .gitignore        # Ignore index/, .utils/, dev_data/
```

**Verdict**: ⚠️ **STOW continue** with `. continue/.gitignore` to exclude caches

---

#### ✅ STOW: Zed
```
zed/
├── settings.json         ✅ Settings - YES
├── keymap.json           ✅ Keybindings - YES
└── themes/               ✅ Custom themes - YES
```

**Verdict**: ✅ **STOW zed** (all configs, Zed doesn't create cache here)

---

#### ⚠️ PARTIAL: Goose
```
goose/
├── config.yaml           ✅ Main config - YES
└── .goose_cache/         ❌ Cache - NO (if it exists)
```

**Verdict**: ✅ **STOW goose** (config only)

---

#### ❌ DON'T STOW: Cursor/Windsurf (Large AI Editors)
```
Cursor/
├── User/
│   ├── settings.json     ✅ Settings - MAYBE
│   └── globalStorage/    ❌ Large cache - NO
├── Cache/                ❌ Cache - NO
├── CachedData/           ❌ 10s of MBs - NO
├── extensions/           ❌ Downloaded extensions - NO
└── logs/                 ❌ Log files - NO
```

**Size**: 33M (Cursor), 28M (Windsurf)

**Recommendation**: DON'T stow entire directory

**Alternative**: Extract only settings
```
cursor/
├── settings.json         # Manually copy this file only
├── keybindings.json      # And this
└── README.md             # Document manual setup
```

**Verdict**: ❌ **DON'T STOW cursor/windsurf** (too large, mostly cache)

---

#### ❌ DON'T STOW: VS Code (Flatpak)
```
~/.var/app/com.visualstudio.code/
```

**Reason**: Flatpak location, settings sync handles this, too large

**Verdict**: ❌ **DON'T STOW vscode** (use Settings Sync feature)

---

### Desktop Environments

#### ⚠️ PARTIAL: XFCE4
```
xfce4/
├── xfconf/               ✅ Desktop settings - YES
│   └── xfce-perchannel-xml/
├── panel/                ✅ Panel config - YES
├── terminal/             ✅ Terminal settings - YES
└── sessions/             ❌ Session files - NO (machine-specific)
```

**Recommendation**: Selectively stow
```bash
# Check what's in xfce4 first
ls -la ~/.config/xfce4/

# Only stow xfconf and panel, exclude sessions
```

**Verdict**: ⚠️ **STOW xfce4** but use `.stow-local-ignore` for sessions

---

#### ✅ STOW: Thunar
```
Thunar/
├── accels.scm            ✅ Keyboard shortcuts - YES
└── uca.xml               ✅ Custom actions - YES
```

**Verdict**: ✅ **STOW thunar** (small, pure config)

---

### Development Tools

#### ⚠️ PARTIAL: Git
```
git/
├── .gitconfig            ✅ Git settings - YES
├── .git-credentials      ❌ CREDENTIALS - NEVER!
└── .gitignore_global     ✅ Global ignore - YES
```

**Critical**: NEVER stow git-credentials!

**Verdict**: ⚠️ **STOW git** but gitignore credentials

---

#### ⚠️ SECURITY: GitHub CLI
```
gh/
├── config.yml            ⚠️ May contain tokens - CHECK FIRST!
└── hosts.yml             ❌ CONTAINS AUTH TOKENS - NO!
```

**Recommendation**: Don't stow, or heavily filter

**Alternative**:
```
gh/
├── config.yml.template   # Template without tokens
└── README.md             # Document: run `gh auth login`
```

**Verdict**: ❌ **DON'T STOW gh** (contains auth tokens)

---

#### ✅ STOW: Zsh
```
zsh/
├── .zshrc                ✅ Config - YES
├── .zsh_aliases          ✅ Aliases - YES
├── .zsh_functions        ✅ Functions - YES
└── .zsh_history          ❌ History - NO (personal)
```

**Verdict**: ✅ **STOW zsh** (exclude history in .gitignore)

---

#### ⚠️ OPTIONAL: Fish
```
fish/
├── config.fish           ✅ Config - YES
├── fish_variables        ⚠️ May have personal data - CHECK
└── conf.d/               ✅ Config directory - YES
```

**Verdict**: ⚠️ **STOW fish** if you use it (check fish_variables first)

---

### Cloud & Services

#### ❌ CRITICAL: AWS
```
aws/
├── config                ✅ AWS config - YES (no secrets)
├── credentials           ❌ CREDENTIALS - NEVER!!!
└── sso/                  ❌ SSO tokens - NEVER!!!
```

**CRITICAL**: Never commit AWS credentials!

**Recommendation**:
```
aws/
├── .aws/
│   ├── config            # Stow this (safe)
│   └── credentials.gpg   # Encrypted backup only
├── .gitignore            # credentials, sso/
└── README.md             # Document: run `aws configure`
```

**Verdict**: ⚠️ **STOW aws** (config only, .gitignore credentials!)

---

#### ⚠️ CHECK: Netlify
```
netlify/
└── *.json                ⚠️ May contain API keys - CHECK FIRST!
```

**Verdict**: ⚠️ **CHECK FIRST** before stowing

---

### System Monitoring

#### ✅ STOW: btop, htop, fastfetch
Pure configuration files, no cache/runtime data.

**Verdict**: ✅ **STOW these** (all safe)

---

### Theming

#### ✅ STOW: gtk, qt5ct, qt6ct, kvantum
All theme settings, no personal data.

**Verdict**: ✅ **STOW these** (all safe)

---

#### ⚠️ CHECK: nwg-look
```
nwg-look/
└── config                ⚠️ May have personal theme paths - CHECK
```

**Verdict**: ⚠️ **CHECK FIRST** (likely safe but verify paths)

---

### Additional Tools

#### ❌ DON'T STOW: Tilix
```
tilix.dconf               # Special: uses dconf dump/load
```

**Reason**: Not a file-based config, uses dconf database

**Verdict**: ❌ **DON'T STOW tilix** (use dconf load/dump instead)

**Keep current method**:
```bash
# Export
dconf dump /com/gexperts/Tilix/ > ~/dotfiles/tilix/tilix.dconf

# Import (on new machine)
dconf load /com/gexperts/Tilix/ < ~/dotfiles/tilix/tilix.dconf
```

---

#### ✅ STOW: mc (Midnight Commander)
```
mc/
├── ini                   ✅ Main config - YES
└── panels.ini            ✅ Panel layout - YES
```

**Verdict**: ✅ **STOW mc** (pure config)

---

#### ✅ STOW: xed
```
xed/
└── preferences           ✅ Editor settings - YES
```

**Verdict**: ✅ **STOW xed** (pure config)

---

## Part 3: Final Recommendations by Package

### ✅ SAFE TO STOW (No Issues)
```
SAFE_PACKAGES="
  hypr waybar swaync kitty rofi wlogout swappy wallust cava
  thunar gtk qt5ct qt6ct kvantum mc xed
  btop htop fastfetch ronema nwg-displays
  zed goose
"
```

### ⚠️ STOW WITH CAUTION (Need .gitignore)
```
CAUTION_PACKAGES="
  continue    # Exclude index/, .utils/, dev_data/
  zsh         # Exclude .zsh_history
  fish        # Check fish_variables first
  aws         # EXCLUDE credentials, sso/
  xfce4       # Exclude sessions/
  nwg-look    # Check for personal paths
  ags         # May have cache
"
```

### ❌ DON'T STOW (Security/Size/Method)
```
DONT_STOW="
  gh          # Contains auth tokens in hosts.yml
  cursor      # 33M, mostly cache
  windsurf    # 28M, mostly cache
  Code        # Flatpak, use Settings Sync
  tilix       # Uses dconf, not files
  ollama      # Systemd override, needs sudo
  zen-browser # Use export/import scripts
  netlify     # May contain API keys - check first
"
```

---

## Part 4: Security Checklist

Before stowing ANY package:

### 1. Check for Credentials
```bash
cd ~/dotfiles/package-name/
grep -r "password\|secret\|token\|key\|credential" .
```

### 2. Check File Sizes
```bash
du -sh ~/.config/package-name
# If > 10M, inspect what's taking space
```

### 3. Look for Cache Directories
```bash
find ~/.config/package-name -type d -name "*cache*" -o -name "*Cache*"
```

### 4. Check for Personal Data
```bash
# History files
find ~/.config/package-name -name "*history*"

# Database files
find ~/.config/package-name -name "*.db" -o -name "*.sqlite"
```

### 5. Review Before Committing
```bash
cd ~/dotfiles
git add package-name/
git status
git diff --staged  # Review what's being added
```

---

## Part 5: .gitignore Templates

### For Each Package with Sensitive Data

#### continue/.gitignore
```
# Exclude personal code embeddings and caches
index/
.utils/
dev_data/
```

#### zsh/.gitignore
```
# Exclude command history (personal)
.zsh_history
.zhistory
```

#### aws/.gitignore
```
# NEVER commit credentials!
.aws/credentials
.aws/sso/
*.pem
*.key
```

#### xfce4/.gitignore
```
# Exclude sessions (machine-specific)
sessions/
```

#### fish/.gitignore (if stowing)
```
# May contain personal variables
fish_variables
```

### Master .gitignore (~/dotfiles/)
```
# ============================================
# CRITICAL SECURITY
# ============================================
# SSH keys
.ssh/id_*
.ssh/*.pem
.ssh/*.key
**/.ssh/id_*

# AWS credentials
.aws/credentials
.aws/sso/
**/*.pem
**/*.key

# Git credentials
.git-credentials
**/. git-credentials

# GitHub tokens
**/gh/hosts.yml
**/github-copilot/hosts.yml

# ============================================
# HISTORY FILES (Personal)
# ============================================
*_history
.*_history
.zsh_history
.bash_history
.python_history

# ============================================
# CACHE DIRECTORIES
# ============================================
**/[Cc]ache/
**/.cache/
**/cache2/
**/CachedData/
**/CachedExtensions/

# ============================================
# AI EDITOR CACHES
# ============================================
# Cursor
Cursor/**/Cache/
Cursor/CachedData/
Cursor/User/globalStorage/

# Windsurf
Windsurf/**/Cache/
Windsurf/CachedData/

# VS Code
Code/**/Cache/
Code/CachedData/

# Continue
.continue/index/
.continue/.utils/
.continue/dev_data/

# ============================================
# BUILD & TEMP FILES
# ============================================
*.tmp
*.temp
*.log
*.swp
*.swo
*~
.DS_Store
Thumbs.db
__pycache__/
*.pyc
node_modules/

# ============================================
# BACKUP FILES
# ============================================
*.backup
*.backup-*
*.bck
*.old
```

---

## Part 6: Makefile with Safety Checks

```makefile
.PHONY: check-security stow-safe stow-all help

# Safe packages (no security concerns)
SAFE := hypr waybar swaync kitty rofi wlogout swappy wallust cava \
        thunar gtk qt5ct qt6ct kvantum mc xed btop htop fastfetch \
        ronema nwg-displays zed

# Packages needing .gitignore
CAUTION := continue zsh fish aws xfce4

# All stowable packages
STOWABLE := $(SAFE) $(CAUTION) goose

help:
	@echo "Stow Management with Security Checks"
	@echo ""
	@echo "Commands:"
	@echo "  make check-security  - Check for credentials before stowing"
	@echo "  make stow-safe       - Stow only safe packages"
	@echo "  make stow-all        - Stow all packages (use after security check)"

check-security:
	@echo "🔒 Checking for credentials and sensitive data..."
	@echo ""
	@echo "Checking AWS..."
	@test ! -f aws/.aws/credentials || (echo "❌ FOUND: aws/.aws/credentials - DO NOT COMMIT!" && exit 1)
	@echo "✅ AWS safe"
	@echo ""
	@echo "Checking GitHub..."
	@test ! -f gh/.config/gh/hosts.yml || (echo "⚠️  WARNING: gh/hosts.yml may contain tokens" && exit 1)
	@echo "✅ GitHub safe"
	@echo ""
	@echo "Checking SSH..."
	@! find . -name "id_*" -o -name "*.pem" | grep -q . || (echo "❌ FOUND SSH keys!" && exit 1)
	@echo "✅ SSH safe"
	@echo ""
	@echo "Checking for history files..."
	@! find . -name "*_history" | grep -q . || (echo "⚠️  WARNING: Found history files" && exit 1)
	@echo "✅ No history files"
	@echo ""
	@echo "✅ Security check passed!"

stow-safe:
	@echo "🔗 Stowing safe packages..."
	@stow --verbose --target=$$HOME --restow $(SAFE)
	@echo "✅ Safe packages stowed!"

stow-all: check-security
	@echo "🔗 Stowing all packages..."
	@stow --verbose --target=$$HOME --restow $(STOWABLE)
	@echo "✅ All packages stowed!"
	@echo ""
	@echo "⚠️  Remember:"
	@echo "  - gh: Run 'gh auth login' separately"
	@echo "  - aws: Run 'aws configure' separately"
	@echo "  - ollama: Manual systemd install"
	@echo "  - tilix: Use dconf load"
```

---

## Part 7: Quick Decision Tree

**For each config directory, ask:**

### 1. Does it contain secrets/credentials?
- YES → ❌ **DON'T STOW** (or heavily filter with .gitignore)
- NO → Continue to #2

### 2. Is it mostly cache/temp data?
- YES → ❌ **DON'T STOW**
- NO → Continue to #3

### 3. Is it larger than 10MB?
- YES → ⚠️ **INVESTIGATE** (may be cache)
- NO → Continue to #4

### 4. Is it personal/machine-specific?
- YES → ⚠️ **CONSIDER** (maybe exclude)
- NO → Continue to #5

### 5. Is it pure configuration?
- YES → ✅ **STOW IT!**
- NO → ⚠️ **REVIEW FIRST**

---

## Summary

### Final Stow List (After Security Review)

**STOW These** (20 packages):
```
hypr waybar swaync kitty rofi wlogout swappy wallust cava ronema
thunar gtk qt5ct qt6ct kvantum mc xed btop htop fastfetch nwg-displays
```

**STOW with .gitignore** (6 packages):
```
zed goose continue zsh fish aws xfce4
```

**DON'T STOW** (8 items):
```
gh cursor windsurf Code tilix ollama zen-browser netlify
```

**Total Managed by Stow**: 26 packages
**Total Manual/Alternative**: 8 items

---

**Next Step**: Review each package individually before stowing!
