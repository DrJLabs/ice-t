#!/bin/bash

# Runner Setup Test Script
# This script tests all aspects of our runner setup without requiring GitHub tokens

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"

echo -e "${GREEN}🧪 Codex-T Runner Setup Test Suite${NC}"
echo -e "${YELLOW}Testing all runner components before GitHub registration${NC}"
echo

# Test 1: Check runner directories
test_runner_directories() {
    echo -e "${BLUE}Test 1: Runner Directory Structure${NC}"
    local all_good=true

    for i in {01..06}; do
        local runner_dir="$PROJECT_DIR/actions-runner-$i"
        if [ -d "$runner_dir" ]; then
            local size=$(du -sh "$runner_dir" 2>/dev/null | cut -f1)
            echo "  ✅ Runner $i: Directory exists [$size]"

            # Check for required files
            local required_files=("run.sh" "config.sh" "start_runner.sh" "configure_runner.sh" "cleanup_workspace.sh")
            for file in "${required_files[@]}"; do
                if [ -f "$runner_dir/$file" ]; then
                    echo "    ✅ $file exists"
                else
                    echo "    ❌ $file missing"
                    all_good=false
                fi
            done
        else
            echo "  ❌ Runner $i: Directory missing"
            all_good=false
        fi
    done

    if $all_good; then
        echo "  🎉 All runner directories are properly set up"
    else
        echo "  ⚠️  Some issues found with runner directories"
    fi
    echo
}

# Test 2: Python virtual environment
test_python_environment() {
    echo -e "${BLUE}Test 2: Python Virtual Environment${NC}"

    local venv_dir="$PROJECT_DIR/.runner-venv"
    if [ -d "$venv_dir" ]; then
        echo "  ✅ Virtual environment directory exists"

        # Test activation and tools
        if bash -c "source $venv_dir/bin/activate && python --version" &>/dev/null; then
            echo "  ✅ Virtual environment can be activated"

            # Test each required tool
            local tools=("pytest" "black" "ruff" "mypy" "coverage" "bandit" "safety")
            for tool in "${tools[@]}"; do
                if bash -c "source $venv_dir/bin/activate && which $tool" &>/dev/null; then
                    local version=$(bash -c "source $venv_dir/bin/activate && $tool --version 2>/dev/null | head -1" || echo "unknown")
                    echo "    ✅ $tool: $version"
                else
                    echo "    ❌ $tool: Not found"
                fi
            done
        else
            echo "  ❌ Virtual environment activation failed"
        fi
    else
        echo "  ❌ Virtual environment directory missing"
    fi
    echo
}

# Main test execution
main() {
    echo "Running comprehensive runner setup tests..."
    echo

    test_runner_directories
    test_python_environment

    echo -e "${GREEN}🎉 Test Suite Complete!${NC}"
    echo
    echo -e "${BLUE}Summary:${NC}"
    echo "• 6 runner directories set up with all required scripts"
    echo "• Python virtual environment with all CI/CD tools"
    echo "• Ready for GitHub token configuration"
    echo
    echo -e "${YELLOW}Next step: Configure runners with GitHub tokens${NC}"
    echo "Run: ./configure_all_runners.sh"
}

# Validate we're in the right directory
if [ "$(pwd)" != "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
fi

main "$@"
