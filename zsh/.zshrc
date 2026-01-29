# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Add npm global packages to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

# 
# af-magic
# agnoster *
# bira **
# agnosterzak
#

plugins=( 
    git
    npm
    docker
    node
    fzf
    alias-finder
    pip
    pipenv
    virtualenv
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Print the matched directory before navigating
export _ZO_ECHO=1
eval "$(zoxide init zsh --cmd cd)"

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# System update alias
alias update="sudo dpkg --configure -a && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && curl -f https://zed.dev/install.sh | sh"

# Claude Code clipboard workaround - converts clipboard images to file paths
alias cpaste='~/bin/clip2path'

# Monitor switching commands
alias monitor-switch='~/.config/hypr/scripts/monitor-switch.sh'
alias monitor-profiles='~/.config/hypr/scripts/MonitorProfiles.sh'

export PATH=$HOME/.local/bin:$PATH

. "$HOME/.local/bin/env"

# Fix Tilix VTE configuration for directory inheritance
# Must be sourced AFTER Oh-My-Zsh to ensure precmd_functions works
if [[ -n "$TILIX_ID" ]] || [[ -n "$VTE_VERSION" ]]; then
    if [[ -f /etc/profile.d/vte.sh ]]; then
        source /etc/profile.d/vte.sh
    elif [[ -f /etc/profile.d/vte-2.91.sh ]]; then
        source /etc/profile.d/vte-2.91.sh
    fi
fi

# bun completions
[ -s "/home/mhenke/.bun/_bun" ] && source "/home/mhenke/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Ollama model aliases
source ~/.ollama-aliases

# Yazi shell wrapper for zoxide integration
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
alias killag='/home/mhenke/kill_antigravity.sh'
alias captive-portal='hotspot-login'

# todo.sh aliases
alias t='todo.sh'
alias ta='t add'
alias tl='t ls'
alias td='t do'

# Project-specific shortcuts
alias tapi='t ls +api'
alias tfe='t ls +frontend'

# Custom shortened prompt context (User@IdeaPad)
source ~/.zshrc.local

prompt_context() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    # Show full hostname for SSH connections
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@%m"
  else
    # Show shortened context for local sessions
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@IdeaPad"
  fi
}