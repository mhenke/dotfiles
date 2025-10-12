# NVM Prefix Conflict Fix Guide

## The Problem

You're seeing this error:
```
Your user's .npmrc file (home/.npmrc) has a globalconfig and/or a prefix setting
Run "nvm use --delete-prefix v22.20.0 --silent" to unset it
```

## Root Cause

You have **TWO Node.js installations** conflicting:

1. **System Node** (via apt): `/usr/bin/node` v22.20.0
2. **nvm Node versions**: `~/.nvm/versions/node/` (v18.20.5, v20.18.1, v20.18.2, v21.6.2, v24.9.0)

The system Node is being used, but nvm is complaining because the npm prefix was set incorrectly.

## Quick Fix (Current Session)

**Option 1: Use nvm node for current shell:**
```bash
# Start a new zsh shell (loads nvm from .zshrc)
zsh

# Or manually load nvm:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use latest nvm version:
nvm use v24.9.0  # Or whichever version you want

# Verify you're now using nvm's node:
which node  # Should show: /home/mhenke/.nvm/versions/node/v24.9.0/bin/node
```

**Option 2: Remove system Node (recommended for clean setup):**
```bash
# Check what's installed:
dpkg -l | grep nodejs

# Remove system Node/npm:
sudo apt remove nodejs npm -y
sudo apt autoremove -y

# Now only nvm will provide node:
zsh  # Start fresh shell
nvm use v24.9.0
which node  # Should show nvm path
```

## Permanent Fix (Already Done in Dotfiles)

✅ **Fixed in commit f8ad57f:**
- Removed `npm config set prefix` from `install-dev-tools.sh`
- Removed `~/.npm-global/bin` from `.zshrc` PATH
- Added comments explaining nvm manages this automatically

## For New Laptop Setup

The fixed `bootstrap.sh` will:
1. Install nvm ✅
2. Install Node LTS via nvm ✅
3. **NOT install system node via apt** ✅
4. **NOT set npm prefix** ✅
5. Load nvm in .zshrc ✅

**Result:** No conflicts, nvm fully manages Node/npm!

## Verification Commands

After fix, verify everything works:

```bash
# Check you're using nvm node:
which node
# Should show: /home/mhenke/.nvm/versions/node/vXX.XX.X/bin/node

# Check npm prefix is nvm-managed:
npm config get prefix
# Should show: /home/mhenke/.nvm/versions/node/vXX.XX.X

# Install global package (test):
npm install -g npm-check-updates
# Should install to nvm directory, not /usr/local or ~/.npm-global

# Verify global packages location:
npm list -g --depth=0
# Should show packages in nvm directory
```

## Why This Happened

Your **old setup** had:
1. System Node installed via `apt install nodejs npm`
2. nvm also installed
3. `.npmrc` with `prefix=~/.npm-global` (to avoid sudo with system node)
4. Both conflicting!

Your **new setup** (after fix):
1. Only nvm (no system node)
2. No `.npmrc` prefix setting
3. nvm fully manages Node/npm versions and global packages
4. No conflicts! ✅

## Current State of Your System

**Before the fix:**
- ✅ nvm installed: `~/.nvm/`
- ✅ nvm versions: v18, v20, v21, v24
- ❌ System node: `/usr/bin/node` v22.20.0 (conflicting)
- ❌ `.npmrc` had prefix (removed)
- ❌ `.zshrc` had `~/.npm-global/bin` in PATH (removed)

**After the fix:**
- ✅ nvm installed and configured in `.zshrc`
- ✅ No `.npmrc` prefix setting
- ✅ Scripts won't set npm prefix
- ⚠️ System node still installed (optional: remove it)

## Recommended Action for Current System

**Option A: Remove system node (clean slate):**
```bash
sudo apt remove nodejs npm -y
sudo apt autoremove -y
zsh  # Start fresh shell with nvm
nvm use v24.9.0
nvm alias default v24.9.0
```

**Option B: Just use nvm node (keep system node as backup):**
```bash
zsh  # Start fresh shell
nvm use v24.9.0
nvm alias default v24.9.0
# System node is still there but won't be used
```

## For Your Migration Scripts

**Good news:** Your scripts are already fixed! ✅

On new laptop, `install-dev-tools.sh` will:
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Install Node LTS
nvm install --lts
nvm use --lts
nvm alias default lts/*

# Does NOT set npm prefix (nvm handles it)
# Does NOT need ~/.npm-global
```

And `.zshrc` will:
```bash
# Load nvm (handles everything automatically)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Does NOT add ~/.npm-global/bin to PATH
```

**Result:** Clean nvm setup, no conflicts! 🎉

## Summary

- ✅ **Dotfiles fixed** (committed & pushed)
- ✅ **New laptop will work perfectly**
- ⚠️ **Current system needs**: Remove system node OR start new shell with `zsh`
- 📝 **Quick fix**: Run `zsh` then `nvm use v24.9.0`

The error you're seeing is just because your **current shell** is still using the old system node. A fresh shell will use nvm properly!
