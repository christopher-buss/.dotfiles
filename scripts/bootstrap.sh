#!/usr/bin/env bash

# Bootstrap script for setting up dotfiles on a new machine
# This script should be run first on a new system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install essential packages
install_essentials() {
    log_info "Installing essential packages..."
    
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y git curl wget build-essential zsh
    elif command_exists yum; then
        sudo yum install -y git curl wget zsh gcc
    elif command_exists pacman; then
        sudo pacman -S --noconfirm git curl wget zsh base-devel
    else
        log_warning "Package manager not found. Please install git, curl, wget, zsh manually."
    fi
}

# Clone dotfiles repository
clone_dotfiles() {
    local repo_url="$1"
    local dotfiles_dir="$HOME/.dotfiles"
    
    if [ -z "$repo_url" ]; then
        log_error "Repository URL is required"
        echo "Usage: $0 <repository-url>"
        exit 1
    fi
    
    log_info "Cloning dotfiles repository..."
    
    if [ -d "$dotfiles_dir" ]; then
        log_warning "Dotfiles directory already exists. Pulling latest changes..."
        cd "$dotfiles_dir" && git pull
    else
        git clone "$repo_url" "$dotfiles_dir"
    fi
    
    cd "$dotfiles_dir"
}

# Run installation
run_installation() {
    log_info "Running dotfiles installation..."
    
    if [ -f "./install.sh" ]; then
        ./install.sh
    else
        log_error "install.sh not found in dotfiles directory"
        exit 1
    fi
}

# Setup package managers and tools
setup_packages() {
    log_info "Setting up package managers and development tools..."
    
    if [ -f "./scripts/install-packages.sh" ]; then
        ./scripts/install-packages.sh
    else
        log_warning "Package installation script not found, skipping package setup"
    fi
}

# Main function
main() {
    local repo_url="$1"
    
    log_info "Starting dotfiles bootstrap process..."
    
    # Check if git is installed
    if ! command_exists git; then
        log_info "Git not found. Installing essentials first..."
        install_essentials
    fi
    
    # Clone and install dotfiles
    clone_dotfiles "$repo_url"
    run_installation
    
    # Setup development environment
    setup_packages
    
    log_success "Bootstrap completed successfully!"
    log_info "You may want to:"
    log_info "  1. Set zsh as your default shell: chsh -s \$(which zsh)"
    log_info "  2. Restart your terminal"
    log_info "  3. Run 'mise doctor' to verify development tools"
    log_info "  4. Review and customize your configurations"
}

# Show usage if no arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <repository-url>"
    echo "Example: $0 https://github.com/christopher-buss/dotfiles.git"
    exit 1
fi

main "$@"