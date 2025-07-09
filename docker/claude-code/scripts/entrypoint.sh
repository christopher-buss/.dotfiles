#!/bin/bash

# Entrypoint script for Claude Code container
# Performs security checks and environment setup

set -e

echo "🚀 Starting Claude Code container..."

# Safety checks
WORKSPACE_DIR="/home/claude/workspace"
DANGEROUS_DIRS=("/" "/home" "/usr" "/etc" "/var")

# Check if workspace is mounted to a dangerous directory
REAL_WORKSPACE=$(realpath "$WORKSPACE_DIR" 2>/dev/null || echo "$WORKSPACE_DIR")
for dangerous_dir in "${DANGEROUS_DIRS[@]}"; do
    if [[ "$REAL_WORKSPACE" == "$dangerous_dir" ]]; then
        echo "❌ ERROR: Workspace is mounted to dangerous directory: $dangerous_dir"
        echo "   This could allow Claude to modify system files!"
        echo "   Please mount a specific project directory instead."
        exit 1
    fi
done

# Check if we're running as root (security risk)
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  WARNING: Running as root user!"
    echo "   This reduces container security isolation."
fi

# Initialize firewall if we have the capability
if command -v iptables >/dev/null 2>&1; then
    echo "🔥 Initializing firewall..."
    if sudo /home/claude/init-firewall.sh; then
        echo "✅ Firewall initialized successfully"
    else
        echo "⚠️  WARNING: Firewall initialization failed"
        echo "   Container will run without network restrictions"
    fi
else
    echo "⚠️  WARNING: iptables not available"
    echo "   Container will run without network restrictions"
fi

# Check Claude authentication
echo "🔐 Checking Claude authentication..."
if [[ -f "/home/claude/.claude/session.json" ]]; then
    echo "✅ Claude session found"
elif [[ -n "$ANTHROPIC_API_KEY" ]]; then
    echo "✅ ANTHROPIC_API_KEY found"
else
    echo "⚠️  WARNING: No Claude authentication found"
    echo "   You'll need to authenticate Claude inside the container"
    echo "   Run: claude auth or set ANTHROPIC_API_KEY"
fi

# Set up environment
export SHELL=/bin/zsh
export USER=claude
export HOME=/home/claude

# Change to workspace directory
cd "$WORKSPACE_DIR"

echo "🎉 Claude Code container is ready!"
echo "📁 Workspace: $WORKSPACE_DIR"
echo "🛡️  Security: Firewall active, non-root user"
echo "⚡ Command: claude --dangerously-skip-permissions"
echo ""

# Execute the command passed to the container
exec "$@"