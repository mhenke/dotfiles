#!/bin/bash
#
# export-vscode-extensions.sh - Export VSCode extensions list
#
# Creates a list of installed VSCode extensions that can be
# imported on a new machine
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

log_info "Exporting VSCode extensions..."

# Check if code command exists
if ! command -v code &> /dev/null; then
    log_error "VSCode (code command) not found"
    log_info "Install VSCode first or add it to PATH"
    exit 1
fi

# Get dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSIONS_FILE="$DOTFILES_DIR/packages/vscode-extensions.txt"

# Export extensions list
log_info "Listing installed extensions..."
if code --list-extensions > "$EXTENSIONS_FILE" 2>/dev/null; then
    EXTENSION_COUNT=$(wc -l < "$EXTENSIONS_FILE")
    log_success "Exported $EXTENSION_COUNT extensions to: $EXTENSIONS_FILE"

    echo ""
    log_info "Extensions exported:"
    cat "$EXTENSIONS_FILE" | sed 's/^/  • /'

    echo ""
    log_success "Extension list saved!"
    log_info "To install on new machine: ./scripts/install-vscode-extensions.sh"
else
    log_error "Failed to export extensions"
    exit 1
fi
