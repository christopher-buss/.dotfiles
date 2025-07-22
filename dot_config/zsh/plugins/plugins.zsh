#!/usr/bin/env zsh

# Antidote ZSH Plugin Manager
# https://github.com/mattmc3/antidote

export ANTIDOTE_HOME=~/.cache/antidote

# Initialize antidote
antidote_dir="$ZDOTDIR/.antidote"
if [[ -d "$antidote_dir" ]]; then
    # Load antidote
    source "$antidote_dir/antidote.zsh"

    # Plugin file location
    zsh_plugins="$ZDOTDIR/.zsh_plugins.txt"

    # Initialize plugins from .zsh_plugins.txt
    if [[ -f "$zsh_plugins" ]]; then
        antidote load "$zsh_plugins"
    fi
else
    echo "Warning: antidote not found at $antidote_dir"
    echo "Run 'chezmoi apply' to install via chezmoi externals"
fi

# ZSH Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585858"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
    OLD_SELF_INSERT=${widgets[self - insert]#*:}
    OLD_SELF_INSERT=${OLD_SELF_INSERT%:*}
    zle -N self-insert url-quote-magic
}

pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# ZSH-Z configuration
ZSHZ_DATA="$ZDOTDIR/.z"
