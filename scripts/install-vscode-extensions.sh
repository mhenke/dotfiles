#!/bin/bash
#
# install-vscode-extensions.sh - Install VSCode extensions from list
#
# Reads packages/vscode-extensions.txt and installs all extensions
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Installing VSCode extensions..."

# Check if code command exists
if ! command -v code &> /dev/null; then
    log_error "VSCode (code command) not found"
    log_info "Install VSCode first:"
    log_info "  sudo snap install code --classic"
    log_info "  OR download from: https://code.visualstudio.com/"
    exit 1
fi

# Get dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSIONS_FILE="$DOTFILES_DIR/packages/vscode-extensions.txt"

# Check if extensions file exists
if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    log_error "Extensions file not found: $EXTENSIONS_FILE"
    log_info "Run ./scripts/export-vscode-extensions.sh on your old machine first"
    exit 1
fi

# Count extensions
TOTAL=$(wc -l < "$EXTENSIONS_FILE")
log_info "Found $TOTAL extensions to install"

echo ""
read -p "Install all $TOTAL extensions? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Installation cancelled"
    exit 0
fi

echo ""
log_info "Installing extensions..."

# Track success/failure
SUCCESS=0
FAILED=0
SKIPPED=0

# Install each extension
while IFS= read -r extension; do
    # Skip empty lines and comments
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue

    # Check if already installed
    if code --list-extensions 2>/dev/null | grep -q "^${extension}$"; then
        log_info "⊙ $extension (already installed)"
        ((SKIPPED++))
        continue
    fi

    # Install extension
    log_info "Installing: $extension"
    if code --install-extension "$extension" --force &>/dev/null; then
        log_success "✓ $extension"
        ((SUCCESS++))
    else
        log_warn "✗ $extension (failed)"
        ((FAILED++))
    fi
done < "$EXTENSIONS_FILE"

# Summary
echo ""
log_success "Installation complete!"
echo ""
echo "Summary:"
echo "  ✓ Installed:        $SUCCESS"
echo "  ⊙ Already installed: $SKIPPED"
echo "  ✗ Failed:           $FAILED"
echo "  ━━━━━━━━━━━━━━━━━━━━"
echo "  Total:              $TOTAL"
echo ""

if [[ $FAILED -gt 0 ]]; then
    log_warn "Some extensions failed to install"
    log_info "You can retry manually with: code --install-extension <extension-id>"
fi

log_info "Restart VSCode to activate all extensions"
