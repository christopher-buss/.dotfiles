#!/bin/bash

# Initialize firewall rules for Claude Code container
# This script restricts network access for enhanced security

set -e

echo "🔥 Initializing firewall rules for Claude Code container..."

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow DNS resolution (necessary for Claude API calls)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow HTTPS traffic to Claude API (api.anthropic.com)
# Note: This allows HTTPS to any destination - could be more restrictive
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Allow HTTP traffic (for package installations and updates)
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

# Block all other outbound traffic
iptables -A OUTPUT -j DROP

# Log dropped packets for debugging
iptables -A INPUT -j LOG --log-prefix "DROPPED INPUT: " --log-level 4
iptables -A OUTPUT -j LOG --log-prefix "DROPPED OUTPUT: " --log-level 4

echo "✅ Firewall rules initialized successfully"
echo "📋 Active rules:"
iptables -L -n --line-numbers

echo "🔒 Container network access is now restricted"
echo "   - Loopback: ✅ Allowed"
echo "   - DNS: ✅ Allowed"
echo "   - HTTPS: ✅ Allowed (for Claude API)"
echo "   - HTTP: ✅ Allowed (for package management)"
echo "   - Everything else: ❌ Blocked"