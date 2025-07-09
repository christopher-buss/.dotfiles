#!/usr/bin/env bash

# Windows Package Manager (winget) setup script
# Installs packages from winget-packages.json

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WINGET_FILE="$DOTFILES_DIR/packages/winget-packages.json"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

# Check if running on Windows
check_windows() {
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" && ! -f "/proc/version" ]]; then
        log_error "This script is designed for Windows environments"
        exit 1
    fi
    
    # Check if we're in WSL
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        log_warning "Running in WSL - winget commands will need to be run from Windows"
        log_info "You may need to run: cmd.exe /c 'winget import \"$WINGET_FILE\"'"
        return 0
    fi
}

# Check if winget is available
check_winget() {
    if ! command -v winget.exe >/dev/null 2>&1 && ! command -v winget >/dev/null 2>&1; then
        log_error "winget is not installed or not in PATH"
        log_info "Please install winget from Microsoft Store or https://github.com/microsoft/winget-cli"
        exit 1
    fi
    
    log_info "winget found and available"
}

# Install packages from winget-packages.json
install_winget_packages() {
    if [[ ! -f "$WINGET_FILE" ]]; then
        log_error "winget-packages.json not found at $WINGET_FILE"
        exit 1
    fi
    
    log_info "Installing packages from winget-packages.json..."
    
    # Try to use winget.exe if available (for WSL compatibility)
    local winget_cmd="winget"
    if command -v winget.exe >/dev/null 2>&1; then
        winget_cmd="winget.exe"
    fi
    
    # Import packages from JSON file
    if $winget_cmd import --import-file "$WINGET_FILE" --accept-source-agreements --accept-package-agreements; then
        log_success "Packages installed successfully"
    else
        log_error "Some packages failed to install"
        log_info "You can retry individual packages with: $winget_cmd install <PackageId>"
        exit 1
    fi
}

# Update winget sources
update_winget_sources() {
    log_info "Updating winget sources..."
    
    local winget_cmd="winget"
    if command -v winget.exe >/dev/null 2>&1; then
        winget_cmd="winget.exe"
    fi
    
    $winget_cmd source update
    log_success "winget sources updated"
}

# Check if WSL2 is installed and working
check_wsl2() {
    log_info "Checking WSL2 installation..."
    
    # Check if WSL is available
    if ! command -v wsl.exe >/dev/null 2>&1 && ! command -v wsl >/dev/null 2>&1; then
        log_info "WSL not found - will install WSL2 with Ubuntu"
        return 1
    fi
    
    # Check if any WSL distributions are installed
    local wsl_cmd="wsl"
    if command -v wsl.exe >/dev/null 2>&1; then
        wsl_cmd="wsl.exe"
    fi
    
    local wsl_list
    if wsl_list=$($wsl_cmd -l -v 2>/dev/null); then
        # Check if Ubuntu is installed and running WSL2
        if echo "$wsl_list" | grep -q "Ubuntu.*2"; then
            log_success "WSL2 with Ubuntu is already installed"
            return 0
        elif echo "$wsl_list" | grep -q "Ubuntu"; then
            log_warning "Ubuntu is installed but may not be WSL2"
            return 1
        else
            log_info "WSL is available but Ubuntu is not installed"
            return 1
        fi
    else
        log_info "WSL command available but no distributions found"
        return 1
    fi
}

# Install WSL2 with Ubuntu
install_wsl2() {
    log_info "Installing WSL2 with Ubuntu..."
    
    # Check if we're running with administrator privileges
    if ! net session >/dev/null 2>&1; then
        log_error "Administrator privileges required for WSL2 installation"
        log_info "Please run this script as Administrator or run the following command manually:"
        log_info "  wsl --install -d Ubuntu"
        return 1
    fi
    
    # Install WSL2 with Ubuntu
    local wsl_cmd="wsl"
    if command -v wsl.exe >/dev/null 2>&1; then
        wsl_cmd="wsl.exe"
    fi
    
    log_info "Running: $wsl_cmd --install -d Ubuntu"
    if $wsl_cmd --install -d Ubuntu; then
        log_success "WSL2 with Ubuntu installation initiated"
        log_warning "A system restart may be required to complete the installation"
        log_info "After restart, you'll need to set up your Ubuntu username and password"
        log_info "Run 'wsl' to access your Ubuntu environment"
    else
        log_error "Failed to install WSL2 with Ubuntu"
        log_info "You may need to:"
        log_info "  1. Enable Windows Subsystem for Linux feature manually"
        log_info "  2. Enable Virtual Machine Platform feature"
        log_info "  3. Restart your computer"
        log_info "  4. Run: wsl --install -d Ubuntu"
        return 1
    fi
}

# Setup WSL2 Ubuntu environment
setup_wsl2_ubuntu() {
    log_info "Setting up WSL2 Ubuntu environment..."
    
    # Check if WSL2 is already set up
    if ! check_wsl2; then
        install_wsl2
        log_info "WSL2 installation completed. Please restart your computer and run this script again."
        return 0
    fi
    
    log_info "WSL2 Ubuntu is ready for use"
    log_info "You can access it by running: wsl"
    log_info "To install your dotfiles in WSL2, run the bootstrap script inside WSL2:"
    log_info "  curl -fsSL https://raw.githubusercontent.com/christopher-buss/dotfiles/main/scripts/bootstrap.sh | bash"
}

# Main setup function
main() {
    log_info "Starting Windows Package Manager (winget) setup..."
    
    check_windows
    check_winget
    update_winget_sources
    install_winget_packages
    
    # Setup WSL2 Ubuntu
    setup_wsl2_ubuntu
    
    log_success "winget setup completed!"
    log_info "Installed packages can be viewed with: winget list"
    log_info "Access WSL2 Ubuntu with: wsl"
}

# Show usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -u, --update   Update winget sources only"
    echo "  -w, --wsl-only Setup WSL2 Ubuntu only"
    echo ""
    echo "This script installs packages from packages/winget-packages.json"
    echo "and sets up WSL2 with Ubuntu. Make sure winget is installed and available in PATH"
    echo ""
    echo "Note: WSL2 installation requires Administrator privileges"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -u|--update)
            update_winget_sources
            exit 0
            ;;
        -w|--wsl-only)
            setup_wsl2_ubuntu
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi