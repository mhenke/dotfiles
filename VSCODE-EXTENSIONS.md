# VSCode Extensions Management

Documentation for exporting and importing VSCode extensions across machines.

## Overview

Your VSCode setup has **37 extensions** that are automatically managed via the dotfiles repository.

## Workflow

### On Current Machine (Export)

```bash
# Export current extensions
./scripts/export-vscode-extensions.sh

# Commit and push the list
git add packages/vscode-extensions.txt
git commit -m "Update VSCode extensions list"
git push
```

### On New Machine (Import)

Extensions are automatically installed during bootstrap:

```bash
# Option 1: During bootstrap (Step 3)
./bootstrap.sh
# Select step 3 (Install applications)
# Will prompt: "Install VSCode extensions now? (y/N)"

# Option 2: Manual installation
./scripts/install-vscode-extensions.sh
```

## Extension List

Current extensions (37 total):

### AI & GitHub
- `anthropic.claude-code` - Claude Code AI assistant
- `github.copilot` - GitHub Copilot
- `github.copilot-chat` - GitHub Copilot Chat
- `github.codespaces` - GitHub Codespaces
- `github.vscode-github-actions` - GitHub Actions
- `github.vscode-pull-request-github` - GitHub Pull Requests

### Angular Development
- `1tontech.angular-material` - Angular Material snippets
- `cyrilletuzi.angular-schematics` - Angular schematics

### AWS & Cloud
- `amazonwebservices.aws-toolkit-vscode` - AWS Toolkit
- `ms-vscode.azure-repos` - Azure Repos

### Code Quality
- `dbaeumer.vscode-eslint` - ESLint
- `esbenp.prettier-vscode` - Prettier
- `eamodio.gitlens` - GitLens

### IntelliSense & Autocomplete
- `christian-kohler.npm-intellisense` - npm IntelliSense
- `christian-kohler.path-intellisense` - Path IntelliSense
- `visualstudioexptteam.vscodeintellicode` - IntelliCode
- `visualstudioexptteam.vscodeintellicode-completions` - IntelliCode Completions
- `visualstudioexptteam.intellicode-api-usage-examples` - IntelliCode API examples

### Python Development
- `ms-python.python` - Python
- `ms-python.debugpy` - Python Debugger
- `ms-python.vscode-pylance` - Pylance
- `ms-python.vscode-python-envs` - Python Environments

### UI Enhancements
- `naumovs.color-highlight` - Color Highlight
- `oderwat.indent-rainbow` - Indent Rainbow
- `vincaslt.highlight-matching-tag` - Highlight Matching Tag
- `ibm.output-colorizer` - Output Colorizer

### Utilities
- `fabiospampinato.vscode-terminals` - Terminals Manager
- `natqe.reload` - Reload VSCode
- `ms-vscode.live-server` - Live Server
- `pmneo.tsimporter` - TypeScript Importer
- `redhat.vscode-yaml` - YAML Support

### Remote Development
- `ms-vscode-remote.remote-containers` - Remote Containers
- `ms-azuretools.vscode-containers` - Docker
- `ms-vscode.remote-repositories` - Remote Repositories
- `github.remotehub` - Remote Hub

### Frameworks
- `svelte.svelte-vscode` - Svelte

### Theme
- `wesbos.theme-cobalt2` - Cobalt2 Theme

## Maintenance

### Adding New Extensions

When you install a new extension:

```bash
# Re-export the list
./scripts/export-vscode-extensions.sh

# Commit and push
git add packages/vscode-extensions.txt
git commit -m "Add new VSCode extension: <extension-name>"
git push
```

### Removing Extensions

When you uninstall an extension:

```bash
# Re-export the list (it will update automatically)
./scripts/export-vscode-extensions.sh

# Commit and push
git add packages/vscode-extensions.txt
git commit -m "Remove VSCode extension: <extension-name>"
git push
```

## Troubleshooting

### Extension Installation Fails

```bash
# Install manually
code --install-extension <extension-id>

# Or check if extension is deprecated/renamed
# Search on marketplace: https://marketplace.visualstudio.com/vscode
```

### VSCode Command Not Found

```bash
# Check if VSCode is installed
which code

# If not in PATH, add to ~/.zshrc:
export PATH="$PATH:/usr/share/code/bin"

# Or reinstall VSCode
sudo snap install code --classic
```

### Extensions Not Loading

```bash
# Restart VSCode
# Or reload window: Ctrl+Shift+P -> "Developer: Reload Window"

# Check extension host log
# Ctrl+Shift+P -> "Developer: Show Extension Host Log"
```

## Integration with Bootstrap

The bootstrap process handles VSCode extensions automatically:

**Step 3 (Install Applications)**:
1. Installs VSCode (or offers to purge/reinstall)
2. Detects `packages/vscode-extensions.txt`
3. Prompts: "Install VSCode extensions now? (y/N)"
4. If yes: Runs `install-vscode-extensions.sh`
5. Shows progress: installed/skipped/failed counts

## Manual Commands

```bash
# Export extensions
./scripts/export-vscode-extensions.sh

# Install extensions
./scripts/install-vscode-extensions.sh

# List currently installed extensions
code --list-extensions

# Install single extension
code --install-extension <extension-id>

# Uninstall extension
code --uninstall-extension <extension-id>
```

## Notes

- Extensions are installed **after** VSCode installation
- Already installed extensions are **skipped** (not reinstalled)
- Failed extensions are **reported** at the end
- VSCode settings sync separately (sign in to sync settings/keybindings)
- Extensions list is version-controlled in git
- No need to backup extension data (settings are synced via VSCode)

## See Also

- [VSCode Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync)
- [VSCode Extension Marketplace](https://marketplace.visualstudio.com/vscode)
- [Bootstrap Process](./bootstrap.sh)
