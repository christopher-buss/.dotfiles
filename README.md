# 🏠 Dotfiles

Windows development environment configuration managed with chezmoi for consistent setup across multiple machines.

## 🚀 Quick Start

### New Machine Setup

**One-liner (recommended):**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply christopher-buss/.dotfiles
```

**Windows-specific:**
```powershell
# Install chezmoi via winget
winget install twpayne.chezmoi

# Initialize and apply dotfiles
chezmoi init --apply christopher-buss/.dotfiles
```

### Manual Installation

```powershell
# Clone the repository
git clone https://github.com/christopher-buss/.dotfiles.git D:/.dotfiles

# Initialize chezmoi with custom source directory
chezmoi init --source=D:/.dotfiles

# Apply configurations
chezmoi apply
```

## 📁 Structure

```
├── .chezmoidata/               # Data templates and configurations
│   └── winget-packages.dsc.yaml    # Windows DSC package definitions
├── .chezmoiexternals/          # External dependencies
├── .chezmoiscripts/            # Installation and setup scripts
│   └── windows/                # Windows-specific scripts
├── dot_bashrc                  # → ~/.bashrc
├── dot_config/                 # → ~/.config/
│   ├── chezmoi/                # Chezmoi configuration template
│   ├── claude/                 # Claude Code configuration
│   ├── git/                    # Git configuration
│   ├── mise/                   # Development tools management
│   ├── shell/                  # Shell helpers and aliases
│   ├── zsh/                    # Zsh configuration
│   └── starship.toml           # Starship prompt configuration
├── etc/                        # System-level configurations
└── refreshenv.ps1              # Environment refresh utility
```

## 🛠 Core Components

### Development Tools Management (mise)
- **Version management**: Node.js, Python, Rust, and other runtimes
- **Global configuration**: `dot_config/mise/config.toml`
- **Auto-installation**: Tools install when entering directories with `.tool-versions`

### Claude Code Integration
- **Smart hooks**: Auto-detects project types and runs appropriate linters/tests
- **Language support**: Python (ruff, black), JavaScript (eslint, prettier), Rust, Shell, Luau
- **Per-project configuration**: `.claude-hooks-config.sh` support

### Shell Configuration
- **Primary shell**: Zsh with Bash compatibility
- **XDG compliance**: Clean home directory organization
- **Starship prompt**: Beautiful terminal prompts
- **Windows integration**: MSYS2/Git Bash compatibility

### Package Management
- **Declarative packages**: Windows DSC configuration
- **Essential tools**: Git, Docker, VS Code, development utilities
- **Automated installation**: Via chezmoi scripts

## ⚙️ Key Commands

### Chezmoi Management
```bash
chezmoi apply              # Apply all dotfiles to system
chezmoi diff               # Show differences between source and target
chezmoi status             # Show status of dotfiles
chezmoi update             # Pull and apply latest changes
chezmoi edit <file>        # Edit a dotfile in source directory
chezmoi add <file>         # Add new file to be managed
```

### Development Environment
```bash
mise install               # Install all tools from .tool-versions
mise list                  # Show installed tools and versions
mise use <tool>@<version>  # Install and use specific tool version
refreshenv                 # Refresh environment variables (PowerShell)
```

### Package Management
```powershell
winget install --id <package-id>  # Install packages via winget
```

## 🔧 Configuration Files

### Shell Configuration
- `dot_bashrc` → `~/.bashrc` - Bash configuration with XDG setup
- `dot_config/zsh/dot_zshrc` → `~/.config/zsh/.zshrc` - Zsh configuration
- `dot_config/shell/aliases.sh` → Shell aliases and functions
- `dot_config/shell/shell-helpers.sh` → Cross-platform utilities

### Git Configuration
- `dot_config/git/config` → `~/.config/git/config` - Git configuration
- `dot_config/git/ignore` → `~/.config/git/ignore` - Global gitignore
- `dot_config/git/gitmessage` → Git commit message template

### Claude Code Configuration
- `dot_config/claude/settings.json` → Claude Code settings
- `dot_config/claude/hooks/` → Smart linting and testing hooks
- `dot_config/claude/mcp_servers.json` → MCP server configuration

### Development Tools
- `dot_config/mise/config.toml` → Development tools configuration
- `dot_config/starship.toml` → Starship prompt configuration

## 🎯 Features

### XDG Base Directory Compliance
- Clean home directory organization
- Consistent configuration paths across applications
- Proper cache, config, data, and state separation

### Windows Development Optimization
- MSYS2/Git Bash integration
- PowerShell compatibility
- Windows-specific PATH management
- Development drive (`D:`) support

### Intelligent Development Workflow
- Auto-detection of project types for linting/testing
- Per-project hook configuration support
- Environment variable management
- Cross-platform compatibility helpers

## 🔒 Security

- Environment variables properly scoped
- Git ignores sensitive files (`.env`, `.envrc`, etc.)
- SSH configurations not tracked
- Secrets excluded from version control

## 🚨 Backup & Recovery

Chezmoi automatically manages configuration state:
- Source-controlled configurations
- Diff capability before applying changes
- Easy rollback via git history

### Restore Previous State
```bash
# View changes before applying
chezmoi diff

# Revert to previous git commit
git checkout HEAD~1
chezmoi apply
```

## 🐛 Troubleshooting

### Chezmoi Source Directory Issues
```bash
# Check current source directory
chezmoi source-path

# Reinitialize with correct path
chezmoi init --source=D:/.dotfiles
```

### Environment Variable Refresh
```powershell
# PowerShell: Refresh environment variables
./refreshenv.ps1

# Bash/Zsh: Reload configuration
source ~/.bashrc  # or source ~/.config/zsh/.zshrc
```

### Development Tools Issues
```bash
# Reinstall all mise tools
mise install

# Check tool versions
mise list

# Debug mise issues
mise doctor
```

## 📋 TODO

- [x] Chezmoi configuration management
- [x] Windows DSC package management
- [x] Claude Code integration with smart hooks
- [x] Development tools management with mise
- [x] XDG Base Directory compliance
- [ ] Cross-platform compatibility (macOS/Linux)
- [ ] Automated testing across Windows environments
- [ ] Global environment variable management via registry

## 📄 License

MIT License - see LICENSE file for details

---

> 💡 **Tip**: This setup is optimized for Windows development with WSL/MSYS2 compatibility!
