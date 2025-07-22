# Common aliases for shell environments

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
# Function to cd and list contents
cd() { builtin cd "$1" && ls; }

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# grep aliases (modern ripgrep if available, fallback to grep)
if command -v rg >/dev/null 2>&1; then
    alias grep='rg --color=auto'
    alias rg='rg --color=auto'
else
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# Network
alias myip='curl http://ipecho.net/plain; echo'

# Imagine thinking I go outside and touch grass
alias grass='echo "You touched grass!"'
alias weather='curl wttr.in'

# Development
alias refreshenv='source $ZDOTDIR/.zshrc 2>/dev/null || source ~/.bashrc'

# Search
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

# Dotfiles management
alias dotfiles='cd $DEV_HOME/.dotfiles'

# Claude CLI shortcuts - basic commands for all shells
alias cl="claude"
alias clp="claude -p"
alias clr="claude -r"
alias clc="claude -c"
alias cls="claude /status"

# Advanced Claude CLI aliases
alias claude-json="claude -p --output-format json"
alias claude-stream="claude -p --output-format stream-json"

# Security shortcuts (use carefully)
alias claude-safe="claude --allowedTools 'Edit,View'"
alias claude-read="claude --allowedTools 'View'"
alias claude-dev="claude --allowedTools 'Edit,View,Bash(git:*),Bash(npm:*)'"

# DANGEROUS - only for isolated environments
alias yolo="claude --dangerously-skip-permissions"

# Claude Docker shortcuts
alias claude-docker='~/.dotfiles/docker/claude-code/scripts/claude-docker.sh'
alias cld='claude-docker'
alias cld-build='claude-docker build'
alias cld-run='claude-docker run'
alias cld-stop='claude-docker stop'
alias cld-status='claude-docker status'
alias cld-exec='claude-docker exec'
alias cld-logs='claude-docker logs'
alias cld-clean='claude-docker clean'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dimg='docker images'

# Docker Desktop setup
alias docker-setup='~/.dotfiles/scripts/setup-docker-desktop.sh'
alias docker-kill='~/.dotfiles/scripts/docker-kill.sh'
alias docker-restart='~/.dotfiles/scripts/docker-kill.sh restart'

# Make and compile
alias make='make -j$(nproc)'

# Clear screen
alias c='clear'
alias cls='clear'

# Quick edits
alias zshconfig='${EDITOR:-code} $ZDOTDIR/.zshrc'
alias bashconfig='${EDITOR:-code} ~/.bashrc'

# Load local aliases if they exist
if [ -f ~/.aliases.local ]; then
    source ~/.aliases.local
fi
