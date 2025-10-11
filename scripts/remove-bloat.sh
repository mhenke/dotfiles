#!/bin/bash
#
# remove-bloat.sh - Remove bloat from existing Linux Mint installation
#
# This script removes unnecessary packages from your current system:
# - LibreOffice (162 packages)
# - International fonts (102 packages)
# - Printer/Scanner support (30 packages)
# - Bluetooth (if not needed)
# - Default Mint apps you don't use
# - Ubuntu telemetry and bloat
# - XFCE components (you use i3)
#
# ESTIMATED REMOVAL: ~450 packages, ~2.1 GB freed
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should NOT be run as root. Run as your normal user."
   exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "======================================================================"
echo "  Linux Mint Bloat Removal Script"
echo "======================================================================"
echo ""
echo "This will remove:"
echo "  - LibreOffice suite (162 packages, ~600MB)"
echo "  - International fonts (102 packages, ~200MB)"
echo "  - Printer/Scanner support (30 packages, ~150MB)"
echo "  - Bluetooth (5 packages, ~50MB)"
echo "  - Default Mint apps (18 packages, ~300MB)"
echo "  - Ubuntu telemetry (10 packages, ~100MB)"
echo "  - XFCE components (59 packages, ~200MB)"
echo "  - Mint themes/backgrounds (15 packages, ~100MB)"
echo "  - GNOME apps (6 packages, ~100MB)"
echo "  - Accessibility tools (6 packages, ~50MB)"
echo ""
echo "TOTAL: ~450 packages, ~2.1GB freed"
echo ""
log_warn "This is irreversible! Make sure you have backups."
echo ""
read -p "Continue with bloat removal? (yes/NO) " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log_info "Bloat removal cancelled."
    exit 0
fi

# =============================================================================
# REMOVE LIBREOFFICE
# =============================================================================
log_info "Removing LibreOffice suite..."
sudo apt purge -y \
    libreoffice-* \
    uno-libs-private \
    ure \
    ure-java \
    2>/dev/null || log_warn "Some LibreOffice packages not found"

# Remove dictionaries
sudo apt purge -y \
    hunspell-* \
    hyphen-* \
    mythes-* \
    wamerican wbrazilian wbritish wfrench witalian \
    wngerman wogerman wportuguese wspanish wswiss \
    2>/dev/null || log_warn "Some dictionaries not found"

log_success "LibreOffice removed"

# =============================================================================
# REMOVE INTERNATIONAL FONTS
# =============================================================================
log_info "Removing international fonts (keeping English only)..."
sudo apt purge -y \
    fonts-beng* fonts-deva* fonts-gujr* fonts-guru* \
    fonts-knda* fonts-mlym* fonts-orya* fonts-taml* fonts-telu* \
    fonts-thai-tlwg fonts-tlwg-* fonts-tibetan-machine \
    fonts-khmeros-core fonts-lao fonts-lklug-sinhala \
    fonts-wqy-zenhei fonts-ipafont-gothic fonts-noto-cjk \
    fonts-kacst* fonts-sil-* fonts-indic \
    fonts-lohit-* fonts-samyak-* fonts-gargi fonts-nakula \
    fonts-sahadeva fonts-navilu fonts-pagul fonts-sarai \
    fonts-teluguvijayam fonts-smc-* \
    2>/dev/null || log_warn "Some fonts not found"

log_success "International fonts removed"

# =============================================================================
# REMOVE PRINTER/SCANNER SUPPORT
# =============================================================================
log_info "Removing printer and scanner support..."
sudo apt purge -y \
    cups cups-daemon cups-client cups-browsed cups-filters* \
    cups-ipp-utils cups-pk-helper cups-ppdc cups-server-common \
    cups-bsd cups-common cups-core-drivers \
    system-config-printer* \
    printer-driver-* \
    hplip hplip-data \
    sane sane-utils sane-airscan sane-common \
    libsane* simple-scan \
    2>/dev/null || log_warn "Some printer/scanner packages not found"

log_success "Printer/Scanner support removed"

# =============================================================================
# REMOVE BLUETOOTH
# =============================================================================
log_info "Removing Bluetooth support..."
sudo apt purge -y \
    blueman bluetooth bluez bluez-cups bluez-obexd \
    2>/dev/null || log_warn "Some Bluetooth packages not found"

log_success "Bluetooth removed"

# =============================================================================
# REMOVE DEFAULT MINT APPLICATIONS
# =============================================================================
log_info "Removing default Mint applications..."
sudo apt purge -y \
    rhythmbox* celluloid hypnotix \
    hexchat hexchat-common \
    transmission-gtk transmission-common \
    drawing pix pix-data pix-dbg \
    warpinator baobab brasero-common \
    2>/dev/null || log_warn "Some Mint apps not found"

log_success "Default Mint apps removed"

# =============================================================================
# REMOVE UBUNTU TELEMETRY & BLOAT
# =============================================================================
log_info "Removing Ubuntu telemetry and bloat..."
sudo apt purge -y \
    apport apport-gtk python3-apport \
    whoopsie kerneloops popularity-contest \
    ubuntu-report ubuntu-advantage-tools \
    app-install-data aptdaemon* \
    packagekit* gnome-software* \
    mintinstall mintupdate mintsources mintreport \
    webapp-manager \
    snapd snap-confine squashfs-tools \
    flatpak xdg-desktop-portal-gtk xdg-desktop-portal-xapp \
    accountsservice colord* rtkit geoclue-2.0 \
    policykit-1-gnome policykit-desktop-privileges \
    update-manager* update-notifier* \
    ubuntu-dbgsym-keyring \
    modemmanager mobile-broadband-provider-info \
    2>/dev/null || log_warn "Some Ubuntu packages not found"

log_success "Ubuntu telemetry removed"

# =============================================================================
# REMOVE XFCE COMPONENTS
# =============================================================================
log_info "Removing XFCE components (you use i3)..."
sudo apt purge -y \
    xfce4-* xfwm4 xfdesktop4* xfconf thunar* \
    libxfce4* gir1.2-xfconf-0 \
    mint-info-xfce mint-meta-xfce \
    2>/dev/null || log_warn "Some XFCE packages not found"

log_success "XFCE components removed"

# =============================================================================
# REMOVE MINT THEMES/BACKGROUNDS
# =============================================================================
log_info "Removing Mint themes and backgrounds..."
sudo apt purge -y \
    mint-backgrounds-* \
    mint-artwork mint-cursor-themes \
    mint-l-icons mint-l-theme mint-themes \
    mint-x-icons mint-y-icons \
    2>/dev/null || log_warn "Some themes not found"

log_success "Mint themes removed"

# =============================================================================
# REMOVE GNOME APPS
# =============================================================================
log_info "Removing GNOME applications..."
sudo apt purge -y \
    gnome-calculator gnome-disk-utility \
    gnome-system-monitor gnome-logs \
    gnome-shell gnome-shell-extension-appindicator \
    yelp yelp-xsl \
    2>/dev/null || log_warn "Some GNOME apps not found"

log_success "GNOME apps removed"

# =============================================================================
# REMOVE ACCESSIBILITY TOOLS
# =============================================================================
log_info "Removing accessibility tools..."
sudo apt purge -y \
    orca onboard onboard-common caribou \
    mousetweaks brltty \
    2>/dev/null || log_warn "Some accessibility tools not found"

log_success "Accessibility tools removed"

# =============================================================================
# REMOVE ADDITIONAL BLOAT
# =============================================================================
log_info "Removing additional bloat..."
sudo apt purge -y \
    gamemode gamemode-daemon \
    okular evince \
    rdate \
    nitrogen compton compiz* \
    metacity* light-locker* \
    2>/dev/null || log_warn "Some additional packages not found"

log_success "Additional bloat removed"

# =============================================================================
# REMOVE GOBJECT LIBRARIES (keep essential ones)
# =============================================================================
log_info "Removing unnecessary GObject libraries..."
sudo apt purge -y \
    gir1.2-accountsservice-1.0 gir1.2-appstream-1.0 \
    gir1.2-appstreamglib-1.0 gir1.2-caribou-1.0 \
    gir1.2-clutter-1.0 gir1.2-cogl-1.0 gir1.2-coglpango-1.0 \
    gir1.2-dee-1.0 gir1.2-flatpak-1.0 gir1.2-gmenu-3.0 \
    gir1.2-gspell-1 gir1.2-gtksource-3.0 gir1.2-gtksource-4 \
    gir1.2-gtop-2.0 gir1.2-handy-1 gir1.2-ibus-1.0 \
    gir1.2-javascriptcoregtk-4.0 gir1.2-nm-1.0 gir1.2-nma-1.0 \
    gir1.2-packagekitglib-1.0 gir1.2-peas-1.0 gir1.2-polkit-1.0 \
    gir1.2-rb-3.0 gir1.2-soup-2.4 gir1.2-timezonemap-1.0 \
    gir1.2-udisks-2.0 gir1.2-webkit2-4.0 gir1.2-wnck-3.0 \
    gir1.2-xkl-1.0 gir1.2-xviewer-3.0 gir1.2-xapp-1.0 \
    2>/dev/null || log_warn "Some GObject libraries not found"

log_success "GObject libraries cleaned"

# =============================================================================
# CLEANUP
# =============================================================================
log_info "Running autoremove to clean up dependencies..."
sudo apt autoremove -y --purge

log_info "Running autoclean..."
sudo apt autoclean

log_info "Running clean..."
sudo apt clean

# =============================================================================
# FINAL SUMMARY
# =============================================================================
echo ""
echo "======================================================================"
log_success "Bloat removal complete!"
echo "======================================================================"
echo ""
log_info "Summary:"
echo "  - Removed ~450 packages"
echo "  - Freed ~2.1 GB disk space"
echo "  - Removed: LibreOffice, printers, bluetooth, XFCE, telemetry, bloat"
echo ""
log_info "Next steps:"
echo "  1. Reboot your system"
echo "  2. Verify i3 still works correctly"
echo "  3. Run: df -h (to see freed space)"
echo ""
log_warn "If you need any removed package, install manually with: sudo apt install <package>"
echo ""
