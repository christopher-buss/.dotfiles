# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing development environment configurations across multiple machines. The repository uses a symlink-based approach to install configuration files and provides scripts for bootstrapping new systems and updating existing ones.

## Core Architecture

### Symlink Management System
- The `install.sh` script creates symlinks from `config/` subdirectories to `~/.` locations
- Automatic backup system creates timestamped backups before overwriting existing files
- Supports both individual file and directory symlinking

### Bootstrap Process
- `scripts/bootstrap.sh` handles initial setup on new machines
- Installs essential packages via detected package manager (apt-get, yum, brew)
- Clones repository and runs installation automatically
- Designed for remote execution via curl

### Configuration Categories
- **Zsh**: Primary shell with custom configuration, plugins, and prompt
- **Shell Tools**: Universal aliases, inputrc, profile, and shell utilities
- **Git**: gitconfig with extensive aliases, GPG signing, and global gitignore
- **Starship**: Custom prompt configuration with development context
- **SSH**: connection configurations (not tracked for security)

## Common Commands

### Installation and Updates
```bash
# Initial installation (dotfiles only)
./install.sh

# Full installation with packages
./install.sh --with-packages

# Bootstrap new machine (includes packages)
curl -fsSL https://raw.githubusercontent.com/christopher-buss/dotfiles/main/scripts/bootstrap.sh | bash -s -- https://github.com/christopher-buss/dotfiles.git

# Update dotfiles
./scripts/update.sh

# Update from anywhere
dotupdate  # (alias defined in config/shell/aliases)

# Switch to zsh (if not default)
chsh -s $(which zsh)
```

### Package Management
```bash
# Install/setup all packages
./scripts/install-packages.sh

# Setup Homebrew and install packages
./scripts/setup-homebrew.sh

# Setup mise and development tools
./scripts/setup-mise.sh

# Update all tools and packages
mise-update && brewup

# Check development environment
mise doctor
```

### Development Workflow
```bash
# Make executable after cloning
chmod +x install.sh scripts/*.sh

# Test installation (dry run)
# Modify install.sh temporarily to echo commands instead of executing

# Validate configuration
git config --file=config/git/gitconfig --list
```

### CI/CD Testing
```bash
# Run validation locally
shellcheck *.sh scripts/*.sh

# Test directory structure
ls -la config/*/

# Validate git config syntax  
git config --file=config/git/gitconfig --list
```

## Package Management Architecture

### mise-First Approach
- **mise** replaces NVM, pyenv, rbenv for unified version management
- **Homebrew** manages system packages and tools
- **Global package lists** maintain consistent environments across machines

### Package Structure
```
packages/
├── Brewfile                    # Homebrew packages
├── .tool-versions              # mise managed runtimes
├── mise/config.toml           # mise configuration
└── global-packages/
    ├── npm-global.txt         # Node.js global packages
    ├── cargo-tools.txt        # Rust development tools
    └── pip-global.txt         # Python global packages
```

### Version Management Benefits
- **Automatic switching** - mise detects .tool-versions and switches versions
- **Project isolation** - each project can specify its own tool versions
- **Consistent environments** - same versions across development/CI/production
- **Fast shell startup** - no more NVM lazy loading delays

## File Structure Patterns

### Configuration Files
- Located in `config/<category>/` subdirectories
- Symlinked to home directory and `~/.config/` by `install.sh`
- Support `.local` suffix for machine-specific overrides (git-ignored)
- Private files use `.private` or `.secret` extensions (git-ignored)
- Zsh configs create full shell environment with plugin support

### Script Organization
- `install.sh`: Main installation script with modular functions per config category
- `scripts/bootstrap.sh`: New machine setup with package installation
- `scripts/update.sh`: Git pull and reinstall automation
- All scripts include colored logging functions and error handling
- Installation script handles both traditional dotfiles and XDG config directory

### Git Configuration Features
- Extensive alias collection for common workflows
- Custom log formatting with graph visualization
- GPG signing enabled with VS Code as default editor
- Auto-setup for remote tracking branches with rebase by default
- Git LFS support and auto-stashing during rebase
- Includes `.gitconfig.local` for machine-specific settings

## Key Aliases Available

### Git Shortcuts (from config/git/gitconfig:46-97)
- `git lg`: Pretty log with graph and colors
- `git save`: Quick savepoint commit
- `git wip`: Work-in-progress commit  
- `git undo`: Reset last commit but keep changes
- `git mto <branch>`: Merge current branch to specified branch

### Shell Shortcuts (from config/shell/aliases)
- `dotfiles`: Navigate to ~/.dotfiles
- `dotupdate`: Run update script
- `dotcheck`: Run shellcheck on all shell scripts
- `reload`: Source shell configuration (zsh preferred)
- `serve`: Start Python HTTP server on port 8000

### Claude CLI Shortcuts (from config/shell/aliases)
- `claude` or `cl`: Main Claude CLI command (points to local installation)
- `clp`: Claude with project mode
- `clc`: Claude with code mode
- `cls`: Claude status check

### Package Management Shortcuts (from config/zsh/.zshrc)
- `brewup`: Update Homebrew packages and cleanup
- `brewinfo`: Show number of installed formulas
- `mise-update`: Update all mise tools and cleanup
- `mise-sync`: Re-run full package installation
- `tools`: Show all installed development tools
- `npm-globals`: List global npm packages
- `update-globals`: Update all global npm packages

## Development Notes

### Security Considerations
- SSH configurations are git-ignored by default
- NPM tokens and sensitive credentials excluded from tracking
- Git GPG signing configured for commit verification
- Private files automatically excluded via gitignore patterns
- Local git config templates provided for machine-specific settings

### Zsh Environment Features
- Starship prompt with git status, development context, and timing
- Plugin management system with lazy loading
- FZF and direnv integration for enhanced workflow
- Claude CLI deeply integrated with shortcuts and aliases
- Development tools auto-loaded (rokit, cargo, bun, nvm)

### Backup System
- Automatic backup to `~/.dotfiles-backup-YYYYMMDD_HHMMSS/`
- Only backs up real files/directories, removes symlinks
- Provides easy restoration path for rollbacks

### CI Validation
- GitHub Actions workflow validates shell scripts with shellcheck
- Tests installation process in isolated environment  
- Validates directory structure and configuration file syntax
- Matrix testing across Ubuntu versions
- Automated testing of script permissions and functionality
- Dry-run testing of installation process

### Local Development
- `dotcheck` alias runs shellcheck on all shell scripts
- Git configuration includes extensive aliases for common workflows
- Starship prompt provides rich development context
- mise integration for unified development tool management