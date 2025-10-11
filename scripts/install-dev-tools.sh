#!/bin/bash
#
# install-dev-tools.sh - Install development tools
#
# Installs Node.js/npm (if missing), AWS CLI, and related tools
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

# Install Node.js and npm
log_info "Checking Node.js installation..."
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    log_success "Node.js found: $(node --version)"
    log_success "npm found: $(npm --version)"
else
    log_info "Installing Node.js and npm..."
    sudo apt update
    sudo apt install -y nodejs npm
    log_success "Node.js installed: $(node --version)"
    log_success "npm installed: $(npm --version)"
fi

# Install global npm packages
PACKAGES_DIR="$(dirname "$0")/../packages"
if [[ -f "$PACKAGES_DIR/npm-global.txt" ]]; then
    log_info "Installing global npm packages..."
    while IFS= read -r package; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        npm install -g "$package" 2>/dev/null || log_warn "Failed to install $package"
    done < "$PACKAGES_DIR/npm-global.txt"
    log_success "Global npm packages installed"
fi

# Install Jekyll and Bundler
log_info "Installing Jekyll and Bundler..."
if command -v gem &> /dev/null; then
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
