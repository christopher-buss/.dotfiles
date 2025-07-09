#!/usr/bin/env bash

# Package installation orchestrator
# Installs and configures all package managers and their packages

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check if we're in WSL
        if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
            echo "wsl"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Install essential packages via system package manager
install_system_packages() {
    local pm=$(detect_package_manager)
    
    case "$pm" in
        apt)
            log_info "Installing essential packages via apt..."
            sudo apt-get update
            sudo apt-get install -y \
                git curl wget build-essential zsh \
                gnupg openssh-client rsync htop tree \
                software-properties-common
            
            # Add Bitwarden CLI from snap or direct download
            if command_exists snap; then
                sudo snap install bw
                log_success "Bitwarden CLI installed via snap"
            fi
            ;;
        yum)
            log_info "Installing essential packages via yum..."
            sudo yum install -y git curl wget zsh gcc gnupg2 openssh-clients rsync htop tree
            ;;
        pacman)
            log_info "Installing essential packages via pacman..."
            sudo pacman -S --noconfirm git curl wget zsh base-devel gnupg openssh rsync htop tree
            ;;
        *)
            log_warning "Unknown package manager, skipping system packages"
            ;;
    esac
}

# Install Homebrew if not present
install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew already installed"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -d "/opt/homebrew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed successfully"
}

# Install packages from Brewfile
install_brew_packages() {
    log_info "Installing packages from Brewfile..."
    
    if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
        cd "$DOTFILES_DIR/packages"
        brew bundle install
        log_success "Homebrew packages installed"
    else
        log_warning "Brewfile not found, skipping brew packages"
    fi
}

# Setup mise and install tools
setup_mise() {
    if ! command_exists mise; then
        log_error "mise not found. Install it via Homebrew first."
        return 1
    fi
    
    log_info "Setting up mise configuration..."
    
    # Link mise config
    if [[ -f "$DOTFILES_DIR/packages/mise/config.toml" ]]; then
        mkdir -p ~/.config/mise
        ln -sf "$DOTFILES_DIR/packages/mise/config.toml" ~/.config/mise/config.toml
        log_info "Linked mise configuration"
    fi
    
    # Link .tool-versions to home directory
    if [[ -f "$DOTFILES_DIR/packages/.tool-versions" ]]; then
        ln -sf "$DOTFILES_DIR/packages/.tool-versions" ~/.tool-versions
        log_info "Linked global .tool-versions"
    fi
    
    # Install tools from .tool-versions
    log_info "Installing development tools via mise..."
    cd "$DOTFILES_DIR/packages"
    mise install
    
    log_success "mise setup completed"
}

# Install Claude Code CLI
install_claude_code() {
    if command_exists claude; then
        log_info "Claude Code already installed"
        return 0
    fi
    
    log_info "Installing Claude Code CLI..."
    
    if curl -fsSL claude.ai/install.sh | bash; then
        log_success "Claude Code installed successfully"
    else
        log_error "Failed to install Claude Code"
        return 1
    fi
}

# Install global npm packages
install_npm_globals() {
    if [[ -f "$DOTFILES_DIR/packages/global-packages/npm-global.txt" ]]; then
        log_info "Installing global npm packages..."
        
        # Use mise to ensure we're using the right Node version
        # Read npm packages from file, filter comments and empty lines
        mapfile -t packages < <(grep -v '^#' "$DOTFILES_DIR/packages/global-packages/npm-global.txt" | grep -v '^$')
        if [ ${#packages[@]} -gt 0 ]; then
            mise exec -- npm install -g "${packages[@]}"
        fi
        
        log_success "Global npm packages installed"
    else
        log_warning "npm-global.txt not found, skipping npm globals"
    fi
}

# Install global cargo tools
install_cargo_tools() {
    if [[ -f "$DOTFILES_DIR/packages/global-packages/cargo-tools.txt" ]] && command_exists cargo; then
        log_info "Installing global cargo tools..."
        
        while IFS= read -r tool; do
            # Skip comments and empty lines
            [[ "$tool" =~ ^#.*$ ]] || [[ -z "$tool" ]] && continue
            
            log_info "Installing cargo tool: $tool"
            cargo install "$tool" || log_warning "Failed to install $tool"
        done < "$DOTFILES_DIR/packages/global-packages/cargo-tools.txt"
        
        log_success "Cargo tools installation completed"
    else
        log_warning "cargo-tools.txt not found or cargo not available, skipping cargo tools"
    fi
}

# Install global pip packages
install_pip_globals() {
    if [[ -f "$DOTFILES_DIR/packages/global-packages/pip-global.txt" ]] && command_exists python3; then
        log_info "Installing global pip packages..."
        
        # Use mise to ensure we're using the right Python version
        mise exec -- pip install -r "$DOTFILES_DIR/packages/global-packages/pip-global.txt"
        
        log_success "Global pip packages installed"
    else
        log_warning "pip-global.txt not found or python3 not available, skipping pip globals"
    fi
}

# Main installation function
main() {
    log_info "Starting package installation..."
    
    local os=$(detect_os)
    log_info "Detected OS: $os"
    
    case "$os" in
        "windows"|"wsl")
            setup_winget
            
            # Install Claude Code CLI for WSL
            if [[ "$os" == "wsl" ]]; then
                install_claude_code
            fi
            ;;
        "macos"|"linux")
            # Install system packages first
            install_system_packages
            
            # Install package managers
            install_homebrew
            install_brew_packages
            
            # Setup development tools
            setup_mise
            
            # Install Claude Code CLI
            install_claude_code
            
            # Install global packages
            install_npm_globals
            install_cargo_tools
            install_pip_globals
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    log_success "Package installation completed!"
    log_info "You may need to restart your shell or run 'source ~/.zshrc' to use the new tools"
}

# Setup Windows packages via winget
setup_winget() {
    log_info "Setting up Windows packages via winget..."
    
    if [[ -f "$DOTFILES_DIR/scripts/setup-winget.sh" ]]; then
        "$DOTFILES_DIR/scripts/setup-winget.sh"
    else
        log_warning "setup-winget.sh not found, skipping winget setup"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi