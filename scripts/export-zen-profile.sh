#!/bin/bash
#
# export-zen-profile.sh - Export Zen Browser Profile Securely
#
# Exports Zen Browser settings, bookmarks, history, passwords, and extensions
# to an encrypted archive for USB transfer
#
# Usage:
#   ./export-zen-profile.sh [output-directory]
#   Default output: ~/zen-backup/
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

# Configuration
OUTPUT_DIR="${1:-$HOME/zen-backup}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="zen-profile-${TIMESTAMP}.tar.gz"
ENCRYPTED_NAME="zen-profile-${TIMESTAMP}.tar.gz.gpg"

log_info "Zen Browser Profile Export Tool"
echo ""

# Detect Zen Browser installation type and profile location
ZEN_PROFILE_DIR=""

# Check for Flatpak installation
if [[ -d "$HOME/.var/app/app.zen_browser.zen/.zen" ]]; then
    ZEN_PROFILE_DIR="$HOME/.var/app/app.zen_browser.zen/.zen"
    log_info "Detected: Flatpak installation"
# Check for standard .zen directory (AppImage, .deb, tarball)
elif [[ -d "$HOME/.zen" ]]; then
    ZEN_PROFILE_DIR="$HOME/.zen"
    log_info "Detected: Standard installation (AppImage/.deb/tarball)"
# Check for legacy Firefox profile (fallback)
elif [[ -d "$HOME/.mozilla/firefox" ]]; then
    ZEN_PROFILE_DIR="$HOME/.mozilla/firefox"
    log_warn "Detected: Firefox profile directory (Zen may be using Firefox profiles)"
else
    log_error "Zen Browser profile directory not found!"
    log_info "Checked locations:"
    log_info "  - $HOME/.var/app/app.zen_browser.zen/.zen (Flatpak)"
    log_info "  - $HOME/.zen (Standard installation)"
    log_info "  - $HOME/.mozilla/firefox (Legacy)"
    log_info ""
    log_info "Make sure Zen Browser has been launched at least once"
    exit 1
fi

log_success "Profile found: $ZEN_PROFILE_DIR"
echo ""

# Check for gpg
if ! command -v gpg &> /dev/null; then
    log_error "gpg is not installed. Install it with: sudo apt install gnupg"
    exit 1
fi

# Display what will be backed up
log_info "Profile location: $ZEN_PROFILE_DIR"
log_info "Calculating profile size..."
PROFILE_SIZE=$(du -sh "$ZEN_PROFILE_DIR" | cut -f1)
log_info "Profile size: $PROFILE_SIZE"
echo ""

# List profiles found
log_info "Firefox/Zen profiles found:"
find "$ZEN_PROFILE_DIR" -maxdepth 1 -type d -name "*.default*" -o -name "*release" 2>/dev/null | while read -r profile; do
    echo "  - $(basename "$profile")"
done
echo ""

# Confirm backup
log_warn "This will backup ALL Zen Browser data including:"
echo "  ✓ Bookmarks"
echo "  ✓ History"
echo "  ✓ Passwords (encrypted by Zen's master password)"
echo "  ✓ Extensions and settings"
echo "  ✓ Themes and customizations"
echo "  ✓ Session data (open tabs)"
echo ""
read -p "Continue with backup? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Backup cancelled"
    exit 0
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Create temporary working directory
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

log_info "Creating archive..."
# Copy profile to temp directory to avoid issues with running browser
cp -r "$ZEN_PROFILE_DIR" "$TMP_DIR/zen-profile"

# Create archive
cd "$TMP_DIR"
tar -czf "$ARCHIVE_NAME" zen-profile/
log_success "Archive created: $(du -h "$ARCHIVE_NAME" | cut -f1)"

# Encrypt with password
log_info "Encrypting archive..."
echo ""
log_warn "Choose a strong password - you'll need this to restore the profile!"
echo ""

gpg --symmetric --cipher-algo AES256 --output "$OUTPUT_DIR/$ENCRYPTED_NAME" "$ARCHIVE_NAME"

if [[ $? -eq 0 ]]; then
    log_success "Encrypted backup created!"
    echo ""
    echo "────────────────────────────────────────────────────"
    echo "Backup Details:"
    echo "────────────────────────────────────────────────────"
    echo "  Location: $OUTPUT_DIR/$ENCRYPTED_NAME"
    echo "  Size:     $(du -h "$OUTPUT_DIR/$ENCRYPTED_NAME" | cut -f1)"
    echo "  Date:     $(date '+%Y-%m-%d %H:%M:%S')"
    echo "────────────────────────────────────────────────────"
    echo ""
    log_success "Safe to copy to USB stick or external storage"
    echo ""
    log_warn "IMPORTANT:"
    echo "  • Keep your encryption password in a safe place (e.g., Bitwarden)"
    echo "  • Test the restore process before deleting your original profile"
    echo "  • The backup includes passwords encrypted by Zen's master password"
    echo ""

    # Create checksum file
    cd "$OUTPUT_DIR"
    sha256sum "$ENCRYPTED_NAME" > "${ENCRYPTED_NAME}.sha256"
    log_info "Checksum saved: ${ENCRYPTED_NAME}.sha256"
else
    log_error "Encryption failed"
    exit 1
fi
