#!/bin/bash

# Claude Code Docker wrapper script
# Provides easy access to Claude Code in a secure container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$(cd "$DOCKER_DIR/../.." && pwd)"

# Configuration
CONTAINER_NAME="claude-code-dev"
IMAGE_NAME="claude-code:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Show usage information
show_usage() {
    echo "Claude Code Docker Wrapper"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build          Build the Claude Code container"
    echo "  run            Run Claude Code container interactively"
    echo "  start          Start container in background"
    echo "  stop           Stop the container"
    echo "  exec           Execute command in running container"
    echo "  logs           Show container logs"
    echo "  clean          Remove container and image"
    echo "  status         Show container status"
    echo ""
    echo "Options:"
    echo "  -d, --detach   Run container in background"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                    # Build the container"
    echo "  $0 run                      # Run interactively"
    echo "  $0 exec claude --version    # Run Claude command"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or accessible"
        exit 1
    fi
}

# Build the container
build_container() {
    log_info "Building Claude Code container..."
    
    cd "$DOTFILES_DIR"
    docker build -t "$IMAGE_NAME" -f "docker/claude-code/Dockerfile" .
    
    log_success "Container built successfully"
}

# Run the container interactively
run_container() {
    local detach_flag=""
    if [[ "$1" == "--detach" || "$1" == "-d" ]]; then
        detach_flag="-d"
        shift
    fi
    
    # Stop existing container if running
    if docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        log_info "Stopping existing container..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    # Remove existing container if it exists
    if docker ps -aq -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        log_info "Removing existing container..."
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    log_info "Starting Claude Code container..."
    
    # Use docker-compose for easier configuration
    cd "$DOCKER_DIR"
    if [[ -n "$detach_flag" ]]; then
        docker-compose up -d
    else
        docker-compose run --rm claude-code
    fi
}

# Start container in background
start_container() {
    run_container --detach
}

# Stop the container
stop_container() {
    if docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        log_info "Stopping container..."
        docker stop "$CONTAINER_NAME"
        log_success "Container stopped"
    else
        log_warning "Container is not running"
    fi
}

# Execute command in running container
exec_container() {
    if ! docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        log_error "Container is not running. Start it first with: $0 run"
        exit 1
    fi
    
    log_info "Executing command in container..."
    docker exec -it "$CONTAINER_NAME" "$@"
}

# Show container logs
show_logs() {
    if ! docker ps -aq -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        log_error "Container does not exist"
        exit 1
    fi
    
    docker logs "$CONTAINER_NAME" "$@"
}

# Clean up container and image
clean_container() {
    log_info "Cleaning up container and image..."
    
    # Stop and remove container
    if docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        docker stop "$CONTAINER_NAME"
    fi
    
    if docker ps -aq -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        docker rm "$CONTAINER_NAME"
    fi
    
    # Remove image
    if docker images -q "$IMAGE_NAME" >/dev/null 2>&1; then
        docker rmi "$IMAGE_NAME"
    fi
    
    log_success "Cleanup completed"
}

# Show container status
show_status() {
    echo "Container Status:"
    if docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        echo "  🟢 Running"
        docker ps -f name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    elif docker ps -aq -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        echo "  🔴 Stopped"
    else
        echo "  ⚫ Not created"
    fi
    
    echo ""
    echo "Image Status:"
    if docker images -q "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "  📦 Built"
        docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    else
        echo "  ❌ Not built"
    fi
}

# Main script logic
main() {
    check_docker
    
    case "${1:-}" in
        "build")
            build_container
            ;;
        "run")
            shift
            run_container "$@"
            ;;
        "start")
            start_container
            ;;
        "stop")
            stop_container
            ;;
        "exec")
            shift
            exec_container "$@"
            ;;
        "logs")
            shift
            show_logs "$@"
            ;;
        "clean")
            clean_container
            ;;
        "status")
            show_status
            ;;
        "-h"|"--help"|"help")
            show_usage
            ;;
        "")
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"