#!/usr/bin/env bash

# mise setup and configuration script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

# Install mise if not present
install_mise() {
    if command_exists mise; then
        log_info "mise already installed at $(which mise)"
        return 0
    fi
    
    log_info "Installing mise..."
    
    if command_exists brew; then
        brew install mise
    else
        # Fallback to curl installation
        curl https://mise.run | sh
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    log_success "mise installed successfully"
}

# Setup mise configuration
setup_config() {
    log_info "Setting up mise configuration..."
    
    # Create mise config directory
    mkdir -p ~/.config/mise
    
    # Link mise config
    if [[ -f "$DOTFILES_DIR/packages/mise/config.toml" ]]; then
        ln -sf "$DOTFILES_DIR/packages/mise/config.toml" ~/.config/mise/config.toml
        log_info "Linked mise configuration"
    else
        log_warning "mise config.toml not found"
    fi
    
    # Link global .tool-versions
    if [[ -f "$DOTFILES_DIR/packages/.tool-versions" ]]; then
        ln -sf "$DOTFILES_DIR/packages/.tool-versions" ~/.tool-versions
        log_info "Linked global .tool-versions"
    else
        log_warning "Global .tool-versions not found"
    fi
}

# Install development tools
install_tools() {
    log_info "Installing development tools from .tool-versions..."
    
    cd "$DOTFILES_DIR/packages"
    
    if [[ -f ".tool-versions" ]]; then
        # Install all tools from .tool-versions
        mise install
        log_success "Development tools installed"
        
        # Show installed tools
        log_info "Installed tools:"
        mise list
    else
        log_error ".tool-versions file not found"
        return 1
    fi
}

# Setup shell integration
setup_shell() {
    log_info "Setting up shell integration..."
    
    # Add mise activation to shell configs
    SHELL_CONFIG=""
    if [[ -f ~/.zshrc ]]; then
        SHELL_CONFIG=~/.zshrc
    elif [[ -f ~/.bashrc ]]; then
        SHELL_CONFIG=~/.bashrc
    fi
    
    if [[ -n "$SHELL_CONFIG" ]]; then
        if ! grep -q "mise activate" "$SHELL_CONFIG"; then
            {
                echo ''
                echo '# mise activation'
                echo 'eval "$(mise activate zsh)"'
            } >> "$SHELL_CONFIG"
            log_info "Added mise activation to $SHELL_CONFIG"
        else
            log_info "mise activation already present in $SHELL_CONFIG"
        fi
    fi
    
    # Activate mise for current session
    eval "$(mise activate bash)"
}

# Install global packages
install_globals() {
    log_info "Installing global packages..."
    
    # Install npm globals
    if [[ -f "$DOTFILES_DIR/packages/global-packages/npm-global.txt" ]]; then
        log_info "Installing global npm packages..."
        # Read npm packages from file, filter comments and empty lines
        mapfile -t packages < <(grep -v '^#' "$DOTFILES_DIR/packages/global-packages/npm-global.txt" | grep -v '^$')
        if [ ${#packages[@]} -gt 0 ]; then
            mise exec -- npm install -g "${packages[@]}"
        fi
    fi
    
    # Install pip globals
    if [[ -f "$DOTFILES_DIR/packages/global-packages/pip-global.txt" ]]; then
        log_info "Installing global pip packages..."
        mise exec -- pip install -r "$DOTFILES_DIR/packages/global-packages/pip-global.txt"
    fi
    
    log_success "Global packages installed"
}

# Update tools
update_tools() {
    log_info "Updating mise and tools..."
    mise self-update
    mise upgrade
    log_success "Tools updated"
}

# Main function
main() {
    log_info "Setting up mise..."
    
    install_mise
    setup_config
    install_tools
    setup_shell
    install_globals
    
    log_success "mise setup completed!"
    log_info "Restart your shell or run 'eval \"\$(mise activate zsh)\"' to start using mise"
    
    # Show status
    mise doctor || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi