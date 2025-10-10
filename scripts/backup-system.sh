#!/bin/bash
#
# backup-system.sh - Backup current system state
#
# Creates package lists and config backups for migration
#

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
PACKAGES_DIR="$DOTFILES_DIR/packages"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

mkdir -p "$PACKAGES_DIR"
mkdir -p "$BACKUP_DIR"

log_info "Backing up system state..."
log_info "Package lists will be saved to: $PACKAGES_DIR"
log_info "Config backups will be saved to: $BACKUP_DIR"

# 1. APT packages
log_info "Backing up APT packages..."
dpkg --get-selections | grep -v deinstall | awk '{print $1}' | sort > "$PACKAGES_DIR/apt-all.txt"
log_success "Saved $(wc -l < "$PACKAGES_DIR/apt-all.txt") packages to apt-all.txt"

# 2. User-installed packages (exclude dependencies)
log_info "Backing up user-installed packages..."
comm -23 <(apt-mark showmanual | sort) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort) > "$PACKAGES_DIR/apt-manual.txt" 2>/dev/null || true
log_success "Saved user-installed packages to apt-manual.txt"

# 3. Global npm packages
log_info "Backing up global npm packages..."
if command -v npm &> /dev/null; then
    npm list -g --depth=0 --json 2>/dev/null | grep -E '^\s+"' | awk -F'"' '{print $2}' | grep -v '^npm$' > "$PACKAGES_DIR/npm-global.txt" || echo "# No global npm packages" > "$PACKAGES_DIR/npm-global.txt"
    log_success "Saved global npm packages"
else
    log_info "npm not found, skipping"
    echo "# npm not installed" > "$PACKAGES_DIR/npm-global.txt"
fi

# 4. Ruby gems
log_info "Backing up Ruby gems..."
if command -v gem &> /dev/null; then
    gem list --no-versions > "$PACKAGES_DIR/gems.txt"
    log_success "Saved Ruby gems"
else
    log_info "gem not found, skipping"
    echo "# gem not installed" > "$PACKAGES_DIR/gems.txt"
fi

# 5. Python pip packages (user-installed)
log_info "Backing up Python pip packages..."
if command -v pip3 &> /dev/null; then
    pip3 list --user --format=freeze > "$PACKAGES_DIR/pip-user.txt" 2>/dev/null || echo "# No user pip packages" > "$PACKAGES_DIR/pip-user.txt"
    log_success "Saved pip packages"
else
    log_info "pip3 not found, skipping"
    echo "# pip3 not installed" > "$PACKAGES_DIR/pip-user.txt"
fi

# 6. VSCode extensions
log_info "Backing up VSCode extensions..."
if command -v code &> /dev/null; then
    code --list-extensions > "$PACKAGES_DIR/vscode-extensions.txt"
    log_success "Saved $(wc -l < "$PACKAGES_DIR/vscode-extensions.txt") VSCode extensions"
else
    log_info "VSCode not found, skipping"
    echo "# VSCode not installed" > "$PACKAGES_DIR/vscode-extensions.txt"
fi

# 7. Backup zsh history
log_info "Backing up zsh history..."
if [[ -f "$HOME/.zsh_history" ]]; then
    cp "$HOME/.zsh_history" "$BACKUP_DIR/zsh_history"
    log_success "Saved zsh history"
fi

# 8. Backup SSH config (not keys!)
log_info "Backing up SSH config (not keys)..."
if [[ -f "$HOME/.ssh/config" ]]; then
    cp "$HOME/.ssh/config" "$BACKUP_DIR/ssh_config"
    log_success "Saved SSH config"
fi

# 9. Backup configs not yet in dotfiles
log_info "Checking for configs not in dotfiles..."

# Check for rofi
if [[ -d "$HOME/.config/rofi" ]] && [[ ! -d "$DOTFILES_DIR/rofi/.config/rofi" ]]; then
    cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"
    log_success "Backed up rofi config"
fi

# Check for dunst
if [[ -f "$HOME/.config/dunst/dunstrc" ]] && [[ ! -f "$DOTFILES_DIR/dunst/.config/dunst/dunstrc" ]]; then
    mkdir -p "$BACKUP_DIR/dunst"
    cp "$HOME/.config/dunst/dunstrc" "$BACKUP_DIR/dunst/"
    log_success "Backed up dunst config"
fi

# Check for VSCode settings
if [[ -d "$HOME/.config/Code/User" ]] && [[ ! -d "$DOTFILES_DIR/vscode/.config/Code/User" ]]; then
    mkdir -p "$BACKUP_DIR/Code/User"
    cp "$HOME/.config/Code/User/settings.json" "$BACKUP_DIR/Code/User/" 2>/dev/null || true
    cp "$HOME/.config/Code/User/keybindings.json" "$BACKUP_DIR/Code/User/" 2>/dev/null || true
    log_success "Backed up VSCode settings"
fi

# 10. Analyze most used commands
log_info "Analyzing most used commands from zsh history..."
if [[ -f "$HOME/.zsh_history" ]]; then
    cat "$HOME/.zsh_history" | sed 's/^: [0-9]*:[0-9]*;//' | awk '{print $1}' | sort | uniq -c | sort -rn | head -50 > "$PACKAGES_DIR/command-usage.txt"
    log_success "Saved command usage analysis"
fi

# 11. Create summary
cat > "$PACKAGES_DIR/README.md" << 'EOF'
# Package Lists

These files contain all packages and extensions from your system.

## Files

- `apt-all.txt` - All installed APT packages
- `apt-manual.txt` - User-installed APT packages (no dependencies)
- `npm-global.txt` - Global npm packages
- `gems.txt` - Ruby gems
- `pip-user.txt` - User-installed Python packages
- `vscode-extensions.txt` - VSCode extensions
- `command-usage.txt` - Most used commands from shell history

## Usage

The bootstrap script will use these files to restore packages on a new system.

For manual installation:

```bash
# APT packages
xargs sudo apt install -y < apt-manual.txt

# npm packages
xargs npm install -g < npm-global.txt

# Ruby gems
xargs gem install < gems.txt

# VSCode extensions
cat vscode-extensions.txt | xargs -L 1 code --install-extension
```
EOF

echo ""
log_success "Backup complete!"
echo ""
echo "Package lists saved to: $PACKAGES_DIR"
echo "Config backups saved to: $BACKUP_DIR"
echo ""
echo "Files created:"
ls -lh "$PACKAGES_DIR"/*.txt 2>/dev/null || true
echo ""
echo "Next: Commit these to your dotfiles repo:"
echo "  cd $DOTFILES_DIR"
echo "  git add packages/"
echo "  git commit -m 'Update package lists'"
echo "  git push"
