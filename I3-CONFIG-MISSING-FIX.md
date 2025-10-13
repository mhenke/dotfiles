# i3 Config Missing on New Laptop - Fix Guide

## The Problem

After running bootstrap on new laptop:
- i3 shows "first configuration message" - wants to generate new config
- Symlink exists: `~/.config/i3` → `../dotfiles/i3/.config/i3`
- BUT: `/home/mhenke/dotfiles/i3/.config/i3/config` file is MISSING on new laptop
- Config file EXISTS on old laptop
- Config file EXISTS on GitHub

## Root Cause

This is a **git clone/pull issue**, NOT a Stow configuration issue.

The `config` file was not downloaded from GitHub to the new laptop's local dotfiles directory, even though the symlinks were created by Stow.

## Verification

**On OLD laptop (working):**
```bash
cd ~/dotfiles
ls -la i3/.config/i3/
# Shows:
# -rw-rw-r-- 6.9k config (from Jul 17)
# -rw-rw-r-- 2.7k config_new

git log --oneline -1 -- i3/.config/i3/config
# Shows: a105ad1 Fix i3 config and add --no-folding to all stow commands

git ls-tree HEAD i3/.config/i3/config
# Shows: 100644 blob 070d553... i3/.config/i3/config
```

**On NEW laptop (broken):**
```bash
cd ~/dotfiles
ls -la i3/.config/i3/
# Shows: empty or missing config file

ls -la ~/.config/i3
# Shows: symlink exists → ../dotfiles/i3/.config/i3
```

## The Fix - Option 1: Simple git pull

```bash
cd ~/dotfiles
git pull origin master
```

This should download the missing `config` file from GitHub.

## The Fix - Option 2: Force reset (if git pull doesn't work)

```bash
cd ~/dotfiles

# Make sure you're on master branch
git checkout master

# Fetch all data from GitHub
git fetch --all

# Check what files would be restored
git diff HEAD --name-only

# Force reset to match GitHub exactly
git reset --hard origin/master

# Verify config file now exists
ls -la i3/.config/i3/config
```

## The Fix - Option 3: Direct checkout (safest)

```bash
cd ~/dotfiles

# Just restore the specific missing file
git checkout origin/master -- i3/.config/i3/config

# Verify it exists
ls -la i3/.config/i3/config
```

## Verification After Fix

```bash
# 1. Check file exists in dotfiles
ls -la ~/dotfiles/i3/.config/i3/config
# Should show: -rw-rw-r-- 6.9k config

# 2. Check symlink still points correctly
ls -la ~/.config/i3
# Should show: lrwxrwxrwx ~/.config/i3 -> ../dotfiles/i3/.config/i3

# 3. Check i3 can read the config through symlink
i3 -C ~/.config/i3/config
# Should show: config file is valid

# 4. Reload i3
# Press: Mod+Shift+R
# Should NOT show "first configuration" message anymore
```

## Why This Happened

Possible reasons:
1. **Incomplete git clone** - Network issue during initial `gh repo clone`
2. **Git sparse checkout** - If accidentally enabled (unlikely)
3. **File permissions issue** - Prevented file from being written
4. **Interrupted clone** - Clone process was stopped before completing

## What This Was NOT

❌ NOT a Stow configuration issue
❌ NOT a symlink problem
❌ NOT an i3 configuration issue
❌ NOT a permissions issue with the config file itself

The Stow setup is working correctly. The symlinks are created properly. The issue is simply that the source file didn't get cloned from GitHub.

## About the --no-folding Changes

**Important:** The `--no-folding` flags added to stow commands were based on incorrect assumptions.

- Old laptop works perfectly with DEFAULT Stow behavior (directory symlinks)
- The `--no-folding` changes should likely be reverted
- They were added thinking i3 had issues with symlinked directories
- But the REAL issue was the missing config file from git, not Stow behavior

**To verify on old laptop:**
```bash
cd ~
ls -la .config/i3
# Shows: lrwxrwxrwx .config/i3 -> ../dotfiles/i3/.config/i3

# This is a DIRECTORY symlink (not file symlink)
# And it works perfectly with i3!
```

## Recommended Actions

### 1. On NEW laptop (fix immediately):
```bash
cd ~/dotfiles
git checkout origin/master -- i3/.config/i3/config
ls -la i3/.config/i3/config  # verify it exists
i3 -C ~/.config/i3/config    # verify it's valid
# Then reload i3: Mod+Shift+R
```

### 2. On OLD laptop (verify and document):
```bash
cd ~/dotfiles
git status
# Make sure everything is committed and pushed
git push origin master
```

### 3. Consider reverting --no-folding changes:
```bash
# Review commits with --no-folding changes
git log --oneline --all -S "no-folding"

# If needed, revert to previous working state
# (Do this AFTER new laptop is working)
```

## Summary

- ✅ **Config file is on GitHub** (verified in commit a105ad1)
- ✅ **Config file exists on old laptop** (working system)
- ❌ **Config file missing on new laptop** (git issue)
- ✅ **Symlinks are correct** (Stow did its job)
- 🔧 **Fix:** Run `git pull` or `git checkout origin/master -- i3/.config/i3/config`
- ⚠️ **Future:** Consider reverting `--no-folding` changes (they weren't needed)

The error you're seeing is because git didn't download all files from GitHub, not because of any Stow configuration issue!
