#!/bin/bash

# Configure All Runners Script
# This script helps you configure all 6 runners with GitHub registration tokens

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"

echo -e "${GREEN}🔧 Codex-T Runner Configuration Helper${NC}"
echo -e "${YELLOW}This script will help you configure all 6 runners with GitHub tokens${NC}"
echo

# Check if runners exist
echo -e "${BLUE}📊 Checking runner setup...${NC}"
for i in {01..06}; do
    runner_dir="$PROJECT_DIR/actions-runner-$i"
    if [ -d "$runner_dir" ]; then
        if [ -f "$runner_dir/.runner" ]; then
            echo "  ✅ Runner $i: Already configured"
        else
            echo "  🔧 Runner $i: Ready for configuration"
        fi
    else
        echo "  ❌ Runner $i: Not found"
    fi
done
echo

# Instructions for getting tokens
echo -e "${BLUE}📋 How to get registration tokens:${NC}"
echo "1. Go to your GitHub repository"
echo "2. Click Settings → Actions → Runners"
echo "3. Click 'New self-hosted runner'"
echo "4. Select 'Linux' and 'x64'"
echo "5. Copy the registration token (the long string after --token)"
echo "6. Don't follow GitHub's download instructions - we'll use our setup"
echo

# Function to configure a single runner
configure_runner() {
    local runner_num=$1
    local runner_name="codex-runner-$(printf "%02d" $runner_num)"
    local runner_dir="$PROJECT_DIR/actions-runner-$(printf "%02d" $runner_num)"
    local labels=$2

    if [ ! -d "$runner_dir" ]; then
        echo -e "${RED}❌ Runner directory not found: $runner_dir${NC}"
        return 1
    fi

    if [ -f "$runner_dir/.runner" ]; then
        echo -e "${YELLOW}⚠️  Runner $runner_num already configured, skipping${NC}"
        return 0
    fi

    echo -e "${BLUE}Configuring $runner_name with labels: $labels${NC}"

    # Get repo URL
    if [ -z "$REPO_URL" ]; then
        read -p "Enter your repository URL (e.g., https://github.com/user/codex-t): " REPO_URL
        if [ -z "$REPO_URL" ]; then
            echo -e "${RED}Repository URL is required${NC}"
            return 1
        fi
    fi

    # Get registration token
    echo "Get a registration token for $runner_name from GitHub:"
    echo "Repository → Settings → Actions → Runners → New self-hosted runner"
    read -p "Enter registration token for $runner_name: " token

    if [ -z "$token" ]; then
        echo -e "${YELLOW}⚠️  No token provided, skipping $runner_name${NC}"
        return 0
    fi

    # Configure the runner
    cd "$runner_dir"
    echo "  - Configuring with GitHub..."
    ./config.sh --url "$REPO_URL" \
                 --token "$token" \
                 --name "$runner_name" \
                 --labels "$labels" \
                 --runnergroup default \
                 --work _work \
                 --replace \
                 --unattended

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $runner_name configured successfully!${NC}"

        # Create a simple test script for this runner
        cat > test_runner.sh << EOF
#!/bin/bash
# Test script for $runner_name
echo "Testing $runner_name..."

# Test Python environment
source "$PROJECT_DIR/.runner-venv/bin/activate"
echo "Python version: \$(python --version)"
echo "Available tools:"
echo "  - pytest: \$(which pytest)"
echo "  - black: \$(which black)"
echo "  - ruff: \$(which ruff)"
echo "  - mypy: \$(which mypy)"

echo "✅ $runner_name test complete!"
EOF
        chmod +x test_runner.sh

    else
        echo -e "${RED}❌ Failed to configure $runner_name${NC}"
        return 1
    fi

    cd "$PROJECT_DIR"
    echo
}

# Main configuration function
main() {
    echo -e "${YELLOW}Ready to configure runners. You'll need a registration token for each.${NC}"
    read -p "Continue? (y/N): " confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Configuration cancelled"
        exit 0
    fi

    # Runner configurations with their specialized labels
    declare -A runner_configs=(
        [1]="self-hosted,linux,fast-setup,test-runner"
        [2]="self-hosted,linux,test-runner,coverage-tools"
        [3]="self-hosted,linux,pre-commit-ready"
        [4]="self-hosted,linux,python-dev"
        [5]="self-hosted,linux,security-tools,docs-tools"
        [6]="self-hosted,linux,integration-env,full-env"
    )

    # Configure each runner
    for runner_num in {1..6}; do
        labels="${runner_configs[$runner_num]}"
        configure_runner "$runner_num" "$labels"
    done

    echo -e "${GREEN}🎉 Runner configuration complete!${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Test a runner:"
    echo "   cd actions-runner-01 && ./test_runner.sh"
    echo
    echo "2. Start runners:"
    echo "   cd actions-runner-01 && ./start_runner.sh"
    echo
    echo "3. Check status in GitHub:"
    echo "   Repository → Settings → Actions → Runners"
    echo
    echo -e "${BLUE}To start all runners as services:${NC}"
    for i in {01..06}; do
        echo "systemctl --user enable codex-codex-runner-$i.service"
        echo "systemctl --user start codex-codex-runner-$i.service"
    done
}

# Validate we're in the right directory
if [ "$(pwd)" != "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Changing to project directory: $PROJECT_DIR${NC}"
    cd "$PROJECT_DIR"
fi

main "$@"
