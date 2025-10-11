# Linux Mint Bloat Analysis

**Total packages in apt-manual.txt:** 2,205 packages
**Estimated bloat identified:** 500+ packages

---

## 🚨 Major Bloat Categories

### 1. LibreOffice Suite (162 packages)
**Status:** Do you need LibreOffice?

```
LibreOffice core packages:
- libreoffice-base, -calc, -draw, -impress, -writer, -math
- libreoffice-common, -core

Help files (23 packages):
- libreoffice-help-de, -en-gb, -en-us, -es, -fr, -it, -pt, -pt-br, -ru, -zh-cn, -zh-tw

Localization (10 packages):
- libreoffice-l10n-de, -en-gb, -en-za, -es, -fr, -it, -pt, -pt-br, -ru, -zh-cn, -zh-tw

Dictionaries/Hyphenation (106 packages):
- hunspell-* (20 packages)
- hyphen-* (8 packages)
- mythes-* (8 packages)
- fonts-lohit-* (15 packages)
- fonts-smc-* (20 packages)
- fonts-tlwg-* (35 packages)
```

**Recommendation:** If you don't use LibreOffice, this is **162 packages to skip**.

---

### 2. International Fonts (102 packages)
**Status:** You only need English fonts

```
Unnecessary font packages:
- fonts-beng, fonts-beng-extra (Bengali)
- fonts-deva, fonts-deva-extra (Devanagari)
- fonts-gujr, fonts-gujr-extra (Gujarati)
- fonts-guru, fonts-guru-extra (Gurmukhi)
- fonts-knda (Kannada)
- fonts-mlym (Malayalam)
- fonts-orya (Oriya)
- fonts-taml (Tamil)
- fonts-telu (Telugu)
- fonts-thai-tlwg (Thai - 20 packages!)
- fonts-tibetan-machine
- fonts-khmeros-core (Khmer)
- fonts-lao (Lao)
- fonts-sinhala (Sinhala)
- fonts-wqy-zenhei (Chinese)
- fonts-ipafont-gothic (Japanese)
- fonts-kacst (Arabic)
```

**Keep only:**
- fonts-powerline
- fonts-firacode
- fonts-font-awesome
- fonts-noto-color-emoji (emojis)
- fonts-liberation (basic web fonts)

**Save:** ~100 packages

---

### 3. GObject Introspection Libraries (55 packages)
**Status:** Mostly for Python/GNOME apps you don't use

```
gir1.2-* packages (GNOME bindings):
- gir1.2-accountsservice-1.0
- gir1.2-appstream-1.0
- gir1.2-atk-1.0
- gir1.2-caribou-1.0
- gir1.2-clutter-1.0
- gir1.2-gstreamer-1.0
- gir1.2-gtk-3.0 (KEEP - needed for GTK apps)
- gir1.2-notify-0.7 (KEEP - needed for dunst)
- gir1.2-nm-1.0
- gir1.2-packagekitglib-1.0
- gir1.2-rb-3.0 (Rhythmbox)
- gir1.2-webkit2-4.0
- gir1.2-xapp-1.0
- gir1.2-xfconf-0 (XFCE)
- ... 40+ more
```

**Recommendation:** Keep only essential GTK/notification libs, remove ~40 packages.

---

### 4. Printer Drivers & CUPS (30+ packages)
**Status:** Do you have a printer?

```
CUPS printing system:
- cups, cups-daemon, cups-client, cups-browsed
- cups-filters, cups-filters-core-drivers
- cups-ipp-utils, cups-pk-helper, cups-ppdc
- system-config-printer*

Printer drivers (14 packages):
- printer-driver-brlaser
- printer-driver-c2esp
- printer-driver-foo2zjs
- printer-driver-gutenprint
- printer-driver-hpcups
- printer-driver-m2300w
- printer-driver-min12xxw
- printer-driver-pnm2ppa
- printer-driver-postscript-hp
- printer-driver-ptouch
- printer-driver-pxljr
- printer-driver-sag-gdi
- printer-driver-splix

HP printer support:
- hplip, hplip-data

Scanner support:
- sane, sane-utils, sane-airscan
- libsane*, simple-scan
```

**If no printer:** Remove all ~30 packages
**If have printer:** Keep only CUPS basics + your specific driver

---

### 5. Default Mint Applications (18 packages)
**Status:** You don't use these

```
Media apps:
- rhythmbox, rhythmbox-plugins (music player) - You have Kodi
- celluloid (video player) - You have Kodi
- hypnotix (IPTV) - You have Kodi

Communication:
- hexchat, hexchat-common (IRC) - You have Discord
- transmission-gtk (torrent) - Don't use

Graphics:
- drawing (paint app) - Don't use
- pix, pix-data (image viewer) - Don't use
- simple-scan (scanner) - Don't use

File management:
- warpinator (file transfer) - Don't use
- baobab (disk analyzer) - You have htop/ncdu

Utilities:
- brasero-common (CD burner) - Don't use
```

**Remove:** All 18 packages

---

### 6. Accessibility Tools (6 packages)
**Status:** Not needed for most users

```
- orca (screen reader)
- onboard, onboard-common (on-screen keyboard)
- caribou (another on-screen keyboard)
- mousetweaks (mouse accessibility)
- brltty (Braille display support)
```

**Remove:** All 6 packages (unless you need accessibility)

---

### 7. GNOME Applications (6 packages)
**Status:** You use i3, not GNOME

```
- gnome-calculator (use qalc or terminal)
- gnome-disk-utility (use gparted or fdisk)
- gnome-system-monitor (use htop)
- gnome-logs (use journalctl)
- yelp, yelp-xsl (GNOME help viewer)
```

**Remove:** All 6 packages

---

### 8. Mint Branding/Themes (20 packages)
**Status:** Mostly decorative

```
Backgrounds:
- mint-backgrounds-vanessa
- mint-backgrounds-vera
- mint-backgrounds-victoria
- mint-backgrounds-virginia

Themes/Icons:
- mint-artwork
- mint-cursor-themes
- mint-l-icons
- mint-l-theme
- mint-themes
- mint-x-icons
- mint-y-icons

Meta packages:
- mint-meta-xfce (XFCE - you use i3)
- mint-info-xfce (XFCE info)

Keep:
- mint-common (core functionality)
- mint-meta-codecs (media codecs - KEEP)
- mint-mirrors (repository config - KEEP)
- mint-translations (might need)
```

**Remove:** ~15 packages (keep codecs, mirrors, common)

---

### 9. Additional Bloat Found

#### Game Support (not gaming)
```
- gamemode, gamemode-daemon
```

#### Remote Desktop (not needed?)
```
- rdate
- vino (VNC server) - not in list but common
```

#### Java (if you don't use it)
```
- default-jre, default-jre-headless
- openjdk-11-jre, openjdk-11-jre-headless
- openjdk-17-jdk
```

#### Document viewers (duplicates)
```
- xreader, xreader-common (PDF viewer)
- evince (GNOME PDF viewer)
- okular (KDE PDF viewer)
```

**Keep:** Just one (xreader is lightest)

---

## 📊 Bloat Summary by Numbers

| Category | Packages | Action |
|----------|----------|--------|
| LibreOffice (if unused) | 162 | Remove all |
| International fonts | 102 | Keep 4-5 only |
| GObject introspection | 55 | Keep ~10 essential |
| Printer/CUPS (if no printer) | 30 | Remove all |
| Mint default apps | 18 | Remove all |
| Mint themes/backgrounds | 15 | Keep 3-4 |
| GNOME apps | 6 | Remove all |
| Accessibility | 6 | Remove (unless needed) |
| Language packs (non-English) | 4 | Remove |
| **TOTAL** | **~400** | **Removable** |

---

## ✅ Recommended Minimal Package List

### Core i3 Stack (15)
```
i3, i3-wm, i3status, i3lock
polybar, rofi, picom, dunst, feh
arandr, lxappearance
scrot, maim, xclip, xdotool
```

### Terminal & Shell (5)
```
tilix, zsh
fonts-powerline, fonts-font-awesome, fonts-firacode
```

### System Utilities (15)
```
htop, neofetch, tree, jq
ripgrep, fd-find, fzf, stow
curl, wget, git, build-essential
unzip, zip, p7zip-full
```

### Development (8)
```
python3, python3-pip, python3-venv
ruby, ruby-dev
libssl-dev, libreadline-dev, zlib1g-dev
```

### Media & Fonts (5)
```
pavucontrol, pulseaudio, playerctl
fonts-noto-color-emoji
fonts-liberation (web fonts)
```

### Text Editors (2)
```
xed, vim
```

### Keep These Essential Libs
```
- libgtk-3-0 (GTK apps need this)
- libnotify4 (notifications)
- gir1.2-gtk-3.0 (GTK bindings)
- gir1.2-notify-0.7 (notification bindings)
```

**Total minimal packages:** ~50 (down from 2,205!)

---

## 🎯 What to Install via Other Methods

### Don't install via APT (use these instead):

1. **Node.js** → Use `nvm` (Node Version Manager)
2. **VSCode** → Download .deb from Microsoft
3. **Discord** → Download .deb from Discord
4. **Bitwarden** → Download .deb from Bitwarden
5. **Proton VPN** → Add official PPA
6. **AWS CLI** → Use pip or official installer
7. **GitHub CLI (gh)** → Add official PPA

---

## 🚫 Complete EXCLUDE List

### Definitely Remove:
- All XFCE (xfce4-*, thunar, xfwm4, xfdesktop4)
- All LibreOffice (if unused)
- Firefox, Chromium, Thunderbird
- Docker, Maven, Golang (you said you don't use)
- Nitrogen, Alacritty, foot
- Wayland (sway, waybar, wl-clipboard)
- Compiz, metacity, gnome-shell
- Rhythmbox, celluloid, hypnotix, hexchat, transmission
- Drawing, pix, simple-scan, warpinator, baobab
- Orca, onboard, caribou, mousetweaks, brltty
- Gnome-calculator, gnome-disk-utility, gnome-system-monitor
- 100+ international font packages
- 14 printer drivers (unless you have printer)
- CUPS (unless you have printer)
- SANE (unless you have scanner)

---

## 🔧 Next Actions

1. **Decide on LibreOffice:** Need it? (162 packages)
2. **Decide on Printing:** Have printer? (30 packages)
3. **Create minimal list:** I can generate a 50-package ultra-minimal list
4. **Update scripts:** Modified install-packages.sh to use minimal list

---

## 💾 Disk Space Saved

**Estimated savings:**
- LibreOffice: ~600 MB
- International fonts: ~200 MB
- Printer drivers: ~150 MB
- Default apps: ~300 MB
- GObject libs: ~100 MB
- GNOME apps: ~100 MB
- Mint themes/backgrounds: ~100 MB

**Total saved:** ~1.5 GB of packages + dependencies

---

**Want me to create the ultra-minimal package list now?**
