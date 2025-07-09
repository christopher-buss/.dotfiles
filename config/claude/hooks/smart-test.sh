#!/usr/bin/env bash
# Smart Test Hook for Claude Code
# Automatically detects project type and runs appropriate tests

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common helpers
source "$SCRIPT_DIR/common-helpers.sh"

# Check if tests are enabled
check_tests_enabled() {
    if [[ "${CLAUDE_HOOKS_TESTS_ENABLED:-true}" != "true" ]]; then
        log_info "Tests disabled by configuration"
        exit 0
    fi
}

# Test Go project
test_go_project() {
    log_section "Testing Go project"
    
    if ! is_language_enabled "go"; then
        log_debug "Go testing disabled"
        return 0
    fi
    
    local has_errors=false
    
    if command_exists go; then
        # Check if tests exist
        local test_files=($(get_files_to_process "*_test.go"))
        
        if [[ ${#test_files[@]} -gt 0 ]]; then
            local go_test_args="-v"
            
            # Add race detection if enabled
            if [[ "${CLAUDE_HOOKS_GO_RACE_ENABLED:-false}" == "true" ]]; then
                go_test_args="$go_test_args -race"
            fi
            
            if run_command "go test" go test $go_test_args ./...; then
                :
            else
                has_errors=true
            fi
        else
            if [[ "${CLAUDE_HOOKS_TESTS_REQUIRED:-false}" == "true" ]]; then
                log_error "No Go tests found, but tests are required"
                has_errors=true
            else
                log_warning "No Go tests found (*_test.go)"
            fi
        fi
    fi
    
    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Test Python project
test_python_project() {
    log_section "Testing Python project"
    
    if ! is_language_enabled "python"; then
        log_debug "Python testing disabled"
        return 0
    fi
    
    local has_errors=false
    local test_files=($(get_files_to_process "test_*.py"))
    local alt_test_files=($(get_files_to_process "*_test.py"))
    
    if [[ ${#test_files[@]} -gt 0 || ${#alt_test_files[@]} -gt 0 ]]; then
        # Try pytest first
        if command_exists pytest; then
            if run_command "pytest" pytest -v; then
                :
            else
                has_errors=true
            fi
        # Fall back to unittest
        elif command_exists python3; then
            if run_command "unittest" python3 -m unittest discover -s . -p "test_*.py" -v; then
                :
            else
                has_errors=true
            fi
        fi
    else
        if [[ "${CLAUDE_HOOKS_TESTS_REQUIRED:-false}" == "true" ]]; then
            log_error "No Python tests found, but tests are required"
            has_errors=true
        else
            log_warning "No Python tests found (test_*.py or *_test.py)"
        fi
    fi
    
    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Test JavaScript/TypeScript project
test_javascript_project() {
    log_section "Testing JavaScript/TypeScript project"
    
    if ! is_language_enabled "javascript"; then
        log_debug "JavaScript testing disabled"
        return 0
    fi
    
    local has_errors=false
    
    if [[ -f "package.json" ]] && command_exists npm; then
        # Check if test script exists in package.json
        if npm run test --dry-run >/dev/null 2>&1; then
            if run_command "npm test" npm test; then
                :
            else
                has_errors=true
            fi
        else
            if [[ "${CLAUDE_HOOKS_TESTS_REQUIRED:-false}" == "true" ]]; then
                log_error "No test script found in package.json, but tests are required"
                has_errors=true
            else
                log_warning "No test script found in package.json"
            fi
        fi
    fi
    
    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Test Rust project
test_rust_project() {
    log_section "Testing Rust project"
    
    if ! is_language_enabled "rust"; then
        log_debug "Rust testing disabled"
        return 0
    fi
    
    local has_errors=false
    
    if command_exists cargo; then
        # Check if tests exist
        if find . -name "*.rs" -exec grep -l "#\[test\]" {} \; | head -1 | grep -q .; then
            if run_command "cargo test" cargo test; then
                :
            else
                has_errors=true
            fi
        else
            if [[ "${CLAUDE_HOOKS_TESTS_REQUIRED:-false}" == "true" ]]; then
                log_error "No Rust tests found, but tests are required"
                has_errors=true
            else
                log_warning "No Rust tests found (#[test])"
            fi
        fi
    fi
    
    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Test Shell project
test_shell_project() {
    log_section "Testing Shell scripts"
    
    if ! is_language_enabled "shell"; then
        log_debug "Shell testing disabled"
        return 0
    fi
    
    local has_errors=false
    local bats_files=($(get_files_to_process "*.bats"))
    
    if [[ ${#bats_files[@]} -gt 0 ]] && command_exists bats; then
        if run_command "bats" bats "${bats_files[@]}"; then
            :
        else
            has_errors=true
        fi
    else
        if [[ "${CLAUDE_HOOKS_TESTS_REQUIRED:-false}" == "true" ]]; then
            log_error "No shell tests found, but tests are required"
            has_errors=true
        else
            log_warning "No shell tests found (*.bats) or bats not available"
        fi
    fi
    
    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Main testing function
main() {
    local current_dir="$(pwd)"
    
    # Check if hooks are enabled
    check_hooks_enabled
    check_tests_enabled
    
    log_section "Running smart tests in $current_dir"
    log_debug "Testing configuration loaded"
    
    # Get detected project types
    local project_types=($(detect_project_type))
    
    if [[ ${#project_types[@]} -eq 0 ]]; then
        log_warning "No supported project types detected"
        return 0
    fi
    
    log_info "Detected project types: ${project_types[*]}"
    
    local has_errors=false
    local has_tests=false
    
    # Process each project type
    for project_type in "${project_types[@]}"; do
        case "$project_type" in
            "go")
                if ! test_go_project; then
                    has_errors=true
                fi
                has_tests=true
                ;;
            "python")
                if ! test_python_project; then
                    has_errors=true
                fi
                has_tests=true
                ;;
            "javascript")
                if ! test_javascript_project; then
                    has_errors=true
                fi
                has_tests=true
                ;;
            "rust")
                if ! test_rust_project; then
                    has_errors=true
                fi
                has_tests=true
                ;;
            "shell")
                if ! test_shell_project; then
                    has_errors=true
                fi
                has_tests=true
                ;;
        esac
    done
    
    # Handle case where no tests were found
    if [[ "$has_tests" == "false" ]]; then
        if [[ "${CLAUDE_HOOKS_TESTS_REQUIRED:-false}" == "true" ]]; then
            log_error "No tests found, but tests are required by configuration"
            has_errors=true
        else
            log_warning "No tests found in project"
        fi
    fi
    
    if [[ "$has_errors" == "true" ]]; then
        CLAUDE_HOOKS_ERROR_COUNT=$((CLAUDE_HOOKS_ERROR_COUNT + 1))
    fi
    
    report_summary "Smart test"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi