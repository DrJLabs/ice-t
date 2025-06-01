#!/bin/bash

# Setup Missing Runners (07-09)
# Creates the missing runners to complete our 9-runner setup

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
REPO_URL="https://github.com/DrJLabs/codex-t"
RUNNER_VERSION="2.324.0"

echo -e "${GREEN}🔧 Setting Up Missing Runners (07-09)${NC}"
echo -e "${BLUE}====================================${NC}"
echo

# Source the runner configuration
if [ -f "runners/configs/runner_config.sh" ]; then
    source runners/configs/runner_config.sh
    echo -e "${GREEN}✅ Loaded runner configuration${NC}"
else
    echo -e "${RED}❌ Runner configuration not found${NC}"
    exit 1
fi

# Function to setup a missing runner
setup_runner() {
    local runner_num=$1
    local global_dir="/home/drj/actions-runner-$(printf "%02d" $runner_num)"
    local labels="${RUNNER_LABELS[$runner_num]}"
    local runner_name="djin-1-slot-$(printf "%02d" $runner_num)"

    echo -e "${BLUE}🔧 Setting Up Runner $runner_num${NC}"
    echo "   Name: $runner_name"
    echo "   Labels: $labels"
    echo "   Directory: $global_dir"

    # Create directory if it doesn't exist
    if [ ! -d "$global_dir" ]; then
        echo "  Creating directory..."
        mkdir -p "$global_dir"
        cd "$global_dir"

        # Download and extract runner
        echo "  Downloading GitHub Actions Runner..."
        curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
        tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
        rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    else
        echo "  Directory already exists, using existing installation..."
        cd "$global_dir"
    fi

    # Get registration token
    echo
    echo -e "${YELLOW}🔑 Registration token needed for $runner_name${NC}"
    echo "1. Open: https://github.com/DrJLabs/codex-t/settings/actions/runners"
    echo "2. Click 'New self-hosted runner'"
    echo "3. Select 'Linux' and 'x64'"
    echo "4. Copy the token (after --token)"
    read -p "Enter registration token for $runner_name: " token

    if [ -z "$token" ]; then
        echo -e "${RED}❌ No token provided for $runner_name, skipping...${NC}"
        cd "$PROJECT_DIR"
        return 1
    fi

    # Configure the runner
    echo "  Configuring runner..."
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

        # Start the runner
        echo "  Starting runner..."
        nohup ./run.sh > runner.log 2>&1 &
        sleep 2

        if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
            echo -e "${GREEN}✅ $runner_name is now running${NC}"
        else
            echo -e "${YELLOW}⚠️  $runner_name may not have started properly${NC}"
        fi

        # Create symlink in project directory
        cd "$PROJECT_DIR"
        ln -sf "$global_dir" "actions-runner-$(printf "%02d" $runner_num)"
        echo "  Created symlink in project directory"
    else
        echo -e "${RED}❌ Failed to configure $runner_name${NC}"
    fi

    cd "$PROJECT_DIR"
    echo
}

# Main execution
echo -e "${BLUE}📋 Missing runners to create:${NC}"
for i in {07..09}; do
    labels="${RUNNER_LABELS[$(printf "%02d" $i)]}"
    echo "  Runner $i: $labels"
done
echo

read -p "Continue with setup? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

echo -e "${GREEN}🔄 Starting missing runner setup...${NC}"
echo

# Setup each missing runner
for i in {07..09}; do
    setup_runner $(printf "%02d" $i)
done

echo -e "${GREEN}🎉 Missing runner setup complete!${NC}"
echo
echo -e "${BLUE}📊 Next Steps:${NC}"
echo "1. Check GitHub: https://github.com/DrJLabs/codex-t/settings/actions/runners"
echo "2. Verify runner status: ./runners/scripts/quick_status.sh"
echo "3. Test with a workflow run"
