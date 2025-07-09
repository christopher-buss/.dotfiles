#!/usr/bin/env zsh

# Antidote ZSH Plugin Manager
# https://github.com/mattmc3/antidote

# Initialize antidote (installed via Homebrew)
if [[ -d "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/antidote" ]]; then
    # Load antidote
    source "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/antidote/antidote.zsh"
    
    # Plugin file location
    zsh_plugins="$ZDOTDIR/.zsh_plugins.txt"
    
    # Initialize plugins from .zsh_plugins.txt
    if [[ -f "$zsh_plugins" ]]; then
        antidote load "$zsh_plugins"
    fi
else
    echo "Warning: antidote not found. Install with: brew install antidote"
fi

# ZSH Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# ZSH-Z configuration
ZSHZ_DATA="$ZDOTDIR/.z"

# NVM configuration (lazy loaded via zsh-nvm)
export NVM_LAZY_LOAD=true
export NVM_AUTO_USE=true

# ZSH-abbr configuration (managed via brew)
if command -v brew >/dev/null 2>&1; then
    # Load zsh-abbr if installed via brew
    if [[ -f "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/zsh-abbr/zsh-abbr.zsh" ]]; then
        source "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/zsh-abbr/zsh-abbr.zsh"
        
        # Ensure proper permissions and completion setup
        if [[ -d "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share" ]]; then
            chmod go-w "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share" 2>/dev/null
            chmod -R go-w "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/zsh" 2>/dev/null
        fi
        
        # Add zsh-abbr to fpath for completions
        if [[ -d "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/zsh-abbr" ]]; then
            FPATH="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/share/zsh-abbr:$FPATH"
        fi
        
        # Force rebuild completions for zsh-abbr
        rm -f ~/.zcompdump 2>/dev/null
        autoload -Uz compinit && compinit
    fi
fi