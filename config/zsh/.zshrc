### ---- ZSH HOME -----------------------------------
export ZSH=$HOME/.zsh
export BREW="/home/linuxbrew/.linuxbrew"

### ---- Autocompletions -----------------------------------
fpath=(~/.zsh/site-functions $fpath)
autoload -Uz compinit && compinit

### ---- Completion options and styling -----------------------------------
zstyle ':completion:*' menu select # selectable menu
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'  # case insensitive completion
zstyle ':completion:*' special-dirs true # Complete . and .. special directories
zstyle ':completion:*' list-colors '' # colorize completion lists
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01' # colorize kill list
export WORDCHARS=${WORDCHARS//[\/]} # remove / from wordchars so that / is a seperator when deleting complete words

### ---- Source other configs -----------------------------------
[[ -f $ZSH/config/history.zsh ]] && source $ZSH/config/history.zsh
[[ -f $ZSH/config/aliases.zsh ]] && source $ZSH/config/aliases.zsh
[[ -f $ZSH/config/inline-selection.zsh ]] && source $ZSH/config/inline-selection.zsh

### ---- mise activation -----------------------------------
eval "$(mise activate zsh)"

### ---- Source plugins -----------------------------------
[[ -f $ZSH/plugins/plugins.zsh ]] && source $ZSH/plugins/plugins.zsh

### ---- GPG agent config -----------------------------------
export GPG_TTY=$(tty)

### ---- VS Code integration -----------------------------------
export VSCODE_SUGGEST=1

### ---- Add local bin to path -----------------------------------
export PATH=$HOME/bin:$PATH
export PATH="$BREW/bin:$PATH"

# Claude CLI aliases are loaded from ~/.aliases

### ---- Package Management aliases -----------------------------------
# Homebrew
alias brewup="brew update && brew upgrade && brew cleanup"
alias brewinfo="brew list --formula | wc -l && echo 'formulas installed'"

# mise
alias mise-update="mise upgrade && mise prune"
alias mise-sync="~/.dotfiles/scripts/install-packages.sh"
alias tools="mise list"

# Global package management
alias npm-globals="mise exec -- npm list -g --depth=0"
alias update-globals="mise exec -- npm update -g"

### ---- Setup fzf -----------------------------------
eval "$(fzf --zsh)"

### ---- Setup direnv -----------------------------------
eval "$(direnv hook zsh)"

### ---- Load Starship -----------------------------------
eval "$(starship init zsh)"

### ---- Load aliases from dotfiles -----------------------------------
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi