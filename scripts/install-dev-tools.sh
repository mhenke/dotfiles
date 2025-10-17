#!/bin/bash
#
# install-dev-tools.sh - Install development tools
#
# Verifies Node.js installation, installs AWS CLI, and related tools
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

# Install Node.js 22 and npm via NodeSource
log_info "Installing Node.js 22 and npm via NodeSource..."
if command -v node &> /dev/null && [[ "$(node --version)" == v22.* ]]; then
    log_success "Node.js 22 already installed: $(node --version)"
    log_success "npm already installed: $(npm --version)"
else
    log_info "Adding NodeSource Node.js 22 repository..."
    # Prerequisites (curl, build-essential) are installed in install-packages.sh
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    
    log_info "Installing Node.js 22 and npm..."
    sudo apt install -y nodejs
    
    log_success "Node.js installed: $(node --version)"
    log_success "npm installed: $(npm --version)"
fi

# Configure npm to use user-owned global directory (avoids permission issues)
log_info "Configuring npm global directory..."
NPM_GLOBAL_DIR="$HOME/.npm-global"
if [[ ! -d "$NPM_GLOBAL_DIR" ]]; then
    mkdir -p "$NPM_GLOBAL_DIR"
    log_info "Created $NPM_GLOBAL_DIR"
fi

# Set npm prefix to user directory
npm config set prefix "$NPM_GLOBAL_DIR"
log_success "npm prefix configured to $NPM_GLOBAL_DIR"

# Add to PATH for current session
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"

# Add to shell configs for future sessions
for rcfile in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rcfile" ]]; then
        if ! grep -q "\.npm-global/bin" "$rcfile"; then
            echo '' >> "$rcfile"
            echo '# npm global packages' >> "$rcfile"
            echo 'export PATH=~/.npm-global/bin:$PATH' >> "$rcfile"
            log_info "Added npm global path to $rcfile"
        fi
    fi
done

# Install CLI tools with npm (for stability)
PACKAGES_DIR="$(dirname "$0")/../packages"
log_info "Installing CLI tools with npm (claude, copilot)..."

# Install claude
if npm install -g @anthropic-ai/claude-code 2>&1 | grep -v "npm WARN"; then
    log_success "Claude Code installed"
else
    log_warn "Failed to install Claude Code"
fi

# Install copilot
if npm install -g @github/copilot 2>&1 | grep -v "npm WARN"; then
    log_success "GitHub Copilot installed"
else
    log_warn "Failed to install GitHub Copilot"
fi

# Optionally install other packages with Bun (faster) or npm
echo ""
log_info "For remaining packages, you can:"
log_info "  Option 1 (Recommended): Install Bun, then run ./scripts/install-bun.sh"
log_info "  Option 2: Install all with npm from packages/npm-global.txt"
echo ""
read -p "Install remaining packages now? (npm/bun/skip) [skip]: " -r INSTALL_METHOD

case "$INSTALL_METHOD" in
    npm)
        log_info "Installing all packages with npm..."
        if [[ -f "$PACKAGES_DIR/npm-global.txt" ]]; then
            while IFS= read -r package; do
                [[ -z "$package" || "$package" =~ ^# ]] && continue
                # Skip CLI tools (already installed)
                [[ "$package" == "@anthropic-ai/claude-code" ]] && continue
                [[ "$package" == "@github/copilot" ]] && continue
                npm install -g "$package" 2>/dev/null || log_warn "Failed to install $package"
            done < "$PACKAGES_DIR/npm-global.txt"
            log_success "All packages installed with npm"
        fi
        ;;
    bun)
        log_info "Installing Bun and packages..."
        bash "$( dirname "${BASH_SOURCE[0]}" )/install-bun.sh" --auto-install
        ;;
    *)
        log_info "Skipping additional packages - you can install later"
        log_info "  npm: npm install -g <package>"
        log_info "  Bun: ./scripts/install-bun.sh"
        ;;
esac

# Install Jekyll and Bundler
log_info "Installing Jekyll and Bundler..."
if command -v gem &> /dev/null; then
    # Ensure ruby-dev is installed (required for building native extensions)
    if ! dpkg -l | grep -q "^ii  ruby-dev "; then
        log_info "Installing ruby-dev (required for Jekyll native extensions)..."
        sudo apt install -y ruby-dev
    fi
    
    gem install jekyll bundler --user-install 2>/dev/null || sudo gem install jekyll bundler
    log_success "Jekyll and Bundler installed"
else
    log_warn "Ruby gem not found, skipping Jekyll"
fi

# Install AWS CLI v2
log_info "Installing AWS CLI v2..."
if ! command -v aws &> /dev/null; then
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    log_success "AWS CLI installed: $(aws --version)"
else
    log_info "AWS CLI already installed"
fi

# Install GitHub CLI
log_info "Installing GitHub CLI (gh)..."
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh -y
    log_success "GitHub CLI installed: $(gh --version | head -n1)"
else
    log_info "GitHub CLI already installed"
fi

# Install oh-my-zsh
log_info "Installing oh-my-zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "oh-my-zsh installed"
else
    log_info "oh-my-zsh already installed"
fi

# Install zsh plugins
log_info "Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    log_success "zsh-completions installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/plugins/you-should-use"
    log_success "you-should-use installed"
fi

# Install fzf
log_info "Installing fzf..."
if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
    log_success "fzf installed"
else
    log_info "fzf already installed"
fi

log_success "Development tools installed successfully!"
