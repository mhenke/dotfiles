#!/bin/bash
#
# verify-setup.sh - Verify dotfiles repo is ready for migration
#
# Checks that all necessary files are in place
#

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[✓]${NC} $1"; }
log_fail() { echo -e "${RED}[✗]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_info() { echo -e "${BLUE}[i]${NC} $1"; }

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"

echo "======================================"
echo "  Dotfiles Migration Readiness Check"
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# Check documentation
log_info "Checking documentation..."
[[ -f "README.md" ]] && log_pass "README.md exists" || { log_fail "README.md missing"; ((ERRORS++)); }
[[ -f "MIGRATION.md" ]] && log_pass "MIGRATION.md exists" || { log_fail "MIGRATION.md missing"; ((ERRORS++)); }
[[ -f "QUICKREF.md" ]] && log_pass "QUICKREF.md exists" || { log_warn "QUICKREF.md missing"; ((WARNINGS++)); }
[[ -f ".gitignore" ]] && log_pass ".gitignore exists" || { log_warn ".gitignore missing"; ((WARNINGS++)); }
echo ""

# Check main script
log_info "Checking main script..."
if [[ -f "bootstrap.sh" && -x "bootstrap.sh" ]]; then
    log_pass "bootstrap.sh exists and is executable"
else
    log_fail "bootstrap.sh missing or not executable"
    ((ERRORS++))
fi
echo ""

# Check helper scripts
log_info "Checking helper scripts..."
SCRIPTS=("backup-system.sh" "install-packages.sh" "install-dev-tools.sh" "install-apps.sh" "setup-stow.sh")
for script in "${SCRIPTS[@]}"; do
    if [[ -f "scripts/$script" && -x "scripts/$script" ]]; then
        log_pass "scripts/$script exists and is executable"
    else
        log_fail "scripts/$script missing or not executable"
        ((ERRORS++))
    fi
done
echo ""

# Check packages directory
log_info "Checking package lists..."
[[ -d "packages" ]] && log_pass "packages/ directory exists" || { log_fail "packages/ directory missing"; ((ERRORS++)); }
if [[ -d "packages" ]]; then
    PKG_FILES=("apt-all.txt" "apt-manual.txt" "npm-global.txt" "gems.txt" "vscode-extensions.txt")
    for file in "${PKG_FILES[@]}"; do
        if [[ -f "packages/$file" ]]; then
            lines=$(wc -l < "packages/$file")
            log_pass "packages/$file exists ($lines lines)"
        else
            log_warn "packages/$file missing (run backup-system.sh)"
            ((WARNINGS++))
        fi
    done
fi
echo ""

# Check config directories
log_info "Checking config directories..."
CONFIGS=("i3" "polybar" "picom" "rofi" "dunst" "tilix" "zsh" "git" "gtk" "xed")
for config in "${CONFIGS[@]}"; do
    if [[ -d "$config" ]]; then
        log_pass "$config/ directory exists"
    else
        log_warn "$config/ directory missing"
        ((WARNINGS++))
    fi
done
echo ""

# Check for Stow compatibility
log_info "Checking Stow structure..."
STOW_OK=true
for config in i3 polybar picom zsh git gtk xed; do
    if [[ -d "$config/.config" ]] || [[ -f "$config/.zshrc" ]] || [[ -f "$config/.gitconfig" ]]; then
        log_pass "$config/ has Stow-compatible structure"
    else
        log_warn "$config/ may not be Stow-compatible"
        STOW_OK=false
        ((WARNINGS++))
    fi
done
echo ""

# Check if stow is installed
log_info "Checking system requirements..."
if command -v stow &> /dev/null; then
    log_pass "GNU Stow is installed"
else
    log_warn "GNU Stow not installed (bootstrap will install it)"
    ((WARNINGS++))
fi

if command -v git &> /dev/null; then
    log_pass "Git is installed"
else
    log_fail "Git is not installed!"
    ((ERRORS++))
fi
echo ""

# Check git status
log_info "Checking git repository..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_pass "Git repository initialized"
    
    # Check for uncommitted changes
    if [[ -n $(git status -s) ]]; then
        log_warn "Uncommitted changes detected:"
        git status -s | head -10
        ((WARNINGS++))
    else
        log_pass "No uncommitted changes"
    fi
    
    # Check for remote
    if git remote get-url origin &> /dev/null; then
        remote=$(git remote get-url origin)
        log_pass "Git remote configured: $remote"
    else
        log_warn "No git remote configured"
        ((WARNINGS++))
    fi
else
    log_fail "Not a git repository!"
    ((ERRORS++))
fi
echo ""

# Summary
echo "======================================"
echo "  Summary"
echo "======================================"
echo ""

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your dotfiles are ready for migration."
    echo ""
    echo "Next steps:"
    echo "  1. Commit and push: git add . && git commit -m 'Ready for migration' && git push"
    echo "  2. On new machine: git clone <repo> ~/dotfiles && cd ~/dotfiles && ./bootstrap.sh"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠ Checks passed with $WARNINGS warning(s)${NC}"
    echo ""
    echo "Your dotfiles should work, but review warnings above."
else
    echo -e "${RED}✗ $ERRORS error(s) and $WARNINGS warning(s) found${NC}"
    echo ""
    echo "Please fix errors before migrating."
    exit 1
fi

echo ""
echo "Documentation:"
echo "  - README.md      : Overview and quick start"
echo "  - MIGRATION.md   : Step-by-step migration guide"
echo "  - QUICKREF.md    : Command reference"
echo ""
echo "Scripts:"
echo "  - ./bootstrap.sh              : Full automated setup"
echo "  - ./scripts/backup-system.sh  : Update package lists"
echo ""

exit 0
