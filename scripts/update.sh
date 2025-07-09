#!/usr/bin/env bash

# Update script for dotfiles
# Pulls latest changes and re-runs installation

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

main() {
    log_info "Updating dotfiles..."
    
    cd "$DOTFILES_DIR"
    
    # Stash any local changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "Local changes detected. Stashing..."
        git stash push -m "Auto-stash before update $(date)"
    fi
    
    # Pull latest changes
    log_info "Pulling latest changes..."
    git pull origin main || git pull origin master
    
    # Re-run installation
    log_info "Re-running installation..."
    ./install.sh
    
    log_success "Dotfiles updated successfully!"
}

main "$@"