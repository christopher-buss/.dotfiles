#!/usr/bin/env bash

# Docker Desktop force kill script
# Forcefully stops all Docker Desktop processes

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

# Force kill Docker Desktop processes
force_kill_docker() {
    log_info "Force killing Docker Desktop processes..."
    
    # Check if we're in WSL2
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # From WSL2, use cmd.exe to kill Windows processes
        log_info "Killing Docker Desktop from WSL2..."
        
        cmd.exe /c 'taskkill /f /im "Docker Desktop.exe" 2>nul' || true
        cmd.exe /c 'taskkill /f /im "dockerd.exe" 2>nul' || true
        cmd.exe /c 'taskkill /f /im "docker.exe" 2>nul' || true
        cmd.exe /c 'taskkill /f /im "com.docker.backend.exe" 2>nul' || true
        cmd.exe /c 'taskkill /f /im "com.docker.cli.exe" 2>nul' || true
        cmd.exe /c 'taskkill /f /im "vpnkit.exe" 2>nul' || true
        cmd.exe /c 'taskkill /f /im "com.docker.proxy.exe" 2>nul' || true
        
        log_success "Docker Desktop processes killed"
    else
        # Direct Windows commands
        log_info "Killing Docker Desktop processes..."
        
        taskkill.exe /f /im "Docker Desktop.exe" 2>/dev/null || true
        taskkill.exe /f /im "dockerd.exe" 2>/dev/null || true
        taskkill.exe /f /im "docker.exe" 2>/dev/null || true
        taskkill.exe /f /im "com.docker.backend.exe" 2>/dev/null || true
        taskkill.exe /f /im "com.docker.cli.exe" 2>/dev/null || true
        taskkill.exe /f /im "vpnkit.exe" 2>/dev/null || true
        taskkill.exe /f /im "com.docker.proxy.exe" 2>/dev/null || true
        
        log_success "Docker Desktop processes killed"
    fi
}

# Stop Docker services
stop_docker_services() {
    log_info "Stopping Docker services..."
    
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # From WSL2
        cmd.exe /c 'net stop docker 2>nul' || true
        cmd.exe /c 'net stop "Docker Desktop Service" 2>nul' || true
    else
        # Direct Windows
        net.exe stop docker 2>/dev/null || true
        net.exe stop "Docker Desktop Service" 2>/dev/null || true
    fi
    
    log_success "Docker services stopped"
}

# Clean restart Docker Desktop
restart_docker() {
    log_info "Restarting Docker Desktop..."
    
    # Wait a moment
    sleep 3
    
    if [[ -f "/proc/version" ]] && grep -q "microsoft\|WSL" /proc/version; then
        # From WSL2
        local username=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        local user_install="/mnt/c/Users/$username/AppData/Local/Docker/Docker Desktop.exe"
        local system_install="/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
        
        if [[ -f "$user_install" ]]; then
            local windows_path="C:\\Users\\$username\\AppData\\Local\\Docker\\Docker Desktop.exe"
            cmd.exe /c "start \"\" \"$windows_path\"" >/dev/null 2>&1
        elif [[ -f "$system_install" ]]; then
            cmd.exe /c "start \"\" \"C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe\"" >/dev/null 2>&1
        else
            log_error "Docker Desktop executable not found"
            exit 1
        fi
    else
        # Direct Windows
        local user_install="$HOME/AppData/Local/Docker/Docker Desktop.exe"
        local system_install="/c/Program Files/Docker/Docker/Docker Desktop.exe"
        
        if [[ -f "$user_install" ]]; then
            "$user_install" &
        elif [[ -f "$system_install" ]]; then
            "$system_install" &
        else
            log_error "Docker Desktop executable not found"
            exit 1
        fi
    fi
    
    log_success "Docker Desktop restart initiated"
}

# Show usage
usage() {
    echo "Docker Desktop Force Kill Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  kill      Force kill Docker Desktop processes"
    echo "  restart   Kill and restart Docker Desktop"
    echo "  services  Stop Docker services"
    echo "  all       Kill processes, stop services, and restart"
    echo "  -h, --help Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 kill      # Just kill processes"
    echo "  $0 restart   # Kill and restart"
    echo "  $0 all       # Complete reset"
}

# Main function
main() {
    case "${1:-kill}" in
        "kill")
            force_kill_docker
            ;;
        "restart")
            force_kill_docker
            restart_docker
            ;;
        "services")
            stop_docker_services
            ;;
        "all")
            stop_docker_services
            force_kill_docker
            restart_docker
            ;;
        "-h"|"--help"|"help")
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi