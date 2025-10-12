#!/bin/bash
#
# apply-dark-mode.sh - Apply dark mode settings system-wide
#
# Sets dark mode for:
# - GTK applications (Nordic theme)
# - Qt applications
# - Flatpak applications
# - i3 window manager (via Nordic theme)
# - VSCode
# - System preferences
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

log_info "Applying dark mode settings..."
echo ""

# Detect desktop environment
DE=""
if [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]]; then
    DE="XFCE"
    log_info "Detected: XFCE desktop environment"
elif [[ "$XDG_CURRENT_DESKTOP" == *"Cinnamon"* ]]; then
    DE="Cinnamon"
    log_info "Detected: Cinnamon desktop environment"
elif [[ "$XDG_CURRENT_DESKTOP" == *"MATE"* ]]; then
    DE="MATE"
    log_info "Detected: MATE desktop environment"
else
    DE="Unknown"
    log_warn "Unknown desktop environment: $XDG_CURRENT_DESKTOP"
fi

# Apply GTK dark theme (Nordic) based on desktop environment
log_info "Setting GTK theme to Nordic..."
if [[ -d "$HOME/.themes/Nordic" ]]; then
    case "$DE" in
        XFCE)
            # XFCE uses xfconf-query
            if command -v xfconf-query &> /dev/null; then
                xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic" 2>/dev/null || true
                xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" 2>/dev/null || true
                xfconf-query -c xfwm4 -p /general/theme -s "Nordic" 2>/dev/null || true
                log_success "GTK theme set to Nordic (XFCE)"
            else
                log_warn "xfconf-query not found, theme will be set via GTK config files only"
            fi
            ;;
        Cinnamon)
            gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic" 2>/dev/null || true
            gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
            log_success "GTK theme set to Nordic (Cinnamon)"
            ;;
        MATE)
            gsettings set org.mate.interface gtk-theme "Nordic" 2>/dev/null || true
            gsettings set org.mate.interface icon-theme "Papirus-Dark" 2>/dev/null || true
            log_success "GTK theme set to Nordic (MATE)"
            ;;
        *)
            log_warn "Unknown DE - theme will be set via GTK config files only"
            ;;
    esac

    # Also set via gsettings for GNOME apps
    gsettings set org.gnome.desktop.interface gtk-theme "Nordic" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
else
    log_warn "Nordic theme not found - run scripts/install-themes.sh first"
fi

# Apply dark color scheme preference (XFCE 4.18+ and others)
log_info "Setting color scheme to dark..."
case "$DE" in
    XFCE)
        # XFCE 4.18+ has dark mode preference
        if command -v xfconf-query &> /dev/null; then
            xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic" 2>/dev/null || true
            # Some XFCE versions support prefer-dark
            xfconf-query -c xsettings -p /Gtk/PreferDarkTheme -t bool -s true 2>/dev/null || log_info "Dark theme preference set via GTK config"
        fi
        ;;
    Cinnamon)
        gsettings set org.cinnamon.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        ;;
    MATE)
        gsettings set org.mate.interface gtk-color-scheme 'prefer-dark' 2>/dev/null || true
        ;;
esac

# Also try GNOME settings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
log_success "Color scheme set to dark"

# Apply dark theme to GTK applications via settings.ini
log_info "Configuring GTK settings..."

# Ensure .config directory exists first
mkdir -p "$HOME/.config"

# Create GTK-3.0 directory
if ! mkdir -p "$HOME/.config/gtk-3.0" 2>/dev/null; then
    log_warn "Could not create $HOME/.config/gtk-3.0 directory"
    log_warn "Checking permissions..."
    ls -ld "$HOME/.config" 2>/dev/null || log_warn "$HOME/.config does not exist"
fi

# Write settings.ini
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Nordic
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintmedium
gtk-xft-rgba=rgb
EOF

# Create GTK-4.0 directory
mkdir -p "$HOME/.config/gtk-4.0" 2>/dev/null || log_warn "Could not create $HOME/.config/gtk-4.0 directory"

cat > "$HOME/.config/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Nordic
gtk-icon-theme-name=Papirus-Dark
EOF

log_success "GTK settings configured"

# Apply dark theme to Qt applications
log_info "Configuring Qt dark theme..."

# Create Qt5ct directory
mkdir -p "$HOME/.config/qt5ct" 2>/dev/null || log_warn "Could not create $HOME/.config/qt5ct directory"

cat > "$HOME/.config/qt5ct/qt5ct.conf" << 'EOF'
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/darker.conf
custom_palette=true
icon_theme=Papirus-Dark
style=Fusion
EOF

export QT_QPA_PLATFORMTHEME=qt5ct
log_success "Qt dark theme configured"

# Apply dark theme to Flatpak applications
log_info "Applying dark theme to Flatpak applications..."
if command -v flatpak &> /dev/null; then
    # Override theme for all Flatpak apps
    flatpak override --user --filesystem=~/.themes:ro 2>/dev/null || true
    flatpak override --user --filesystem=~/.icons:ro 2>/dev/null || true
    flatpak override --user --env=GTK_THEME=Nordic 2>/dev/null || true

    # Specific overrides for key apps
    flatpak override --user app.zen_browser.zen --env=GTK_THEME=Nordic 2>/dev/null || true
    flatpak override --user com.bitwarden.desktop --env=GTK_THEME=Nordic 2>/dev/null || true
    flatpak override --user md.obsidian.Obsidian --env=GTK_THEME=Nordic 2>/dev/null || true
    flatpak override --user io.github.brunofin.Cohesion --env=GTK_THEME=Nordic 2>/dev/null || true

    log_success "Flatpak dark theme applied"
else
    log_warn "Flatpak not found, skipping Flatpak theme settings"
fi

# Apply dark theme to VSCode (if installed)
log_info "Configuring VSCode dark theme..."
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
if [[ -f "$VSCODE_SETTINGS" ]]; then
    # VSCode settings are managed by sync, but ensure dark theme
    log_info "VSCode settings found - dark theme should sync automatically"
elif command -v code &> /dev/null; then
    # Create VSCode settings directory
    mkdir -p "$HOME/.config/Code/User" 2>/dev/null || log_warn "Could not create VSCode settings directory"

    cat > "$VSCODE_SETTINGS" << 'EOF'
{
    "workbench.colorTheme": "Nord",
    "window.titleBarStyle": "custom",
    "window.menuBarVisibility": "toggle",
    "editor.fontFamily": "'Fira Code', 'Droid Sans Mono', 'monospace'",
    "editor.fontLigatures": true,
    "editor.fontSize": 14
}
EOF
    log_success "VSCode dark theme configured"
else
    log_warn "VSCode not installed, skipping VSCode settings"
fi

# Apply dark theme to Tilix
log_info "Configuring Tilix dark theme..."
if command -v tilix &> /dev/null; then
    # Tilix uses dconf, which is managed via stow
    log_info "Tilix settings managed via dotfiles - dark theme should already be configured"
else
    log_warn "Tilix not installed, skipping Tilix settings"
fi

# Set X resources for terminal colors (fallback)
log_info "Setting X resources for dark terminal colors..."
cat > "$HOME/.Xresources" << EOF
! Nord Color Scheme for terminals
*.foreground:   #D8DEE9
*.background:   #2E3440
*.cursorColor:  #D8DEE9
! Black
*.color0:       #3B4252
*.color8:       #4C566A
! Red
*.color1:       #BF616A
*.color9:       #BF616A
! Green
*.color2:       #A3BE8C
*.color10:      #A3BE8C
! Yellow
*.color3:       #EBCB8B
*.color11:      #EBCB8B
! Blue
*.color4:       #81A1C1
*.color12:      #81A1C1
! Magenta
*.color5:       #B48EAD
*.color13:      #B48EAD
! Cyan
*.color6:       #88C0D0
*.color14:      #8FBCBB
! White
*.color7:       #E5E9F0
*.color15:      #ECEFF4
EOF

xrdb -merge "$HOME/.Xresources" 2>/dev/null || log_warn "Could not load X resources (X server may not be running)"
log_success "X resources configured"

echo ""
log_success "Dark mode applied successfully!"
echo ""
echo "Changes applied to:"
echo "  ✓ GTK theme (Nordic)"
echo "  ✓ Icon theme (Papirus-Dark)"
echo "  ✓ Color scheme (prefer-dark)"
echo "  ✓ Qt applications"
echo "  ✓ Flatpak applications"
echo "  ✓ VSCode (if installed)"
echo "  ✓ Terminal colors (Nord palette)"
echo ""
log_warn "Note: Some applications may require a restart to apply changes"
log_info "For Zen Browser: Dark theme is controlled within browser settings"
echo ""
