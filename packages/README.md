# Package Lists

These files contain all packages and extensions from your system.

## Files

- `apt-all.txt` - All installed APT packages
- `apt-manual.txt` - User-installed APT packages (no dependencies)
- `npm-global.txt` - Global npm packages
- `gems.txt` - Ruby gems
- `pip-user.txt` - User-installed Python packages
- `vscode-extensions.txt` - VSCode extensions
- `command-usage.txt` - Most used commands from shell history

## Usage

The bootstrap script will use these files to restore packages on a new system.

For manual installation:

```bash
# APT packages
xargs sudo apt install -y < apt-manual.txt

# npm packages
xargs npm install -g < npm-global.txt

# Ruby gems
xargs gem install < gems.txt

# VSCode extensions
cat vscode-extensions.txt | xargs -L 1 code --install-extension
```
