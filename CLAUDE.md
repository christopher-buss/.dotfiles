# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **chezmoi-managed dotfiles repository** for Windows development environment setup. It uses chezmoi as the dotfiles manager to maintain consistent configuration across machines.

## Key Commands

### Chezmoi Management
- `chezmoi apply` - Apply all dotfiles to the system
- `chezmoi diff` - Show differences between source and target files
- `chezmoi status` - Show status of dotfiles
- `chezmoi update` - Pull and apply latest changes from git
- `chezmoi edit <file>` - Edit a dotfile in the source directory
- `chezmoi add <file>` - Add a new file to be managed by chezmoi

### Development Environment Setup
- `mise install` - Install all development tools from .tool-versions
- `mise list` - Show all installed tools and versions
- `mise use <tool>@<version>` - Install and use a specific tool version
- `refreshenv` - Refresh environment variables in current PowerShell session

### Package Management
- `winget install --id <package-id>` - Install packages via winget
- Windows packages are managed via DSC configuration in `.chezmoidata/winget-packages.dsc.yaml`

## Architecture Overview

### Directory Structure
- **`.chezmoidata/`** - Data templates and package configurations
  - `winget-packages.dsc.yaml` - Windows DSC package definitions
- **`.chezmoiexternals/`** - External dependencies (antidote)
- **`.chezmoiscripts/`** - Installation and setup scripts
  - `windows/run_onchange_install-mise.ps1` - Mise setup automation
- **`dot_*`** - Files/folders that become dotfiles when applied
  - `dot_bashrc` → `~/.bashrc`
  - `dot_config/` → `~/.config/`
  - `dot_claude/` → `~/.claude/` (Claude Code configuration)
- **`etc/`** - System-level configurations

### Core Components

#### 1. Development Tools Management (mise)
- Uses mise (formerly rtx) for managing development tool versions
- Global configuration in `dot_config/mise/config.toml`
- Supports Node.js, Python, Rust, and other language runtimes
- Auto-installs tools when entering directories with `.tool-versions`

#### 2. Claude Code Integration
- Smart hooks system for linting and testing in `dot_claude/hooks/`
- Language-specific linting: Python (ruff, black), JavaScript (eslint, prettier), Rust (clippy, fmt), Shell (shellcheck), Luau (stylua, luau-lsp)
- Configuration in `dot_claude/settings.json` with telemetry disabled
- Hooks can be configured per-project with `.claude-hooks-config.sh`

#### 3. Shell Configuration
- Primary shell: Zsh
- Bash configuration for compatibility
- XDG Base Directory compliance
- Windows-specific PATH and environment setup
- Starship prompt integration

#### 4. Package Management
- Uses Windows DSC for declarative package management
- Includes essential development tools: Git, Docker, VS Code, etc.
- Automated installation via chezmoi scripts

### Key Files to Understand

- **`dot_claude/hooks/smart-lint.sh`** - Auto-detects project types and runs appropriate linters
- **`dot_claude/hooks/smart-test.sh`** - Auto-detects and runs tests for different project types
- **`dot_claude/hooks/common-helpers.sh`** - Shared utilities for hook scripts
- **`dot_config/mise/config.toml`** - Development tools configuration
- **`.chezmoidata/winget-packages.dsc.yaml`** - System packages definition

## Development Workflow

1. **Making Changes**: Edit files in the dotfiles repository, not the applied versions
2. **Testing Changes**: Use `chezmoi diff` to preview before applying
3. **Applying Changes**: Run `chezmoi apply` to sync changes to system
4. **Adding New Files**: Use `chezmoi add` to start managing new dotfiles
5. **Environment Updates**: Scripts automatically run when configurations change

## Special Considerations

- This is a **Windows-focused** setup with MSYS2/Git Bash compatibility
- Uses PowerShell for system-level operations and package management
- Claude Code hooks provide intelligent linting/testing without configuration
- Mise handles development tool versions automatically
- XDG directories are properly configured for clean home directory
