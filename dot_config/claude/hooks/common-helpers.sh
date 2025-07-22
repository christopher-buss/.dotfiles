#!/usr/bin/env bash
# Claude Code Hooks Common Functions
# Sources shared shell helpers and adds Claude-specific functionality

# Get the directory of this script to find shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set prefix for Claude hooks and source shared library
export SCRIPT_PREFIX="CLAUDE_HOOKS"
if [[ -f "$XDG_CONFIG_HOME/shell/shell-helpers.sh" ]]; then
    source "$XDG_CONFIG_HOME/shell/shell-helpers.sh"
else
    echo "Warning: shell-helpers.sh not found at $XDG_CONFIG_HOME/shell/shell-helpers.sh" >&2
fi

# Claude-specific configuration defaults
CLAUDE_HOOKS_ENABLED=${CLAUDE_HOOKS_ENABLED:-true}
CLAUDE_HOOKS_DEBUG=${CLAUDE_HOOKS_DEBUG:-false}
CLAUDE_HOOKS_FAIL_FAST=${CLAUDE_HOOKS_FAIL_FAST:-true}

# Language-specific enables (defaults that can be overridden by project config)
export CLAUDE_HOOKS_LUAU_ENABLED="${CLAUDE_HOOKS_LUAU_ENABLED:-true}"

# Claude-specific configuration loading
load_config() {
    # Load global configuration
    if [[ -f "$HOME/.claude-hooks.conf" ]]; then
        source "$HOME/.claude-hooks.conf"
    fi
    
    # Load project-specific configuration
    if [[ -f ".claude-hooks-config.sh" ]]; then
        source ".claude-hooks-config.sh"
    fi
}

# Claude-specific wrapper functions that use the shared library
check_hooks_enabled() {
    if [[ "$CLAUDE_HOOKS_ENABLED" != "true" ]]; then
        log_info "Hooks disabled by configuration"
        exit 0
    fi
}

# Claude-specific wrapper functions that override shared library functions
# These use Claude-specific parameters and prefixes

# Override get_files_to_process with Claude-specific ignore file
claude_get_files_to_process() {
    local pattern="$1"
    local max_files="${CLAUDE_HOOKS_MAX_FILES:-1000}"
    local ignore_file="${CLAUDE_HOOKS_IGNORE_FILE:-.claude-hooks-ignore}"
    
    # Use shared function with Claude-specific parameters
    get_files_to_process "$pattern" "$max_files" "$ignore_file"
}

# Override run_command to use Claude prefix
claude_run_command() {
    local description="$1"
    shift
    # Use shared function with Claude prefix
    run_command "$description" "CLAUDE_HOOKS" "$@"
}

# Override is_language_enabled to use Claude prefix  
claude_is_language_enabled() {
    local language="$1"
    # Use shared function with Claude prefix
    is_language_enabled "$language" "CLAUDE_HOOKS"
}

# Override report_summary to use Claude prefix
claude_report_summary() {
    local script_name="$1"
    # Use shared function with Claude prefix
    report_summary "$script_name" "CLAUDE_HOOKS"
}

# Create aliases to maintain backward compatibility
alias get_files_to_process=claude_get_files_to_process
alias run_command=claude_run_command
alias is_language_enabled=claude_is_language_enabled
alias report_summary=claude_report_summary

# Initialize configuration when sourced
load_config