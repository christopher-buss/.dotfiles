# Claude Code Configuration

This is a global Claude Code configuration for development workflow enhancement.

## Development Workflow

### Core Principles
- **Research → Plan → Implement** - Always research before implementing
- **Quality First** - Automated checks ensure code quality
- **Simplicity** - Clear, maintainable code over complexity
- **Efficiency** - Use appropriate tools for each task

### Automated Quality Checks

This configuration includes automated hooks that run after code changes:

1. **Smart Linting** - Automatically detects project type and runs appropriate linters
2. **Smart Testing** - Runs relevant tests for modified code
3. **Notifications** - Alerts when conversations complete

### Hook System

The hook system automatically:
- Detects programming language and project type
- Runs appropriate linters and formatters
- Provides detailed error reporting
- Ensures consistent code quality

### Supported Languages

- **Go** - gofmt, golangci-lint
- **Python** - black, ruff, flake8
- **JavaScript/TypeScript** - ESLint, Prettier
- **Rust** - cargo fmt, cargo clippy
- **Shell** - shellcheck

## Global Configuration

This configuration applies to all Claude Code sessions and provides:
- Consistent development standards
- Automated quality assurance
- Improved workflow efficiency
- Better code maintainability

## Usage

Once installed, hooks will automatically run when you:
- Write or edit files using Claude Code
- Complete conversations (for notifications)

The system is designed to be non-intrusive while maintaining high code quality standards.

## Configuration

### Project-Level Configuration

Copy `.claude-hooks-config.example` to `.claude-hooks-config.sh` in your project root to customize hook behavior:

```bash
cp ~/.claude/hooks/.claude-hooks-config.example .claude-hooks-config.sh
```

### Ignoring Files

Copy `.claude-hooks-ignore.example` to `.claude-hooks-ignore` in your project root to specify files that should be ignored:

```bash
cp ~/.claude/hooks/.claude-hooks-ignore.example .claude-hooks-ignore
```

### Configuration Options

- **CLAUDE_HOOKS_ENABLED**: Enable/disable all hooks
- **CLAUDE_HOOKS_DEBUG**: Enable debug logging
- **CLAUDE_HOOKS_FAIL_FAST**: Stop after first error
- **CLAUDE_HOOKS_TESTS_ENABLED**: Enable/disable testing
- **CLAUDE_HOOKS_NTFY_ENABLED**: Enable/disable notifications

### Language-Specific Controls

Each language can be individually controlled:
- **CLAUDE_HOOKS_GO_ENABLED**: Go linting and testing
- **CLAUDE_HOOKS_PYTHON_ENABLED**: Python linting and testing
- **CLAUDE_HOOKS_JAVASCRIPT_ENABLED**: JavaScript/TypeScript linting and testing
- **CLAUDE_HOOKS_RUST_ENABLED**: Rust linting and testing
- **CLAUDE_HOOKS_SHELL_ENABLED**: Shell script linting