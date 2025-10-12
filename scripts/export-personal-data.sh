#!/bin/bash
#
# export-personal-data.sh - Export Personal Data for Transfer
#
# Backs up large personal data directories for migration to a new laptop.
# Creates an encrypted archive safe for USB transfer or external HDD.
#
# WARNING: This can create VERY LARGE files (10GB+)
#
# Usage:
#   ./export-personal-data.sh [output-directory]
#   Default output: ~/personal-backup/
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
OUTPUT_DIR="${1:-$HOME/personal-backup}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_info "Personal Data Backup Tool"
echo ""

# Check for gpg
if ! command -v gpg &> /dev/null; then
    log_error "gpg is not installed. Install it with: sudo apt install gnupg"
    exit 1
fi

# Define personal data directories
PERSONAL_ITEMS=(
    "$HOME/Documents:Documents folder (includes OSCAR_Data)"
    "$HOME/Desktop:Desktop folder"
    "$HOME/.kodi:Kodi media center data"
    "$HOME/.copilot:GitHub Copilot data"
    "$HOME/.themes:Custom GTK themes"
)

declare -a FOUND_ITEMS=()
declare -a MISSING_ITEMS=()

# Check what exists and calculate sizes
log_info "Scanning for personal data..."
echo ""

TOTAL_SIZE=0
for item in "${PERSONAL_ITEMS[@]}"; do
    IFS=':' read -r path desc <<< "$item"

    if [[ -e "$path" ]]; then
        SIZE=$(du -sb "$path" 2>/dev/null | cut -f1)
        SIZE_HUMAN=$(du -sh "$path" 2>/dev/null | cut -f1)
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
        FOUND_ITEMS+=("$path:$desc:$SIZE_HUMAN")
        echo "  ✓ $desc - $SIZE_HUMAN"
    else
        MISSING_ITEMS+=("$path:$desc")
    fi
done

if [[ ${#FOUND_ITEMS[@]} -eq 0 ]]; then
    log_error "No personal data directories found!"
    exit 1
fi

if [[ ${#MISSING_ITEMS[@]} -gt 0 ]]; then
    echo ""
    log_warn "Not found (will be skipped):"
    for item in "${MISSING_ITEMS[@]}"; do
        IFS=':' read -r path desc <<< "$item"
        echo "  - $desc"
    done
fi

# Show total size
echo ""
TOTAL_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_SIZE)
log_info "Total backup size: $TOTAL_SIZE_HUMAN"

# Warning for large backups
if [[ $TOTAL_SIZE -gt 10737418240 ]]; then  # > 10GB
    log_warn "⚠️  Backup is VERY LARGE (>10GB)!"
    echo "  Consider using external HDD instead of USB stick"
elif [[ $TOTAL_SIZE -gt 5368709120 ]]; then  # > 5GB
    log_warn "Backup is large (>5GB)"
    echo "  Make sure your USB stick has enough space"
fi

# Ask which items to backup
echo ""
log_warn "Which items do you want to backup?"
echo ""

declare -a SELECTED_ITEMS=()

for idx in "${!FOUND_ITEMS[@]}"; do
    item="${FOUND_ITEMS[$idx]}"
    IFS=':' read -r path desc size <<< "$item"
    echo "[$((idx+1))] $desc ($size)"
done

echo ""
echo "Enter selection:"
echo "  • 'all' - Backup everything"
echo "  • Numbers separated by spaces (e.g., '1 2')"
echo "  • Press Enter to cancel"
echo ""
read -p "Selection: " -r SELECTION

if [[ -z "$SELECTION" ]]; then
    log_info "Backup cancelled"
    exit 0
fi

if [[ "$SELECTION" == "all" ]]; then
    SELECTED_ITEMS=("${FOUND_ITEMS[@]}")
else
    for num in $SELECTION; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#FOUND_ITEMS[@]} ]]; then
            SELECTED_ITEMS+=("${FOUND_ITEMS[$((num-1))]}")
        fi
    done
fi

if [[ ${#SELECTED_ITEMS[@]} -eq 0 ]]; then
    log_error "No valid selection"
    exit 1
fi

# Calculate selected size
SELECTED_SIZE=0
echo ""
log_info "Selected items:"
for item in "${SELECTED_ITEMS[@]}"; do
    IFS=':' read -r path desc size <<< "$item"
    echo "  • $desc ($size)"
    SIZE_BYTES=$(du -sb "$path" 2>/dev/null | cut -f1)
    SELECTED_SIZE=$((SELECTED_SIZE + SIZE_BYTES))
done

SELECTED_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $SELECTED_SIZE)
echo ""
log_info "Selected backup size: $SELECTED_SIZE_HUMAN"

# Confirm backup
echo ""
read -p "Continue with backup? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Backup cancelled"
    exit 0
fi

# Create backup for each selected item
mkdir -p "$OUTPUT_DIR"

for item in "${SELECTED_ITEMS[@]}"; do
    IFS=':' read -r path desc size <<< "$item"
    ITEM_NAME=$(basename "$path")
    ARCHIVE_NAME="personal-${ITEM_NAME}-${TIMESTAMP}.tar.gz"
    ENCRYPTED_NAME="${ARCHIVE_NAME}.gpg"

    echo ""
    log_info "Backing up: $desc"

    # Create temporary working directory
    TMP_DIR=$(mktemp -d)
    trap "rm -rf '$TMP_DIR'" EXIT

    # Create archive
    log_info "Creating archive..."
    cd "$(dirname "$path")"
    tar -czf "$TMP_DIR/$ARCHIVE_NAME" "$(basename "$path")" 2>&1 | grep -v "socket ignored" || true
    ARCHIVE_SIZE=$(du -h "$TMP_DIR/$ARCHIVE_NAME" | cut -f1)
    log_success "Archive created: $ARCHIVE_SIZE"

    # Encrypt with password
    log_info "Encrypting archive..."
    echo ""
    log_warn "Choose a strong password for $desc"
    log_info "Recommendation: Store password in Bitwarden"
    echo ""

    gpg --symmetric --cipher-algo AES256 --output "$OUTPUT_DIR/$ENCRYPTED_NAME" "$TMP_DIR/$ARCHIVE_NAME"

    if [[ $? -eq 0 ]]; then
        # Create checksum
        cd "$OUTPUT_DIR"
        sha256sum "$ENCRYPTED_NAME" > "${ENCRYPTED_NAME}.sha256"

        ENCRYPTED_SIZE=$(du -h "$OUTPUT_DIR/$ENCRYPTED_NAME" | cut -f1)
        log_success "$desc backed up successfully!"
        echo "  Location: $OUTPUT_DIR/$ENCRYPTED_NAME"
        echo "  Size: $ENCRYPTED_SIZE"
    else
        log_error "Encryption failed for $desc"
    fi

    # Cleanup temp directory
    rm -rf "$TMP_DIR"
done

# Create master manifest
MANIFEST_FILE="$OUTPUT_DIR/BACKUP-MANIFEST-${TIMESTAMP}.txt"
cat > "$MANIFEST_FILE" << EOF
Personal Data Backup Manifest
Created: $(date '+%Y-%m-%d %H:%M:%S')
Hostname: $(hostname)
User: $(whoami)

Backed Up Items:
EOF

for item in "${SELECTED_ITEMS[@]}"; do
    IFS=':' read -r path desc size <<< "$item"
    ITEM_NAME=$(basename "$path")
    echo "  • $desc ($size)" >> "$MANIFEST_FILE"
    echo "    File: personal-${ITEM_NAME}-${TIMESTAMP}.tar.gz.gpg" >> "$MANIFEST_FILE"
done

cat >> "$MANIFEST_FILE" << EOF

Restoration Instructions:
========================
1. Copy all .gpg files to new laptop
2. Decrypt: gpg --decrypt <filename>.gpg > <filename>
3. Extract: tar -xzf <filename>
4. Move to appropriate location

SECURITY:
========
• These files contain PERSONAL DATA
• Store encryption passwords in Bitwarden
• Delete from USB/HDD after successful transfer
• Keep backups on external storage (not in Git)
EOF

echo ""
echo "════════════════════════════════════════════════════"
echo "Backup Complete!"
echo "════════════════════════════════════════════════════"
echo "  Location: $OUTPUT_DIR/"
echo "  Total size: $SELECTED_SIZE_HUMAN"
echo "  Items: ${#SELECTED_ITEMS[@]}"
echo "  Manifest: $(basename "$MANIFEST_FILE")"
echo "════════════════════════════════════════════════════"
echo ""
log_success "Safe to copy to external storage"
echo ""
log_warn "SECURITY REMINDERS:"
echo "  ⚠ These files may contain personal documents and data"
echo "  ⚠ Store encryption passwords in Bitwarden"
echo "  ⚠ Delete from USB/HDD after successful transfer"
echo "  ⚠ Keep backups on external storage, NOT in Git"
echo ""
log_info "Manifest saved to: $MANIFEST_FILE"
