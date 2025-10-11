# Zen Browser Complete Transfer Guide
## Seamless Migration of All Settings, Bookmarks, History, Tabs, Extensions & Themes

**Browser**: Zen Browser (Firefox-based)
**Profile Size**: ~723MB
**Transfer Method**: Full profile backup OR Firefox Sync
**What Gets Transferred**: Everything!

---

## 📦 What Gets Transferred

Your Zen browser profile includes **everything**:

### ✅ Browsing Data
- **Bookmarks** (places.sqlite)
- **Browsing history** (places.sqlite)
- **Passwords** (logins.json + key4.db - encrypted)
- **Cookies** (cookies.sqlite)
- **Form autofill data** (formhistory.sqlite)
- **Search engines** (search.json.mozlz4)
- **Download history** (places.sqlite)

### ✅ Extensions & Add-ons
- **Installed extensions** (extensions.json, addons.json)
- **Extension data** (storage.sqlite, storage-sync-v2.sqlite)
- **Extension preferences** (extension-preferences.json, extension-settings.json)
- **Extensions folder** with all installed add-ons

### ✅ Settings & Preferences
- **All preferences** (prefs.js)
- **Zen-specific settings** (zen-themes.json)
- **Container tabs** (containers.json)
- **Permissions** (permissions.sqlite)
- **Site-specific settings** (content-prefs.sqlite)
- **Download handlers** (handlers.json)

### ✅ Themes & Appearance
- **Zen themes** (zen-themes.json)
- **Custom CSS** (chrome/ folder if exists)
- **UI state** (xulstore.json)
- **Favicons** (favicons.sqlite)

### ✅ Session & Tabs
- **Open tabs** (sessionstore.jsonlz4, sessionCheckpoints.json)
- **Tab groups** (if using)
- **Window state**
- **Recently closed tabs/windows**

### ✅ Cache & Performance
- **Session storage** (webappsstore.sqlite)
- **Offline cache**
- **Service workers**

---

## 🚀 Transfer Methods

You have **3 options** to transfer your Zen browser setup:

### Option 1: Firefox Sync (Easiest, Recommended)

**What syncs:**
- ✅ Bookmarks
- ✅ History
- ✅ Passwords
- ✅ Extensions (list, but not all extension data)
- ✅ Preferences
- ✅ Open tabs
- ❌ Some extension settings (may need reconfiguration)
- ❌ Local themes/CSS

**How to use:**
```bash
# On OLD laptop:
1. Open Zen Browser
2. Menu → Settings → Firefox Account
3. Sign in with your Mozilla/Firefox Account
4. Enable sync for: Bookmarks, History, Passwords, Tabs, Extensions

# On NEW laptop:
1. Install Zen Browser (via bootstrap.sh or manual)
2. Open Zen Browser
3. Menu → Settings → Firefox Account
4. Sign in with same account
5. Wait for sync to complete (1-5 minutes)
```

**Pros:**
- ✅ Easiest method
- ✅ Works across any device
- ✅ Automatic ongoing sync
- ✅ No manual file copying

**Cons:**
- ❌ Requires internet connection
- ❌ Some extension settings may not sync
- ❌ Custom CSS/themes may not sync
- ❌ Takes 1-5 minutes to sync

---

### Option 2: Full Profile Backup (Complete, Offline)

**What's included:**
- ✅ **Everything** - 100% identical browser state
- ✅ All extensions with all settings
- ✅ All themes and custom CSS
- ✅ Open tabs and session
- ✅ Complete history
- ✅ All passwords (encrypted)
- ✅ All bookmarks

**How to use:**

**On OLD laptop - Create backup:**
```bash
# Run the backup script (already includes Zen)
cd ~/dotfiles
./scripts/backup-app-configs.sh

# This creates: ~/dotfiles-backup-YYYYMMDD-HHMMSS/
# and includes .zen/ directory (~723MB)

# Copy backup to USB or cloud:
cp -r ~/dotfiles-backup-YYYYMMDD-HHMMSS /media/usb-drive/
# OR upload to cloud storage
```

**On NEW laptop - Restore:**
```bash
# After running bootstrap.sh (which installs Zen Browser)
# Before opening Zen for the first time:

# Copy backup from USB/cloud
cp -r /media/usb-drive/dotfiles-backup-YYYYMMDD-HHMMSS ~/

# Run restore script
cd ~/dotfiles-backup-YYYYMMDD-HHMMSS
./restore.sh

# OR manually:
cp -r .zen ~/

# Now open Zen Browser - everything will be exactly as before!
```

**Pros:**
- ✅ **100% complete** - exact replica
- ✅ Works offline
- ✅ Instant (no waiting for sync)
- ✅ All extension settings preserved
- ✅ Custom themes/CSS included

**Cons:**
- ❌ Requires manual backup/restore
- ❌ Large file size (~723MB)
- ❌ Need USB drive or cloud storage

---

### Option 3: Hybrid (Best of Both)

**Recommended for most users:**

```bash
# Use Firefox Sync for ongoing sync
# PLUS create a one-time full backup for safety

# On OLD laptop:
1. Enable Firefox Sync (see Option 1)
2. Run backup script: ./scripts/backup-app-configs.sh
3. Keep backup on USB as insurance

# On NEW laptop:
1. Install Zen via bootstrap
2. Sign into Firefox Sync (gets 90% there)
3. If anything is missing, restore from backup
```

**Why this is best:**
- ✅ Firefox Sync handles most things automatically
- ✅ Backup ensures nothing is lost
- ✅ Can restore specific things if needed
- ✅ Ongoing sync keeps browsers in sync

---

## 📁 Zen Browser Profile Structure

Your Zen profile (`~/.zen/gp866hh7.Michael Henke/`) contains:

```
~/.zen/
├── profiles.ini                   # Profile configuration
├── installs.ini                   # Installation info
└── gp866hh7.Michael Henke/       # Your main profile (~723MB)
    ├── bookmarkbackups/           # Automatic bookmark backups
    ├── extensions/                # Installed add-ons
    ├── storage/                   # Extension storage
    ├── chrome/                    # Custom CSS (if you have it)
    ├── places.sqlite              # Bookmarks + History
    ├── favicons.sqlite            # Website icons
    ├── cookies.sqlite             # Cookies
    ├── formhistory.sqlite         # Form autofill data
    ├── logins.json                # Encrypted passwords
    ├── key4.db                    # Password encryption key
    ├── prefs.js                   # All preferences
    ├── zen-themes.json            # Zen-specific themes
    ├── sessionstore.jsonlz4       # Open tabs/windows
    ├── sessionCheckpoints.json    # Session backup
    ├── extensions.json            # Extension list
    ├── addons.json                # Add-on metadata
    ├── extension-preferences.json # Extension settings
    ├── storage.sqlite             # Extension data
    ├── containers.json            # Container tabs
    ├── handlers.json              # File download handlers
    ├── permissions.sqlite         # Site permissions
    ├── content-prefs.sqlite       # Per-site preferences
    └── webappsstore.sqlite        # Session storage
```

---

## 🔧 Detailed Transfer Instructions

### Method: Full Profile Backup (Step-by-Step)

#### On OLD Laptop

**Step 1: Run Backup Script**
```bash
cd ~/dotfiles
./scripts/backup-app-configs.sh
```

**What happens:**
- Creates `~/dotfiles-backup-YYYYMMDD-HHMMSS/`
- Copies `~/.zen/` directory (entire profile)
- Creates `restore.sh` script for easy restoration
- Includes README with instructions

**Step 2: Verify Backup**
```bash
cd ~/dotfiles-backup-YYYYMMDD-HHMMSS
ls -lh .zen/
# Should show ~723MB directory

# Check profile exists:
ls -la .zen/gp866hh7.Michael\ Henke/ | head -20
# Should list bookmarks, history, extensions, etc.
```

**Step 3: Copy to USB or Cloud**
```bash
# To USB:
cp -r ~/dotfiles-backup-YYYYMMDD-HHMMSS /media/your-usb-drive/

# Or tar it for easier transfer:
cd ~
tar -czf zen-backup.tar.gz dotfiles-backup-YYYYMMDD-HHMMSS/
cp zen-backup.tar.gz /media/your-usb-drive/

# Or upload to cloud storage (Dropbox, Google Drive, etc.)
```

#### On NEW Laptop

**Step 1: Install Zen Browser First**
```bash
# Run bootstrap (installs Zen Browser among other apps)
cd ~/dotfiles
./bootstrap.sh

# OR install Zen manually if not in bootstrap:
# Download from https://zen-browser.app/
```

**Step 2: Close Zen if it Opened**
```bash
# Make sure Zen is NOT running
pkill -f zen-bin || true
```

**Step 3: Restore Profile**
```bash
# Copy backup from USB/cloud
cp -r /media/usb-drive/dotfiles-backup-YYYYMMDD-HHMMSS ~/

# OR extract if tarred:
cd ~
tar -xzf /media/usb-drive/zen-backup.tar.gz

# Run restore script:
cd ~/dotfiles-backup-YYYYMMDD-HHMMSS
./restore.sh

# OR manually:
cp -r .zen ~/
```

**Step 4: Open Zen Browser**
```bash
# Launch Zen
zen-browser

# OR from rofi: Mod+d → type "zen"
```

**Step 5: Verify Everything Works**
- [ ] Bookmarks are there
- [ ] History intact
- [ ] Extensions installed and working
- [ ] Passwords saved (master password if you have one)
- [ ] Open tabs restored (if browser crashed/closed with tabs open)
- [ ] Themes applied
- [ ] Settings preserved

---

## 🛡️ Important Files for Transfer

If you want to **manually** transfer specific items instead of full profile:

### Bookmarks Only
```bash
# Copy these files:
~/.zen/gp866hh7.Michael Henke/places.sqlite
~/.zen/gp866hh7.Michael Henke/favicons.sqlite
~/.zen/gp866hh7.Michael Henke/bookmarkbackups/
```

### Passwords Only
```bash
# Copy these files:
~/.zen/gp866hh7.Michael Henke/logins.json
~/.zen/gp866hh7.Michael Henke/key4.db
```

### Extensions Only
```bash
# Copy these:
~/.zen/gp866hh7.Michael Henke/extensions/
~/.zen/gp866hh7.Michael Henke/extensions.json
~/.zen/gp866hh7.Michael Henke/addons.json
~/.zen/gp866hh7.Michael Henke/storage.sqlite
~/.zen/gp866hh7.Michael Henke/extension-preferences.json
```

### Settings Only
```bash
# Copy these:
~/.zen/gp866hh7.Michael Henke/prefs.js
~/.zen/gp866hh7.Michael Henke/zen-themes.json
~/.zen/gp866hh7.Michael Henke/handlers.json
~/.zen/gp866hh7.Michael Henke/containers.json
```

### Open Tabs/Session Only
```bash
# Copy these:
~/.zen/gp866hh7.Michael Henke/sessionstore.jsonlz4
~/.zen/gp866hh7.Michael Henke/sessionCheckpoints.json
```

---

## ✅ Verification Checklist

After restoring on new laptop, verify:

### Bookmarks
```bash
# Open Zen → Ctrl+Shift+B (Bookmarks Library)
# Check that all folders and bookmarks are there
```

### History
```bash
# Ctrl+H (History sidebar)
# Should show months of browsing history
```

### Passwords
```bash
# Settings → Privacy & Security → Saved Logins
# Check that passwords are saved
# May need to enter master password if you have one
```

### Extensions
```bash
# Menu → Extensions
# All extensions should be installed
# Check that extension settings are preserved
```

### Themes
```bash
# Check Zen themes are applied
# Menu → Themes or look for zen-themes.json
```

### Open Tabs
```bash
# If you had tabs open when backup was made
# They should restore on first launch
# Or: History → Recently Closed Tabs
```

### Settings
```bash
# Settings → General, Privacy, Search, etc.
# All preferences should match old laptop
```

---

## 🔧 Troubleshooting

### Zen won't start after restore
```bash
# Remove compatibility.ini and try again:
rm ~/.zen/gp866hh7.Michael\ Henke/compatibility.ini
zen-browser
```

### Extensions not working
```bash
# Extensions may need to be re-enabled:
# Menu → Extensions → Enable all
# Some may need to be reinstalled from addons.mozilla.org
```

### Bookmarks missing
```bash
# Check bookmark backups:
ls ~/.zen/gp866hh7.Michael\ Henke/bookmarkbackups/

# Restore from backup:
# Bookmarks Library → Import and Backup → Restore → Choose backup date
```

### Passwords don't work
```bash
# Make sure you copied both files:
ls ~/.zen/gp866hh7.Michael\ Henke/logins.json
ls ~/.zen/gp866hh7.Michael\ Henke/key4.db

# If you have a master password, you'll need to enter it
```

### Session not restored
```bash
# Manually restore session:
# Menu → History → Restore Previous Session
```

---

## 📋 Quick Reference

### Backup Zen (Old Laptop)
```bash
cd ~/dotfiles
./scripts/backup-app-configs.sh
cp -r ~/dotfiles-backup-* /media/usb/
```

### Restore Zen (New Laptop)
```bash
# After installing Zen via bootstrap.sh:
cp -r /media/usb/dotfiles-backup-* ~/
cd ~/dotfiles-backup-*
./restore.sh
```

### Manual Backup (Alternative)
```bash
# Just copy the .zen folder:
cp -r ~/.zen ~/backup-zen-$(date +%Y%m%d)
tar -czf zen-backup.tar.gz backup-zen-*
```

### Manual Restore (Alternative)
```bash
# Extract and copy:
tar -xzf zen-backup.tar.gz
cp -r backup-zen-*/.zen ~/
```

---

## 🎯 Recommended Approach

**For your migration, I recommend:**

1. **Enable Firefox Sync** (for ongoing sync)
   - Sign into Firefox Account in Zen
   - Enable all sync options
   - This keeps your browsers in sync going forward

2. **Create Full Profile Backup** (insurance)
   - Run `./scripts/backup-app-configs.sh`
   - Copy to USB drive
   - Keep as backup in case sync misses anything

3. **On New Laptop:**
   - Install Zen via `./bootstrap.sh`
   - Sign into Firefox Account (gets 90% of data)
   - Check if everything synced
   - If anything missing, restore from USB backup

**Why this works best:**
- ✅ Firefox Sync is convenient and automatic
- ✅ Full backup ensures nothing is lost
- ✅ Best of both worlds
- ✅ Future-proof (sync keeps working)

---

## 📊 What's Already Handled

Your `backup-app-configs.sh` script **already includes** Zen Browser:

```bash
# Lines 38-43 of backup-app-configs.sh:
if [ -d "$HOME/.zen" ]; then
    log_info "Found Zen Browser config"
    cp -r "$HOME/.zen" "$BACKUP_DIR/"
    log_success "Zen Browser backed up"
fi
```

And the `restore.sh` (auto-generated):
```bash
# Zen Browser
if [ -d ".zen" ]; then
    log_info "Restoring Zen Browser..."
    cp -r .zen "$HOME/"
    log_success "Zen Browser restored"
fi
```

**So you're already covered!** ✅

---

## ✨ Summary

Your Zen browser transfer is **fully automated**:

1. **Run** `./scripts/backup-app-configs.sh` on old laptop
2. **Copy** the backup to USB/cloud
3. **Run** `./restore.sh` on new laptop
4. **Done!** Everything transferred: bookmarks, history, tabs, extensions, themes, settings, passwords

**OR use Firefox Sync** for ongoing automatic synchronization across devices.

**Total time: ~5 minutes** (or instant with Firefox Sync) 🚀
