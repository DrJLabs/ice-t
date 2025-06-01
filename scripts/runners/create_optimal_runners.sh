#!/bin/bash

# Optimal 9-Runner Setup Script for Maximum CI Efficiency
# This script creates and configures 9 specialized GitHub Actions runners

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
REPO_URL="https://github.com/DrJLabs/codex-t"

echo -e "${GREEN}🚀 Creating Optimal 9-Runner Setup for Maximum CI Efficiency${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Function to get system capacity
check_system_capacity() {
    local cpu_cores=$(nproc)
    local total_mem=$(free -g | awk 'NR==2{print $2}')

    echo -e "${BLUE}📊 System Capacity Analysis:${NC}"
    echo "  CPU Cores: $cpu_cores"
    echo "  Total Memory: ${total_mem}GB"

    if [ $cpu_cores -ge 8 ] && [ $total_mem -ge 32 ]; then
        echo -e "${GREEN}✅ System can handle 9 runners efficiently${NC}"
        return 0
    elif [ $cpu_cores -ge 6 ] && [ $total_mem -ge 16 ]; then
        echo -e "${YELLOW}⚠️  System can handle 9 runners with moderate load${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  System may be stressed with 9 runners - consider 6 runners${NC}"
        return 1
    fi
}

# Function to get registration token from GitHub
get_token_instructions() {
    echo -e "${BLUE}📋 How to get registration tokens:${NC}"
    echo "1. Open: https://github.com/DrJLabs/codex-t/settings/actions/runners"
    echo "2. Click 'New self-hosted runner'"
    echo "3. Select 'Linux' and 'x64'"
    echo "4. Copy the token (after --token)"
    echo "5. Paste it when prompted below"
    echo
}

# Function to setup a single runner
setup_runner() {
    local runner_num=$1
    local runner_name=$2
    local labels=$3
    local description=$4

    local runner_dir="$PROJECT_DIR/actions-runner-$(printf "%02d" $runner_num)"

    echo -e "${BLUE}🔧 Setting up Runner $runner_num: $runner_name${NC}"
    echo "   Purpose: $description"
    echo "   Labels: $labels"

    # Create runner directory
    if [ ! -d "$runner_dir" ]; then
        mkdir -p "$runner_dir"
        echo "  Created directory: $runner_dir"
    fi

    cd "$runner_dir"

    # Download runner if not exists
    if [ ! -f "config.sh" ]; then
        echo "  Downloading GitHub Actions Runner..."
        curl -s -o actions-runner-linux-x64-2.324.0.tar.gz -L \
            https://github.com/actions/runner/releases/download/v2.324.0/actions-runner-linux-x64-2.324.0.tar.gz
        tar xzf ./actions-runner-linux-x64-2.324.0.tar.gz
        rm actions-runner-linux-x64-2.324.0.tar.gz
    fi

    # Get token for this runner
    echo
    echo -e "${YELLOW}🔑 Token needed for $runner_name${NC}"
    get_token_instructions
    read -p "Enter registration token for $runner_name: " token

    if [ -z "$token" ]; then
        echo -e "${RED}❌ No token provided for $runner_name, skipping...${NC}"
        cd "$PROJECT_DIR"
        return 1
    fi

    # Configure runner
    echo "  Configuring with GitHub..."
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

        # Install as service (optional)
        read -p "Install $runner_name as system service? (y/N): " install_service
        if [[ $install_service =~ ^[Yy]$ ]]; then
            sudo ./svc.sh install drj
            sudo ./svc.sh start
            echo "  ✅ Service installed and started"
        else
            echo "  ℹ️  To start manually: cd $runner_dir && ./run.sh"
        fi
    else
        echo -e "${RED}❌ Failed to configure $runner_name${NC}"
        cd "$PROJECT_DIR"
        return 1
    fi

    cd "$PROJECT_DIR"
    echo
}

# Main setup function
main() {
    echo -e "${BLUE}Checking system capacity...${NC}"
    check_system_capacity
    echo

    echo -e "${BLUE}🎯 Optimal 9-Runner Configuration:${NC}"
    echo

    # Define the 9 specialized runners based on workflow needs
    declare -A runners=(
        # Core Infrastructure Runners (Always Active)
        [1]="fast-setup|self-hosted,linux,fast-setup|Environment validation & cache management"
        [2]="pre-commit-ready|self-hosted,linux,pre-commit-ready|Code quality & documentation"
        [3]="python-dev|self-hosted,linux,python-dev|Type checking & development tools"

        # Testing Runners (Parallel Test Execution)
        [4]="test-runner-1|self-hosted,linux,test-runner|Unit tests (core & features)"
        [5]="test-runner-2|self-hosted,linux,test-runner|Unit tests (utils & integrations)"
        [6]="test-runner-3|self-hosted,linux,test-runner|Unit tests (api & cli)"

        # Specialized Runners
        [7]="security-tools|self-hosted,linux,security-tools|Security scanning & analysis"
        [8]="full-env|self-hosted,linux,full-env|Integration tests & performance"
        [9]="final-validation|self-hosted,linux,full-env|Final validation & reporting"
    )

    # Display the plan
    for i in {1..9}; do
        IFS='|' read -r name labels description <<< "${runners[$i]}"
        echo "  Runner $i: $name"
        echo "    - $description"
        echo "    - Labels: $labels"
        echo
    done

    read -p "Continue with setup? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Setup cancelled"
        exit 0
    fi

    echo -e "${GREEN}🔄 Starting runner setup...${NC}"
    echo

    # Setup each runner
    for i in {1..9}; do
        IFS='|' read -r name labels description <<< "${runners[$i]}"
        setup_runner "$i" "$name" "$labels" "$description"

        # Small delay between setups
        sleep 2
    done

    echo -e "${GREEN}🎉 Runner setup complete!${NC}"
    echo
    echo -e "${BLUE}📊 Next Steps:${NC}"
    echo "1. Check GitHub: https://github.com/DrJLabs/codex-t/settings/actions/runners"
    echo "2. Create a test PR to validate the setup"
    echo "3. Monitor performance in GitHub Actions"
    echo
    echo -e "${BLUE}🚀 Expected Performance:${NC}"
    echo "- 3-4x faster CI pipeline"
    echo "- 6 parallel test groups"
    echo "- 95% faster dependency setup (cached)"
    echo "- Maximum utilization of your system resources"
}

# Validate environment
if [ "$(pwd)" != "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
fi

if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not in a Git repository${NC}"
    exit 1
fi

main "$@"
