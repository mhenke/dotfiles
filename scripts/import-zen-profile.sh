#!/bin/bash
#
# import-zen-profile.sh - Import Zen Browser Profile from Encrypted Backup
#
# Restores Zen Browser settings, bookmarks, history, passwords, and extensions
# from an encrypted archive created by export-zen-profile.sh
#
# Usage:
#   ./import-zen-profile.sh <encrypted-backup-file>
#   Example: ./import-zen-profile.sh zen-profile-20250112_143022.tar.gz.gpg
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

log_info "Zen Browser Profile Import Tool"
echo ""

# Check for encrypted backup file argument
if [[ -z "$1" ]]; then
    log_error "No backup file specified!"
    echo ""
    echo "Usage: $0 <encrypted-backup-file>"
    echo "Example: $0 zen-profile-20250112_143022.tar.gz.gpg"
    echo ""
    log_info "Looking for backups in ~/zen-backup/..."
    if [[ -d "$HOME/zen-backup" ]]; then
        find "$HOME/zen-backup" -name "*.gpg" -type f | while read -r backup; do
            echo "  - $(basename "$backup")"
        done
    fi
    exit 1
fi

ENCRYPTED_FILE="$1"

# Check if file exists
if [[ ! -f "$ENCRYPTED_FILE" ]]; then
    log_error "File not found: $ENCRYPTED_FILE"
    exit 1
fi

# Check for gpg
if ! command -v gpg &> /dev/null; then
    log_error "gpg is not installed. Install it with: sudo apt install gnupg"
    exit 1
fi

# Verify checksum if available
CHECKSUM_FILE="${ENCRYPTED_FILE}.sha256"
if [[ -f "$CHECKSUM_FILE" ]]; then
    log_info "Verifying backup integrity..."
    if sha256sum -c "$CHECKSUM_FILE" &> /dev/null; then
        log_success "Checksum verified!"
    else
        log_error "Checksum verification failed! File may be corrupted."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    log_warn "No checksum file found, skipping integrity check"
fi

# Detect Zen Browser installation type and target profile location
ZEN_PROFILE_DIR=""
INSTALLATION_TYPE=""

# Check for Flatpak installation
if flatpak list 2>/dev/null | grep -q app.zen_browser.zen; then
    ZEN_PROFILE_DIR="$HOME/.var/app/app.zen_browser.zen/.zen"
    INSTALLATION_TYPE="Flatpak"
    log_info "Detected: Flatpak installation"
# Check for Zen Browser executable (AppImage, .deb, tarball)
elif command -v zen-browser &> /dev/null || command -v zen &> /dev/null; then
    ZEN_PROFILE_DIR="$HOME/.zen"
    INSTALLATION_TYPE="Standard"
    log_info "Detected: Standard installation (AppImage/.deb/tarball)"
else
    log_warn "Zen Browser installation not detected!"
    echo ""
    echo "Choose installation type:"
    echo "  1. Flatpak (profile: ~/.var/app/app.zen_browser.zen/.zen)"
    echo "  2. Standard (profile: ~/.zen)"
    echo ""
    read -p "Choose [1-2]: " -n 1 -r
    echo
    case "$REPLY" in
        1)
            ZEN_PROFILE_DIR="$HOME/.var/app/app.zen_browser.zen/.zen"
            INSTALLATION_TYPE="Flatpak"
            ;;
        2)
            ZEN_PROFILE_DIR="$HOME/.zen"
            INSTALLATION_TYPE="Standard"
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
fi

log_success "Target profile: $ZEN_PROFILE_DIR"
echo ""

# Warn about overwriting existing profile
if [[ -d "$ZEN_PROFILE_DIR" ]]; then
    log_warn "WARNING: Existing Zen Browser profile found!"
    log_warn "This will REPLACE your current profile with the backup."
    echo ""
    log_info "Current profile size: $(du -sh "$ZEN_PROFILE_DIR" | cut -f1)"
    echo ""
    read -p "Create backup of current profile first? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        BACKUP_DIR="$HOME/zen-backup/pre-import-backup-$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        log_info "Backing up current profile to: $BACKUP_DIR"
        cp -r "$ZEN_PROFILE_DIR" "$BACKUP_DIR/"
        log_success "Current profile backed up"
    fi
    echo ""
    read -p "Continue with import? This will OVERWRITE your current profile (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Import cancelled"
        exit 0
    fi
fi

# Create temporary working directory
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

log_info "Decrypting backup..."
echo ""
gpg --decrypt --output "$TMP_DIR/$ARCHIVE_NAME" "$ENCRYPTED_FILE"

if [[ $? -ne 0 ]]; then
    log_error "Decryption failed!"
    exit 1
fi

log_success "Backup decrypted"

# Extract archive
log_info "Extracting archive..."
cd "$TMP_DIR"
tar -xzf "$ARCHIVE_NAME"

if [[ ! -d "$TMP_DIR/zen-profile" ]]; then
    log_error "Invalid backup archive - missing zen-profile directory"
    exit 1
fi

log_success "Archive extracted"

# Close Zen Browser if running
log_info "Checking if Zen Browser is running..."
if pgrep -f "zen-browser|zen" > /dev/null; then
    log_warn "Zen Browser is currently running!"
    log_warn "Please close Zen Browser before continuing."
    echo ""
    read -p "Press Enter when Zen Browser is closed..." -r
fi

# Remove old profile and restore backup
log_info "Restoring profile..."

# Backup parent directory structure
PARENT_DIR="$(dirname "$ZEN_PROFILE_DIR")"
mkdir -p "$PARENT_DIR"

# Remove old profile if exists
if [[ -d "$ZEN_PROFILE_DIR" ]]; then
    rm -rf "$ZEN_PROFILE_DIR"
fi

# Copy restored profile
cp -r "$TMP_DIR/zen-profile" "$ZEN_PROFILE_DIR"

log_success "Profile restored successfully!"
echo ""
echo "────────────────────────────────────────────────────"
echo "Import Complete!"
echo "────────────────────────────────────────────────────"
echo "  Profile location: $ZEN_PROFILE_DIR"
echo "  Installation type: $INSTALLATION_TYPE"
echo "────────────────────────────────────────────────────"
echo ""
log_success "You can now launch Zen Browser"
echo ""
log_info "Your bookmarks, history, settings, and extensions have been restored"
log_warn "Note: You may need to sign in to services again (sync, extensions, etc.)"
