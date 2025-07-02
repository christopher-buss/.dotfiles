#!/usr/bin/env bash

# Update script for dotfiles
# Pulls latest changes and re-runs installation

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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