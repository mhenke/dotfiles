# Optimized .zshrc for better performance
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme - af-magic (clean, fast, with git info)  
ZSH_THEME="af-magic"

# Show computer name prominently (add after oh-my-zsh loads)
PROMPT='%{$FG[032]%}%m%{$reset_color%} ${PROMPT}'

# Update behavior
zstyle ':omz:update' mode auto

# History configuration (optimized)
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE

# Terminal
export TERMINAL=tilix

# FINAL OPTIMIZED PLUGINS (10 plugins, excellent performance)
plugins=(
    git                     # Essential for git workflows
    aliases                 # Git shortcuts like grhh, ga, etc.
    z                       # Smart directory jumping
    zsh-autosuggestions    # Command suggestions
    zsh-syntax-highlighting # Syntax coloring (keep last for performance)
    npm                     # Node development shortcuts
    docker-compose         # Container development shortcuts
    aws                     # AWS CLI shortcuts
    fzf                     # Fuzzy finding
    you-should-use         # Shows available aliases
)

# Load oh-my-zsh
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

# USER CONFIGURATION
export EDITOR='zed'
export VISUAL='zed'
export PAGER='less'

# OPTIMIZED PATH CONFIGURATION (consolidated, no duplicates)
typeset -U path
path=(
    ~/.console-ninja/.bin
    ~/.local/bin
    ~/go/bin
    $path
)

# FZF configuration (optimized)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
fi

# ALIASES (organized and optimized)
# Config editing
alias zshconfig="$EDITOR ~/.zshrc"
alias i3config="$EDITOR ~/.config/i3/config"
alias picomconfig="$EDITOR ~/.config/picom/picom.conf"
alias alacrittyconfig="$EDITOR ~/.config/alacritty/alacritty.yml"

# GitHub CLI aliases
alias ghpr='gh pr list'
alias ghco='gh copilot'
alias ghce='gh copilot explain'
alias ghcs='gh copilot suggest'
alias ghci='gh copilot'
alias ghcopilot='gh copilot'

# System
alias update="sudo dpkg --configure -a && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y"

# Better defaults (check if commands exist first)
if command -v exa >/dev/null 2>&1; then
    alias ls="exa --icons --group-directories-first"
    alias la="exa -la --icons --group-directories-first"
    alias tree="exa --tree --icons"
fi

if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
fi

if command -v htop >/dev/null 2>&1; then
    alias top="htop"
fi

# DIRECTORY NAVIGATION
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# COMPLETION SETTINGS (optimized)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache

# Load custom functions safely
if [[ -d ~/.zsh/functions ]]; then
    for function in ~/.zsh/functions/*; do
        [[ -r "$function" ]] && source "$function"
    done
fi

# SYNTAX HIGHLIGHTING CONFIGURATION
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[cursor]='bold'

# NVM setup (always load for immediate access to global packages)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
