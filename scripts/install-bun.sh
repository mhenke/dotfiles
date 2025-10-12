#!/bin/bash
#
# install-bun.sh - Install Bun and global packages
#
# Bun is a fast all-in-one JavaScript runtime, bundler, and package manager.
# This script installs Bun and optionally migrates from npm.
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

log_info "Bun Installation Script"
echo ""

# Check if Bun is already installed
if command -v bun &> /dev/null; then
    log_success "Bun is already installed: $(bun --version)"
    read -p "Reinstall Bun? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping Bun installation"
    else
        log_info "Reinstalling Bun..."
        curl -fsSL https://bun.sh/install | bash
        log_success "Bun reinstalled"
    fi
else
    log_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    log_success "Bun installed: $(~/.bun/bin/bun --version)"
fi

# Add Bun to PATH for this session
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Check if we should auto-install packages (when called from another script)
AUTO_INSTALL="${1:-}"

# Ask about global package installation (unless auto-installing)
if [[ "$AUTO_INSTALL" == "--auto-install" ]]; then
    log_info "Auto-installing global packages with Bun..."
    INSTALL_PACKAGES="yes"
else
    echo ""
    log_info "Bun can install global packages from npm-global.txt"
    echo ""
    log_warn "Known compatibility issues:"
    echo "  ⚠ @anthropic-ai/claude-code has bugs with Bun (crashes, permission issues)"
    echo ""
    read -p "Install global packages with Bun? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_PACKAGES="yes"
    else
        INSTALL_PACKAGES="no"
    fi
fi

if [[ "$INSTALL_PACKAGES" == "yes" ]]; then
    PACKAGES_DIR="$(dirname "$0")/../packages"

    if [[ -f "$PACKAGES_DIR/npm-global.txt" ]]; then
        log_info "Installing global packages with Bun..."

        # Read packages and install
        while IFS= read -r package; do
            # Skip comments and empty lines
            [[ -z "$package" || "$package" =~ ^# ]] && continue

            # Skip CLI tools that should use npm (authentication, native modules)
            if [[ "$package" == "@anthropic-ai/claude-code" ]] || [[ "$package" == "@github/copilot" ]]; then
                log_warn "Skipping $package (CLI tool - use npm for stability)"
                log_info "  Install with: npm install -g $package"
                continue
            fi

            log_info "Installing: $package"
            bun install -g "$package" 2>/dev/null || log_warn "Failed to install $package"
        done < "$PACKAGES_DIR/npm-global.txt"

        log_success "Global packages installed with Bun"
    else
        log_warn "npm-global.txt not found"
    fi
else
    log_info "Skipping global package installation"
    log_info "You can install packages later with: bun install -g <package>"
fi

# Show installed packages
echo ""
log_info "Bun global packages installed:"
bun pm ls -g 2>/dev/null || log_warn "No global packages installed yet"

echo ""
log_success "Bun installation complete!"
echo ""
echo "════════════════════════════════════════════════════"
echo "Quick Start:"
echo "════════════════════════════════════════════════════"
echo "  • Install package:    bun install <package>"
echo "  • Install globally:   bun install -g <package>"
echo "  • Run script:         bun run <script>"
echo "  • Execute file:       bun <file>.ts"
echo ""
echo "Speed comparison to npm:"
echo "  • 7× faster than npm install"
echo "  • 4× faster than pnpm install"
echo "  • 17× faster than yarn install"
echo ""
log_warn "CLI Tools - Use npm for stability:"
echo "  ⚠ @anthropic-ai/claude-code"
echo "  ⚠ @github/copilot"
echo ""
echo "Install with:"
echo "  npm install -g @anthropic-ai/claude-code @github/copilot"
echo ""
log_info "Bun is installed to: $BUN_INSTALL"
log_info "Add to PATH in ~/.zshrc if not already present"
echo ""
