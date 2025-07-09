#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from dotfiles to home directory

set -e

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helpers
source "$DOTFILES_DIR/lib/shell-helpers.sh"

# Create backup directory
BACKUP_DIR=$(create_backup_dir)

# Detect operating system (using helper functions)
detect_os() {
    if is_wsl; then
        echo "wsl"
    elif is_macos; then
        echo "macos"
    elif is_linux; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Install functions using helpers
install_config() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    local target_dir
    target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi
    
    # Use helper function to create symlink with backup
    create_symlink "$source" "$target" "$BACKUP_DIR"
}

# Install shell configurations
install_shell_configs() {
    log_info "Installing shell configurations..."
    
    # Bash
    if [ -f "$DOTFILES_DIR/config/shell/bashrc" ]; then
        install_config "$DOTFILES_DIR/config/shell/bashrc" "$HOME/.bashrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/shell/bash_profile" ]; then
        install_config "$DOTFILES_DIR/config/shell/bash_profile" "$HOME/.bash_profile"
    fi
    
    # Zsh
    if [ -f "$DOTFILES_DIR/config/shell/zshrc" ]; then
        install_config "$DOTFILES_DIR/config/shell/zshrc" "$HOME/.zshrc"
    fi
    
    # Common aliases and functions
    if [ -f "$DOTFILES_DIR/config/shell/aliases" ]; then
        install_config "$DOTFILES_DIR/config/shell/aliases" "$HOME/.aliases"
    fi
}

# Install git configuration
install_git_config() {
    log_info "Installing git configuration..."
    
    if [ -f "$DOTFILES_DIR/config/git/gitconfig" ]; then
        install_config "$DOTFILES_DIR/config/git/gitconfig" "$HOME/.gitconfig"
    fi
    
    if [ -f "$DOTFILES_DIR/config/git/gitignore_global" ]; then
        install_config "$DOTFILES_DIR/config/git/gitignore_global" "$HOME/.gitignore_global"
    fi
    
    if [ -f "$DOTFILES_DIR/config/git/gitmessage" ]; then
        install_config "$DOTFILES_DIR/config/git/gitmessage" "$HOME/.gitmessage"
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
        install_config "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zshenv" ]; then
        install_config "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
    fi
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zprofile" ]; then
        install_config "$DOTFILES_DIR/config/zsh/.zprofile" "$HOME/.zprofile"
    fi
    
    # Install zsh directory structure
    if [ -d "$DOTFILES_DIR/config/zsh/.zsh" ]; then
        install_config "$DOTFILES_DIR/config/zsh/.zsh" "$HOME/.zsh"
    fi
    
    # Install zsh plugins file for antidote
    if [ -f "$DOTFILES_DIR/config/zsh/.zsh_plugins.txt" ]; then
        install_config "$DOTFILES_DIR/config/zsh/.zsh_plugins.txt" "$HOME/.zsh/.zsh_plugins.txt"
    fi
}

# Install starship configuration
install_starship_config() {
    log_info "Installing starship configuration..."
    
    if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
        install_config "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
    fi
}

# Install shell tools configuration
install_shell_tools_config() {
    log_info "Installing shell tools configuration..."
    
    if [ -f "$DOTFILES_DIR/config/shell/.inputrc" ]; then
        install_config "$DOTFILES_DIR/config/shell/.inputrc" "$HOME/.inputrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/shell/.profile" ]; then
        install_config "$DOTFILES_DIR/config/shell/.profile" "$HOME/.profile"
    fi
}

# Install rokit configuration
install_rokit_config() {
    log_info "Installing rokit configuration..."
    
    if [ -f "$DOTFILES_DIR/config/rokit/rokit.toml" ]; then
        install_config "$DOTFILES_DIR/config/rokit/rokit.toml" "$HOME/.rokit/rokit.toml"
    fi
    
    if [ -f "$DOTFILES_DIR/config/rokit/env" ]; then
        install_config "$DOTFILES_DIR/config/rokit/env" "$HOME/.rokit/env"
    fi
}

# Install Claude Code configuration
install_claude_config() {
    log_info "Installing Claude Code configuration..."
    
    # Create .claude directory
    mkdir -p "$HOME/.claude"
    
    # Install settings.json
    if [ -f "$DOTFILES_DIR/config/claude/settings.json" ]; then
        install_config "$DOTFILES_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"
    fi
    
    # Install CLAUDE.md
    if [ -f "$DOTFILES_DIR/config/claude/CLAUDE.md" ]; then
        install_config "$DOTFILES_DIR/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    fi
    
    # Install hooks directory
    if [ -d "$DOTFILES_DIR/config/claude/hooks" ]; then
        install_config "$DOTFILES_DIR/config/claude/hooks" "$HOME/.claude/hooks"
    fi
    
    # Install commands directory (if it exists)
    if [ -d "$DOTFILES_DIR/config/claude/commands" ]; then
        install_config "$DOTFILES_DIR/config/claude/commands" "$HOME/.claude/commands"
    fi
    
    log_success "Claude Code configuration installed"
}

# Install shared library scripts
install_lib_scripts() {
    log_info "Installing shared library scripts..."
    
    # Create .local/lib/dotfiles directory
    mkdir -p "$HOME/.local/lib/dotfiles"
    
    # Install shared library scripts
    if [ -d "$DOTFILES_DIR/lib" ]; then
        # Copy all library files to ~/.local/lib/dotfiles/
        cp -r "$DOTFILES_DIR/lib/"* "$HOME/.local/lib/dotfiles/"
        log_success "Shared library scripts installed to ~/.local/lib/dotfiles/"
        
        # Make scripts executable
        chmod +x "$HOME/.local/lib/dotfiles/"*.sh 2>/dev/null || true
    else
        log_warning "lib/ directory not found, skipping shared library installation"
    fi
}

# Install Windows Terminal configuration
install_windows_terminal_config() {
    log_info "Installing Windows Terminal configuration..."
    
    # Windows Terminal settings location
    local wt_settings_dir="$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
    
    # Create directory if it doesn't exist
    if [ ! -d "$wt_settings_dir" ]; then
        mkdir -p "$wt_settings_dir"
        log_info "Created Windows Terminal settings directory: $wt_settings_dir"
    fi
    
    # Install settings.json
    if [ -f "$DOTFILES_DIR/config/windows-terminal/settings.json" ]; then
        install_config "$DOTFILES_DIR/config/windows-terminal/settings.json" "$wt_settings_dir/settings.json"
        log_success "Windows Terminal settings installed"
    else
        log_warning "Windows Terminal settings.json not found, skipping"
    fi
}

# Install PowerToys configuration
install_powertoys_config() {
    log_info "Installing PowerToys configuration..."
    
    # PowerToys settings location
    local powertoys_dir="$HOME/AppData/Local/Microsoft/PowerToys"
    
    # Create directory if it doesn't exist
    if [ ! -d "$powertoys_dir" ]; then
        mkdir -p "$powertoys_dir"
        log_info "Created PowerToys settings directory: $powertoys_dir"
    fi
    
    # Install main settings.json
    if [ -f "$DOTFILES_DIR/config/powertoys/settings.json" ]; then
        install_config "$DOTFILES_DIR/config/powertoys/settings.json" "$powertoys_dir/settings.json"
    fi
    
    # Install OOBE settings
    if [ -f "$DOTFILES_DIR/config/powertoys/OOBE_Settings.json" ]; then
        install_config "$DOTFILES_DIR/config/powertoys/OOBE_Settings.json" "$powertoys_dir/OOBE_Settings.json"
    fi
    
    # Install Awake settings
    if [ -f "$DOTFILES_DIR/config/powertoys/Awake/settings.json" ]; then
        mkdir -p "$powertoys_dir/Awake"
        install_config "$DOTFILES_DIR/config/powertoys/Awake/settings.json" "$powertoys_dir/Awake/settings.json"
    fi
    
    # Install FancyZones settings (if they exist)
    if [ -f "$DOTFILES_DIR/config/powertoys/FancyZones/custom-layouts.json" ]; then
        mkdir -p "$powertoys_dir/FancyZones"
        install_config "$DOTFILES_DIR/config/powertoys/FancyZones/custom-layouts.json" "$powertoys_dir/FancyZones/custom-layouts.json"
    fi
    
    if [ -f "$DOTFILES_DIR/config/powertoys/FancyZones/zones-settings.json" ]; then
        mkdir -p "$powertoys_dir/FancyZones"
        install_config "$DOTFILES_DIR/config/powertoys/FancyZones/zones-settings.json" "$powertoys_dir/FancyZones/zones-settings.json"
    fi
    
    # Install Workspaces settings (if they exist)
    if [ -d "$DOTFILES_DIR/config/powertoys/Workspaces" ] && [ "$(ls -A "$DOTFILES_DIR/config/powertoys/Workspaces" 2>/dev/null | grep -v '\.gitkeep')" ]; then
        mkdir -p "$powertoys_dir/Workspaces"
        cp -r "$DOTFILES_DIR/config/powertoys/Workspaces"/* "$powertoys_dir/Workspaces/"
    fi
    
    # Install Keyboard Manager settings (if they exist)
    if [ -f "$DOTFILES_DIR/config/powertoys/Keyboard Manager/default.json" ]; then
        mkdir -p "$powertoys_dir/Keyboard Manager"
        install_config "$DOTFILES_DIR/config/powertoys/Keyboard Manager/default.json" "$powertoys_dir/Keyboard Manager/default.json"
    fi
    
    log_success "PowerToys configuration installed"
}

# Setup Windows environment
setup_windows() {
    log_info "Setting up Windows environment..."
    
    # Install Windows Terminal configuration
    install_windows_terminal_config
    
    # Install PowerToys configuration
    install_powertoys_config
    
    # Run winget setup (includes WSL2 Ubuntu installation)
    if [ -f "$DOTFILES_DIR/scripts/setup-winget.sh" ]; then
        log_info "Running Windows package setup..."
        "$DOTFILES_DIR/scripts/setup-winget.sh"
    else
        log_warning "Windows setup script not found, skipping package installation"
    fi
    
    # Configure Docker Desktop for WSL2 integration
    if [ -f "$DOTFILES_DIR/scripts/setup-docker-desktop.sh" ]; then
        log_info "Configuring Docker Desktop for WSL2..."
        "$DOTFILES_DIR/scripts/setup-docker-desktop.sh"
    else
        log_warning "Docker Desktop setup script not found, skipping configuration"
    fi
    
    log_info "Windows setup completed!"
    log_info "To access WSL2 Ubuntu, run: wsl"
    log_info "To install dotfiles in WSL2, run the following inside WSL2:"
    log_info "  curl -fsSL https://raw.githubusercontent.com/christopher-buss/dotfiles/main/scripts/bootstrap.sh | bash"
}

# Main installation function
main() {
    log_info "Starting dotfiles installation..."
    log_info "Dotfiles directory: $DOTFILES_DIR"
    
    local os=$(detect_os)
    log_info "Detected OS: $os"
    
    # Handle Windows differently - it needs winget setup instead of symlinks
    if [ "$os" = "windows" ]; then
        setup_windows
        return 0
    fi
    
    create_backup_dir
    
    # Install configurations (for macOS, Linux, and WSL)
    install_shell_configs
    install_git_config
    install_zsh_config
    install_starship_config
    install_shell_tools_config
    install_rokit_config
    install_claude_config
    install_lib_scripts
    
    # Optionally install packages (can be run separately)
    if [ "$1" = "--with-packages" ]; then
        log_info "Installing packages..."
        "$DOTFILES_DIR/scripts/install-packages.sh"
    fi
    
    log_success "Dotfiles installation completed!"
    log_info "Backup directory: $BACKUP_DIR"
    log_info "Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes"
    
    # OS-specific final instructions
    case "$os" in
        "macos"|"linux"|"wsl")
            log_info "Note: If using zsh, you may want to set it as your default shell: chsh -s \$(which zsh)"
            ;;
    esac
}

# Check if running as source or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi