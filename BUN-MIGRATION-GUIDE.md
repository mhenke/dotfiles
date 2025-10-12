# Bun Migration Guide

Complete guide for using Bun instead of npm on your new laptop.

## What is Bun?

Bun is a fast all-in-one JavaScript runtime, bundler, test runner, and package manager. It's designed as a drop-in replacement for Node.js and npm with significantly better performance.

**Speed Benefits:**
- 7× faster than npm
- 4× faster than pnpm
- 17× faster than yarn

## Should You Use Bun?

### ✅ **Pros:**
- **Much faster** package installation
- **npm compatible** - uses npm registry, works with existing projects
- **Drop-in replacement** for most npm commands
- **Built-in runtime** - can replace Node.js for many use cases
- **Modern features** - TypeScript, JSX, Hot reloading out of the box

### ⚠️ **Cons:**
- **Not 100% Node.js compatible** (getting closer every release)
- **Some packages have issues** (see compatibility section below)
- **Newer tool** - less mature than npm/Node.js ecosystem

## Compatibility Status

### ✅ **Works Great with Bun:**
All of these packages work fine with `bun install -g`:
- TypeScript, ts-node, tsx
- webpack, webpack-cli, vite
- prettier, eslint, jshint
- nodemon, pm2
- @angular/cli, @vue/cli, create-react-app, create-next-app
- serverless, netlify-cli, vercel
- jest, mocha, cypress
- yarn, pnpm
- Most other npm packages

### ⚠️ **Use npm for CLI Tools:**

#### **@anthropic-ai/claude-code** (⚠️ USE NPM)
- **Status**: Has documented bugs with Bun
- **Issues**:
  - Crashes on Windows (Bun v1.2.17+)
  - Permission errors on macOS
  - Update failures when BUN_INSTALL env var is set
- **Solution**: Install with npm
  ```bash
  npm install -g @anthropic-ai/claude-code
  ```

#### **@github/copilot** (⚠️ USE NPM - RECOMMENDED)
- **Status**: No documented issues, but not officially supported
- **Reason to use npm**:
  - Only npm installation is documented by GitHub
  - CLI tool requires stable authentication
  - May use native Node.js modules
  - Low install frequency (speed doesn't matter)
  - High breakage cost (breaks your workflow)
- **Recommended**: Install with npm for stability
  ```bash
  npm install -g @github/copilot
  ```

## Installation Guide

### Option 1: Bun Only (Recommended)

Use Bun for everything except problematic packages:

```bash
# 1. Install Bun
curl -fsSL https://bun.sh/install | bash

# 2. Install most packages with Bun (fast!)
bun install -g typescript webpack vite prettier eslint

# 3. Install CLI tools with npm (stable)
npm install -g @anthropic-ai/claude-code @github/copilot
```

### Option 2: Hybrid (Bun + npm)

Keep npm as fallback:

```bash
# Install both
curl -fsSL https://bun.sh/install | bash  # Bun
sudo apt install nodejs npm               # npm

# Use Bun by default, npm when needed
alias install='bun install'
alias i='bun install'
```

### Option 3: Use Our Script

We've created an installation script:

```bash
cd ~/dotfiles
./scripts/install-bun.sh
```

This script:
- Installs Bun
- Reads packages/npm-global.txt
- Installs packages with Bun
- **Skips** @anthropic-ai/claude-code (tells you to use npm)
- Shows all installed packages

## Command Comparison

| Task | npm | Bun |
|------|-----|-----|
| Install all deps | `npm install` | `bun install` |
| Install package | `npm install <pkg>` | `bun install <pkg>` |
| Install global | `npm install -g <pkg>` | `bun install -g <pkg>` |
| Uninstall | `npm uninstall <pkg>` | `bun remove <pkg>` |
| Run script | `npm run <script>` | `bun run <script>` |
| Execute file | `node file.js` | `bun file.js` |
| List global | `npm list -g --depth=0` | `bun pm ls -g` |

## Bun Global Package Location

Bun installs global packages to: `~/.bun/install/global/node_modules/`

This is different from npm's location.

## PATH Configuration

Add Bun to your PATH in `.zshrc`:

```bash
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

This is automatically added by the Bun installer.

## Migration Strategy for New Laptop

### Recommended Approach:

1. **Install Node.js first** (for npm access):
   ```bash
   sudo apt install nodejs npm
   ```

2. **Install Bun**:
   ```bash
   ./scripts/install-bun.sh
   ```

3. **Install problematic packages with npm**:
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

4. **Use Bun for everything else**:
   ```bash
   # In your projects
   bun install          # instead of npm install
   bun run dev          # instead of npm run dev

   # Global packages
   bun install -g typescript webpack vite
   ```

## Testing Bun Compatibility

After installation, verify everything works:

```bash
# Check Bun version
bun --version

# Check installed global packages
bun pm ls -g

# Test Claude Code (installed via npm)
claude --version

# Test Copilot (installed via Bun)
copilot --version

# Test other tools
typescript --version
vite --version
prettier --version
```

## Troubleshooting

### Bun command not found

```bash
# Add to PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Or reload shell
source ~/.zshrc
```

### Package not working after Bun install

Try installing with npm instead:

```bash
npm install -g <package-name>
```

### Permission errors

Bun should not require sudo. If you see permission errors:

```bash
# Don't use sudo with Bun
bun install -g <package>  # ✅ Correct

sudo bun install -g <package>  # ❌ Wrong
```

### Global package not in PATH

```bash
# Check where Bun installed it
bun pm ls -g

# Make sure ~/.bun/bin is in PATH
echo $PATH | grep .bun
```

## Performance Examples

Real-world performance improvements:

```bash
# Installing a React app
npm install:  ~45 seconds
bun install:  ~6 seconds (7× faster)

# Installing Next.js deps
npm install:  ~120 seconds
bun install:  ~15 seconds (8× faster)
```

## Our Package List (npm-global.txt)

Our curated list has 54 global packages:

**Bun-Compatible** (52 packages):
- All TypeScript tools
- All build tools (webpack, vite)
- All framework CLIs (Angular, Vue, React, Next.js)
- All testing tools (jest, mocha, cypress)
- All formatters/linters (prettier, eslint)
- All deployment tools (serverless, netlify, vercel)

**npm-Only** (2 packages - CLI tools):
- @anthropic-ai/claude-code ⚠️ (documented bugs with Bun)
- @github/copilot ⚠️ (stability over speed for CLI tools)

## Why Not nvm?

You asked about nvm - we're **not using nvm** because:

1. **Bun includes a runtime** - Don't need Node.js version management
2. **Simpler setup** - One tool instead of nvm + npm
3. **Faster** - Bun's package manager is much faster than npm
4. **Modern** - Bun handles TypeScript/JSX natively

If you need multiple Node.js versions later, you can add nvm, but it's not needed for the initial setup.

## Future-Proofing

Bun is actively developed and Node.js compatibility improves with every release:

- **Current**: ~95% Node.js API compatibility
- **Trend**: Improving every release
- **Popular frameworks**: Next.js, Express, Remix mostly work

If a package doesn't work with Bun, you can always fall back to npm without reinstalling everything.

## Recommendation

### For Your New Laptop:

**YES, use Bun!** With this strategy:

1. ✅ Install Bun via `./scripts/install-bun.sh`
2. ✅ Use Bun for 96% of packages (fast installs)
3. ✅ Use npm for CLI tools (claude, copilot)
4. ✅ Keep npm installed as fallback (no harm)
5. ✅ Enjoy 7× faster package installs

This gives you the best of both worlds: Bun's speed + npm's compatibility.

## Quick Reference Card

```bash
# Installation
curl -fsSL https://bun.sh/install | bash

# Or use our script
./scripts/install-bun.sh

# Common commands
bun install                    # Install dependencies
bun install -g <package>       # Install global package
bun add <package>              # Add package to project
bun remove <package>           # Remove package
bun run <script>               # Run package.json script
bun <file>.ts                  # Execute TypeScript file
bun pm ls -g                   # List global packages

# CLI tools - use npm for stability
npm install -g @anthropic-ai/claude-code @github/copilot
```

## Summary

- ✅ **Use Bun** for speed and modern features
- ✅ **Keep npm** as fallback for CLI tools
- ✅ **No nvm needed** - Bun handles runtime
- ⚠️ **Use npm** for CLI tools (claude, copilot) for stability
- 🚀 **Enjoy** 7× faster installs for everything else

---

**Questions?**
- Check Bun docs: https://bun.sh/docs
- Check compatibility: https://bun.sh/docs/runtime/nodejs-apis
- Our script: `./scripts/install-bun.sh`
