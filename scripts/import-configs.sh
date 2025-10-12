#!/bin/bash
#
# import-configs.sh - Import Configuration Data from Encrypted Backup
#
# Restores configuration files and directories from backup created by
# export-configs.sh
#
# Usage:
#   ./import-configs.sh <encrypted-backup-file>
#   Example: ./import-configs.sh config-backup-20250112_143022.tar.gz.gpg
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

log_info "Configuration Import Tool"
echo ""

# Check for encrypted backup file argument
if [[ -z "$1" ]]; then
    log_error "No backup file specified!"
    echo ""
    echo "Usage: $0 <encrypted-backup-file>"
    echo "Example: $0 config-backup-20250112_143022.tar.gz.gpg"
    echo ""
    log_info "Looking for backups in ~/config-backup/..."
    if [[ -d "$HOME/config-backup" ]]; then
        find "$HOME/config-backup" -name "*.gpg" -type f | while read -r backup; do
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

# Create temporary working directory
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

log_info "Decrypting backup..."
echo ""

# Extract just the base filename without extensions
ARCHIVE_NAME="${ENCRYPTED_FILE%.gpg}"
ARCHIVE_NAME="$(basename "$ARCHIVE_NAME")"

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

if [[ ! -d "$TMP_DIR/config-backup" ]]; then
    log_error "Invalid backup archive - missing config-backup directory"
    exit 1
fi

log_success "Archive extracted"

# Display manifest
if [[ -f "$TMP_DIR/config-backup/MANIFEST.txt" ]]; then
    echo ""
    echo "════════════════════════════════════════════════════"
    cat "$TMP_DIR/config-backup/MANIFEST.txt"
    echo "════════════════════════════════════════════════════"
    echo ""
fi

# Show README
if [[ -f "$TMP_DIR/config-backup/README.txt" ]]; then
    log_info "Review README for important information"
fi

# Confirm restore
log_warn "This will restore configuration files to your home directory"
echo ""
read -p "Continue with import? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Import cancelled"
    log_info "Archive contents extracted to: $TMP_DIR/config-backup"
    log_info "You can manually inspect and copy files from there"
    exit 0
fi

# Import critical items
if [[ -d "$TMP_DIR/config-backup/critical" ]]; then
    log_info "Restoring critical items (SSH keys, GPG, credentials)..."

    for item in "$TMP_DIR/config-backup/critical"/*; do
        basename=$(basename "$item")
        target="$HOME/.$basename"

        # Backup existing if present
        if [[ -e "$target" ]]; then
            backup_target="${target}.backup-$(date +%Y%m%d_%H%M%S)"
            log_warn "Backing up existing $basename to $(basename "$backup_target")"
            cp -r "$target" "$backup_target"
        fi

        # Restore item
        cp -r "$item" "$target"

        # Fix permissions for sensitive items
        case "$basename" in
            ssh)
                chmod 700 "$target"
                chmod 600 "$target"/* 2>/dev/null || true
                chmod 644 "$target"/*.pub 2>/dev/null || true
                log_info "Fixed permissions for $basename"
                ;;
            gnupg)
                chmod 700 "$target"
                chmod 600 "$target"/* 2>/dev/null || true
                log_info "Fixed permissions for $basename"
                ;;
            aws)
                chmod 700 "$target"
                chmod 600 "$target"/* 2>/dev/null || true
                log_info "Fixed permissions for $basename"
                ;;
        esac

        log_success "Restored: $basename"
    done
fi

# Import important items
if [[ -d "$TMP_DIR/config-backup/important" ]]; then
    log_info "Restoring important items (app configs)..."

    for item in "$TMP_DIR/config-backup/important"/*; do
        basename=$(basename "$item")

        # Determine target location
        if [[ "$basename" == "gitconfig" ]] || [[ "$basename" == "zshrc" ]] || [[ "$basename" == "bashrc" ]]; then
            target="$HOME/.$basename"
        else
            # Most items go to .config
            target="$HOME/.config/$basename"
            mkdir -p "$HOME/.config"
        fi

        # Backup existing if present
        if [[ -e "$target" ]]; then
            backup_target="${target}.backup-$(date +%Y%m%d_%H%M%S)"
            log_warn "Backing up existing $basename to $(basename "$backup_target")"
            cp -r "$target" "$backup_target"
        fi

        # Restore item
        cp -r "$item" "$target"
        log_success "Restored: $basename"
    done
fi

# Import optional items (ask first)
if [[ -d "$TMP_DIR/config-backup/optional" ]]; then
    echo ""
    read -p "Restore optional items (shell history, desktop settings)? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restoring optional items..."

        for item in "$TMP_DIR/config-backup/optional"/*; do
            basename=$(basename "$item")

            # Determine target location
            if [[ "$basename" == *_history ]] || [[ "$basename" == "dconf" ]]; then
                if [[ "$basename" == "dconf" ]]; then
                    target="$HOME/.config/$basename"
                    mkdir -p "$HOME/.config"
                else
                    target="$HOME/.$basename"
                fi
            else
                target="$HOME/.$basename"
            fi

            # Backup existing if present
            if [[ -e "$target" ]]; then
                backup_target="${target}.backup-$(date +%Y%m%d_%H%M%S)"
                cp -r "$target" "$backup_target" 2>/dev/null || true
            fi

            # Restore item
            cp -r "$item" "$target"
            log_success "Restored: $basename"
        done
    else
        log_info "Skipping optional items"
    fi
fi

echo ""
log_success "Configuration import complete!"
echo ""
echo "════════════════════════════════════════════════════"
echo "Next Steps:"
echo "════════════════════════════════════════════════════"
echo ""
echo "1. Verify SSH keys work:"
echo "   ssh-add -l"
echo ""
echo "2. Test GitHub authentication:"
echo "   gh auth status"
echo ""
echo "3. Verify GPG keys:"
echo "   gpg --list-secret-keys"
echo ""
echo "4. Check AWS credentials:"
echo "   aws sts get-caller-identity"
echo ""
echo "5. If you haven't already, run the main bootstrap:"
echo "   cd ~/dotfiles && ./bootstrap.sh"
echo ""
echo "════════════════════════════════════════════════════"
echo ""
log_warn "SECURITY REMINDER:"
echo "  • Delete the encrypted backup from USB after successful import"
echo "  • All existing configs were backed up with .backup-YYYYMMDD_HHMMSS suffix"
echo ""
