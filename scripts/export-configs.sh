#!/bin/bash
#
# export-configs.sh - Export Important Configuration Data for Transfer
#
# Backs up essential configuration directories and files for migration
# to a new laptop. Creates an encrypted archive safe for USB transfer.
#
# Usage:
#   ./export-configs.sh [output-directory]
#   Default output: ~/config-backup/
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
OUTPUT_DIR="${1:-$HOME/config-backup}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="config-backup-${TIMESTAMP}.tar.gz"
ENCRYPTED_NAME="config-backup-${TIMESTAMP}.tar.gz.gpg"

log_info "Configuration Backup Tool"
echo ""

# Check for gpg
if ! command -v gpg &> /dev/null; then
    log_error "gpg is not installed. Install it with: sudo apt install gnupg"
    exit 1
fi

# Create temporary working directory
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

BACKUP_ROOT="$TMP_DIR/config-backup"
mkdir -p "$BACKUP_ROOT"

# Define what to backup
# Format: source_path:description:priority(critical/important/optional)

BACKUP_ITEMS=(
    # Critical - Contains secrets/credentials
    "$HOME/.ssh:SSH keys and config:critical"
    "$HOME/.gnupg:GPG keys:critical"
    "$HOME/.aws:AWS credentials:critical"
    "$HOME/.password-store:Password store (pass):critical"
    "$HOME/.cert:SSL certificates:critical"

    # Important - Application data
    "$HOME/.config/gh:GitHub CLI config:important"
    "$HOME/.gitconfig:Git global config:important"
    "$HOME/.config/Bitwarden:Bitwarden desktop config:important"
    "$HOME/.thunderbird:Thunderbird email:important"
    "$HOME/.config/OSCAR_Team:OSCAR CPAP software config:important"

    # Optional - Can be recreated but nice to have
    "$HOME/.config/dconf:Desktop settings:optional"
    "$HOME/.zsh_history:Shell history:optional"
    "$HOME/.bash_history:Bash history:optional"
)

# Categories
declare -a CRITICAL_ITEMS=()
declare -a IMPORTANT_ITEMS=()
declare -a OPTIONAL_ITEMS=()
declare -a MISSING_ITEMS=()

# Categorize items
log_info "Scanning for configuration files..."
echo ""

for item in "${BACKUP_ITEMS[@]}"; do
    IFS=':' read -r path desc priority <<< "$item"

    if [[ -e "$path" ]]; then
        case "$priority" in
            critical)
                CRITICAL_ITEMS+=("$path:$desc")
                echo "  ✓ [CRITICAL] $desc"
                ;;
            important)
                IMPORTANT_ITEMS+=("$path:$desc")
                echo "  ✓ [IMPORTANT] $desc"
                ;;
            optional)
                OPTIONAL_ITEMS+=("$path:$desc")
                echo "  ✓ [OPTIONAL] $desc"
                ;;
        esac
    else
        MISSING_ITEMS+=("$path:$desc")
    fi
done

if [[ ${#MISSING_ITEMS[@]} -gt 0 ]]; then
    echo ""
    log_warn "Not found (will be skipped):"
    for item in "${MISSING_ITEMS[@]}"; do
        IFS=':' read -r path desc <<< "$item"
        echo "  - $desc ($(basename "$path"))"
    done
fi

# Calculate total size
echo ""
log_info "Calculating backup size..."
TOTAL_SIZE=0
for item in "${CRITICAL_ITEMS[@]}" "${IMPORTANT_ITEMS[@]}" "${OPTIONAL_ITEMS[@]}"; do
    IFS=':' read -r path desc <<< "$item"
    if [[ -e "$path" ]]; then
        SIZE=$(du -sb "$path" 2>/dev/null | cut -f1)
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
    fi
done

TOTAL_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_SIZE)
log_info "Total backup size: $TOTAL_SIZE_HUMAN"

# Show warning if large
if [[ $TOTAL_SIZE -gt 1073741824 ]]; then  # > 1GB
    log_warn "Backup is larger than 1GB"
fi

# Confirm backup
echo ""
log_warn "This will backup:"
echo "  • ${#CRITICAL_ITEMS[@]} critical items (SSH keys, GPG, AWS, passwords)"
echo "  • ${#IMPORTANT_ITEMS[@]} important items (GitHub, Git config, Bitwarden)"
echo "  • ${#OPTIONAL_ITEMS[@]} optional items (shell history, desktop settings)"
echo ""
read -p "Continue with backup? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Backup cancelled"
    exit 0
fi

# Create backup structure
log_info "Creating backup archive..."

# Copy critical items
if [[ ${#CRITICAL_ITEMS[@]} -gt 0 ]]; then
    mkdir -p "$BACKUP_ROOT/critical"
    for item in "${CRITICAL_ITEMS[@]}"; do
        IFS=':' read -r path desc <<< "$item"
        if [[ -e "$path" ]]; then
            basename=$(basename "$path")
            cp -rL "$path" "$BACKUP_ROOT/critical/$basename" 2>/dev/null || log_warn "Could not backup: $desc"
        fi
    done
    log_success "Critical items backed up"
fi

# Copy important items
if [[ ${#IMPORTANT_ITEMS[@]} -gt 0 ]]; then
    mkdir -p "$BACKUP_ROOT/important"
    for item in "${IMPORTANT_ITEMS[@]}"; do
        IFS=':' read -r path desc <<< "$item"
        if [[ -e "$path" ]]; then
            basename=$(basename "$path")
            cp -rL "$path" "$BACKUP_ROOT/important/$basename" 2>/dev/null || log_warn "Could not backup: $desc"
        fi
    done
    log_success "Important items backed up"
fi

# Copy optional items
if [[ ${#OPTIONAL_ITEMS[@]} -gt 0 ]]; then
    mkdir -p "$BACKUP_ROOT/optional"
    for item in "${OPTIONAL_ITEMS[@]}"; do
        IFS=':' read -r path desc <<< "$item"
        if [[ -e "$path" ]]; then
            basename=$(basename "$path")
            cp -rL "$path" "$BACKUP_ROOT/optional/$basename" 2>/dev/null || log_warn "Could not backup: $desc"
        fi
    done
    log_success "Optional items backed up"
fi

# Create manifest
cat > "$BACKUP_ROOT/MANIFEST.txt" << EOF
Configuration Backup
Created: $(date '+%Y-%m-%d %H:%M:%S')
Hostname: $(hostname)
User: $(whoami)

Critical Items (${#CRITICAL_ITEMS[@]}):
EOF

for item in "${CRITICAL_ITEMS[@]}"; do
    IFS=':' read -r path desc <<< "$item"
    echo "  - $desc ($(basename "$path"))" >> "$BACKUP_ROOT/MANIFEST.txt"
done

cat >> "$BACKUP_ROOT/MANIFEST.txt" << EOF

Important Items (${#IMPORTANT_ITEMS[@]}):
EOF

for item in "${IMPORTANT_ITEMS[@]}"; do
    IFS=':' read -r path desc <<< "$item"
    echo "  - $desc ($(basename "$path"))" >> "$BACKUP_ROOT/MANIFEST.txt"
done

cat >> "$BACKUP_ROOT/MANIFEST.txt" << EOF

Optional Items (${#OPTIONAL_ITEMS[@]}):
EOF

for item in "${OPTIONAL_ITEMS[@]}"; do
    IFS=':' read -r path desc <<< "$item"
    echo "  - $desc ($(basename "$path"))" >> "$BACKUP_ROOT/MANIFEST.txt"
done

# Create README
cat > "$BACKUP_ROOT/README.txt" << EOF
Configuration Backup - Transfer Guide

This encrypted archive contains your personal configuration files and credentials.

IMPORTANT SECURITY NOTES:
========================
• This archive contains SENSITIVE DATA (SSH keys, GPG keys, passwords)
• Keep this file SECURE at all times
• Do NOT share the encryption password
• Delete from USB stick after successful transfer
• Store password in Bitwarden or secure password manager

CONTENTS:
=========
• critical/  - SSH keys, GPG keys, AWS credentials, passwords
• important/ - GitHub CLI, Git config, application settings
• optional/  - Shell history, desktop preferences

RESTORATION:
============
On your new laptop, use: ./scripts/import-configs.sh <this-file>

Or manually decrypt with: gpg --decrypt <this-file>

WHAT'S NOT INCLUDED:
====================
• Dotfiles (managed separately via git: ~/dotfiles/)
• Zen Browser profile (use export-zen-profile.sh)
• Large caches (.docker - 27GB, .mozilla - 101MB, VSCode - 5.6GB)
• Node modules (.nvm, .npm)

These are either managed by version control or will be reinstalled fresh.
EOF

log_success "Manifest and README created"

# Create archive
mkdir -p "$OUTPUT_DIR"
cd "$TMP_DIR"
tar -czf "$ARCHIVE_NAME" config-backup/
log_success "Archive created: $(du -h "$ARCHIVE_NAME" | cut -f1)"

# Encrypt with password
log_info "Encrypting archive..."
echo ""
log_warn "Choose a strong password - you'll need this to restore configs!"
log_info "Recommendation: Store password in Bitwarden"
echo ""

gpg --symmetric --cipher-algo AES256 --output "$OUTPUT_DIR/$ENCRYPTED_NAME" "$ARCHIVE_NAME"

if [[ $? -eq 0 ]]; then
    # Create checksum
    cd "$OUTPUT_DIR"
    sha256sum "$ENCRYPTED_NAME" > "${ENCRYPTED_NAME}.sha256"

    echo ""
    log_success "Encrypted backup created!"
    echo ""
    echo "────────────────────────────────────────────────────"
    echo "Backup Details:"
    echo "────────────────────────────────────────────────────"
    echo "  Location: $OUTPUT_DIR/$ENCRYPTED_NAME"
    echo "  Size:     $(du -h "$OUTPUT_DIR/$ENCRYPTED_NAME" | cut -f1)"
    echo "  Date:     $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  Items:    ${#CRITICAL_ITEMS[@]} critical, ${#IMPORTANT_ITEMS[@]} important, ${#OPTIONAL_ITEMS[@]} optional"
    echo "────────────────────────────────────────────────────"
    echo ""
    log_success "Safe to copy to USB stick"
    echo ""
    log_warn "SECURITY REMINDERS:"
    echo "  ⚠ This file contains SSH keys, GPG keys, and passwords"
    echo "  ⚠ Keep the encryption password in a secure location (Bitwarden)"
    echo "  ⚠ Delete from USB after successful transfer"
    echo "  ⚠ Do not leave USB stick unattended"
    echo ""
    log_info "To view contents: cat $OUTPUT_DIR/$(basename "$BACKUP_ROOT")/MANIFEST.txt"
else
    log_error "Encryption failed"
    exit 1
fi
