#!/usr/bin/env bash

# Docker Desktop configuration script for Windows
# Automatically configures WSL2 integration and optimal settings

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
        log_warning "Running in WSL - Docker Desktop settings will be applied to Windows host"
        return 0
    fi
}

# Check if Docker Desktop is installed
check_docker_desktop() {
    local docker_desktop_path
    local docker_desktop_exe
    
    # Check if we're in WSL2
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # In WSL2, access Windows paths through /mnt/c
        local username=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        
        # Check common Docker Desktop installation locations
        local user_install="/mnt/c/Users/$username/AppData/Local/Docker/Docker Desktop.exe"
        local system_install="/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
        
        if [[ -f "$user_install" ]]; then
            docker_desktop_exe="$user_install"
            docker_desktop_path="/mnt/c/Users/$username/AppData/Local/Docker"
        elif [[ -f "$system_install" ]]; then
            docker_desktop_exe="$system_install"
            docker_desktop_path="/mnt/c/Program Files/Docker/Docker"
        else
            log_error "Docker Desktop is not installed"
            log_info "Please install Docker Desktop first using: winget install Docker.DockerDesktop"
            log_info "Or run: ./scripts/setup-winget.sh"
            exit 1
        fi
    else
        # In Windows directly
        local user_install="$HOME/AppData/Local/Docker/Docker Desktop.exe"
        local system_install="/c/Program Files/Docker/Docker/Docker Desktop.exe"
        
        if [[ -f "$user_install" ]]; then
            docker_desktop_exe="$user_install"
            docker_desktop_path="$HOME/AppData/Local/Docker"
        elif [[ -f "$system_install" ]]; then
            docker_desktop_exe="$system_install"
            docker_desktop_path="/c/Program Files/Docker/Docker"
        else
            log_error "Docker Desktop is not installed"
            log_info "Please install Docker Desktop first using: winget install Docker.DockerDesktop"
            log_info "Or run: ./scripts/setup-winget.sh"
            exit 1
        fi
    fi
    
    log_info "Docker Desktop installation found at: $docker_desktop_path"
    log_info "Docker Desktop executable: $docker_desktop_exe"
}

# Stop Docker Desktop if running
stop_docker_desktop() {
    log_info "Stopping Docker Desktop to apply configuration..."
    
    # Stop Docker Desktop process
    if tasklist.exe | grep -q "Docker Desktop.exe"; then
        taskkill.exe /IM "Docker Desktop.exe" /F 2>/dev/null || true
    fi
    
    # Wait a moment for processes to stop
    sleep 3
    
    log_info "Docker Desktop stopped"
}

# Create Docker configuration directory
create_docker_config_dir() {
    local docker_config_dir
    
    # Check if we're in WSL2
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # In WSL2, access Windows paths through /mnt/c
        local username=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        docker_config_dir="/mnt/c/Users/$username/AppData/Roaming/Docker"
    else
        # In Windows directly
        docker_config_dir="$HOME/AppData/Roaming/Docker"
    fi
    
    if [[ ! -d "$docker_config_dir" ]]; then
        mkdir -p "$docker_config_dir"
        log_info "Created Docker configuration directory: $docker_config_dir"
    fi
}

# Apply Docker Desktop configuration
apply_docker_config() {
    local docker_config_dir
    local settings_file
    
    # Check if we're in WSL2
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # In WSL2, access Windows paths through /mnt/c
        local username=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        docker_config_dir="/mnt/c/Users/$username/AppData/Roaming/Docker"
    else
        # In Windows directly
        docker_config_dir="$HOME/AppData/Roaming/Docker"
    fi
    
    settings_file="$docker_config_dir/settings-store.json"
    
    log_info "Applying Docker Desktop configuration..."
    
    # Copy settings-store.json
    if [[ -f "$DOTFILES_DIR/config/docker/settings-store.json" ]]; then
        cp "$DOTFILES_DIR/config/docker/settings-store.json" "$settings_file"
        log_success "Docker Desktop settings applied to: $settings_file"
    else
        log_warning "Docker Desktop configuration file not found"
    fi
}

# Enable WSL2 features if not already enabled
enable_wsl2_features() {
    log_info "Checking WSL2 features..."
    
    # Check if WSL2 is installed
    if ! command -v wsl.exe >/dev/null 2>&1; then
        log_warning "WSL2 is not installed. Installing..."
        
        # Enable WSL feature
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        
        # Enable Virtual Machine Platform
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        
        log_warning "WSL2 features enabled. A system restart may be required."
        log_info "After restart, run: wsl --install -d Ubuntu"
    else
        log_success "WSL2 is available"
    fi
}

# Start Docker Desktop with new configuration
start_docker_desktop() {
    log_info "Starting Docker Desktop with new configuration..."
    
    # Get the Docker Desktop executable path from the detection function
    local docker_desktop_exe
    
    # Check if we're in WSL2
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # In WSL2, access Windows paths through /mnt/c
        local username=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        
        # Check common Docker Desktop installation locations
        local user_install="/mnt/c/Users/$username/AppData/Local/Docker/Docker Desktop.exe"
        local system_install="/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
        
        if [[ -f "$user_install" ]]; then
            docker_desktop_exe="$user_install"
        elif [[ -f "$system_install" ]]; then
            docker_desktop_exe="$system_install"
        else
            log_error "Docker Desktop executable not found"
            exit 1
        fi
        
        # Start Docker Desktop using cmd.exe from WSL2
        log_info "Starting Docker Desktop from WSL2..."
        log_info "Using executable: $docker_desktop_exe"
        
        # Convert WSL path to Windows path for cmd.exe
        local windows_path=$(echo "$docker_desktop_exe" | sed 's|/mnt/c|C:|')
        cmd.exe /c "start \"\" \"$windows_path\"" >/dev/null 2>&1
        log_success "Docker Desktop start command sent"
    else
        # In Windows directly
        local user_install="$HOME/AppData/Local/Docker/Docker Desktop.exe"
        local system_install="/c/Program Files/Docker/Docker/Docker Desktop.exe"
        
        if [[ -f "$user_install" ]]; then
            docker_desktop_exe="$user_install"
        elif [[ -f "$system_install" ]]; then
            docker_desktop_exe="$system_install"
        else
            log_error "Docker Desktop executable not found"
            exit 1
        fi
        
        # Start Docker Desktop in background
        "$docker_desktop_exe" &
        log_success "Docker Desktop started"
    fi
    
    # Wait for Docker Desktop to initialize
    log_info "Waiting for Docker Desktop to initialize..."
    sleep 15
    
    # Check if Docker is responding
    local timeout=90
    local count=0
    
    while ! docker info >/dev/null 2>&1 && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
        if [ $((count % 15)) -eq 0 ]; then
            log_info "Still waiting for Docker Desktop... ($count/$timeout seconds)"
        fi
    done
    
    if docker info >/dev/null 2>&1; then
        log_success "Docker Desktop is ready!"
    else
        log_warning "Docker Desktop may still be starting. Check the system tray."
        log_info "You can manually check with: docker info"
    fi
}

# Verify WSL2 integration
verify_wsl2_integration() {
    log_info "Verifying WSL2 integration..."
    
    # Check if docker command is available in WSL2
    if command -v docker >/dev/null 2>&1; then
        log_success "Docker command available in WSL2"
        
        # Test docker connection
        if docker info >/dev/null 2>&1; then
            log_success "Docker WSL2 integration is working"
            docker --version
        else
            log_warning "Docker command found but not connected to Docker Desktop"
            log_info "Docker Desktop may still be starting up"
        fi
    else
        log_warning "Docker command not available in WSL2"
        log_info "WSL2 integration may take a few moments to activate"
    fi
}

# Main setup function
main() {
    log_info "Starting Docker Desktop configuration..."
    
    check_windows
    check_docker_desktop
    stop_docker_desktop
    create_docker_config_dir
    apply_docker_config
    enable_wsl2_features
    start_docker_desktop
    verify_wsl2_integration
    
    log_success "Docker Desktop configuration completed!"
    log_info "Docker Desktop should now have WSL2 integration enabled"
    log_info "You can test it by running: docker run hello-world"
}

# Show usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -n, --no-start Don't start Docker Desktop after configuration"
    echo ""
    echo "This script automatically configures Docker Desktop for WSL2 integration"
    echo "Make sure Docker Desktop is installed before running this script"
}

# Parse command line arguments
NO_START=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -n|--no-start)
            NO_START=true
            shift
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