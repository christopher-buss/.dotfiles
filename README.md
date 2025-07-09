# 🏠 Dotfiles

Personal development environment configuration files for consistent setup across multiple machines.

## 🚀 Quick Start

### New Machine Setup

```bash
# Clone and bootstrap
curl -fsSL https://raw.githubusercontent.com/christopher-buss/dotfiles/main/scripts/bootstrap.sh | bash -s -- https://github.com/christopher-buss/dotfiles.git
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/christopher-buss/dotfiles.git ~/.dotfiles

# Run the installation script
cd ~/.dotfiles
./install.sh
```

## 📁 Structure

```
├── config/                 # Configuration files
│   ├── shell/              # Shell configurations and tools
│   ├── git/                # Git configuration
│   ├── zsh/                # Zsh configuration
│   ├── starship/           # Starship prompt configuration
│   └── ssh/                # SSH configuration (not tracked)
├── packages/               # Package management
│   ├── Brewfile            # Homebrew packages
│   ├── .tool-versions      # mise managed runtimes
│   ├── mise/               # mise configuration
│   └── global-packages/    # Global package lists
├── scripts/                # Utility scripts
├── themes/                 # Color schemes and themes
├── docs/                   # Documentation
├── install.sh              # Main installation script
└── README.md               # This file
```

## 🛠 Scripts

### `install.sh`
Main installation script that creates symlinks from dotfiles to home directory.
```bash
./install.sh                    # Install configurations only
./install.sh --with-packages    # Install configurations and packages
```

### `scripts/bootstrap.sh`
Bootstrap script for setting up dotfiles on a new machine. Installs essential packages, development tools, and runs the full installation.

```bash
./scripts/bootstrap.sh <repository-url>
```

### `scripts/update.sh`
Updates dotfiles by pulling latest changes and re-running installation.

```bash
./scripts/update.sh
```

### Package Management Scripts

#### `scripts/install-packages.sh`
Master package installer that orchestrates Homebrew and mise setup.

#### `scripts/setup-homebrew.sh`
Installs Homebrew and all packages from Brewfile.

#### `scripts/setup-mise.sh`
Installs and configures mise, installs development tools from .tool-versions.

## ⚙️ Configuration Files

### Shell Configuration
- `config/shell/aliases` → `~/.aliases`
- `config/shell/.inputrc` → `~/.inputrc`
- `config/shell/.profile` → `~/.profile`

### Zsh Configuration
- `config/zsh/.zshrc` → `~/.zshrc`
- `config/zsh/.zshenv` → `~/.zshenv`
- `config/zsh/.zprofile` → `~/.zprofile`

### Git Configuration
- `config/git/gitconfig` → `~/.gitconfig`
- `config/git/gitignore_global` → `~/.gitignore_global`

### Starship Configuration
- `config/starship/starship.toml` → `~/.config/starship.toml`

### Package Management
- `packages/Brewfile` → Homebrew package definitions
- `packages/.tool-versions` → mise runtime versions
- `packages/mise/config.toml` → mise configuration
- `packages/global-packages/*.txt` → Global package lists

## 🔧 Customization

1. **Add new configurations**: Place files in appropriate `config/` subdirectories
2. **Update install script**: Modify `install.sh` to handle new symlinks
3. **Machine-specific configs**: Use `.local` suffix for machine-specific overrides

### Example: Adding a new shell alias

1. Edit `config/shell/aliases`
2. Run `./install.sh` to update symlinks
3. Source your shell configuration (`source ~/.zshrc` or restart terminal)

### Zsh Setup

This configuration is optimized for Zsh with:
- **Antidote plugin manager** for efficient plugin management
- **Starship prompt** for beautiful terminal prompts
- **Plugin ecosystem**: syntax highlighting, autosuggestions, smart navigation
- **Claude CLI integration** with advanced shortcuts
- **Development tools integration** (fzf, direnv, mise, etc.)

#### Plugin Management with Antidote

Plugins are managed via Antidote (installed via Homebrew):
- Plugin list: `config/zsh/.zsh_plugins.txt`
- Automatic installation and updates
- Fast, git-based plugin loading
- No vendor lock-in or framework overhead

## 🔒 Security

- SSH configurations are ignored by default
- Private files should use `.private` or `.secret` extensions
- Local overrides use `.local` suffix and are ignored by git

## 🚨 Backup

The installation script automatically backs up existing configurations to:
```
~/.dotfiles-backup-YYYYMMDD_HHMMSS/
```

## 🐛 Troubleshooting

### Permission Issues
```bash
chmod +x install.sh scripts/*.sh
```

### Broken Symlinks
```bash
# Remove broken symlinks and re-run installation
find ~ -type l -exec test ! -e {} \\; -delete
./install.sh
```

### Restore from Backup
```bash
# Find your backup directory
ls ~/.dotfiles-backup-*

# Restore specific file
cp ~/.dotfiles-backup-YYYYMMDD_HHMMSS/.bashrc ~/
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on a clean environment
5. Submit a pull request

## 📋 TODO

- [x] Add Brewfile for package management
- [x] Include development tools setup automation
- [x] Add mise for unified version management
- [x] Create global package management system
- [ ] Add system-specific configurations
- [ ] Create zsh plugin management
- [ ] Add automated testing for multiple shell environments
- [ ] Add Docker development environment option

## 📄 License

MIT License - see LICENSE file for details

---

> 💡 **Tip**: Star this repository to easily find it later when setting up new machines!