# ------------------------------------------------------------------------------
# .zshrc - Zsh configuration
# ------------------------------------------------------------------------------
# This file is organized into sections for clarity:
# 1. Environment: Set essential environment variables (PATH, etc.)
# 2. Aliases: Define custom command shortcuts
# 3. Functions: Define helper functions
# 4. Plugins: Source Zsh plugins for extended functionality
# 5. Initialization: Final setup steps for the shell (e.g., prompt)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 1. Environment
# ------------------------------------------------------------------------------
# Set the default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Set PATH to include local binaries
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Set language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory notify

# ------------------------------------------------------------------------------
# 2. Aliases
# ------------------------------------------------------------------------------
# General
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias zshconfig='nvim ~/.zshrc'

# Docker
alias d='docker'
alias dc='docker-compose'

# Git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit -am'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# uv
alias uva='source .venv/bin/activate'

# Just
alias j='just'
alias jg='just -g'

# bat
alias bat='batcat'
# ------------------------------------------------------------------------------
# 3. Functions
# ------------------------------------------------------------------------------
# Function to extract most archive types
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ------------------------------------------------------------------------------
# 4. Plugins
# ------------------------------------------------------------------------------
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
    git
    python
    pip
    docker
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
    extract
    colored-man-pages
    uv
)

# Source Oh My Zsh
if [ -d "$ZSH" ]; then
    source $ZSH/oh-my-zsh.sh
else
    echo "Oh My Zsh is not installed at $ZSH"
fi

# ------------------------------------------------------------------------------
# 5. Initialization
# ------------------------------------------------------------------------------
# Initialize Starship prompt
eval "$(starship init zsh)"

# Source local environment file if it exists
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# Source machine-specific configuration if it exists
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
