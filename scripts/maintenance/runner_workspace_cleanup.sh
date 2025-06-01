#!/bin/bash

# Runner Workspace Cleanup Script
# This script cleans up workspace directories for self-hosted runners

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🧹 GitHub Actions Runner Workspace Cleanup${NC}"

# Function to clean a specific runner's workspace
clean_runner_workspace() {
    local runner_dir=$1
    local runner_name=$2

    if [ ! -d "$runner_dir" ]; then
        echo -e "${YELLOW}⚠️  Runner directory $runner_dir not found, skipping${NC}"
        return
    fi

    echo -e "${YELLOW}Cleaning workspace for $runner_name...${NC}"

    # Clean the _work directory (where jobs run)
    local work_dir="$runner_dir/_work"
    if [ -d "$work_dir" ]; then
        echo "  - Cleaning $work_dir"
        rm -rf "$work_dir"/* 2>/dev/null || true
        rm -rf "$work_dir"/.[!.]* 2>/dev/null || true
        echo "  ✅ Workspace cleaned"
    else
        echo "  - No _work directory found"
    fi

    # Clean any temporary files
    local temp_patterns=("*.tmp" "*.temp" "*.log" ".runner" "*.pid")
    for pattern in "${temp_patterns[@]}"; do
        find "$runner_dir" -maxdepth 1 -name "$pattern" -type f -delete 2>/dev/null || true
    done

    # Show disk usage
    local usage=$(du -sh "$runner_dir" 2>/dev/null | cut -f1 || echo "N/A")
    echo "  📊 Disk usage: $usage"
    echo
}

# Function to clean all runner workspaces
clean_all_workspaces() {
    local runners=(
        "actions-runner-01:codex-runner-01"
        "actions-runner-02:codex-runner-02"
        "actions-runner-03:codex-runner-03"
        "actions-runner-04:codex-runner-04"
        "actions-runner-05:codex-runner-05"
        "actions-runner-06:codex-runner-06"
    )

    for runner_config in "${runners[@]}"; do
        IFS=':' read -r runner_dir runner_name <<< "$runner_config"
        clean_runner_workspace "$runner_dir" "$runner_name"
    done
}

# Function to show runner statuses
show_runner_status() {
    echo -e "${GREEN}📊 Runner Status Overview${NC}"
    echo

    local runners=(
        "actions-runner-01:codex-runner-01"
        "actions-runner-02:codex-runner-02"
        "actions-runner-03:codex-runner-03"
        "actions-runner-04:codex-runner-04"
        "actions-runner-05:codex-runner-05"
        "actions-runner-06:codex-runner-06"
    )

    for runner_config in "${runners[@]}"; do
        IFS=':' read -r runner_dir runner_name <<< "$runner_config"

        if [ -d "$runner_dir" ]; then
            local status="📁 Configured"
            if [ -f "$runner_dir/.runner" ]; then
                status="✅ Active"
            fi

            # Check if running as service
            if systemctl --user is-active "github-runner-$runner_name.service" &>/dev/null; then
                status="🚀 Running (service)"
            fi

            local usage=$(du -sh "$runner_dir" 2>/dev/null | cut -f1 || echo "N/A")
            printf "%-20s %-20s %s\n" "$runner_name" "$status" "[$usage]"
        else
            printf "%-20s %-20s %s\n" "$runner_name" "❌ Not configured" "[N/A]"
        fi
    done
    echo
}

# Main function
main() {
    case "${1:-status}" in
        "clean")
            clean_all_workspaces
            echo -e "${GREEN}🎉 All runner workspaces cleaned!${NC}"
            ;;
        "status")
            show_runner_status
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo
            echo "Commands:"
            echo "  status  - Show runner status (default)"
            echo "  clean   - Clean all runner workspaces"
            echo "  help    - Show this help message"
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
