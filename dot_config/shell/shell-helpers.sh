#!/usr/bin/env bash

[[ $__stdlib_sourced__ ]] && return
__stdlib_sourced__=1

#
# The only code that executes when the library is sourced
#
__stdlib_init__() {
    __log_init__
}


# print directories in $PATH, one per line
print_path() {
    local -a dirs
    local dir
    IFS=: read -ra dirs <<<"$PATH"
    for dir in "${dirs[@]}"; do printf '%s\n' "$dir"; done
}

# Shell helpers library
# Common functions for use across dotfiles scripts

__log_init__() {
    if [[ -t 1 ]]; then
        # colors for logging in interactive mode
        [[ $COLOR_BOLD ]] || COLOR_BOLD="\033[1m"
        [[ $COLOR_RED ]] || COLOR_RED="\033[0;31m"
        [[ $COLOR_GREEN ]] || COLOR_GREEN="\033[0;34m"
        [[ $COLOR_YELLOW ]] || COLOR_YELLOW="\033[0;33m"
        [[ $COLOR_BLUE ]] || COLOR_BLUE="\033[0;32m"
        [[ $COLOR_OFF ]] || COLOR_OFF="\033[0m"
    else
        # no colors to be used if non-interactive
        COLOR_RED= COLOR_GREEN= COLOR_YELLOW= COLOR_BLUE= COLOR_OFF=
    fi

    readonly COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE COLOR_OFF

    #
    # map log level strings (FATAL, ERROR, etc.) to numeric values
    #
    # Note the '-g' option passed to declare - it is essential
    #
    unset _log_levels _loggers_level_map
    declare -gA _log_levels _loggers_level_map
    _log_levels=([FATAL]=0 [ERROR]=1 [WARN]=2 [INFO]=3 [DEBUG]=4 [VERBOSE]=5)

    #
    # hash to map loggers to their log levels
    # the default logger "default" has INFO as its default log level
    #
    _loggers_level_map["default"]=3 # the log level for the default logger is INFO
}

#
# Core and private log printing logic to be called by all logging functions.
# Note that we don't make use of any external commands like 'date' and hence we don't fork at all.
# We use the Bash's printf builtin instead.
#
_print_log() {
    local in_level=$1
    shift
    local logger=default log_level_set log_level color_code prefix
    [[ $1 = "-l" ]] && {
        logger=$2
        shift 2
    }
    log_level="${_log_levels[$in_level]}"
    log_level_set="${_loggers_level_map[$logger]}"

    # Set color and prefix based on log level
    case "$in_level" in
    FATAL | ERROR)
        color_code="$COLOR_RED"
        prefix="ERROR: "
        ;;
    WARN)
        color_code="$COLOR_YELLOW"
        prefix="WARN: "
        ;;
    INFO)
        color_code="$COLOR_BLUE"
        prefix=""
        ;;
    DEBUG | VERBOSE)
        color_code="$COLOR_GREEN"
        prefix=""
        ;;
    *)
        color_code=""
        prefix=""
        ;;
    esac

    if [[ $log_level_set ]]; then
        ((log_level_set >= log_level)) && {
            # Print with color and level prefix, no date/time
            if [[ "$in_level" == "FATAL" || "$in_level" == "ERROR" ]]; then
                {
                    printf "${color_code}${prefix}"
                    printf '%s\n' "$@"
                    printf "$COLOR_OFF"
                } >&2
            else
                printf "${color_code}${prefix}"
                printf '%s\n' "$@"
                printf "$COLOR_OFF"
            fi
        }
    else
        printf "${COLOR_YELLOW}WARN: Unknown logger '$logger'${COLOR_OFF}\n" >&2
    fi
}

# Logging functions
log_fatal() { _print_log FATAL "$@"; }
log_error() { _print_log ERROR "$@"; }
log_warn() { _print_log WARN "$@"; }
log_info() { _print_log INFO "$@"; }
log_success() { _print_log INFO "SUCCESS: $@"; }
log_debug() { _print_log DEBUG "$@"; }
log_verbose() { _print_log VERBOSE "$@"; }

# logging file content
log_info_file() { _print_log_file INFO "$@"; }
log_debug_file() { _print_log_file DEBUG "$@"; }
log_verbose_file() { _print_log_file VERBOSE "$@"; }

# logging for function entry and exit
log_info_enter() { _print_log INFO "Entering function ${FUNCNAME[1]}"; }
log_debug_enter() { _print_log DEBUG "Entering function ${FUNCNAME[1]}"; }
log_verbose_enter() { _print_log VERBOSE "Entering function ${FUNCNAME[1]}"; }
log_info_leave() { _print_log INFO "Leaving function ${FUNCNAME[1]}"; }
log_debug_leave() { _print_log DEBUG "Leaving function ${FUNCNAME[1]}"; }
log_verbose_leave() { _print_log VERBOSE "Leaving function ${FUNCNAME[1]}"; }

print_bold() {
    printf '%b\n' "$COLOR_BOLD$@$COLOR_OFF"
}

# print only if output is going to terminal
print_tty() {
    if [[ -t 1 ]]; then
        printf '%s\n' "$@"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get dotfiles directory path
get_dotfiles_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" =~ ^darwin ]]
}

# Check if running on Linux
is_linux() {
    [[ "$OSTYPE" =~ ^linux ]]
}

# Check if running on Windows
is_windows() {
    case "$OSTYPE" in
        cygwin*|msys*|win32*) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if running on WSL
is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ "$(uname -r)" == *microsoft* ]]
}

# Detect package manager
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Safe source file (only if it exists)
safe_source() {
    local file="$1"
    [[ -f "$file" ]] && source "$file"
}

# Create backup directory with timestamp
create_backup_dir() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local backup_dir="${3:-}"

    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        if [[ -n "$backup_dir" ]]; then
            local backup_path="$backup_dir/$(basename "$target")"
            log_warning "Backing up existing $target to $backup_path"
            mv "$target" "$backup_path"
        else
            log_warning "Removing existing $target"
            rm -rf "$target"
        fi
    elif [[ -L "$target" ]]; then
        log_info "Removing existing symlink $target"
        rm "$target"
    fi

    log_info "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

# Check if script is being sourced or executed
is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

# Exit with error message if not sourced
require_source() {
    if ! is_sourced; then
        log_error "This script should be sourced, not executed directly"
        exit 1
    fi
}

# return path to parent script's source directory
get_my_source_dir() {
    __clear_output__

    # Reference: https://stackoverflow.com/a/246128/6862601
    OUTPUT="$(cd "$(dirname "${BASH_SOURCE[1]}")" >/dev/null 2>&1 && pwd -P)"
}

# wait for user to hit Enter key
wait_for_enter() {
    local prompt=${1:-"Press Enter to continue"}
    read -r -n1 -s -p "Press Enter to continue" </dev/tty
}


# Initialize the library when sourced
__stdlib_init__
