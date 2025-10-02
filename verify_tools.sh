#!/bin/bash

# Tool Verification Script

set -euo pipefail

# Configuration
readonly CONFIG_FILE="tools_config.json"

# Counters
TOTAL_TOOLS=0
INSTALLED_TOOLS=0
NOT_INSTALLED_TOOLS=0

# Banner
print_banner() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                  Tool Verification System                 ║
╚═══════════════════════════════════════════════════════════╝
EOF
}

# Check for jq
ensure_jq() {
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq is not installed. Please install it first." >&2
        exit 1
    fi
}

# Source user's shell configuration
source_shell_config() {
    local user_shell
    user_shell=$(getent passwd "$USER" | cut -d: -f7)

    case "$user_shell" in
        */bash)
            if [ -f "$HOME/.bashrc" ]; then
                # shellcheck disable=SC1090
                source "$HOME/.bashrc"
            fi
            ;;
        */zsh)
            if [ -f "$HOME/.zshrc" ]; then
                export PATH=$(zsh -c 'source ~/.zshrc && echo $PATH')
            fi
            ;;
        *)
            if [ -f "$HOME/.profile" ]; then
                # shellcheck disable=SC1090
                source "$HOME/.profile"
            fi
            ;;
    esac
}

# Verify a single tool
verify_tool() {
    local tool_name=$1
    local verify_cmd=$2
    
    TOTAL_TOOLS=$((TOTAL_TOOLS + 1))
    
    echo -n "Verifying $tool_name..."
    
    if eval "$verify_cmd" &>/dev/null; then
        echo " ✓ Installed"
        INSTALLED_TOOLS=$((INSTALLED_TOOLS + 1))
    else
        echo " ✗ Not Installed"
        NOT_INSTALLED_TOOLS=$((NOT_INSTALLED_TOOLS + 1))
    fi
}

# Process tools from config
verify_tools_from_config() {
    echo "INFO: Verifying tools from configuration..." >&2
    
    local categories
    categories=$(jq -r 'keys[]' "$CONFIG_FILE")
    
    for category in $categories; do
        if [ "$category" = "script_config" ]; then
            continue
        fi

        local category_enabled
        category_enabled=$(jq -r --arg cat "$category" '.[$cat].enabled' "$CONFIG_FILE")
        
        if [ "$category_enabled" != "true" ]; then
            continue
        fi
        
        echo -e "\n=== Category: $(echo "$category" | tr '_' ' ' | tr '[:lower:]' '[:upper:]') ==="
        
        local tools
        tools=$(jq -r --arg cat "$category" '.[$cat].tools | keys[]' "$CONFIG_FILE")
        
        for tool in $tools; do
            local tool_enabled
            tool_enabled=$(jq -r --arg cat "$category" --arg t "$tool" '.[$cat].tools[$t].enabled' "$CONFIG_FILE")
            
            if [ "$tool_enabled" != "true" ]; then
                continue
            fi
            
            local verify_cmd
            verify_cmd=$(jq -r --arg cat "$category" --arg t "$tool" '.[$cat].tools[$t].verify_cmd // empty' "$CONFIG_FILE")
            
            if [ -n "$verify_cmd" ]; then
                verify_tool "$tool" "$verify_cmd"
            fi
        done
    done
}

# Main function
main() {
    print_banner
    ensure_jq
    source_shell_config
    verify_tools_from_config
    
    # Final summary
    echo -e "\n========================================"
    echo -e "Verification Complete!"
    echo -e "========================================"
    echo -e "\nSummary:"
    echo -e "  Total tools checked: $TOTAL_TOOLS"
    echo -e "  Installed: $INSTALLED_TOOLS"
    echo -e "  Not Installed: $NOT_INSTALLED_TOOLS"
}

# Run main function
main "$@"
