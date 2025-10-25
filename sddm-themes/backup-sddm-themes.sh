#!/bin/bash
set -e

echo "=== Backing Up Custom SDDM Themes ==="
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="/usr/share/sddm/themes"

# Check if running with sufficient permissions
if [ ! -r "$THEMES_DIR" ]; then
    echo "Error: Cannot read $THEMES_DIR"
    echo "Run: sudo chmod -R o+rX /usr/share/sddm/themes/"
    exit 1
fi

# Find themes owned by user (not root-only)
echo "Scanning for custom themes in $THEMES_DIR..."
echo

CUSTOM_THEMES=()
for theme_dir in "$THEMES_DIR"/*; do
    if [ -d "$theme_dir" ]; then
        theme_name=$(basename "$theme_dir")
        
        # Check if theme has git repo or is owned by user
        if [ -d "$theme_dir/.git" ] || [ "$(stat -c '%U' "$theme_dir" 2>/dev/null)" = "$USER" ]; then
            CUSTOM_THEMES+=("$theme_name")
        fi
    fi
done

if [ ${#CUSTOM_THEMES[@]} -eq 0 ]; then
    echo "No custom themes found (must be owned by $USER or have .git directory)"
    exit 0
fi

echo "Found ${#CUSTOM_THEMES[@]} custom theme(s):"
for theme in "${CUSTOM_THEMES[@]}"; do
    echo "  - $theme"
done
echo

# Backup each theme
for theme_name in "${CUSTOM_THEMES[@]}"; do
    echo "Backing up: $theme_name"
    
    THEME_PATH="$THEMES_DIR/$theme_name"
    BACKUP_PATH="$SCRIPT_DIR/$theme_name"
    
    # Create backup directory structure
    mkdir -p "$BACKUP_PATH"/{Backgrounds,configs/sddm.conf.d}
    
    # Check if it's a git repo
    if [ -d "$THEME_PATH/.git" ]; then
        echo "  - Git repo detected, checking for modifications..."
        cd "$THEME_PATH"
        
        # Show git status
        git status --short
        
        # Backup modified/new files
        MODIFIED_FILES=$(git status --short --porcelain | grep -E "^( M|\?\?)" | awk '{print $2}')
        
        if [ -n "$MODIFIED_FILES" ]; then
            echo "  - Backing up modified files..."
            for file in $MODIFIED_FILES; do
                if [[ "$file" == Backgrounds/* ]] && [[ "$file" == *.png || "$file" == *.jpg ]]; then
                    cp "$THEME_PATH/$file" "$BACKUP_PATH/Backgrounds/"
                    echo "    ✓ $file"
                elif [[ "$file" == *.conf* ]]; then
                    cp "$THEME_PATH/$file" "$BACKUP_PATH/configs/"
                    echo "    ✓ $file"
                fi
            done
        else
            echo "  - No modifications to backup"
        fi
        
        cd - > /dev/null
    else
        # Not a git repo, backup everything
        echo "  - Backing up all backgrounds and configs..."
        
        if [ -d "$THEME_PATH/Backgrounds" ]; then
            cp "$THEME_PATH/Backgrounds"/*.{png,jpg} "$BACKUP_PATH/Backgrounds/" 2>/dev/null || true
        fi
        
        cp "$THEME_PATH"/*.conf* "$BACKUP_PATH/configs/" 2>/dev/null || true
    fi
    
    # Backup system SDDM config for this theme
    if [ -f /etc/sddm.conf.d/theme.conf.user ]; then
        CURRENT_THEME=$(grep "^Current=" /etc/sddm.conf.d/theme.conf.user 2>/dev/null | cut -d'=' -f2)
        if [ "$CURRENT_THEME" = "$theme_name" ]; then
            cp /etc/sddm.conf.d/theme.conf.user "$BACKUP_PATH/configs/sddm.conf.d/"
            echo "  - Backed up system config (active theme)"
        fi
    fi
    
    # Create/update README
    cat > "$BACKUP_PATH/README.md" << THEME_EOF
# SDDM Theme: $theme_name

Backed up: $(date)

## Restore
\`\`\`bash
cd ~/dotfiles/sddm-themes
./install-theme.sh $theme_name
\`\`\`

## Manual Restore
\`\`\`bash
sudo cp Backgrounds/*.{png,jpg} /usr/share/sddm/themes/$theme_name/Backgrounds/
sudo cp configs/*.conf /usr/share/sddm/themes/$theme_name/
sudo chown -R \$USER:\$USER /usr/share/sddm/themes/$theme_name
\`\`\`
THEME_EOF
    
    echo "  ✓ Backed up to: $BACKUP_PATH"
    echo
done

# Update dotfiles git
cd "$SCRIPT_DIR/.."
echo "=== Git Status ==="
git status --short sddm-themes/

echo
echo "To commit changes:"
echo "  cd ~/dotfiles"
echo "  git add sddm-themes/"
echo "  git commit -m 'Update SDDM theme backups'"
echo "  git push"
