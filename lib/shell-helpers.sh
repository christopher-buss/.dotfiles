#!/usr/bin/env bash

# Shell helpers library
# Common functions for use across dotfiles scripts

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get dotfiles directory path
get_dotfiles_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" =~ ^darwin ]]
}

# Check if running on Linux
is_linux() {
    [[ "$OSTYPE" =~ ^linux ]]
}

# Check if running on WSL
is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ "$(uname -r)" == *microsoft* ]]
}

# Detect package manager
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Install packages based on detected package manager
install_packages() {
    local packages=("$@")
    local pm=$(detect_package_manager)
    
    case "$pm" in
        apt)
            sudo apt-get update
            sudo apt-get install -y "${packages[@]}"
            ;;
        yum)
            sudo yum install -y "${packages[@]}"
            ;;
        pacman)
            sudo pacman -S --noconfirm "${packages[@]}"
            ;;
        brew)
            brew install "${packages[@]}"
            ;;
        *)
            log_warning "Package manager not found. Please install manually: ${packages[*]}"
            return 1
            ;;
    esac
}

# Safe source file (only if it exists)
safe_source() {
    local file="$1"
    [[ -f "$file" ]] && source "$file"
}

# Create backup directory with timestamp
create_backup_dir() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local backup_dir="${3:-}"
    
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        if [[ -n "$backup_dir" ]]; then
            local backup_path="$backup_dir/$(basename "$target")"
            log_warning "Backing up existing $target to $backup_path"
            mv "$target" "$backup_path"
        else
            log_warning "Removing existing $target"
            rm -rf "$target"
        fi
    elif [[ -L "$target" ]]; then
        log_info "Removing existing symlink $target"
        rm "$target"
    fi
    
    log_info "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

# Check if script is being sourced or executed
is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

# Exit with error message if not sourced
require_source() {
    if ! is_sourced; then
        log_error "This script should be sourced, not executed directly"
        exit 1
    fi
}

