#!/usr/bin/env bash

# Homebrew installation and package management script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

# Install Homebrew
install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew already installed at $(which brew)"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure shell environment
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        # Linux installation
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    elif [[ -d "/opt/homebrew" ]]; then
        # macOS Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    elif [[ -d "/usr/local/Homebrew" ]]; then
        # macOS Intel
        eval "$(/usr/local/bin/brew shellenv)"
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    fi
    
    log_success "Homebrew installed successfully"
}

# Update Homebrew
update_homebrew() {
    log_info "Updating Homebrew..."
    brew update
    brew upgrade
    log_success "Homebrew updated"
}

# Install packages from Brewfile
install_packages() {
    log_info "Installing packages from Brewfile..."
    
    if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
        cd "$DOTFILES_DIR/packages"
        brew bundle install --verbose
        log_success "Packages installed from Brewfile"
    else
        log_error "Brewfile not found at $DOTFILES_DIR/packages/Brewfile"
        return 1
    fi
}

# Clean up
cleanup() {
    log_info "Cleaning up Homebrew..."
    brew cleanup
    brew autoremove
    log_success "Cleanup completed"
}

# Main function
main() {
    log_info "Setting up Homebrew and packages..."
    
    install_homebrew
    update_homebrew
    install_packages
    cleanup
    
    log_success "Homebrew setup completed!"
    
    # Show installed packages
    log_info "Installed packages:"
    brew list --formula | head -10
    if [[ $(brew list --formula | wc -l) -gt 10 ]]; then
        echo "... and $(($(brew list --formula | wc -l) - 10)) more"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi