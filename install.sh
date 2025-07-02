#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from dotfiles to home directory

set -e

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
}

# Backup existing file/directory
backup_existing() {
    local source="$1"
    local backup_path
    backup_path="$BACKUP_DIR/$(basename "$source")"
    
    if [ -e "$source" ] && [ ! -L "$source" ]; then
        mv "$source" "$backup_path"
        log_warning "Backed up existing $source to $backup_path"
    elif [ -L "$source" ]; then
        rm "$source"
        log_info "Removed existing symlink: $source"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    local target_dir
    target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi
    
    # Backup existing file/directory
    backup_existing "$target"
    
    # Create symlink
    ln -sf "$source" "$target"
    log_success "Linked $source → $target"
}

# Install shell configurations
install_shell_configs() {
    log_info "Installing shell configurations..."
    
    # Bash
    if [ -f "$DOTFILES_DIR/config/shell/bashrc" ]; then
        create_symlink "$DOTFILES_DIR/config/shell/bashrc" "$HOME/.bashrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/shell/bash_profile" ]; then
        create_symlink "$DOTFILES_DIR/config/shell/bash_profile" "$HOME/.bash_profile"
    fi
    
    # Zsh
    if [ -f "$DOTFILES_DIR/config/shell/zshrc" ]; then
        create_symlink "$DOTFILES_DIR/config/shell/zshrc" "$HOME/.zshrc"
    fi
    
    # Common aliases and functions
    if [ -f "$DOTFILES_DIR/config/shell/aliases" ]; then
        create_symlink "$DOTFILES_DIR/config/shell/aliases" "$HOME/.aliases"
    fi
}

# Install git configuration
install_git_config() {
    log_info "Installing git configuration..."
    
    if [ -f "$DOTFILES_DIR/config/git/gitconfig" ]; then
        create_symlink "$DOTFILES_DIR/config/git/gitconfig" "$HOME/.gitconfig"
    fi
    
    if [ -f "$DOTFILES_DIR/config/git/gitignore_global" ]; then
        create_symlink "$DOTFILES_DIR/config/git/gitignore_global" "$HOME/.gitignore_global"
    fi
    
    if [ -f "$DOTFILES_DIR/config/git/gitmessage" ]; then
        create_symlink "$DOTFILES_DIR/config/git/gitmessage" "$HOME/.gitmessage"
    fi
    
    # Create local git config from template if it doesn't exist
    if [ ! -f "$HOME/.gitconfig.local" ] && [ -f "$DOTFILES_DIR/config/git/gitconfig.local.template" ]; then
        cp "$DOTFILES_DIR/config/git/gitconfig.local.template" "$HOME/.gitconfig.local"
        log_warning "Created ~/.gitconfig.local from template. Please edit it with your GPG signing key."
        log_info "Run 'gpg --list-secret-keys --keyid-format LONG' to find your key ID"
    fi
}

# Install zsh configuration
install_zsh_config() {
    log_info "Installing zsh configuration..."
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
        create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zshenv" ]; then
        create_symlink "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
    fi
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zprofile" ]; then
        create_symlink "$DOTFILES_DIR/config/zsh/.zprofile" "$HOME/.zprofile"
    fi
}

# Install starship configuration
install_starship_config() {
    log_info "Installing starship configuration..."
    
    if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
        create_symlink "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
    fi
}

# Install shell tools configuration
install_shell_tools_config() {
    log_info "Installing shell tools configuration..."
    
    if [ -f "$DOTFILES_DIR/config/shell/.inputrc" ]; then
        create_symlink "$DOTFILES_DIR/config/shell/.inputrc" "$HOME/.inputrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/shell/.profile" ]; then
        create_symlink "$DOTFILES_DIR/config/shell/.profile" "$HOME/.profile"
    fi
}

# Main installation function
main() {
    log_info "Starting dotfiles installation..."
    log_info "Dotfiles directory: $DOTFILES_DIR"
    
    create_backup_dir
    
    # Install configurations
    install_shell_configs
    install_git_config
    install_zsh_config
    install_starship_config
    install_shell_tools_config
    
    # Optionally install packages (can be run separately)
    if [ "$1" = "--with-packages" ]; then
        log_info "Installing packages..."
        "$DOTFILES_DIR/scripts/install-packages.sh"
    fi
    
    log_success "Dotfiles installation completed!"
    log_info "Backup directory: $BACKUP_DIR"
    log_info "Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes"
    log_info "Note: If using zsh, you may want to set it as your default shell: chsh -s \$(which zsh)"
}

# Check if running as source or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi