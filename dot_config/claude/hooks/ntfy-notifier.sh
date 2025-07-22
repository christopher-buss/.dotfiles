#!/usr/bin/env bash
# NTFY Notification Hook for Claude Code
# Sends notifications when Claude Code conversations complete

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common helpers
source "$SCRIPT_DIR/common-helpers.sh"

# Send notification
send_notification() {
    # Check if notifications are enabled
    if [[ "${CLAUDE_HOOKS_NTFY_ENABLED:-false}" != "true" ]]; then
        log_debug "Notifications disabled by configuration"
        return 0
    fi

    local current_dir="$(pwd)"
    local project_name="$(basename "$current_dir")"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local message="Claude Code session completed in $project_name at $timestamp"

    log_debug "Sending notification for project: $project_name"

    # Try ntfy notification
    if [[ -f "$HOME/.config/ntfy/config.yml" ]] || [[ -n "${CLAUDE_HOOKS_NTFY_URL:-}" ]]; then
        if command_exists ntfy; then
            ntfy send "claude-code" "$message" 2>/dev/null || true
            log_info "Notification sent via ntfy"
            return 0
        elif command_exists curl && [[ -n "${CLAUDE_HOOKS_NTFY_URL:-}" ]]; then
            curl -s -X POST "$CLAUDE_HOOKS_NTFY_URL" \
                -H "Content-Type: text/plain" \
                -d "$message" 2>/dev/null || true
            log_info "Notification sent via curl to ntfy"
            return 0
        fi
    fi

    # Try macOS notification
    if command_exists osascript; then
        osascript -e "display notification \"Claude Code session completed\" with title \"$project_name\"" 2>/dev/null || true
        log_info "macOS notification sent"
        return 0
    fi

    # Try Linux desktop notification
    if command_exists notify-send; then
        notify-send "Claude Code" "Session completed in $project_name" 2>/dev/null || true
        log_info "Linux desktop notification sent"
        return 0
    fi

    # If no notification method worked
    log_debug "No notification method available or configured"
}

# Main function
main() {
    send_notification
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
