# Shared Shell Helper Library

This directory contains shared shell utilities that can be used by any project script.

## Usage

### Basic Usage

```bash
#!/usr/bin/env bash

# Source the shared library (adjust path as needed)
source "$(dirname "$0")/../lib/shell-helpers.sh"

# Or if installed globally:
# source "$HOME/.local/lib/dotfiles/shell-helpers.sh"

# Now you can use all the helper functions
log_info "Starting my script..."
log_success "Script completed successfully!"
```

### With Custom Prefix

```bash
#!/usr/bin/env bash

# Set a custom prefix for your script
export SCRIPT_PREFIX="MY_SCRIPT"
source "$(dirname "$0")/../lib/shell-helpers.sh"

# Functions will use MY_SCRIPT_DEBUG, MY_SCRIPT_ERROR_COUNT, etc.
log_info "This uses MY_SCRIPT prefix"
run_command "test command" "MY_SCRIPT" echo "hello"
```

## Available Functions

### Logging Functions
- `log_debug(message, [prefix])` - Debug output (only if DEBUG=true)
- `log_info(message)` - Information output
- `log_success(message)` - Success output
- `log_warning(message, [prefix])` - Warning output (increments warning count)
- `log_error(message, [prefix])` - Error output (increments error count)
- `log_section(message)` - Section header output

### Utility Functions
- `command_exists(command)` - Check if command is available
- `should_ignore_file(file, [ignore_file])` - Check if file should be ignored
- `get_files_to_process(pattern, [max_files], [ignore_file])` - Get files matching pattern
- `detect_project_type()` - Detect project types (go, python, javascript, rust, shell, nix)

### Error Tracking
- `init_error_tracking([prefix])` - Initialize error counters
- `get_error_count([prefix])` - Get current error count
- `get_warning_count([prefix])` - Get current warning count
- `is_debug_enabled([prefix])` - Check if debug mode is enabled
- `is_fail_fast_enabled([prefix])` - Check if fail-fast mode is enabled

### Command Execution
- `run_command(description, [prefix], command...)` - Run command with error handling
- `is_language_enabled(language, [prefix])` - Check if language is enabled
- `report_summary(script_name, [prefix])` - Generate final report and exit

## Color Variables

The following color variables are available:
- `RED`, `GREEN`, `YELLOW`, `BLUE`, `PURPLE`, `CYAN`, `NC` (No Color)

## Environment Variables

### Default Prefix: `SHELL`
- `SHELL_DEBUG` - Enable debug output (default: false)
- `SHELL_FAIL_FAST` - Exit on first error (default: true)
- `SHELL_ERROR_COUNT` - Current error count (auto-managed)
- `SHELL_WARNING_COUNT` - Current warning count (auto-managed)

### Language Controls (with prefix)
- `{PREFIX}_{LANGUAGE}_ENABLED` - Enable/disable specific language (default: true)

Example with custom prefix `MY_SCRIPT`:
- `MY_SCRIPT_DEBUG=true`
- `MY_SCRIPT_PYTHON_ENABLED=false`
- `MY_SCRIPT_FAIL_FAST=false`

## Example Script

```bash
#!/usr/bin/env bash
set -euo pipefail

# Set custom prefix and source library
export SCRIPT_PREFIX="BUILD"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/shell-helpers.sh"

main() {
    log_section "Starting build process"
    
    # Detect project type
    local project_types=($(detect_project_type))
    log_info "Detected project types: ${project_types[*]}"
    
    # Run commands with error handling
    if run_command "Running tests" "BUILD" npm test; then
        log_success "Tests passed"
    fi
    
    # Generate final report
    report_summary "Build script" "BUILD"
}

# Run main function
main "$@"
```