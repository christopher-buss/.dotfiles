#!/usr/bin/env bash
# Smart Lint Hook for Claude Code
# Automatically detects project type and runs appropriate linters

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common helpers
source "$SCRIPT_DIR/common-helpers.sh"

# Check if this is a Python project
is_python_project() {
    [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || ls *.py >/dev/null 2>&1
}

# Check if this is a JavaScript/TypeScript project
is_javascript_project() {
    [[ -f "package.json" ]] || ls *.js *.ts *.jsx *.tsx >/dev/null 2>&1
}

# Check if this is a Rust project
is_rust_project() {
    [[ -f "Cargo.toml" ]] || ls *.rs >/dev/null 2>&1
}

# Check if this is a Shell project
is_shell_project() {
    ls *.sh >/dev/null 2>&1
}

# Check if this is a Luau project
is_luau_project() {
    [[ -f ".luaurc" ]] || [[ -f "stylua.toml" ]] || ls *.luau >/dev/null 2>&1
}

# Get list of modified and untracked files (if available from git)
get_modified_files() {
    if [[ -d .git || -f .git ]] && command_exists git; then
        # Get files modified in the last commit, currently staged/modified, and untracked
        {
            git diff --name-only HEAD 2>/dev/null || true
            git diff --cached --name-only 2>/dev/null || true
            git ls-files --others --exclude-standard 2>/dev/null || true
        } | sort -u
    fi
}

# Get modified line ranges for files
get_modified_line_ranges() {
    if [[ -d .git ]] && command_exists git; then
        # Get unified diff with line numbers
        git diff --unified=0 HEAD 2>/dev/null | awk '
        BEGIN { current_file = "" }
        /^\+\+\+ b\// {
            current_file = substr($0, 7)  # Remove "+++ b/" prefix
        }
        /^@@ / {
            if (current_file != "") {
                # Parse the line range from @@ -old_start,old_count +new_start,new_count @@
                match($0, /\+([0-9]+)(,([0-9]+))?/, arr)
                start = arr[1]
                count = arr[3] ? arr[3] : 1
                end = start + count - 1
                if (end < start) end = start  # Handle single-line changes
                print current_file ":" start "-" end
            }
        }
        '
    fi
}

# Check if we should skip a file
should_skip_file() {
    local file="$1"

    # Check .claude-hooks-ignore if it exists
    if [[ -f ".claude-hooks-ignore" ]]; then
        while IFS= read -r pattern; do
            # Skip comments and empty lines
            [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue

            # Check if file matches pattern
            if [[ "$file" == $pattern ]]; then
                log_debug "Skipping $file due to .claude-hooks-ignore pattern: $pattern"
                return 0
            fi
        done <".claude-hooks-ignore"
    fi

    # Check for inline skip comments
    if [[ -f "$file" ]] && head -n 5 "$file" 2>/dev/null | grep -q "claude-hooks-disable"; then
        log_debug "Skipping $file due to inline claude-hooks-disable comment"
        return 0
    fi

    return 1
}

# Detect project types
detect_project_type() {
    local types=()

    if is_python_project; then
        types+=("python")
    fi

    if is_javascript_project; then
        types+=("javascript")
    fi

    if is_rust_project; then
        types+=("rust")
    fi

    if is_shell_project; then
        types+=("shell")
    fi

    if is_luau_project; then
        types+=("luau")
    fi

    printf '%s\n' "${types[@]}"
}

# Lint Python project
lint_python_project() {
    log_section "Linting Python project"

    if ! is_language_enabled "python"; then
        log_debug "Python linting disabled"
        return 0
    fi

    local has_errors=false

    # Black
    if [[ "${CLAUDE_HOOKS_PYTHON_BLACK_ENABLED:-true}" == "true" ]] && command_exists black; then
        if run_command "black" black --check --diff .; then
            :
        else
            has_errors=true
        fi
    fi

    # Ruff
    if [[ "${CLAUDE_HOOKS_PYTHON_RUFF_ENABLED:-true}" == "true" ]] && command_exists ruff; then
        if run_command "ruff check" ruff check .; then
            :
        else
            has_errors=true
        fi
    fi

    # Flake8 (fallback)
    if [[ "${CLAUDE_HOOKS_PYTHON_FLAKE8_ENABLED:-true}" == "true" ]] && command_exists flake8 && ! command_exists ruff; then
        if run_command "flake8" flake8 .; then
            :
        else
            has_errors=true
        fi
    fi

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi

    return 0
}

# Lint JavaScript/TypeScript project
lint_javascript_project() {
    log_section "Linting JavaScript/TypeScript project"

    if ! is_language_enabled "javascript"; then
        log_debug "JavaScript linting disabled"
        return 0
    fi

    local has_errors=false

    if [[ -f "package.json" ]] && command_exists npm; then
        # ESLint
        if [[ "${CLAUDE_HOOKS_JS_ESLINT_ENABLED:-true}" == "true" ]] && npm list eslint >/dev/null 2>&1; then
            if run_command "ESLint" npx eslint .; then
                :
            else
                has_errors=true
            fi
        fi

        # Prettier
        if [[ "${CLAUDE_HOOKS_JS_PRETTIER_ENABLED:-true}" == "true" ]] && npm list prettier >/dev/null 2>&1; then
            if run_command "Prettier" npx prettier --check .; then
                :
            else
                has_errors=true
            fi
        fi
    fi

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi

    return 0
}

# Lint Rust project
lint_rust_project() {
    log_section "Linting Rust project"

    if ! is_language_enabled "rust"; then
        log_debug "Rust linting disabled"
        return 0
    fi

    local has_errors=false

    if command_exists cargo; then
        # cargo fmt
        if [[ "${CLAUDE_HOOKS_RUST_FMT_ENABLED:-true}" == "true" ]]; then
            if run_command "cargo fmt" cargo fmt --all -- --check; then
                :
            else
                has_errors=true
            fi
        fi

        # cargo clippy
        if [[ "${CLAUDE_HOOKS_RUST_CLIPPY_ENABLED:-true}" == "true" ]]; then
            if run_command "cargo clippy" cargo clippy --all-targets --all-features -- -D warnings; then
                :
            else
                has_errors=true
            fi
        fi
    fi

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi

    return 0
}

# Lint Shell project
lint_shell_project() {
    log_section "Linting Shell scripts"

    if ! is_language_enabled "shell"; then
        log_debug "Shell linting disabled"
        return 0
    fi

    local has_errors=false

    if [[ "${CLAUDE_HOOKS_SHELL_SHELLCHECK_ENABLED:-true}" == "true" ]] && command_exists shellcheck; then
        local shell_files=($(get_files_to_process "*.sh"))

        if [[ ${#shell_files[@]} -gt 0 ]]; then
            if run_command "shellcheck" shellcheck "${shell_files[@]}"; then
                :
            else
                has_errors=true
            fi
        else
            log_info "No shell files found to check"
        fi
    fi

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi

    return 0
}

# Lint Luau project
lint_luau_project() {
    log_section "Linting Luau project"

    if ! is_language_enabled "luau"; then
        log_debug "Luau linting disabled"
        return 0
    fi

    # Get Luau files to process (modified only if flag is set, otherwise all)
    local luau_files
    if [[ "${CLAUDE_HOOKS_LUAU_MODIFIED_ONLY:-false}" == "true" ]]; then
        luau_files=$(get_modified_files | grep '\.luau$' || true)
        if [[ -z "$luau_files" ]]; then
            log_debug "No modified Luau files found"
            return 0
        fi
        log_debug "Modified Luau files: $luau_files"
    else
        luau_files=$(find . -name "*.luau" -type f | head -20 || true)
        if [[ -z "$luau_files" ]]; then
            log_debug "No Luau files found"
            return 0
        fi
        log_debug "All Luau files: $luau_files"
    fi

    local has_errors=false

    # StyLua formatting on selected files
    if [[ "${CLAUDE_HOOKS_LUAU_STYLUA_ENABLED:-true}" == "true" ]]; then
        if command_exists stylua; then
            local stylua_files=()
            while IFS= read -r file; do
                if [[ -f "$file" ]] && ! should_skip_file "$file"; then
                    stylua_files+=("$file")
                fi
            done <<<"$luau_files"

            if [[ ${#stylua_files[@]} -gt 0 ]]; then
                if run_command "StyLua check" stylua --check "${stylua_files[@]}"; then
                    log_debug "StyLua formatting check passed"
                else
                    # Apply formatting and capture any errors
                    if run_command "StyLua format" stylua "${stylua_files[@]}"; then
                        log_info "StyLua auto-formatted files"
                    else
                        has_errors=true
                    fi
                fi
            fi
        else
            log_error "stylua not found - install with rokit or cargo"
            has_errors=true
        fi
    fi

    # Luau LSP analysis on selected files
    if [[ "${CLAUDE_HOOKS_LUAU_LSP_ENABLED:-true}" == "true" ]]; then
        local luau_lsp_binary="${CLAUDE_HOOKS_LUAU_LSP_BINARY:-luau-lsp}"

        if command_exists "$luau_lsp_binary"; then
            local lsp_files=()
            while IFS= read -r file; do
                if [[ -f "$file" ]] && ! should_skip_file "$file"; then
                    lsp_files+=("$file")
                fi
            done <<<"$luau_files"

            if [[ ${#lsp_files[@]} -gt 0 ]]; then
                # Build luau-lsp command
                local cmd="$luau_lsp_binary analyze"

                # Add definitions if specified
                if [[ -n "${CLAUDE_HOOKS_LUAU_DEFINITIONS:-}" ]]; then
                    for def in "${CLAUDE_HOOKS_LUAU_DEFINITIONS[@]}"; do
                        if [[ -f "$def" ]]; then
                            cmd+=" --definitions=$def"
                        fi
                    done
                fi

                # Add base luaurc if it exists
                local luaurc_file="${CLAUDE_HOOKS_LUAU_BASE_LUAURC:-.luaurc}"
                if [[ -f "$luaurc_file" ]]; then
                    cmd+=" --base-luaurc=$luaurc_file"
                fi

                # Add sourcemap if specified
                if [[ -n "${CLAUDE_HOOKS_LUAU_SOURCEMAP:-}" && -f "${CLAUDE_HOOKS_LUAU_SOURCEMAP}" ]]; then
                    cmd+=" --sourcemap=${CLAUDE_HOOKS_LUAU_SOURCEMAP}"
                fi

                # Add settings if specified
                if [[ -n "${CLAUDE_HOOKS_LUAU_SETTINGS:-}" && -f "${CLAUDE_HOOKS_LUAU_SETTINGS}" ]]; then
                    cmd+=" --settings=${CLAUDE_HOOKS_LUAU_SETTINGS}"
                fi

                # Add extra arguments if specified
                if [[ -n "${CLAUDE_HOOKS_LUAU_EXTRA_ARGS:-}" ]]; then
                    cmd+=" ${CLAUDE_HOOKS_LUAU_EXTRA_ARGS}"
                fi

                # Add modified files to analyze
                while IFS= read -r file; do
                    [[ -n "$file" ]] && cmd+=" \"$file\""
                done <<<"$modified_files"

                log_debug "Running: $cmd"

                local lsp_output
                if lsp_output=$(eval "$cmd" 2>&1); then
                    log_debug "luau-lsp completed successfully"
                else
                    # Filter output based on mode (modified-only or all files)
                    local filtered_output=""

                    if [[ "${CLAUDE_HOOKS_LUAU_MODIFIED_ONLY:-false}" == "true" ]]; then
                        # Get modified line ranges for filtering in modified-only mode
                        local line_ranges=$(get_modified_line_ranges)
                        log_debug "Modified line ranges: $line_ranges"

                        if [[ -n "$line_ranges" ]]; then
                            # Filter luau-lsp output line by line
                            while IFS= read -r output_line; do
                                # Parse luau-lsp output format: file(line,column): message
                                if [[ "$output_line" =~ ^([^\(]+)\(([0-9]+), ]]; then
                                    local error_file="${BASH_REMATCH[1]}"
                                    local error_line="${BASH_REMATCH[2]}"

                                    # Check if this error line is in any of the modified ranges
                                    local in_range=false
                                    while IFS= read -r range_line; do
                                        if [[ "$range_line" =~ ^([^:]+):([0-9]+)-([0-9]+)$ ]]; then
                                            local range_file="${BASH_REMATCH[1]}"
                                            local range_start="${BASH_REMATCH[2]}"
                                            local range_end="${BASH_REMATCH[3]}"

                                            if [[ "$error_file" == "$range_file" && "$error_line" -ge "$range_start" && "$error_line" -le "$range_end" ]]; then
                                                in_range=true
                                                break
                                            fi
                                        fi
                                    done <<<"$line_ranges"

                                    if [[ "$in_range" == "true" ]]; then
                                        filtered_output+="$output_line"$'\n'
                                    fi
                                fi
                            done <<<"$lsp_output"
                        else
                            # No line ranges available, show all output for modified files
                            filtered_output="$lsp_output"
                        fi

                        if [[ -n "$filtered_output" ]]; then
                            log_error "luau-lsp found issues in modified code:"
                            echo "$filtered_output" >&2
                            has_errors=true
                        else
                            log_debug "luau-lsp found issues, but none in modified lines"
                        fi
                    else
                        # In all-files mode, show all output
                        log_error "luau-lsp found issues:"
                        echo "$lsp_output" >&2
                        has_errors=true
                    fi
                fi
            fi
        else
            log_error "$luau_lsp_binary not found - install with rokit or check CLAUDE_HOOKS_LUAU_LSP_BINARY"
            has_errors=true
        fi
    fi

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi

    return 0
}

# Main linting function
main() {
    local current_dir="$(pwd)"

    # Check if hooks are enabled
    check_hooks_enabled

    log_section "Running smart lint in $current_dir"
    log_debug "Configuration loaded and ready"

    # Get detected project types
    local project_types=($(detect_project_type))

    if [[ ${#project_types[@]} -eq 0 ]]; then
        log_warning "No supported project types detected"
        return 0
    fi

    log_info "Detected project types: ${project_types[*]}"

    local has_errors=false

    # Process each project type
    for project_type in "${project_types[@]}"; do
        case "$project_type" in
        "python")
            if ! lint_python_project; then
                has_errors=true
            fi
            ;;
        "javascript")
            if ! lint_javascript_project; then
                has_errors=true
            fi
            ;;
        "rust")
            if ! lint_rust_project; then
                has_errors=true
            fi
            ;;
        "shell")
            if ! lint_shell_project; then
                has_errors=true
            fi
            ;;
        "luau")
            if ! lint_luau_project; then
                has_errors=true
            fi
            ;;
        esac
    done

    if [[ "$has_errors" == "true" ]]; then
        CLAUDE_HOOKS_ERROR_COUNT=$((CLAUDE_HOOKS_ERROR_COUNT + 1))
    fi

    report_summary "Smart lint"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
