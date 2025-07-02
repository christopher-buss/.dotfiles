# Link to .zsh folder for configs
ZDOTDIR=~/.zsh

# Homebrew environment (load early)
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "/opt/homebrew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Development tools
. "$HOME/.rokit/env"
. "$HOME/.cargo/env"
. "$HOME/.local/bin/env"

# Bun completions
[ -s "/home/isentinel/.bun/_bun" ] && source "/home/isentinel/.bun/_bun"